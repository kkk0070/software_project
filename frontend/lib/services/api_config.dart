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
    // Check for dart-define override (useful for CI/CD deployment)
    const String envUrl = String.fromEnvironment('BACKEND_URL');
    if (envUrl.isNotEmpty) return envUrl;

    if (kIsWeb) {
      // Flutter Web - pointing to Vercel Prod server
      return 'https://backend-two-sigma-39.vercel.app';
    } else {
      // Mobile platforms
      try {
        if (Platform.isAndroid) {
          // Android emulator
          return 'https://backend-two-sigma-39.vercel.app';
        } else {
          // iOS simulator or physical device
          return 'https://backend-two-sigma-39.vercel.app';
        }
      } catch (e) {
        // Fallback
        if (kDebugMode) {
          print('Platform detection error: $e. Using local IP.');
        }
        return 'https://backend-two-sigma-39.vercel.app';
      }
    }
  }
  // API endpoints
  static const String authEndpoint = '/api/auth';
  static const String documentsEndpoint = '/api/documents';
  static const String usersEndpoint = '/api/users';
  static const String ridesEndpoint = '/api/rides';
  static const String carpoolsEndpoint = '/api/carpools';
  static const String emergencyEndpoint = '/api/emergency';
  static const String mapsEndpoint = '/api/maps';
  
  // Full URLs
  static String get authUrl => '$baseUrl$authEndpoint';
  static String get documentsUrl => '$baseUrl$documentsEndpoint';
  static String get usersUrl => '$baseUrl$usersEndpoint';
  static String get ridesUrl => '$baseUrl$ridesEndpoint';
  static String get carpoolsUrl => '$baseUrl$carpoolsEndpoint';
  static String get emergencyUrl => '$baseUrl$emergencyEndpoint';
  static String get mapsUrl => '$baseUrl$mapsEndpoint';

  // ML Service (OSMx + ML Models)
  static String get mlBaseUrl {
    // 1. Check for dart-define override (set during CI/CD build for production)
    const String envMlUrl = String.fromEnvironment('ML_URL');
    if (envMlUrl.isNotEmpty) return envMlUrl;

    // 2. Production/Fallback
    if (kIsWeb) return 'https://ecoride-ml.onrender.com';
    try {
      if (Platform.isAndroid) return 'https://ecoride-ml.onrender.com';
    } catch (_) {}
    return 'https://ecoride-ml.onrender.com';
  }

  static String get mlRouteUrl => '$mlBaseUrl/route';
  static String get mlAllRoutesUrl => '$mlBaseUrl/all_routes';
  static String get mlFareUrl => '$mlBaseUrl/fare';
  static String get mlEmissionUrl => '$mlBaseUrl/emission';
  static String get mlAutocompleteUrl => '$mlBaseUrl/autocomplete';
  static String get mlGeocodeUrl => '$mlBaseUrl/geocode';
  
  // Timeout durations
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
