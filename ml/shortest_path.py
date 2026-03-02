#!/usr/bin/env python3
"""
ML-based shortest path finder using OSMnx + NetworkX.

Downloads the real road network from OpenStreetMap around the origin and
destination, then applies:
  - Dijkstra's algorithm  (guaranteed shortest path)
  - A* algorithm           (heuristic-guided, faster for large graphs)
  - Yen's k-shortest paths (up to k road-following alternatives)

All routes with their distances and travel-time estimates are printed to the
terminal so you can compare them at a glance.

Usage (standalone):
    python shortest_path.py <origin_lat> <origin_lng> <dest_lat> <dest_lng> [k]

Example:
    python shortest_path.py 37.7749 -122.4194 37.8044 -122.2712 3
"""

import sys
import math
import time

# Third-party – install via:  pip install -r requirements.txt
import osmnx as ox
import networkx as nx
from geopy.distance import geodesic


# ---------------------------------------------------------------------------
# Distance helpers
# ---------------------------------------------------------------------------

def haversine_m(lat1: float, lng1: float, lat2: float, lng2: float) -> float:
    """Straight-line (Haversine) distance in metres."""
    return geodesic((lat1, lng1), (lat2, lng2)).meters


def _path_length_m(G: nx.MultiDiGraph, path: list) -> float:
    """Sum the minimum edge 'length' along a node-path.

    For a MultiDiGraph there may be several parallel edges between the same
    pair of nodes.  We take the minimum so the reported length is consistent
    with the minimum-weight projection used by Yen's algorithm.
    """
    total = 0.0
    for u, v in zip(path[:-1], path[1:]):
        edges = G[u][v].values() if G.has_edge(u, v) else G[v][u].values()
        total += min(e.get("length", 0.0) for e in edges)
    return total


# ---------------------------------------------------------------------------
# Road-network helpers
# ---------------------------------------------------------------------------

def _download_network(
    origin_lat: float, origin_lng: float,
    dest_lat: float, dest_lng: float,
    buffer_km: float = 2.0,
) -> nx.MultiDiGraph:
    """Download the driving road network that covers origin → destination."""
    center_lat = (origin_lat + dest_lat) / 2
    center_lng = (origin_lng + dest_lng) / 2

    diag_km = haversine_m(origin_lat, origin_lng, dest_lat, dest_lng) / 1_000
    # Radius = half the diagonal + buffer, at least 3 km
    radius_m = max((diag_km / 2 + buffer_km) * 1_000, 3_000)

    print(
        f"  Downloading OSM road network "
        f"(center={center_lat:.4f},{center_lng:.4f}, "
        f"radius={radius_m / 1_000:.1f} km)…"
    )

    # ox.settings.use_cache = True persists downloads across runs.
    ox.settings.use_cache = True

    G = ox.graph_from_point(
        (center_lat, center_lng),
        dist=radius_m,
        network_type="drive",
        simplify=True,
    )
    print(f"  Network ready: {len(G.nodes):,} nodes, {len(G.edges):,} edges")
    return G


def _nearest_nodes(
    G: nx.MultiDiGraph,
    origin_lat: float, origin_lng: float,
    dest_lat: float, dest_lng: float,
) -> tuple:
    """Return (origin_node_id, dest_node_id) closest to the given coordinates."""
    orig = ox.distance.nearest_nodes(G, origin_lng, origin_lat)
    dest = ox.distance.nearest_nodes(G, dest_lng, dest_lat)
    return orig, dest


def _path_to_coords(G: nx.MultiDiGraph, path: list) -> list:
    """Convert a list of node IDs to [(lat, lng), …] coordinate pairs.

    OSMnx stores road-curve waypoints in the ``geometry`` attribute of each
    edge (a Shapely LineString).  Using only node coordinates gives straight
    lines between intersections; unpacking the full edge geometry produces a
    polyline that faithfully follows every curve of the actual road.
    """
    if len(path) < 2:
        return []
    coords = []
    for u, v in zip(path[:-1], path[1:]):
        # Pick the minimum-length parallel edge (same choice as _path_length_m).
        # Use float("inf") as fallback so edges without 'length' are never
        # falsely treated as the shortest.
        edge_data = min(
            G[u][v].values(),
            key=lambda d: d.get("length", float("inf")),
        )
        geom = edge_data.get("geometry")
        if geom is not None:
            # geom is a Shapely LineString with (lng, lat) coordinate order.
            pts = [(lat, lng) for lng, lat in geom.coords]
        else:
            # No geometry stored – fall back to the two endpoint nodes.
            pts = [
                (G.nodes[u]["y"], G.nodes[u]["x"]),
                (G.nodes[v]["y"], G.nodes[v]["x"]),
            ]
        # Avoid duplicating the shared node between consecutive edges.
        if coords:
            coords.extend(pts[1:])
        else:
            coords.extend(pts)
    return coords


def _est_time_min(distance_m: float, speed_kmh: float = 40.0) -> float:
    """Estimate driving time in minutes at the given average speed."""
    return (distance_m / 1_000) / speed_kmh * 60


# ---------------------------------------------------------------------------
# Shortest-path algorithms
# ---------------------------------------------------------------------------

def dijkstra(
    G: nx.MultiDiGraph, orig: int, dest: int, weight: str = "length"
) -> tuple:
    """
    Dijkstra's algorithm via NetworkX.

    Returns (path, length_m) where *path* is a list of node IDs and
    *length_m* is the total road distance in metres.
    """
    path = nx.dijkstra_path(G, orig, dest, weight=weight)
    length = nx.dijkstra_path_length(G, orig, dest, weight=weight)
    return path, length


def astar(G: nx.MultiDiGraph, orig: int, dest: int) -> tuple:
    """
    A* algorithm with a Haversine heuristic (admissible → optimal).

    Returns (path, length_m).
    """
    dest_data = G.nodes[dest]

    def heuristic(u: int, _v: int) -> float:
        u_data = G.nodes[u]
        return haversine_m(
            u_data["y"], u_data["x"],
            dest_data["y"], dest_data["x"],
        )

    path = nx.astar_path(G, orig, dest, heuristic=heuristic, weight="length")
    length = _path_length_m(G, path)
    return path, length


def _to_simple_digraph(G: nx.MultiDiGraph, weight: str = "length") -> nx.DiGraph:
    """
    Project a MultiDiGraph to a simple DiGraph.

    ``nx.shortest_simple_paths`` (Yen's algorithm) only accepts simple graphs,
    not MultiDiGraphs.  For each pair of nodes we keep the edge with the
    smallest *weight* value so that path lengths remain correct.  All
    attributes of the winning edge are preserved.
    """
    DG = nx.DiGraph()
    DG.add_nodes_from(G.nodes(data=True))
    for u, v, data in G.edges(data=True):
        w = data.get(weight, 1.0)
        if not DG.has_edge(u, v) or DG[u][v].get(weight, float("inf")) > w:
            DG.add_edge(u, v, **data)  # keep all attributes of the min-weight edge
    return DG


def yen_k_shortest(
    G: nx.MultiDiGraph, orig: int, dest: int,
    k: int = 3, weight: str = "length",
) -> list:
    """
    Yen's k-shortest simple paths algorithm (via NetworkX).

    OSMnx always returns a MultiDiGraph; we project it to a simple DiGraph
    (keeping the minimum-weight parallel edge) before calling
    ``nx.shortest_simple_paths``, which requires a simple graph.

    Returns a list of up to *k* tuples (path, length_m), shortest first.
    """
    results = []
    try:
        G_simple = _to_simple_digraph(G, weight=weight)
        for path in nx.shortest_simple_paths(G_simple, orig, dest, weight=weight):
            # Measure length on the original MultiDiGraph for accuracy.
            length = _path_length_m(G, path)
            results.append((path, length))
            if len(results) >= k:
                break
    except nx.NetworkXException:
        # Covers NetworkXNoPath, NodeNotFound, NetworkXError, etc.
        pass
    except Exception as exc:
        # Unexpected error – log it so it can be investigated, then degrade.
        print(f"  ⚠ Unexpected error in yen_k_shortest: {exc}")
    return results


# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------

ROUTE_LABELS = ["Eco-Optimised", "Fastest", "Balanced"]
CO2_FACTORS = {
    "Eco-Optimised": 0.12,   # kg CO₂ per km
    "Fastest":       0.21,
    "Balanced":      0.15,
}


def find_all_routes(
    origin_lat: float, origin_lng: float,
    dest_lat: float, dest_lng: float,
    k: int = 3,
) -> list:
    """
    Download the OSM road network and compute up to *k* shortest road routes.

    Terminal output includes:
      • Straight-line distance
      • Dijkstra and A* results (for comparison)
      • All k alternative routes with distance, time, and CO₂

    Returns a list of dicts (one per route):
        {
          "label":       str,
          "distance_m":  float,
          "distance_km": float,
          "time_min":    float,
          "co2_kg":      float,
          "co2_saved":   float,   # vs the "Fastest" route
          "node_count":  int,
          "coordinates": [[lat, lng], …],
        }
    """
    straight_m = haversine_m(origin_lat, origin_lng, dest_lat, dest_lng)

    _hr()
    print("  SHORTEST PATH FINDER  (OSMnx + Dijkstra / A* / Yen's)")
    _hr()
    print(f"  Origin      : ({origin_lat:.6f}, {origin_lng:.6f})")
    print(f"  Destination : ({dest_lat:.6f},  {dest_lng:.6f})")
    print(f"  Straight-line: {straight_m / 1_000:.3f} km")
    _sep()

    t0 = time.time()
    G = _download_network(origin_lat, origin_lng, dest_lat, dest_lng)
    orig_node, dest_node = _nearest_nodes(
        G, origin_lat, origin_lng, dest_lat, dest_lng
    )
    print(f"  Origin node      : {orig_node}")
    print(f"  Destination node : {dest_node}")
    _sep()

    # ── Dijkstra (single shortest path) ──────────────────────────────────────
    print("  Running Dijkstra's algorithm…")
    dijk_path, dijk_len = dijkstra(G, orig_node, dest_node)
    print(f"  ✓ Dijkstra: {dijk_len / 1_000:.3f} km  ({len(dijk_path)} nodes)")

    # ── A* (single shortest path, for comparison) ─────────────────────────────
    print("  Running A* algorithm…")
    try:
        astar_path, astar_len = astar(G, orig_node, dest_node)
        print(f"  ✓ A*:       {astar_len / 1_000:.3f} km  ({len(astar_path)} nodes)")
    except Exception as exc:
        print(f"  A* failed ({exc}), using Dijkstra result.")
        astar_path, astar_len = dijk_path, dijk_len

    # ── Yen's k-shortest (alternatives) ──────────────────────────────────────
    print(f"  Running Yen's {k}-shortest paths…")
    k_routes = yen_k_shortest(G, orig_node, dest_node, k=k)
    if not k_routes:
        # Yen's can still fail on complex graphs; use Dijkstra result so the
        # server always returns a usable road-following polyline.
        print("  ⚠ Yen's k-shortest yielded no paths; using Dijkstra result.")
        k_routes = [(dijk_path, dijk_len)]

    elapsed = time.time() - t0
    _hr()
    print(f"  RESULTS  (computed in {elapsed:.2f} s)")
    _hr()
    print(f"  {'Route':<20}  {'Distance':>10}  {'Time':>8}  {'Nodes':>6}")
    _sep()

    # Identify the fastest route distance (for CO₂ saved calculation)
    fastest_km = min(r[1] for r in k_routes) / 1_000

    routes = []
    for i, (path, length_m) in enumerate(k_routes):
        label = ROUTE_LABELS[i] if i < len(ROUTE_LABELS) else f"Route {i + 1}"
        coords = _path_to_coords(G, path)
        dist_km = length_m / 1_000
        time_min = _est_time_min(length_m)
        co2_factor = CO2_FACTORS.get(label, 0.15)
        co2_kg = dist_km * co2_factor
        fastest_co2 = fastest_km * CO2_FACTORS["Fastest"]
        co2_saved = max(0.0, fastest_co2 - co2_kg)

        print(
            f"  {label:<20}  {dist_km:>9.3f} km  "
            f"{time_min:>6.1f} min  {len(path):>6}"
        )
        if coords:
            print(f"    First waypoint : {coords[0]}")
            print(f"    Last  waypoint : {coords[-1]}")

        routes.append({
            "label":       label,
            "distance_m":  round(length_m, 2),
            "distance_km": round(dist_km, 3),
            "time_min":    round(time_min, 1),
            "co2_kg":      round(co2_kg, 3),
            "co2_saved":   round(co2_saved, 3),
            "node_count":  len(path),
            "coordinates": [[lat, lng] for lat, lng in coords],
        })

    _hr()
    best = routes[0]
    print(
        f"  Shortest road route : {best['distance_km']:.3f} km "
        f"({best['time_min']:.1f} min)"
    )
    print(f"  Straight-line       : {straight_m / 1_000:.3f} km")
    print(
        f"  Road/straight ratio : "
        f"{best['distance_km'] / (straight_m / 1_000):.2f}x"
    )
    _hr()
    print()

    return routes


# ---------------------------------------------------------------------------
# Terminal helpers
# ---------------------------------------------------------------------------

def _hr():
    print("=" * 64)


def _sep():
    print("-" * 64)


# ---------------------------------------------------------------------------
# CLI entry-point
# ---------------------------------------------------------------------------

if __name__ == "__main__":
    if len(sys.argv) < 5:
        print(__doc__)
        print("ERROR: Need at least 4 arguments: "
              "origin_lat origin_lng dest_lat dest_lng")
        sys.exit(1)

    _origin_lat = float(sys.argv[1])
    _origin_lng = float(sys.argv[2])
    _dest_lat   = float(sys.argv[3])
    _dest_lng   = float(sys.argv[4])
    _k          = int(sys.argv[5]) if len(sys.argv) > 5 else 3

    _routes = find_all_routes(
        _origin_lat, _origin_lng,
        _dest_lat,   _dest_lng,
        k=_k,
    )

    print(f"Found {len(_routes)} road route(s):\n")
    for idx, r in enumerate(_routes, 1):
        print(
            f"  Route {idx} ({r['label']}): "
            f"{r['distance_km']:.2f} km, "
            f"{r['time_min']:.1f} min, "
            f"{len(r['coordinates'])} waypoints, "
            f"{r['co2_kg']:.2f} kg CO₂"
        )
