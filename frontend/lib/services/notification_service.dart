import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'storage_service.dart';

class NotificationService {
  static const String notificationEndpoint = '/api/notifications';
  
  // Get all notifications for the current user
  static Future<Map<String, dynamic>> getNotifications({
    String? type,
    String? category,
    String? read,
    int limit = 50,
  }) async {
    try {
      final token = await StorageService.getToken();
      final userId = await StorageService.getUserId();
      
      if (userId == null) {
        return {
          'success': false,
          'message': 'User ID not found'
        };
      }

      final queryParams = {
        'user_id': userId.toString(),
        'limit': limit.toString(),
      };
      
      if (type != null) queryParams['type'] = type;
      if (category != null) queryParams['category'] = category;
      if (read != null) queryParams['read'] = read;
      
      final uri = Uri.parse('${ApiConfig.baseUrl}$notificationEndpoint')
          .replace(queryParameters: queryParams);
      
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
          'message': 'Failed to fetch notifications: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to fetch notifications: $e'
      };
    }
  }

  // Get unread notification count
  static Future<int> getUnreadNotificationCount() async {
    try {
      final result = await getNotifications(read: 'false');
      
      if (result['success'] == true && result['data'] != null) {
        final List<dynamic> notifications = result['data'];
        return notifications.length;
      }
      return 0;
    } catch (e) {
      print('Error getting unread notification count: $e');
      return 0;
    }
  }

  // Mark notification as read
  static Future<Map<String, dynamic>> markAsRead(int notificationId) async {
    try {
      final token = await StorageService.getToken();

      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}$notificationEndpoint/$notificationId/read'),
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
          'message': 'Failed to mark notification as read: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to mark notification as read: $e'
      };
    }
  }

  // Delete notification
  static Future<Map<String, dynamic>> deleteNotification(int notificationId) async {
    try {
      final token = await StorageService.getToken();

      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}$notificationEndpoint/$notificationId'),
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
          'message': 'Failed to delete notification: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to delete notification: $e'
      };
    }
  }

  // Delete all notifications for current user
  static Future<Map<String, dynamic>> deleteAllNotifications() async {
    try {
      final token = await StorageService.getToken();
      final userId = await StorageService.getUserId();
      
      if (userId == null) {
        return {
          'success': false,
          'message': 'User ID not found'
        };
      }

      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}$notificationEndpoint/all?user_id=$userId'),
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
          'message': 'Failed to delete notifications: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to delete notifications: $e'
      };
    }
  }

  // Create notification
  static Future<Map<String, dynamic>> createNotification({
    required int userId,
    required String title,
    required String message,
    String? type,
    String? category,
  }) async {
    try {
      final token = await StorageService.getToken();

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}$notificationEndpoint'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'user_id': userId,
          'title': title,
          'message': message,
          if (type != null) 'type': type,
          if (category != null) 'category': category,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Failed to create notification: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to create notification: $e'
      };
    }
  }
}
