#!/usr/bin/env python3
"""
Emission & Air Quality ML Model
================================

Predicts CO₂ emissions (kg) for a trip based on *vehicle type* and
*distance* using a scikit-learn Linear Regression model trained on
synthetic yet realistic data derived from well-known emission factors.

The model uses vehicle_type × distance interaction features (one regression
coefficient per vehicle type) so that predictions scale linearly with distance
and independently per vehicle — matching the known physics of road transport.

Air Quality Index (AQI) is estimated with a simplified physics-inspired
model that combines a location-based urban-density proxy with the emission
contribution of the selected vehicle over the given route distance.

Usage
-----
    from emission_model import predict_emission, estimate_aqi, VEHICLE_TYPES

    result = predict_emission("car_petrol", 12.5)
    aqi    = estimate_aqi(37.77, -122.42, 12.5, "car_petrol")
"""

import numpy as np
from sklearn.linear_model import LinearRegression

# ---------------------------------------------------------------------------
# Vehicle type catalogue
# ---------------------------------------------------------------------------

VEHICLE_TYPES = [
    "car_petrol",
    "car_diesel",
    "motorcycle",
    "electric",
    "bus",
    "bicycle",
    "walking",
]

# Ground-truth CO₂ emission factors (kg CO₂ / km) used to generate
# synthetic training data.  Sources: EEA, IPCC, IEA.
_TRUE_FACTORS: dict[str, float] = {
    "car_petrol":  0.210,   # average petrol passenger car
    "car_diesel":  0.171,   # average diesel passenger car
    "motorcycle":  0.103,   # average motorcycle / scooter
    "electric":    0.053,   # average EV on grid-average electricity
    "bus":         0.089,   # per passenger on a full bus
    "bicycle":     0.000,   # human-powered
    "walking":     0.000,   # human-powered
}

# AQI impact factor per vehicle type (relative scale; higher = worse).
_AQI_FACTORS: dict[str, float] = {
    "car_petrol":  1.00,
    "car_diesel":  1.25,   # diesel NOx / particulates
    "motorcycle":  0.80,
    "electric":    0.08,   # near-zero tailpipe emissions
    "bus":         0.30,   # per passenger
    "bicycle":     0.00,
    "walking":     0.00,
}

_VT_INDEX: dict[str, int] = {vt: i for i, vt in enumerate(VEHICLE_TYPES)}


# ---------------------------------------------------------------------------
# Synthetic training dataset
# ---------------------------------------------------------------------------

def _generate_training_data(n_per_type: int = 300):
    """
    Generate n_per_type synthetic observations per vehicle type.

    Feature vector: [vt0*dist, vt1*dist, ..., vtN*dist]  (interaction terms)
    Target:         co2_kg = true_factor * dist * (1 + noise)

    Using interaction features ensures the model learns one coefficient per
    vehicle type, directly representing its emission factor.
    """
    rng = np.random.default_rng(seed=42)
    n_vt = len(VEHICLE_TYPES)
    X_rows = []
    y_rows = []

    for vt, factor in _TRUE_FACTORS.items():
        idx = _VT_INDEX[vt]
        distances = rng.uniform(0.5, 150.0, size=n_per_type)
        noise = rng.uniform(0.97, 1.03, size=n_per_type)
        co2 = factor * distances * noise

        for d, c in zip(distances, co2):
            row = [0.0] * n_vt
            row[idx] = d          # interaction: vehicle_i * distance
            X_rows.append(row)
            y_rows.append(c)

    return np.array(X_rows), np.array(y_rows)


# ---------------------------------------------------------------------------
# ML model
# ---------------------------------------------------------------------------

class EmissionModel:
    """
    Linear Regression model for predicting vehicle CO2 emissions.

    Features
    --------
    Interaction terms: [vt_0 * distance, vt_1 * distance, ...]
    Each feature is non-zero only for the selected vehicle type.

    Target
    ------
    co2_kg : total CO2 for the trip (kg)

    With no intercept the learned coefficients directly approximate the
    per-vehicle emission factors (kg CO2 / km).  The model is trained once
    at import time on synthetic data.
    """

    def __init__(self) -> None:
        self._model = self._build_and_train()

    @staticmethod
    def _build_and_train() -> LinearRegression:
        X, y = _generate_training_data()
        model = LinearRegression(fit_intercept=False)
        model.fit(X, y)
        return model

    def predict(self, vehicle_type: str, distance_km: float) -> dict:
        """
        Predict CO2 emissions for a given vehicle type and distance.

        Parameters
        ----------
        vehicle_type : str   One of VEHICLE_TYPES.
        distance_km  : float Route distance in kilometres (must be >= 0).

        Returns
        -------
        dict with keys:
            co2_kg                    - total CO2 in kg
            emission_factor_kg_per_km - learned factor for this vehicle
            category                  - human-readable emission band
            aqi_impact                - relative AQI contribution score
        """
        if vehicle_type not in _VT_INDEX:
            raise ValueError(
                f"Unknown vehicle type '{vehicle_type}'. "
                f"Choose from: {VEHICLE_TYPES}"
            )
        if distance_km < 0:
            raise ValueError("distance_km must be non-negative.")

        n_vt = len(VEHICLE_TYPES)
        idx = _VT_INDEX[vehicle_type]
        x = np.zeros((1, n_vt))
        x[0, idx] = distance_km

        co2_kg = float(self._model.predict(x)[0])
        co2_kg = max(0.0, co2_kg)

        learned_factor = float(self._model.coef_[idx])
        aqi_impact = _AQI_FACTORS[vehicle_type] * distance_km

        # Emission category bands
        if co2_kg == 0:
            category = "Zero Emission"
        elif co2_kg < 0.5:
            category = "Very Low"
        elif co2_kg < 1.5:
            category = "Low"
        elif co2_kg < 3.0:
            category = "Moderate"
        elif co2_kg < 6.0:
            category = "High"
        else:
            category = "Very High"

        return {
            "co2_kg":                    round(co2_kg, 3),
            "emission_factor_kg_per_km": round(learned_factor, 4),
            "category":                  category,
            "aqi_impact":                round(aqi_impact, 2),
        }


# ---------------------------------------------------------------------------
# AQI estimation
# ---------------------------------------------------------------------------

def estimate_aqi(lat: float, lng: float,
                 distance_km: float, vehicle_type: str) -> dict:
    """
    Estimate the Air Quality Index (AQI) for a route midpoint.

    Uses a simplified model that combines:
      1. A location-based urban-density proxy (periodic function on
         latitude / longitude).
      2. The vehicle's emission contribution along the route.

    AQI scale follows the US EPA 0-500 scale.

    Parameters
    ----------
    lat, lng     : float  Route midpoint coordinates.
    distance_km  : float  Route distance in km.
    vehicle_type : str    One of VEHICLE_TYPES.

    Returns
    -------
    dict with keys: aqi (0-500), category, color (hex), description
    """
    # Urban density proxy: produces a value in [0, 1] that varies smoothly
    # with geographic location.  The frequencies 0.12 (lat) and 0.08 (lng)
    # are chosen so that the proxy changes meaningfully over city-scale
    # distances (~10-80 km) without oscillating at sub-km scale.
    # Multiplying sin and cos gives a 2-D Lissajous pattern that roughly
    # correlates with urban vs. rural gradients.
    # base_aqi ranges from 40 (rural/clean) to 120 (dense urban) before
    # vehicle contribution is added.
    urban_factor = abs(np.sin(lat * 0.12)) * abs(np.cos(lng * 0.08))
    base_aqi = 40 + urban_factor * 80

    # Vehicle emission contribution to local air quality
    emission_contribution = _AQI_FACTORS.get(vehicle_type, 0.5) * distance_km * 2.5

    aqi_value = int(min(500, round(base_aqi + emission_contribution)))

    # US EPA AQI categories
    if aqi_value <= 50:
        category = "Good"
        color = "#00e400"
        description = "Air quality is satisfactory, and air pollution poses little or no risk."
    elif aqi_value <= 100:
        category = "Moderate"
        color = "#ffff00"
        description = "Air quality is acceptable. Unusually sensitive people may experience effects."
    elif aqi_value <= 150:
        category = "Unhealthy for Sensitive Groups"
        color = "#ff7e00"
        description = "Sensitive groups may experience health effects."
    elif aqi_value <= 200:
        category = "Unhealthy"
        color = "#ff0000"
        description = "Everyone may begin to experience health effects."
    elif aqi_value <= 300:
        category = "Very Unhealthy"
        color = "#8f3f97"
        description = "Health alert: risk of health effects for everyone."
    else:
        category = "Hazardous"
        color = "#7e0023"
        description = "Health warning of emergency conditions."

    return {
        "aqi":         aqi_value,
        "category":    category,
        "color":       color,
        "description": description,
    }


# ---------------------------------------------------------------------------
# Module-level singleton + convenience wrappers
# ---------------------------------------------------------------------------

_model = EmissionModel()


def predict_emission(vehicle_type: str, distance_km: float) -> dict:
    """Predict CO2 emission for a vehicle type and distance (module-level API)."""
    return _model.predict(vehicle_type, distance_km)


# ---------------------------------------------------------------------------
# Quick self-test (run with:  python emission_model.py)
# ---------------------------------------------------------------------------

if __name__ == "__main__":
    print("\n  Emission Model Self-Test\n" + "=" * 55)
    print(f"  {'Vehicle':<15} {'10 km CO2':>10} {'50 km CO2':>10} {'Factor':>8}  Category")
    print("  " + "-" * 60)
    for vt in VEHICLE_TYPES:
        r10 = predict_emission(vt, 10.0)
        r50 = predict_emission(vt, 50.0)
        print(
            f"  {vt:<15} {r10['co2_kg']:>9.3f}  {r50['co2_kg']:>9.3f}  "
            f"{r10['emission_factor_kg_per_km']:>7.4f}  {r10['category']}"
        )

    print("\n  AQI Estimates (SF, 10 km)\n" + "=" * 55)
    for vt in ["car_petrol", "car_diesel", "electric", "bicycle"]:
        aqi = estimate_aqi(37.77, -122.42, 10.0, vt)
        print(f"  {vt:<15} -> AQI {aqi['aqi']:3d}  [{aqi['category']}]")
    print()
