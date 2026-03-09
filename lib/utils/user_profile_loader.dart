import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

/// Mixin to provide user profile loading functionality to screens
/// 
/// Usage:
/// ```dart
/// class MyScreen extends StatefulWidget {
///   // ...
/// }
/// 
/// class _MyScreenState extends State<MyScreen> with UserProfileLoader {
///   @override
///   void initState() {
///     super.initState();
///     loadUserProfile();
///   }
/// 
///   @override
///   Widget build(BuildContext context) {
///     if (isLoadingProfile) {
///       return CircularProgressIndicator();
///     }
///     return Text(userName ?? 'Unknown');
///   }
/// }
/// ```
mixin UserProfileLoader<T extends StatefulWidget> on State<T> {
  Map<String, dynamic>? _userData;
  bool _isLoadingProfile = true;

  /// Whether user profile is currently being loaded
  bool get isLoadingProfile => _isLoadingProfile;

  /// Current user data
  Map<String, dynamic>? get userData => _userData;

  /// Convenience getters for common fields
  String? get userName => _userData?['name'];
  String? get userEmail => _userData?['email'];
  String? get userRole => _userData?['role'];
  String? get userPhone => _userData?['phone'];
  String? get userLocation => _userData?['location'];
  String? get userProfilePhoto => _userData?['profile_photo'];
  bool get profileSetupComplete => _userData?['profile_setup_complete'] ?? false;

  /// Map user data from API response to internal format
  Map<String, dynamic> _mapUserData(Map<String, dynamic> user) {
    return {
      'name': user['name'],
      'email': user['email'],
      'role': user['role'],
      'phone': user['phone'],
      'location': user['location'],
      'profile_photo': user['profile_photo'],
      'profile_setup_complete': user['profile_setup_complete'] ?? false,
    };
  }

  /// Load user profile from storage and backend
  /// 
  /// This method:
  /// 1. First loads cached data from StorageService (fast)
  /// 2. Then fetches fresh data from backend via AuthService
  /// 3. Updates state automatically
  /// 
  /// Call this in initState():
  /// ```dart
  /// @override
  /// void initState() {
  ///   super.initState();
  ///   loadUserProfile();
  /// }
  /// ```
  Future<void> loadUserProfile() async {
    try {
      // First try to load from storage (faster)
      final storedData = await StorageService.getUserData();
      if (storedData['name'] != null && mounted) {
        setState(() {
          _userData = storedData;
          _isLoadingProfile = false;
        });
      }

      // Then fetch fresh data from backend
      final result = await AuthService.getProfile();
      if (result['success'] == true && result['user'] != null && mounted) {
        setState(() {
          _userData = _mapUserData(result['user']);
          _isLoadingProfile = false;
        });
      } else if (_userData == null && mounted) {
        // If backend fails and no storage data, still stop loading
        setState(() {
          _isLoadingProfile = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingProfile = false;
        });
      }
    }
  }

  /// Refresh user profile from backend
  /// 
  /// Similar to loadUserProfile but skips loading from storage
  /// and always fetches fresh data from backend.
  Future<void> refreshUserProfile() async {
    if (mounted) {
      setState(() {
        _isLoadingProfile = true;
      });
    }

    try {
      final result = await AuthService.getProfile();
      if (result['success'] == true && result['user'] != null && mounted) {
        setState(() {
          _userData = _mapUserData(result['user']);
          _isLoadingProfile = false;
        });
      } else if (mounted) {
        setState(() {
          _isLoadingProfile = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingProfile = false;
        });
      }
    }
  }
}
