#!/usr/bin/env python3
"""
Fare Prediction ML Model
========================

Predicts the trip fare based on:
- Distance (km)
- Weather condition (Clear, Rainy, Snowy, Stormy)
- Traffic level (Low, Medium, High)
- Time of Day (Peak, Off-Peak, Night)
- Vehicle Type (Standard Car, Bike, Auto, etc.)

The model uses a RandomForestRegressor approach trained on synthetic data
reflecting real-world pricing dynamics in India.
"""

import numpy as np
from sklearn.ensemble import RandomForestRegressor

# ---------------------------------------------------------------------------
# Constants & Enums
# ---------------------------------------------------------------------------

WEATHER_CONDITIONS = ["Clear", "Rainy", "Snowy", "Stormy"]
TRAFFIC_LEVELS = ["Low", "Medium", "High"]
TIME_OF_DAY = ["Off-Peak", "Peak", "Night"]

# Base rates in Rupees (INR)
# User requested 33 per km, no base fare mentioned
BASE_FARE = 0.00  
VEHICLE_RATES = {
    "car_petrol": 33.0,
    "car_diesel": 33.0,
    "motorcycle": 12.0,
    "auto":       22.0,
    "comfort":    38.0,
    "premium":    50.0,
    "electric":   28.0,
    "bus":        5.0,
    "bicycle":    0.0,
    "walking":    0.0
}

# ---------------------------------------------------------------------------
# Synthetic training dataset
# ---------------------------------------------------------------------------

def _generate_training_data(n_samples: int = 300):
    rng = np.random.default_rng(seed=42)
    v_types = list(VEHICLE_RATES.keys())
    
    # Random distributions
    distances = rng.uniform(1.0, 50.0, size=n_samples)
    weather_idx = rng.integers(0, len(WEATHER_CONDITIONS), size=n_samples)
    traffic_idx = rng.integers(0, len(TRAFFIC_LEVELS), size=n_samples)
    time_idx = rng.integers(0, len(TIME_OF_DAY), size=n_samples)
    v_idx = rng.integers(0, len(v_types), size=n_samples)
    
    fares = []
    X = []
    
    for i in range(n_samples):
        vt = v_types[v_idx[i]]
        rate = VEHICLE_RATES[vt]
        dist = distances[i]
        
        # Ground truth calculation: pure distance * rate
        fare = dist * rate
        
        # Weather impact
        if WEATHER_CONDITIONS[weather_idx[i]] == "Rainy":
            fare *= 1.2
        elif WEATHER_CONDITIONS[weather_idx[i]] in ["Snowy", "Stormy"]:
            fare *= 1.5
            
        # Traffic impact
        if TRAFFIC_LEVELS[traffic_idx[i]] == "Medium":
            fare *= 1.15
        elif TRAFFIC_LEVELS[traffic_idx[i]] == "High":
            fare *= 1.4
            
        # Peak time impact
        if TIME_OF_DAY[time_idx[i]] == "Peak":
            fare *= 1.3
            
        fares.append(fare)
        
        # Features: dist, weather_idx, traffic_idx, time_idx, v_idx
        X.append([dist, weather_idx[i], traffic_idx[i], time_idx[i], v_idx[i]])
        
    return np.array(X), np.array(fares)

# ---------------------------------------------------------------------------
# ML model
# ---------------------------------------------------------------------------

class FareModel:
    def __init__(self) -> None:
        self.v_types = list(VEHICLE_RATES.keys())
        self._model = self._build_and_train()

    def _build_and_train(self) -> RandomForestRegressor:
        X, y = _generate_training_data()
        # Lighter RandomForest for low-RAM hosting
        model = RandomForestRegressor(n_estimators=10, random_state=42)
        model.fit(X, y)
        return model

    def predict(self, distance_km: float, weather: str, traffic: str, 
                time_of_day: str, vehicle_type: str) -> dict:
        
        # Safely map to internal indices
        w_i = WEATHER_CONDITIONS.index(weather) if weather in WEATHER_CONDITIONS else 0
        tr_i = TRAFFIC_LEVELS.index(traffic) if traffic in TRAFFIC_LEVELS else 0
        t_i = TIME_OF_DAY.index(time_of_day) if time_of_day in TIME_OF_DAY else 0
        v_i = self.v_types.index(vehicle_type) if vehicle_type in self.v_types else 0
        
        X_input = [[distance_km, w_i, tr_i, t_i, v_i]]
        fare = float(self._model.predict(X_input)[0])
        
        # Absolute zero for non-motorized
        if VEHICLE_RATES[vehicle_type] == 0:
            fare = 0.0
            
        fare = max(0.0 if VEHICLE_RATES[vehicle_type] == 0 else BASE_FARE, fare)
        
        # Components breakdown (approximated for UI)
        rate = VEHICLE_RATES[vehicle_type]
        base_component = (BASE_FARE + (distance_km * rate)) if rate > 0 else 0.0
        surge_multiplier = fare / base_component if base_component > 1 else 1.0
        if fare <= 0: surge_multiplier = 0.0
        
        return {
            "estimated_fare": round(fare, 2),
            "currency": "INR",
            "breakdown": {
                "base_price": round(base_component, 2),
                "surge_multiplier": round(surge_multiplier, 2),
                "factors": {
                    "weather": weather,
                    "traffic": traffic,
                    "time": time_of_day,
                    "vehicle": vehicle_type
                }
            }
        }

# Singleton
_fare_model = None

def _get_model():
    global _fare_model
    if _fare_model is None:
        _fare_model = FareModel()
    return _fare_model

def predict_fare(distance_km: float, weather: str, traffic: str, time: str, co2_kg: float = 0.0, vehicle_type: str = "car_petrol") -> dict:
    return _get_model().predict(distance_km, weather, traffic, time, vehicle_type)

if __name__ == "__main__":
    print("Fare Model Test (Car @ 33/km):")
    res = predict_fare(10.0, "Clear", "Low", "Off-Peak", vehicle_type="car_petrol")
    print(res)
    print("\nFare Model Test (Bike @ 12/km):")
    res = predict_fare(10.0, "Clear", "Low", "Off-Peak", vehicle_type="motorcycle")
    print(res)
