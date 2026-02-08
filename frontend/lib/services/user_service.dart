import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'storage_service.dart';

class UserService {
  // Get all users with optional filters
  static Future<Map<String, dynamic>> getUsers({
    String? role,
    String? status,
    String? verified,
    String? search,
  }) async {
    try {
      final token = await StorageService.getToken();
      
      // Build query parameters
      final queryParams = <String, String>{};
      if (role != null) queryParams['role'] = role;
      if (status != null) queryParams['status'] = status;
      if (verified != null) queryParams['verified'] = verified;
      if (search != null) queryParams['search'] = search;
      
      final uri = Uri.parse(ApiConfig.usersUrl).replace(
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch users: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to fetch users: $e'
      };
    }
  }

  // Get available drivers (for riders to see)
  static Future<Map<String, dynamic>> getAvailableDrivers() async {
    try {
      final token = await StorageService.getToken();
      
      final response = await http.get(
        Uri.parse('${ApiConfig.usersUrl}?role=Driver&status=Active'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        
        // Filter drivers who are available, verified, and have completed profile
        if (result['success'] == true && result['data'] != null) {
          final List<dynamic> allDrivers = result['data'];
          final availableDrivers = allDrivers.where((driver) {
            // Check if driver is available
            final isAvailable = driver['available'] == true;
            
            // Check if driver's documents are verified
            final isVerified = driver['verification_status'] == 'Verified';
            
            // Check if profile is 100% complete
            final profileComplete = driver['profile_setup_complete'] == true;
            
            return isAvailable && isVerified && profileComplete;
          }).toList();
          
          return {
            'success': true,
            'data': availableDrivers,
            'count': availableDrivers.length,
          };
        }
        
        return result;
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch available drivers: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to fetch available drivers: $e'
      };
    }
  }

  // Get user by ID
  static Future<Map<String, dynamic>> getUserById(int userId) async {
    try {
      final token = await StorageService.getToken();

      final response = await http.get(
        Uri.parse('${ApiConfig.usersUrl}/$userId'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch user: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to fetch user: $e'
      };
    }
  }

  // Get user statistics
  static Future<Map<String, dynamic>> getUserStats() async {
    try {
      final token = await StorageService.getToken();

      final response = await http.get(
        Uri.parse('${ApiConfig.usersUrl}/stats'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch user stats: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to fetch user stats: $e'
      };
    }
  }

  // Update user availability (for drivers)
  static Future<Map<String, dynamic>> updateDriverAvailability({
    required int userId,
    required bool available,
  }) async {
    try {
      final token = await StorageService.getToken();

      final response = await http.put(
        Uri.parse('${ApiConfig.usersUrl}/$userId'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'available': available,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Failed to update availability: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to update availability: $e'
      };
    }
  }
}
