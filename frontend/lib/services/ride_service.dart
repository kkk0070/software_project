import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'storage_service.dart';

/// Service for ride-related API operations
class RideService {
  static Future<Map<String, String>> _authHeaders() async {
    final token = await StorageService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Get rides with optional filters (driver_id, rider_id, status)
  static Future<Map<String, dynamic>> getRides({
    String? driverId,
    String? riderId,
    String? status,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (driverId != null) queryParams['driver_id'] = driverId;
      if (riderId != null) queryParams['rider_id'] = riderId;
      if (status != null) queryParams['status'] = status;

      final uri = Uri.parse(ApiConfig.ridesUrl).replace(
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      final response = await http.get(
        uri,
        headers: await _authHeaders(),
      ).timeout(ApiConfig.connectionTimeout);

      return jsonDecode(response.body);
    } catch (e) {
      if (kDebugMode) print('[ERROR] getRides: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// Create a new ride booking
  static Future<Map<String, dynamic>> createRide({
    required int riderId,
    required int driverId,
    required String pickupLocation,
    required String dropoffLocation,
    double? fare,
    String? rideType,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.ridesUrl),
        headers: await _authHeaders(),
        body: jsonEncode({
          'rider_id': riderId,
          'driver_id': driverId,
          'pickup_location': pickupLocation,
          'dropoff_location': dropoffLocation,
          if (fare != null) 'fare': fare,
          if (rideType != null) 'ride_type': rideType,
          'status': 'Pending',
        }),
      ).timeout(ApiConfig.connectionTimeout);

      return jsonDecode(response.body);
    } catch (e) {
      if (kDebugMode) print('[ERROR] createRide: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// Driver accepts a ride
  static Future<Map<String, dynamic>> acceptRide(int rideId) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.ridesUrl}/$rideId/accept'),
        headers: await _authHeaders(),
      ).timeout(ApiConfig.connectionTimeout);

      return jsonDecode(response.body);
    } catch (e) {
      if (kDebugMode) print('[ERROR] acceptRide: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// Driver rejects a ride
  static Future<Map<String, dynamic>> rejectRide(int rideId) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.ridesUrl}/$rideId/reject'),
        headers: await _authHeaders(),
      ).timeout(ApiConfig.connectionTimeout);

      return jsonDecode(response.body);
    } catch (e) {
      if (kDebugMode) print('[ERROR] rejectRide: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// Submit a rating for a completed ride
  static Future<Map<String, dynamic>> rateRide({
    required int rideId,
    required int rating,
    String? feedback,
    String? ratedBy,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.ridesUrl}/$rideId/rate'),
        headers: await _authHeaders(),
        body: jsonEncode({
          'rating': rating,
          if (feedback != null) 'feedback': feedback,
          if (ratedBy != null) 'rated_by': ratedBy,
        }),
      ).timeout(ApiConfig.connectionTimeout);

      return jsonDecode(response.body);
    } catch (e) {
      if (kDebugMode) print('[ERROR] rateRide: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// Get rides history for a rider or driver
  static Future<Map<String, dynamic>> getRidesHistory({
    String? riderId,
    String? driverId,
  }) async {
    return getRides(
      riderId: riderId,
      driverId: driverId,
      status: 'Completed',
    );
  }
}
