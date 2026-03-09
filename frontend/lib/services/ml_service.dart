import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class MLService {
  /// Get place suggestions for autocomplete
  static Future<List<String>> getAutocompleteSuggestions(String input) async {
    if (input.length < 3) return [];
    
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.mlAutocompleteUrl}?input=$input'),
      ).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final predictions = data['predictions'] as List;
        return predictions.map((p) => p['description'] as String).toList();
      }
    } catch (e) {
      print('Autocomplete error: $e');
    }
    return [];
  }

  /// Get coordinates for a selected address
  static Future<Map<String, double>?> geocodeAddress(String address) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.mlGeocodeUrl}?address=$address'),
      ).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'lat': (data['lat'] as num).toDouble(),
          'lng': (data['lng'] as num).toDouble(),
        };
      }
    } catch (e) {
      print('Geocoding error: $e');
    }
    return null;
  }

  /// Predict fare based on multiple conditions
  static Future<Map<String, dynamic>> predictFare({
    required double distanceKm,
    String weather = 'Clear',
    String traffic = 'Low',
    String time = 'Off-Peak',
    double co2Kg = 0.0,
    String vehicleType = 'car_petrol',
  }) async {
    try {
      final url = '${ApiConfig.mlFareUrl}?distance_km=$distanceKm&weather=$weather&traffic=$traffic&time=$time&co2_kg=$co2Kg&vehicle_type=$vehicleType';
      final response = await http.get(
        Uri.parse(url),
      ).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('Fare prediction error: $e');
    }
    return {'success': false, 'error': 'Could not calculate fare'};
  }

  /// Get route data including distance and coordinates
  static Future<Map<String, dynamic>> getRoute({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  }) async {
    try {
      final url = '${ApiConfig.mlRouteUrl}?origin_lat=$originLat&origin_lng=$originLng&dest_lat=$destLat&dest_lng=$destLng';
      final response = await http.get(
        Uri.parse(url),
      ).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('Routing error: $e');
    }
    return {'success': false, 'error': 'Could not calculate route'};
  }
}
