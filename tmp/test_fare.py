
import sys
import os
sys.path.append(os.path.join(os.getcwd(), 'ml'))
from fare_model import predict_fare

print("Testing Car @ 10km (Exp: ~370):")
print(predict_fare(10.0, "Clear", "Low", "Off-Peak", vehicle_type="car_petrol"))

print("\nTesting Bike @ 10km (Exp: ~160):")
print(predict_fare(10.0, "Clear", "Low", "Off-Peak", vehicle_type="motorcycle"))

print("\nTesting Premium @ 10km (Exp: ~540):")
print(predict_fare(10.0, "Clear", "Low", "Off-Peak", vehicle_type="premium"))
