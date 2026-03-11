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

# geopy is lightweight — safe to import at top level
from geopy.distance import geodesic

# osmnx and networkx are heavy (~200MB). Imported lazily inside functions
# so the Flask server starts instantly on Render's free 512MB tier.
_ox = None
_nx = None

def _get_ox():
    global _ox
    if _ox is None:
        import osmnx as ox  # noqa: PLC0415
        _ox = ox
    return _ox

def _get_nx():
    global _nx
    if _nx is None:
        import networkx as nx  # noqa: PLC0415
        _nx = nx
    return _nx


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

# ---------------------------------------------------------------------------
# GIS Engine (Disabled on Free Tier due to 512MB RAM limit)
# ---------------------------------------------------------------------------

_ox = None
_nx = None
_ENABLE_GIS = True # Enabled for road-following routes

def _get_ox():
    if not _ENABLE_GIS: return None
    global _ox
    if _ox is None:
        try:
            import osmnx as ox  # noqa: PLC0415
            ox.settings.use_cache = True
            ox.settings.log_console = True
            _ox = ox
        except ImportError: return None
    return _ox

def _get_nx():
    if not _ENABLE_GIS: return None
    global _nx
    if _nx is None:
        try:
            import networkx as nx  # noqa: PLC0415
            _nx = nx
        except ImportError: return None
    return _nx

def _download_network(
    origin_lat: float, origin_lng: float,
    dest_lat: float, dest_lng: float,
    straight_m: float,
    buffer_km: float = 3.0,
) -> object:
    """Download the road network within a bounding box including the route."""
    ox = _get_ox()
    if not ox: return None

    # Try a very small buffer first to save RAM
    buffer_km = 1.0 
    north = max(origin_lat, dest_lat) + (buffer_km / 111.0)
    south = min(origin_lat, dest_lat) - (buffer_km / 111.0)
    lat_factor = math.cos(math.radians(origin_lat))
    east = max(origin_lng, dest_lng) + (buffer_km / (111.0 * lat_factor))
    west = min(origin_lng, dest_lng) - (buffer_km / (111.0 * lat_factor))

    bbox_key = (round(north, 4), round(south, 4), round(east, 4), round(west, 4))
    if bbox_key in _GRAPH_CACHE:
        return _GRAPH_CACHE[bbox_key]

    print(f"  Downloading tiny area GIS: N:{north:.4f} S:{south:.4f} E:{east:.4f} W:{west:.4f}")
    try:
        # network_type='drive' and simplify=True are crucial
        G = ox.graph_from_bbox(north, south, east, west, network_type='drive', simplify=True)
        # Keep only the largest strongly connected component
        G = ox.utils_graph.get_largest_component(G, strongly=True)
        _GRAPH_CACHE[bbox_key] = G
        return G
    except Exception as e:
        print(f"  OSMnx Tiny Download Error: {e}")
        return None



def _nearest_nodes(
    G, origin_lat, origin_lng, dest_lat, dest_lng
) -> tuple:
    """Return (origin_node_id, dest_node_id) closest to the given coordinates."""
    ox = _get_ox()
    orig = ox.distance.nearest_nodes(G, origin_lng, origin_lat)
    dest = ox.distance.nearest_nodes(G, dest_lng, dest_lat)
    return orig, dest


def _path_to_coords(G, path: list) -> list:
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

def dijkstra(G, orig: int, dest: int, weight: str = "length") -> tuple:
    """
    Dijkstra's algorithm via NetworkX.
    Returns (path, length_m) where *path* is a list of node IDs and
    *length_m* is the total road distance in metres.
    """
    nx = _get_nx()
    path = nx.dijkstra_path(G, orig, dest, weight=weight)
    length = nx.dijkstra_path_length(G, orig, dest, weight=weight)
    return path, length


def astar(G, orig: int, dest: int, weight: str = "length") -> tuple:
    """A* algorithm with a math Haversine heuristic (faster)."""
    nx = _get_nx()
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


def _to_simple_digraph(G, weight: str = "length"):
    """Project a MultiDiGraph to a simple DiGraph (optimized)."""
    nx = _get_nx()
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


def penalty_k_shortest(G, orig: int, dest: int, k: int = 3, weight: str = "length") -> list:
    """
    Find k diverse alternative paths using the Penalty Method.
    MUCH faster than Yen's algorithm for road networks.
    """
    nx = _get_nx()
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
        except (_get_nx().NetworkXNoPath, _get_nx().NodeNotFound):
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


def _estimated_routes(
    origin_lat: float, origin_lng: float,
    dest_lat: float, dest_lng: float,
    straight_m: float,
    k: int,
) -> list:
    """Return estimated routes using straight-line × road-factor when OSMnx
    would be too slow (routes > 60 km on free hosting)."""
    # Straight waypoints: origin → midpoint → destination
    mid_lat = (origin_lat + dest_lat) / 2
    mid_lng = (origin_lng + dest_lng) / 2
    offsets = [0.0, 0.01, -0.01]

    # Realistic road-distance multipliers for eco / fast / balanced
    multipliers = [1.30, 1.45, 1.38]
    labels = ROUTE_LABELS[:k]
    results = []
    fast_km = (straight_m / 1000) * multipliers[1]

    for i in range(min(k, 3)):
        dist_km = (straight_m / 1000) * multipliers[i]
        dist_m  = dist_km * 1000
        time_min = dist_km / 50 * 60  # assume ~50 km/h avg highway speed
        label = labels[i]
        co2_factor = CO2_FACTORS.get(label, 0.15)
        co2_kg    = dist_km * co2_factor
        co2_saved = max(0.0, fast_km * CO2_FACTORS["Fastest"] - co2_kg)

        # Slightly offset intermediate waypoint per route
        via_lat = mid_lat + offsets[i] * abs(dest_lat - origin_lat)
        via_lng = mid_lng + offsets[i] * abs(dest_lng - origin_lng)
        coordinates = [
            [origin_lat, origin_lng],
            [via_lat, via_lng],
            [dest_lat, dest_lng],
        ]
        results.append({
            "label":       label,
            "distance_m":  round(dist_m, 2),
            "distance_km": round(dist_km, 3),
            "time_min":    round(time_min, 1),
            "co2_kg":      round(co2_kg, 3),
            "co2_saved":   round(co2_saved, 3),
            "node_count":  3,
            "coordinates": coordinates,
            "estimated":   True,  # flag so UI knows this is an approximation
        })
    return results


# Max straight-line km before we skip OSMnx and use the estimator
_MAX_OSMNX_KM = 60.0


def find_all_routes(
    origin_lat: float, origin_lng: float,
    dest_lat: float, dest_lng: float,
    k: int = 3,
) -> list:
    """
    Compute up to *k* road routes.
    On low-memory servers, this uses the fast Road Distance Estimator.
    """
    # 0. Result Cache Check
    cache_key = (round(origin_lat, 4), round(origin_lng, 4), round(dest_lat, 4), round(dest_lng, 4), k)
    if cache_key in _RESULT_CACHE:
        print("  Using cached route result...")
        return _RESULT_CACHE[cache_key]

    straight_m = haversine_m(origin_lat, origin_lng, dest_lat, dest_lng)
    straight_km = straight_m / 1000

    _hr()
    print("  SHORTEST PATH FINDER  (Optimized Mode)")
    _hr()
    print(f"  Origin       : ({origin_lat:.6f}, {origin_lng:.6f})")
    print(f"  Destination  : ({dest_lat:.6f},  {dest_lng:.6f})")
    print(f"  Straight-line: {straight_km:.3f} km")
    _sep()

    # 2. GIS Routing (Only if enabled and short)
    try:
        if not _ENABLE_GIS or straight_km > _MAX_OSMNX_KM:
             raise ValueError("GIS disabled or route too long")

        t0 = time.time()
        G = _download_network(origin_lat, origin_lng, dest_lat, dest_lng, straight_m)
        if G is None:
             raise ValueError("Could not download road network")

        orig_node, dest_node = _nearest_nodes(G, origin_lat, origin_lng, dest_lat, dest_lng)
        print(f"  Origin node      : {orig_node}")
        print(f"  Destination node : {dest_node}")
        _sep()

        k_routes = []
        if k == 1:
            #  Optimized Single Path (Bidirectional Dijkstra) 
            print("  Running Bidirectional Dijkstra (optimized)...")
            path_len, path = _get_nx().bidirectional_dijkstra(G, orig_node, dest_node, weight="length")
            k_routes = [(path, path_len)]
        else:
            #  Optimized Multiple Paths (Penalty Method) 
            print(f"  Running Penalty Method for {k} alternative paths...")
            k_routes = penalty_k_shortest(G, orig_node, dest_node, k=k)
        
        if not k_routes:
            print("  Falling back to standard Dijkstra...")
            p = _get_nx().dijkstra_path(G, orig_node, dest_node, weight="length")
            l = _get_nx().dijkstra_path_length(G, orig_node, dest_node, weight="length")
            k_routes = [(p, l)]

        elapsed = time.time() - t0
        _hr()
        print(f"  RESULTS  (computed in {elapsed:.2f} s)")
    except Exception as e:
        err_msg = str(e)
        print(f"  GIS Routing skipped/failed: {err_msg}")
        routes = _estimated_routes(origin_lat, origin_lng, dest_lat, dest_lng, straight_m, k)
        for r in routes:
            r["debug_error"] = err_msg
        _RESULT_CACHE[cache_key] = routes
        return routes
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
