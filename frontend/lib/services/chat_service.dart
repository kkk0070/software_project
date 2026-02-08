import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'storage_service.dart';

class ChatService {
  static const String chatEndpoint = '/api/chat';

  // Get all conversations for the current user
  static Future<Map<String, dynamic>> getConversations() async {
    try {
      final token = await StorageService.getToken();
      final userId = await StorageService.getUserId();

      print(
        'ChatService.getConversations: userId=$userId, hasToken=${token != null}',
      );

      if (userId == null) {
        return {'success': false, 'message': 'User ID not found'};
      }

      final url =
          '${ApiConfig.baseUrl}$chatEndpoint/conversations?userId=$userId';
      print('ChatService.getConversations: Calling $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      print('ChatService.getConversations: statusCode=${response.statusCode}');
      print('ChatService.getConversations: body=${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'success': false,
          'message':
              'Failed to fetch conversations: ${response.statusCode}, Body: ${response.body}',
        };
      }
    } catch (e, stackTrace) {
      print('ChatService.getConversations: Exception=$e');
      print('ChatService.getConversations: StackTrace=$stackTrace');
      return {'success': false, 'message': 'Failed to fetch conversations: $e'};
    }
  }

  // Get or create a conversation between rider and driver
  static Future<Map<String, dynamic>> getOrCreateConversation({
    required int riderId,
    required int driverId,
    int? rideId,
  }) async {
    try {
      final token = await StorageService.getToken();

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}$chatEndpoint/conversations'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'riderId': riderId,
          'driverId': driverId,
          if (rideId != null) 'rideId': rideId,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Failed to create conversation: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Failed to create conversation: $e'};
    }
  }

  // Get messages for a conversation
  static Future<Map<String, dynamic>> getMessages({
    required int conversationId,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final token = await StorageService.getToken();

      final response = await http.get(
        Uri.parse(
          '${ApiConfig.baseUrl}$chatEndpoint/conversations/$conversationId/messages?limit=$limit&offset=$offset',
        ),
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
          'message': 'Failed to fetch messages: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Failed to fetch messages: $e'};
    }
  }

  // Send a message
  static Future<Map<String, dynamic>> sendMessage({
    required int conversationId,
    required int senderId,
    required int receiverId,
    required String message,
  }) async {
    try {
      final token = await StorageService.getToken();

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}$chatEndpoint/messages'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'conversationId': conversationId,
          'senderId': senderId,
          'receiverId': receiverId,
          'message': message,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Failed to send message: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Failed to send message: $e'};
    }
  }

  // Mark messages as read
  static Future<Map<String, dynamic>> markAsRead({
    required int conversationId,
    required int userId,
  }) async {
    try {
      final token = await StorageService.getToken();

      final response = await http.put(
        Uri.parse(
          '${ApiConfig.baseUrl}$chatEndpoint/conversations/$conversationId/read',
        ),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode({'userId': userId}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Failed to mark messages as read: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to mark messages as read: $e',
      };
    }
  }

  // Get unread message count
  static Future<Map<String, dynamic>> getUnreadCount() async {
    try {
      final token = await StorageService.getToken();
      final userId = await StorageService.getUserId();

      if (userId == null) {
        return {'success': false, 'message': 'User ID not found'};
      }

      final response = await http.get(
        Uri.parse(
          '${ApiConfig.baseUrl}$chatEndpoint/unread-count?userId=$userId',
        ),
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
          'message': 'Failed to fetch unread count: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Failed to fetch unread count: $e'};
    }
  }
}
