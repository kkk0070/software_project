
import time
import networkx as nx
import osmnx as ox
from geopy.distance import geodesic

def haversine_m(lat1, lng1, lat2, lng2):
    return geodesic((lat1, lng1), (lat2, lng2)).meters

def _path_length_m(G, path):
    total = 0.0
    for u, v in zip(path[:-1], path[1:]):
        edges = G[u][v].values() if G.has_edge(u, v) else G[v][u].values()
        total += min(e.get("length", 0.0) for e in edges)
    return total

def test_speed():
    # San Francisco coordinates
    origin_lat, origin_lng = 37.7749, -122.4194
    dest_lat, dest_lng = 37.8044, -122.2712
    
    center_lat = (origin_lat + dest_lat) / 2
    center_lng = (origin_lng + dest_lng) / 2
    radius_m = 8000
    
    ox.settings.use_cache = True
    print("Loading network...")
    G = ox.graph_from_point((center_lat, center_lng), dist=radius_m, network_type="drive", simplify=True)
    orig_node = ox.distance.nearest_nodes(G, origin_lng, origin_lat)
    dest_node = ox.distance.nearest_nodes(G, dest_lng, dest_lat)
    
    print(f"Nodes: {len(G.nodes)}, Edges: {len(G.edges)}")
    
    # Dijkstra
    t0 = time.time()
    path1 = nx.dijkstra_path(G, orig_node, dest_node, weight='length')
    len1 = nx.dijkstra_path_length(G, orig_node, dest_node, weight='length')
    t_dijk = time.time() - t0
    print(f"Dijkstra: {t_dijk:.4f}s, Len: {len1:.2f}m")
    
    # A* with slow heuristic
    dest_data = G.nodes[dest_node]
    dest_y, dest_x = dest_data["y"], dest_data["x"]
    def heuristic_slow(u, v):
        u_data = G.nodes[u]
        return haversine_m(u_data["y"], u_data["x"], dest_y, dest_x)
    
    t0 = time.time()
    try:
        path2 = nx.astar_path(G, orig_node, dest_node, heuristic=heuristic_slow, weight='length')
        t_astar_slow = time.time() - t0
        len2 = _path_length_m(G, path2)
        print(f"A* (slow heuristic): {t_astar_slow:.4f}s, Len: {len2:.2f}m")
    except Exception as e:
        print(f"A* slow error: {e}")

    # A* with fast heuristic
    def heuristic_fast(u, v):
        u_data = G.nodes[u]
        dy = (u_data["y"] - dest_y) * 111000.0
        dx = (u_data["x"] - dest_x) * 85000.0 # Approximation for SF
        return (dy**2 + dx**2)**0.5
    
    t0 = time.time()
    path3 = nx.astar_path(G, orig_node, dest_node, heuristic=heuristic_fast, weight='length')
    t_astar_fast = time.time() - t0
    len3 = _path_length_m(G, path3)
    print(f"A* (fast heuristic): {t_astar_fast:.4f}s, Len: {len3:.2f}m")
    
    # Bidirectional Dijkstra
    t0 = time.time()
    len4, path4 = nx.bidirectional_dijkstra(G, orig_node, dest_node, weight='length')
    t_bidijk = time.time() - t0
    print(f"Bidirectional Dijkstra: {t_bidijk:.4f}s, Len: {len4:.2f}m")

if __name__ == "__main__":
    test_speed()
