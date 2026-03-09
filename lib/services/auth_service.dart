import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'api_config.dart';
import 'storage_service.dart';

class AuthService {
  /// Helper method to safely decode JSON responses
  /// Returns null if the response is not valid JSON (e.g., HTML error page)
  static dynamic _safeJsonDecode(http.Response response) {
    try {
      return jsonDecode(response.body);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to parse response as JSON: ${e.toString()}');
        print('Response status: ${response.statusCode}');
        print('Response body (first 200 chars): ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}');
      }
      
      // Check if response looks like HTML
      if (response.body.trim().startsWith('<')) {
        throw FormatException(
          'Server returned an HTML error page. Please ensure the backend server is running at ${ApiConfig.baseUrl}'
        );
      }
      
      throw FormatException('Invalid response from server: ${e.toString()}');
    }
  }

  // Login
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.authUrl}/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(ApiConfig.connectionTimeout);

      if (kDebugMode) {
        print('🔵 Login Response Status: ${response.statusCode}');
      }

      final data = _safeJsonDecode(response);

      if (response.statusCode == 200 && data['success'] == true) {
        // Check if 2FA is required
        if (data['requires2FA'] == true) {
          return {
            'success': true,
            'requires2FA': true,
            'message': data['message'] ?? 'OTP sent to your email',
            'email': data['data']['email'],
            'userId': data['data']['userId'],
          };
        }
        
        // Save token and user data
        final token = data['data']['token'];
        final user = data['data']['user'];
        
        await StorageService.saveToken(token);
        await StorageService.saveUserData(
          userId: user['id'].toString(),
          email: user['email'],
          name: user['name'],
          role: user['role'],
        );

        return {
          'success': true,
          'message': data['message'] ?? 'Login successful',
          'user': user,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Login failed',
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Login error: ${e.toString()}');
      }
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Verify login OTP (for 2FA during login)
  static Future<Map<String, dynamic>> verifyLoginOTP({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.authUrl}/verify-login-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'otp': otp,
        }),
      ).timeout(ApiConfig.connectionTimeout);

      if (kDebugMode) {
        print('🔵 Verify Login OTP Response Status: ${response.statusCode}');
      }

      final data = _safeJsonDecode(response);

      if (response.statusCode == 200 && data['success'] == true) {
        // Save token and user data
        final token = data['data']['token'];
        final user = data['data']['user'];
        
        await StorageService.saveToken(token);
        await StorageService.saveUserData(
          userId: user['id'].toString(),
          email: user['email'],
          name: user['name'],
          role: user['role'],
        );

        return {
          'success': true,
          'message': data['message'] ?? 'Login successful',
          'user': user,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'OTP verification failed',
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Verify login OTP error: ${e.toString()}');
      }
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Signup
  static Future<Map<String, dynamic>> signup({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? location,
    required String role,
    String? vehicleType,
    String? vehicleModel,
    String? licensePlate,
    String? licenseNumber,
    String? vehicleYear,
  }) async {
    try {
      if (kDebugMode) {
        print('🔵 Signup Request - Role: $role, Name: $name');
      }
      
      final body = {
        'name': name,
        'email': email,
        'password': password,
        'role': role,
      };

      if (phone != null) body['phone'] = phone;
      if (location != null) body['location'] = location;
      
      // Add driver-specific fields if role is Driver
      if (role?.toLowerCase() == 'driver') {
        if (vehicleType != null) body['vehicle_type'] = vehicleType;
        if (vehicleModel != null) body['vehicle_model'] = vehicleModel;
        if (licensePlate != null) body['license_plate'] = licensePlate;
        if (licenseNumber != null) body['license_number'] = licenseNumber;
        if (vehicleYear != null) body['vehicle_year'] = vehicleYear;
      }

      if (kDebugMode) {
        print('🔵 Signup URL: ${ApiConfig.authUrl}/signup');
        // Only log non-sensitive fields
        print('🔵 Signup Body: {name: $name, email: ${email.substring(0, 3)}***, role: $role}');
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.authUrl}/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ).timeout(ApiConfig.connectionTimeout);

      if (kDebugMode) {
        print('🔵 Signup Response Status: ${response.statusCode}');
      }

      final data = _safeJsonDecode(response);

      if (response.statusCode == 201 && data['success'] == true) {
        // Save token and user data
        final token = data['data']['token'];
        final user = data['data']['user'];
        
        await StorageService.saveToken(token);
        await StorageService.saveUserData(
          userId: user['id'].toString(),
          email: user['email'],
          name: user['name'],
          role: user['role'],
        );

        if (kDebugMode) {
          print('✅ Signup successful - User Role: ${user['role']}');
        }

        return {
          'success': true,
          'message': data['message'] ?? 'Signup successful',
          'user': user,
        };
      } else {
        if (kDebugMode) {
          print('❌ Signup failed: ${data['message']}');
        }
        return {
          'success': false,
          'message': data['message'] ?? 'Signup failed',
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Signup error: ${e.toString()}');
      }
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Get user profile
  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final token = await StorageService.getToken();
      
      if (token == null) {
        return {
          'success': false,
          'message': 'No authentication token found',
        };
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.authUrl}/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(ApiConfig.connectionTimeout);

      final data = _safeJsonDecode(response);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'user': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to fetch profile',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Complete profile setup
  static Future<Map<String, dynamic>> completeProfileSetup() async {
    try {
      final token = await StorageService.getToken();
      
      if (token == null) {
        return {
          'success': false,
          'message': 'No authentication token found',
        };
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.authUrl}/complete-setup'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(ApiConfig.connectionTimeout);

      final data = _safeJsonDecode(response);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'] ?? 'Profile setup completed',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to complete setup',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Logout
  static Future<void> logout() async {
    await StorageService.clearAll();
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    return await StorageService.isLoggedIn();
  }

  // Get 2FA status
  static Future<Map<String, dynamic>> get2FAStatus() async {
    try {
      final token = await StorageService.getToken();
      
      if (token == null) {
        return {
          'success': false,
          'message': 'No authentication token found',
        };
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.authUrl}/2fa/status'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(ApiConfig.connectionTimeout);

      final data = _safeJsonDecode(response);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'two_factor_enabled': data['data']['two_factor_enabled'] ?? false,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to fetch 2FA status',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Request OTP for 2FA
  static Future<Map<String, dynamic>> request2FAOTP() async {
    try {
      final token = await StorageService.getToken();
      
      if (token == null) {
        return {
          'success': false,
          'message': 'No authentication token found',
        };
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.authUrl}/2fa/request-otp'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(ApiConfig.connectionTimeout);

      final data = _safeJsonDecode(response);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'] ?? 'OTP sent successfully',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to send OTP',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Enable 2FA
  static Future<Map<String, dynamic>> enable2FA({required String otp}) async {
    try {
      final token = await StorageService.getToken();
      
      if (token == null) {
        return {
          'success': false,
          'message': 'No authentication token found',
        };
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.authUrl}/2fa/enable'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'otp': otp}),
      ).timeout(ApiConfig.connectionTimeout);

      final data = _safeJsonDecode(response);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'] ?? '2FA enabled successfully',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to enable 2FA',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Disable 2FA
  static Future<Map<String, dynamic>> disable2FA({required String password}) async {
    try {
      final token = await StorageService.getToken();
      
      if (token == null) {
        return {
          'success': false,
          'message': 'No authentication token found',
        };
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.authUrl}/2fa/disable'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'password': password}),
      ).timeout(ApiConfig.connectionTimeout);

      final data = _safeJsonDecode(response);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'] ?? '2FA disabled successfully',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to disable 2FA',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Update user profile
  static Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? phone,
    String? location,
  }) async {
    try {
      final token = await StorageService.getToken();
      
      if (token == null) {
        return {
          'success': false,
          'message': 'No authentication token found',
        };
      }

      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (phone != null) body['phone'] = phone;
      if (location != null) body['location'] = location;

      final response = await http.put(
        Uri.parse('${ApiConfig.authUrl}/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      ).timeout(ApiConfig.connectionTimeout);

      final data = _safeJsonDecode(response);

      if (response.statusCode == 200 && data['success'] == true) {
        // Update local storage
        if (name != null) await StorageService.saveUserName(name);
        
        return {
          'success': true,
          'message': data['message'] ?? 'Profile updated successfully',
          'user': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to update profile',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Upload profile photo
  static Future<Map<String, dynamic>> uploadProfilePhoto(String filePath) async {
    try {
      final token = await StorageService.getToken();
      
      if (token == null) {
        return {
          'success': false,
          'message': 'No authentication token found',
        };
      }

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.authUrl}/upload-photo'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath('photo', filePath));

      final streamedResponse = await request.send().timeout(ApiConfig.connectionTimeout);
      final response = await http.Response.fromStream(streamedResponse);

      final data = _safeJsonDecode(response);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'] ?? 'Profile photo uploaded successfully',
          'user': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to upload photo',
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Photo upload error: ${e.toString()}');
      }
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Upload profile photo from bytes (for web)
  static Future<Map<String, dynamic>> uploadProfilePhotoFromBytes(
    List<int> bytes,
    String filename,
  ) async {
    try {
      final token = await StorageService.getToken();
      
      if (token == null) {
        return {
          'success': false,
          'message': 'No authentication token found',
        };
      }

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.authUrl}/upload-photo'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(http.MultipartFile.fromBytes(
        'photo',
        bytes,
        filename: filename,
      ));

      final streamedResponse = await request.send().timeout(ApiConfig.connectionTimeout);
      final response = await http.Response.fromStream(streamedResponse);

      final data = _safeJsonDecode(response);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'] ?? 'Profile photo uploaded successfully',
          'user': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to upload photo',
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Photo upload error: ${e.toString()}');
      }
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }
}
