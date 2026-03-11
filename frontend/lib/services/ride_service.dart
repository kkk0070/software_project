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
    int? passengerCount,
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
          if (passengerCount != null) 'passenger_count': passengerCount,
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

  /// Driver arrives at pickup
  static Future<Map<String, dynamic>> arriveAtPickup(int rideId) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.ridesUrl}/$rideId/arrive'),
        headers: await _authHeaders(),
      ).timeout(ApiConfig.connectionTimeout);

      return jsonDecode(response.body);
    } catch (e) {
      if (kDebugMode) print('[ERROR] arriveAtPickup: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// Verify OTP and start trip
  static Future<Map<String, dynamic>> verifyOtp(int rideId, String otp) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.ridesUrl}/$rideId/verify-otp'),
        headers: await _authHeaders(),
        body: jsonEncode({'otp': otp}),
      ).timeout(ApiConfig.connectionTimeout);

      return jsonDecode(response.body);
    } catch (e) {
      if (kDebugMode) print('[ERROR] verifyOtp: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// Driver arrives at pickup
  static Future<Map<String, dynamic>> arriveAtPickup(int rideId) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.ridesUrl}/$rideId/arrive'),
        headers: await _authHeaders(),
      ).timeout(ApiConfig.connectionTimeout);

      return jsonDecode(response.body);
    } catch (e) {
      if (kDebugMode) print('[ERROR] arriveAtPickup: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// Driver completes a ride
  static Future<Map<String, dynamic>> completeRide(int rideId) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.ridesUrl}/$rideId/complete'),
        headers: await _authHeaders(),
      ).timeout(ApiConfig.connectionTimeout);

      return jsonDecode(response.body);
    } catch (e) {
      if (kDebugMode) print('[ERROR] completeRide: $e');
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
    String? status,
  }) async {
    return getRides(
      riderId: riderId,
      driverId: driverId,
      status: status,
    );
  }

  // CARPOOL METHODS

  static Future<Map<String, dynamic>> getAvailableCarpools() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.carpoolsUrl}/available'),
        headers: await _authHeaders(),
      ).timeout(ApiConfig.connectionTimeout);

      return jsonDecode(response.body);
    } catch (e) {
      if (kDebugMode) print('[ERROR] getAvailableCarpools: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> createCarpool({
    required int creatorId,
    required String pickupLocation,
    required String dropoffLocation,
    required String scheduledTime,
    required double fare,
    required int maxParticipants,
    String? vehicleType,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.carpoolsUrl}/create'),
        headers: await _authHeaders(),
        body: jsonEncode({
          'creator_id': creatorId,
          'pickup_location': pickupLocation,
          'dropoff_location': dropoffLocation,
          'pickup': pickupLocation,
          'dropoff': dropoffLocation,
          'scheduled_time': scheduledTime,
          'fare': fare,
          'max_participants': maxParticipants,
          if (vehicleType != null) 'vehicleType': vehicleType,
        }),
      ).timeout(ApiConfig.connectionTimeout);

      return jsonDecode(response.body);
    } catch (e) {
      if (kDebugMode) print('[ERROR] createCarpool: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> acceptCarpool({
    required int carpoolId,
    required int participantId,
    Map<String, double>? userLocation,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.carpoolsUrl}/accept'),
        headers: await _authHeaders(),
        body: jsonEncode({
          'carpoolId': carpoolId,
          'userId': participantId,
          'location': userLocation,
        }),
      ).timeout(ApiConfig.connectionTimeout);

      final result = jsonDecode(response.body);
      if (result['success'] == true) {
        return {'success': true, 'user_otp': result['otp']};
      }
      return result;
    } catch (e) {
      return {'success': false, 'message': 'Network error'};
    }
  }

  static Future<Map<String, dynamic>> getCarpoolHistory() async {
    try {
      final userId = await StorageService.getUserId();
      final response = await http.get(
        Uri.parse('${ApiConfig.carpoolsUrl}/history?userId=$userId'),
        headers: await _authHeaders(),
      ).timeout(ApiConfig.connectionTimeout);

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error'};
    }
  }

  static Future<Map<String, dynamic>> getCarpoolDetails(int carpoolId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.carpoolsUrl}/$carpoolId'),
        headers: await _authHeaders(),
      ).timeout(ApiConfig.connectionTimeout);

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error'};
    }
  }

  static Future<Map<String, dynamic>> deleteCarpool(int carpoolId) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.carpoolsUrl}/$carpoolId'),
        headers: await _authHeaders(),
      ).timeout(ApiConfig.connectionTimeout);

      return jsonDecode(response.body);
    } catch (e) {
      if (kDebugMode) print('[ERROR] deleteCarpool: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Maps
  static Future<Map<String, dynamic>> saveDownloadedMap({
    required String pickup,
    required String dropoff,
    required String encodedPolyline,
  }) async {
    try {
      final userId = await StorageService.getUserId();
      final body = jsonEncode({
        'userId': userId,
        'pickup': pickup,
        'dropoff': dropoff,
        'encodedPolyline': encodedPolyline,
      });

      final response = await http.post(
        Uri.parse('${ApiConfig.mapsUrl}/download'),
        headers: await _authHeaders(),
        body: body,
      ).timeout(ApiConfig.connectionTimeout);

      return jsonDecode(response.body);
    } catch (e) {
      if (kDebugMode) print('[ERROR] saveDownloadedMap: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getDownloadedMaps() async {
    try {
      final userId = await StorageService.getUserId();
      final response = await http.get(
        Uri.parse('${ApiConfig.mapsUrl}/downloaded?userId=$userId'),
        headers: await _authHeaders(),
      ).timeout(ApiConfig.connectionTimeout);

      return jsonDecode(response.body);
    } catch (e) {
      if (kDebugMode) print('[ERROR] getDownloadedMaps: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> deleteDownloadedMap(int mapId) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.mapsUrl}/downloaded/$mapId'),
        headers: await _authHeaders(),
      ).timeout(ApiConfig.connectionTimeout);

      return jsonDecode(response.body);
    } catch (e) {
      if (kDebugMode) print('[ERROR] deleteDownloadedMap: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
}
