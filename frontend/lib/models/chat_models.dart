class Message {
  final int id;
  final int conversationId;
  final int senderId;
  final int receiverId;
  final String message;
  final bool isRead;
  final DateTime createdAt;
  final String? senderName;
  final String? senderRole;

  Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.isRead,
    required this.createdAt,
    this.senderName,
    this.senderRole,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      conversationId: json['conversation_id'],
      senderId: json['sender_id'],
      receiverId: json['receiver_id'],
      message: json['message'],
      isRead: json['is_read'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      senderName: json['sender_name'],
      senderRole: json['sender_role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'message': message,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
      'sender_name': senderName,
      'sender_role': senderRole,
    };
  }
}

class Conversation {
  final int id;
  final int riderId;
  final int driverId;
  final int? rideId;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? otherUserName;
  final int? otherUserId;
  final String? otherUserRole;
  final int? unreadCount;

  Conversation({
    required this.id,
    required this.riderId,
    required this.driverId,
    this.rideId,
    this.lastMessage,
    this.lastMessageTime,
    required this.createdAt,
    required this.updatedAt,
    this.otherUserName,
    this.otherUserId,
    this.otherUserRole,
    this.unreadCount,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'],
      riderId: json['rider_id'],
      driverId: json['driver_id'],
      rideId: json['ride_id'],
      lastMessage: json['last_message'],
      lastMessageTime: json['last_message_time'] != null
          ? DateTime.parse(json['last_message_time'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      otherUserName: json['other_user_name'],
      otherUserId: json['other_user_id'],
      otherUserRole: json['other_user_role'],
      unreadCount: json['unread_count'] is String 
          ? int.tryParse(json['unread_count']) ?? 0
          : json['unread_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rider_id': riderId,
      'driver_id': driverId,
      'ride_id': rideId,
      'last_message': lastMessage,
      'last_message_time': lastMessageTime?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'other_user_name': otherUserName,
      'other_user_id': otherUserId,
      'other_user_role': otherUserRole,
      'unread_count': unreadCount,
    };
  }
}
