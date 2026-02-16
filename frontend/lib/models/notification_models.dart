class NotificationModel {
  final int id;
  final int userId;
  final String title;
  final String message;
  final String type;
  final String? category;
  final bool read;
  final DateTime createdAt;
  final String? userName;
  final String? userEmail;
  final int? conversationId;
  final int? senderId;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.category,
    required this.read,
    required this.createdAt,
    this.userName,
    this.userEmail,
    this.conversationId,
    this.senderId,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      title: json['title'] as String,
      message: json['message'] as String,
      type: json['type'] as String? ?? 'Info',
      category: json['category'] as String?,
      read: json['read'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      userName: json['user_name'] as String?,
      userEmail: json['user_email'] as String?,
      conversationId: json['conversation_id'] as int?,
      senderId: json['sender_id'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'message': message,
      'type': type,
      'category': category,
      'read': read,
      'created_at': createdAt.toIso8601String(),
      'user_name': userName,
      'user_email': userEmail,
      'conversation_id': conversationId,
      'sender_id': senderId,
    };
  }
}
