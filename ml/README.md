# ML Route Engine — OpenStreetMap + Dijkstra / A* / Yen's

This folder contains the Python backend that replaces direct Google Maps REST
calls (which fail with CORS errors in Flutter Web).  It downloads the real
road network from OpenStreetMap and applies graph shortest-path algorithms to
return polylines that follow actual roads.

## Algorithms

| Algorithm | Purpose |
|---|---|
| **Dijkstra's** | Classic shortest path — guaranteed optimal, O((V+E) log V) |
| **A*** | Heuristic-guided Dijkstra with Haversine distance — faster on large graphs |
| **Yen's k-shortest** | Finds up to *k* alternative simple paths for route comparison |

## Setup

```bash
cd ml/
python -m venv .venv
source .venv/bin/activate     # Windows: .venv\Scripts\activate
pip install -r requirements.txt
```

## Run the standalone CLI (prints all routes to terminal)

```bash
python shortest_path.py <origin_lat> <origin_lng> <dest_lat> <dest_lng> [k]

# Example — San Francisco → Oakland (k=3 alternative routes)
python shortest_path.py 37.7749 -122.4194 37.8044 -122.2712 3
```

**Sample terminal output:**

```
================================================================
  SHORTEST PATH FINDER  (OSMnx + Dijkstra / A* / Yen's)
================================================================
  Origin      : (37.774900, -122.419400)
  Destination : (37.804400, -122.271200)
  Straight-line: 13.221 km
----------------------------------------------------------------
  Downloading OSM road network (radius=9.6 km)…
  Network ready: 12,847 nodes, 31,204 edges
  Origin node      : 65302177
  Destination node : 53168291
----------------------------------------------------------------
  Running Dijkstra's algorithm…
  ✓ Dijkstra: 16.842 km  (247 nodes)
  Running A* algorithm…
  ✓ A*:       16.842 km  (247 nodes)
  Running Yen's 3-shortest paths…
================================================================
  RESULTS  (computed in 4.31 s)
================================================================
  Route                 Distance       Time   Nodes
----------------------------------------------------------------
  Eco-Optimised        16.842 km    25.3 min    247
    First waypoint : (37.7748, -122.4192)
    Last  waypoint : (37.8043, -122.2714)
  Fastest              17.105 km    25.7 min    231
  Balanced             17.391 km    26.1 min    258
================================================================
  Shortest road route : 16.842 km (25.3 min)
  Straight-line       : 13.221 km
  Road/straight ratio : 1.27x
================================================================
```

## Start the Flask server (used by Flutter Web)

```bash
python server.py
# listens on http://localhost:8080
```

### API endpoints

| Method | Path | Description |
|---|---|---|
| GET | `/route` | Single shortest road route |
| GET | `/all_routes` | Up to 3 alternative routes |
| GET | `/geocode` | Address → lat/lng (Nominatim) |
| GET | `/autocomplete` | Place suggestions (Nominatim) |

**Example requests:**

```bash
# Shortest route
curl "http://localhost:8080/route?origin_lat=37.7749&origin_lng=-122.4194&dest_lat=37.8044&dest_lng=-122.2712"

# All alternative routes
curl "http://localhost:8080/all_routes?origin_lat=37.7749&origin_lng=-122.4194&dest_lat=37.8044&dest_lng=-122.2712"

# Geocode an address
curl "http://localhost:8080/geocode?address=Golden+Gate+Bridge"

# Autocomplete
curl "http://localhost:8080/autocomplete?input=San+Fra"
```

## How Flutter connects

The Flutter app (`maps_screen.dart`, `green_route_screen.dart`) checks
`kIsWeb` at runtime.  When running in Chrome:

1. Address geocoding → `GET /geocode`
2. Place autocomplete → `GET /autocomplete`
3. Route polyline (MapsScreen) → `GET /route`
4. Alternative routes (GreenRouteScreen) → `GET /all_routes`

On Android / iOS the existing native geocoding (`geocoding` package) and
Google Directions API paths are used unchanged.

## Notes

- OSMnx caches downloaded road networks in `~/.cache/osmnx/` so subsequent
  calls in the same area are fast.
- The server enables CORS for all origins so the Flutter Web app on any
  localhost port can reach it.
- Nominatim is a free geocoder but rate-limited.  For production use, consider
  a self-hosted Nominatim instance or a paid geocoder.
