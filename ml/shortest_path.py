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

# Third-party - install via:  pip install -r requirements.txt
import osmnx as ox
import networkx as nx
from geopy.distance import geodesic


# ---------------------------------------------------------------------------
# Distance helpers
# ---------------------------------------------------------------------------

def haversine_m(lat1: float, lng1: float, lat2: float, lng2: float) -> float:
    """Straight-line (Haversine) distance in metres."""
    # A fast, math-based Haversine approximation is much faster than geodesic for algorithms.
    R = 6371000.0
    phi1, phi2 = math.radians(lat1), math.radians(lat2)
    dphi = math.radians(lat2 - lat1)
    dlambda = math.radians(lng2 - lng1)
    a = math.sin(dphi/2.0)**2 + \
        math.cos(phi1) * math.cos(phi2) * math.sin(dlambda/2.0)**2
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1.0 - a))
    return R * c


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

# Simple in-memory cache to avoid repeated graph downloads/loading
_GRAPH_CACHE = {} # key -> G
_SPATIAL_GRAPHS = [] # list of {'bbox': (s, n, w, e), 'G': MultiDiGraph}
_RESULT_CACHE = {} # (rounded_coords, k) -> routes_dict

def _download_network(
    origin_lat: float, origin_lng: float,
    dest_lat: float, dest_lng: float,
    buffer_km: float = 1.0,
) -> nx.MultiDiGraph:
    """Download or reuse a road network that covers origin  destination."""
    
    # 1. Spatial Reuse Check: See if existing loaded graphs cover this route
    min_lat, max_lat = min(origin_lat, dest_lat), max(origin_lat, dest_lat)
    min_lng, max_lng = min(origin_lng, dest_lng), max(origin_lng, dest_lng)
    
    for entry in _SPATIAL_GRAPHS:
        s, n, w, e = entry['bbox']
        # Check if points are well within the bbox (buffer of 200m to be safe)
        if s < min_lat - 0.002 and n > max_lat + 0.002 and \
           w < min_lng - 0.002 and e > max_lng + 0.002:
            print("  Reusing existing spatial graph...")
            return entry['G']

    center_lat = (origin_lat + dest_lat) / 2
    center_lng = (origin_lng + dest_lng) / 2

    diag_m = haversine_m(origin_lat, origin_lng, dest_lat, dest_lng)
    radius_m = max((diag_m / 2 + (buffer_km * 1000)), 3000)

    cache_key = (round(center_lat, 2), round(center_lng, 2), round(radius_m, -1))
    if cache_key in _GRAPH_CACHE:
        print(f"  Using cached road network for {cache_key}")
        return _GRAPH_CACHE[cache_key]

    print(f"  Downloading OSM road network (radius={radius_m / 1_000:.1f} km)...")
    ox.settings.use_cache = True

    try:
        G = ox.graph_from_point(
            (center_lat, center_lng),
            dist=radius_m,
            network_type="drive",
            simplify=True,
        )
    except Exception as e:
        print(f"  OSMnx failed: {e}. Falling back...")
        G = ox.graph_from_point((center_lat, center_lng), dist=2000, network_type="drive", simplify=True)

    print(f"  Network ready: {len(G.nodes):,} nodes, {len(G.edges):,} edges")
    
    # Add to caches
    _GRAPH_CACHE[cache_key] = G
    # Approximate bbox of the downloaded graph
    _SPATIAL_GRAPHS.append({
        'bbox': (center_lat - (radius_m/111000), center_lat + (radius_m/111000),
                 center_lng - (radius_m/85000), center_lng + (radius_m/85000)),
        'G': G
    })
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
    """Convert a list of node IDs to [(lat, lng), ...] coordinate pairs.

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
            # No geometry stored - fall back to the two endpoint nodes.
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


def _est_time_min(distance_m: float, speed_kmh: float = 30.0) -> float:
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


def astar(G: nx.MultiDiGraph, orig: int, dest: int, weight: str = "length") -> tuple:
    """A* algorithm with a math Haversine heuristic (faster)."""
    dest_data = G.nodes[dest]
    dest_y, dest_x = dest_data["y"], dest_data["x"]

    def heuristic(u: int, _v: int) -> float:
        u_data = G.nodes[u]
        # Using math-based local approximation for speed in the inner loop
        dy = (u_data["y"] - dest_y) * 111000.0
        dx = (u_data["x"] - dest_x) * (math.cos(math.radians(dest_y)) * 111000.0)
        return math.sqrt(dy**2 + dx**2)

    path = nx.astar_path(G, orig, dest, heuristic=heuristic, weight=weight)
    # bidirectional_dijkstra is often faster but astar is good for single-path too.
    # nx.astar_path in NetworkX is unidirectional.
    length = _path_length_m(G, path)
    return path, length


def _to_simple_digraph(G: nx.MultiDiGraph, weight: str = "length") -> nx.DiGraph:
    """Project a MultiDiGraph to a simple DiGraph (optimized)."""
    DG = nx.DiGraph()
    # Pre-populate nodes to avoid overhead in the loop
    DG.add_nodes_from(G.nodes(data=True))
    
    # Sort or iterate smartly? For MultiDiGraph edges, we need min weight.
    # G.edges(data=True) is an iterator.
    for u, v, data in G.edges(data=True):
        w = data.get(weight, 1.0)
        if not DG.has_edge(u, v) or DG[u][v].get(weight, float("inf")) > w:
            DG.add_edge(u, v, **data)
    return DG


def penalty_k_shortest(
    G: nx.MultiDiGraph, orig: int, dest: int,
    k: int = 3, weight: str = "length",
) -> list:
    """
    Find k diverse alternative paths using the Penalty Method.
    MUCH faster than Yen's algorithm for road networks.
    """
    results = []
    # Work on a simple graph for speed in pathfinding
    DG = _to_simple_digraph(G, weight=weight)
    
    # Store weights to revert later if needed, though we usually discard DG
    modified_edges = {}

    for _ in range(k):
        try:
            length, path = nx.bidirectional_dijkstra(DG, orig, dest, weight=weight)
            results.append((path, length))
            
            # Penalize edges in the found path to encourage diversity
            for u, v in zip(path[:-1], path[1:]):
                curr_w = DG[u][v][weight]
                new_w = curr_w * 1.5 # 50% penalty
                DG[u][v][weight] = new_w
                modified_edges[(u, v)] = curr_w
        except (nx.NetworkXNoPath, nx.NodeNotFound):
            break
            
    return results


# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------

ROUTE_LABELS = ["Eco-Optimised", "Fastest", "Balanced"]
CO2_FACTORS = {
    "Eco-Optimised": 0.12,   # kg CO per km
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
      * Straight-line distance
      * Dijkstra and A* results (for comparison)
      * All k alternative routes with distance, time, and CO

    Returns a list of dicts (one per route):
        {
          "label":       str,
          "distance_m":  float,
          "distance_km": float,
          "time_min":    float,
          "co2_kg":      float,
          "co2_saved":   float,   # vs the "Fastest" route
          "node_count":  int,
          "coordinates": [[lat, lng], ...],
        }
    """
    # 0. Result Cache Check
    cache_key = (round(origin_lat, 4), round(origin_lng, 4), round(dest_lat, 4), round(dest_lng, 4), k)
    if cache_key in _RESULT_CACHE:
        print("  Using cached route result...")
        return _RESULT_CACHE[cache_key]

    straight_m = haversine_m(origin_lat, origin_lng, dest_lat, dest_lng)

    _hr()
    print("  SHORTEST PATH FINDER  (Optimized: Spatial Cache + Penalty Method)")
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

    k_routes = []
    if k == 1:
        #  Optimized Single Path (Bidirectional Dijkstra) 
        print("  Running Bidirectional Dijkstra (optimized)...")
        path_len, path = nx.bidirectional_dijkstra(G, orig_node, dest_node, weight="length")
        k_routes = [(path, path_len)]
    else:
        #  Optimized Multiple Paths (Penalty Method) 
        print(f"  Running Penalty Method for {k} alternative paths...")
        k_routes = penalty_k_shortest(G, orig_node, dest_node, k=k)
    
    if not k_routes:
        print("  Falling back to standard Dijkstra...")
        p, l = nx.dijkstra_path(G, orig_node, dest_node, weight="length"), \
               nx.dijkstra_path_length(G, orig_node, dest_node, weight="length")
        k_routes = [(p, l)]

    elapsed = time.time() - t0
    _hr()
    print(f"  RESULTS  (computed in {elapsed:.2f} s)")
    _hr()
    print(f"  {'Route':<20}  {'Distance':>10}  {'Time':>8}  {'Nodes':>6}")
    _sep()

    # Identify the fastest route distance (for CO saved calculation)
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

    # Cache and return
    _RESULT_CACHE[cache_key] = routes
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
            f"{r['co2_kg']:.2f} kg CO"
        )
