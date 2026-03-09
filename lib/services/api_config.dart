import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
// Conditional import to avoid dart:io on web
import 'dart:io' show Platform if (dart.library.html) 'dart:html';

class ApiConfig {
  // Base URL for the backend API
  // Automatically detects platform and uses the appropriate URL:
  // - Web: http://localhost:5000
  // - Android Emulator: http://10.0.2.2:5000
  // - iOS Simulator: http://localhost:5000
  // - Physical Device: http://localhost:5000 (update to your computer's IP if needed)
  //
  // Make sure the backend server is running before using the app!
  static String get baseUrl {
    if (kIsWeb) {
      // Flutter Web - use localhost
      return 'http://localhost:5000';
    } else {
      // Mobile platforms
      try {
        if (Platform.isAndroid) {
          // Android emulator - use 10.0.2.2 to access host machine
          return 'http://10.0.2.2:5000';
        } else {
          // iOS simulator or physical device - use localhost
          // For physical devices, you may need to change this to your computer's IP
          return 'http://localhost:5000';
        }
      } catch (e) {
        // Fallback to localhost if platform detection fails
        if (kDebugMode) {
          print('Platform detection error: $e. Using localhost.');
        }
        return 'http://localhost:5000';
      }
    }
  }
  
  // API endpoints
  static const String authEndpoint = '/api/auth';
  static const String documentsEndpoint = '/api/documents';
  static const String usersEndpoint = '/api/users';
  static const String ridesEndpoint = '/api/rides';
  static const String emergencyEndpoint = '/api/emergency';
  
  // Full URLs
  static String get authUrl => '$baseUrl$authEndpoint';
  static String get documentsUrl => '$baseUrl$documentsEndpoint';
  static String get usersUrl => '$baseUrl$usersEndpoint';
  static String get ridesUrl => '$baseUrl$ridesEndpoint';
  static String get emergencyUrl => '$baseUrl$emergencyEndpoint';
  
  // Timeout durations
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
