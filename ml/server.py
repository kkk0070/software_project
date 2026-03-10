#!/usr/bin/env python3
"""
Route & Geocode Server — Flask + OSMnx

Provides road-following route data, geocoding, and place autocomplete for the
Flutter app.  All requests are answered with CORS headers so that the Flutter
Web build (running on localhost) can reach this server without browser errors.

Endpoints
---------
GET /route
    Shortest road route between two coordinates (used by MapsScreen).
    Query params: origin_lat, origin_lng, dest_lat, dest_lng

GET /all_routes
    Up to 3 alternative road routes (used by GreenRouteScreen).
    Query params: origin_lat, origin_lng, dest_lat, dest_lng

GET /geocode
    Convert a free-text address to lat/lng via Nominatim (OpenStreetMap).
    Query params: address

GET /autocomplete
    Return up to 5 place-name suggestions via Nominatim.
    Query params: input

GET /emission
    Calculate CO₂ emissions for a given vehicle type and distance using the
    ML emission model (scikit-learn LinearRegression).
    Query params: vehicle_type, distance_km
    Supported vehicle_type values: car_petrol, car_diesel, motorcycle,
                                   electric, bus, bicycle, walking

GET /air_quality
    Estimate Air Quality Index (AQI) for a route midpoint and vehicle.
    Query params: lat, lng, distance_km, vehicle_type

Start
-----
    cd ml/
    pip install -r requirements.txt
    python server.py

The server listens on http://localhost:8080 by default.
Set the PORT environment variable to override.
"""

import os
import traceback

from flask import Flask, request, jsonify
from flask_cors import CORS
from geopy.geocoders import Nominatim
from geopy.exc import GeocoderTimedOut, GeocoderServiceError

from shortest_path import find_all_routes
from emission_model import predict_emission, estimate_aqi, VEHICLE_TYPES
from fare_model import predict_fare, WEATHER_CONDITIONS, TRAFFIC_LEVELS, TIME_OF_DAY


app = Flask(__name__)
CORS(app, origins=[
    "http://localhost:*",
    "https://*.vercel.app",
    "https://frontend-kkk0070s-projects.vercel.app",
    "https://web-axdhnv022-kkk0070s-projects.vercel.app",
])

_geocoder = Nominatim(user_agent="sepro-route-server/1.0", timeout=10)


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def _float(name: str):
    """Parse a float query parameter; return None if missing or invalid."""
    raw = request.args.get(name)
    if raw is None:
        return None
    try:
        return float(raw)
    except (ValueError, TypeError):
        return None


def _err(msg: str, code: int = 400):
    return jsonify({"error": msg}), code


@app.route("/health")
def health():
    """Health check endpoint for monitoring (Render, UptimeRobot, etc.)."""
    return jsonify({"status": "ok", "service": "EcoRide ML Server"});


# ---------------------------------------------------------------------------
# /route  — single shortest road route
# ---------------------------------------------------------------------------

@app.route("/route")
def route():
    """Return the single shortest road route as a list of [lat, lng] pairs."""
    origin_lat = _float("origin_lat")
    origin_lng = _float("origin_lng")
    dest_lat   = _float("dest_lat")
    dest_lng   = _float("dest_lng")

    if None in (origin_lat, origin_lng, dest_lat, dest_lng):
        return _err("Required params: origin_lat, origin_lng, dest_lat, dest_lng")

    try:
        routes = find_all_routes(origin_lat, origin_lng, dest_lat, dest_lng, k=1)
        if not routes:
            return _err("No road route found between the two points", 404)
        r = routes[0]
        return jsonify({
            "distance_km": r["distance_km"],
            "time_min":    r["time_min"],
            "co2_kg":      r["co2_kg"],
            "coordinates": r["coordinates"],   # [[lat, lng], …]
        })
    except Exception as exc:
        traceback.print_exc()
        return _err(f"Routing error: {exc}", 500)


# ---------------------------------------------------------------------------
# /all_routes  — up to 3 alternative road routes
# ---------------------------------------------------------------------------

@app.route("/all_routes")
def all_routes():
    """Return up to 3 alternative road routes (for GreenRouteScreen)."""
    origin_lat = _float("origin_lat")
    origin_lng = _float("origin_lng")
    dest_lat   = _float("dest_lat")
    dest_lng   = _float("dest_lng")

    if None in (origin_lat, origin_lng, dest_lat, dest_lng):
        return _err("Required params: origin_lat, origin_lng, dest_lat, dest_lng")

    try:
        routes = find_all_routes(origin_lat, origin_lng, dest_lat, dest_lng, k=3)
        return jsonify({"routes": routes})
    except Exception as exc:
        traceback.print_exc()
        return _err(f"Routing error: {exc}", 500)


# ---------------------------------------------------------------------------
# /geocode  — address → lat/lng
# ---------------------------------------------------------------------------

@app.route("/geocode")
def geocode():
    """Convert a free-text address to lat/lng using Nominatim."""
    address = request.args.get("address", "").strip()
    if not address:
        return _err("Required param: address")

    try:
        location = _geocoder.geocode(address)
        if location is None:
            return _err("Address not found", 404)
        return jsonify({
            "lat":          location.latitude,
            "lng":          location.longitude,
            "display_name": location.address,
        })
    except (GeocoderTimedOut, GeocoderServiceError) as exc:
        return _err(f"Geocoder unavailable: {exc}", 503)


# ---------------------------------------------------------------------------
# /autocomplete  — place-name suggestions
# ---------------------------------------------------------------------------

@app.route("/autocomplete")
def autocomplete():
    """Return up to 5 place-name suggestions using Nominatim."""
    query = request.args.get("input", "").strip()
    if len(query) < 3:
        return jsonify({"predictions": []})

    try:
        results = _geocoder.geocode(query, exactly_one=False, limit=5) or []
        predictions = [{"description": r.address} for r in results]
        return jsonify({"predictions": predictions})
    except (GeocoderTimedOut, GeocoderServiceError) as exc:
        return _err(f"Geocoder unavailable: {exc}", 503)


# ---------------------------------------------------------------------------
# /emission  — ML-based CO₂ emission prediction
# ---------------------------------------------------------------------------

@app.route("/emission")
def emission():
    """
    Calculate CO₂ emissions using the ML emission model.

    Required params
    ---------------
    vehicle_type : str   One of: car_petrol, car_diesel, motorcycle,
                                 electric, bus, bicycle, walking
    distance_km  : float Route distance in kilometres.

    Returns
    -------
    JSON with co2_kg, emission_factor_kg_per_km, category, aqi_impact,
    and the full list of supported vehicle types.
    """
    vehicle_type = request.args.get("vehicle_type", "").strip()
    distance_km  = _float("distance_km")

    if not vehicle_type:
        return _err(
            f"Required param: vehicle_type. "
            f"Supported types: {', '.join(VEHICLE_TYPES)}"
        )
    if distance_km is None:
        return _err("Required param: distance_km (numeric, in km)")

    try:
        result = predict_emission(vehicle_type, distance_km)
        result["vehicle_type"]    = vehicle_type
        result["distance_km"]     = round(distance_km, 3)
        result["supported_types"] = VEHICLE_TYPES
        return jsonify(result)
    except ValueError as exc:
        return _err(str(exc))
    except Exception as exc:
        traceback.print_exc()
        return _err(f"Emission calculation error: {exc}", 500)


# ---------------------------------------------------------------------------
# /air_quality  — AQI estimate for a route midpoint
# ---------------------------------------------------------------------------

@app.route("/air_quality")
def air_quality():
    """
    Estimate Air Quality Index (AQI) for a route midpoint.

    Required params
    ---------------
    lat          : float Route midpoint latitude.
    lng          : float Route midpoint longitude.

    Optional params
    ---------------
    distance_km  : float Route distance (default 0).
    vehicle_type : str   Vehicle type (default car_petrol).

    Returns
    -------
    JSON with aqi (0–500), category, color (hex), and description.
    """
    lat          = _float("lat")
    lng          = _float("lng")
    distance_km  = _float("distance_km") or 0.0
    vehicle_type = request.args.get("vehicle_type", "car_petrol").strip()

    if None in (lat, lng):
        return _err("Required params: lat, lng")

    try:
        result = estimate_aqi(lat, lng, distance_km, vehicle_type)
        return jsonify(result)
    except Exception as exc:
        traceback.print_exc()
        return _err(f"AQI calculation error: {exc}", 500)


# ---------------------------------------------------------------------------
# /fare — ML-based fare prediction
# ---------------------------------------------------------------------------

@app.route("/fare")
def fare():
    """
    Calculate estimated fare using the ML fare model.

    Required params: distance_km, weather, traffic, time, co2_kg
    """
    distance_km = _float("distance_km")
    weather     = request.args.get("weather", "Clear").strip()
    traffic     = request.args.get("traffic", "Low").strip()
    time        = request.args.get("time", "Off-Peak").strip()
    co2_kg      = _float("co2_kg") or 0.0
    vehicle_type = request.args.get("vehicle_type", "car_petrol").strip()

    if distance_km is None:
        return _err("Required param: distance_km")

    try:
        result = predict_fare(distance_km, weather, traffic, time, co2_kg, vehicle_type)
        result["inputs"] = {
            "distance_km": distance_km,
            "weather": weather,
            "traffic": traffic,
            "time": time,
            "co2_kg": co2_kg
        }
        result["supported_options"] = {
            "weather": WEATHER_CONDITIONS,
            "traffic": TRAFFIC_LEVELS,
            "time": TIME_OF_DAY
        }
        return jsonify(result)
    except Exception as exc:
        traceback.print_exc()
        return _err(f"Fare calculation error: {exc}", 500)


# ---------------------------------------------------------------------------
# Entry-point
# ---------------------------------------------------------------------------

if __name__ == "__main__":
    _port_str = os.environ.get("PORT", "").strip()
    port = int(_port_str) if _port_str.isdigit() else 8080
    print(f"\n  Route & Geocode Server  →  http://localhost:{port}\n")
    print("  Endpoints:")
    print("    GET /route        – single shortest road route")
    print("    GET /all_routes   – up to 3 alternative road routes")
    print("    GET /geocode      – address → lat/lng")
    print("    GET /autocomplete – place-name suggestions")
    print("    GET /emission     – ML CO₂ emission prediction (vehicle_type + distance_km)")
    print("    GET /air_quality  – AQI estimate (lat + lng + distance_km + vehicle_type)\n")
    app.run(host="0.0.0.0", port=port, debug=False)
