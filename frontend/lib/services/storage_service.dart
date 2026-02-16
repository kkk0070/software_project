import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _storage = FlutterSecureStorage();
  
  // Keys for storage
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';
  static const String _userNameKey = 'user_name';
  static const String _userRoleKey = 'user_role';
  static const String _themeModeKey = 'theme_mode';
  static const String _fcmTokenKey = 'fcm_token';
  
  // Save authentication token
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }
  
  // Get authentication token
  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }
  
  // Delete authentication token
  static Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }
  
  // Save FCM token
  static Future<void> saveFCMToken(String token) async {
    await _storage.write(key: _fcmTokenKey, value: token);
  }
  
  // Get FCM token
  static Future<String?> getFCMToken() async {
    return await _storage.read(key: _fcmTokenKey);
  }
  
  // Save user data
  static Future<void> saveUserData({
    required String userId,
    required String email,
    required String name,
    required String role,
  }) async {
    await _storage.write(key: _userIdKey, value: userId);
    await _storage.write(key: _userEmailKey, value: email);
    await _storage.write(key: _userNameKey, value: name);
    await _storage.write(key: _userRoleKey, value: role);
  }
  
  // Save user name
  static Future<void> saveUserName(String name) async {
    await _storage.write(key: _userNameKey, value: name);
  }
  
  // Get user data
  static Future<Map<String, String?>> getUserData() async {
    return {
      'userId': await _storage.read(key: _userIdKey),
      'email': await _storage.read(key: _userEmailKey),
      'name': await _storage.read(key: _userNameKey),
      'role': await _storage.read(key: _userRoleKey),
    };
  }
  
  // Get user ID
  static Future<int?> getUserId() async {
    final userId = await _storage.read(key: _userIdKey);
    return userId != null ? int.tryParse(userId) : null;
  }
  
  // Get user role
  static Future<String?> getUserRole() async {
    return await _storage.read(key: _userRoleKey);
  }
  
  // Clear all stored data
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
  
  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
  
  // Save theme mode preference
  static Future<void> saveThemeMode(String themeMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, themeMode);
  }
  
  // Get theme mode preference
  static Future<String?> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeModeKey);
  }
}
