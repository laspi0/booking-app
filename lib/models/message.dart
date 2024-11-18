// models/message.dart
class Message {
  final int id;
  final int conversationId;
  final int userId;
  final String userName;
  final String content;
  final DateTime createdAt;
  final bool isRead;

  Message({
    required this.id,
    required this.conversationId,
    required this.userId,
    required this.userName,
    required this.content,
    required this.createdAt,
    this.isRead = false,
  });

 factory Message.fromJson(Map<String, dynamic> json) {
  return Message(
    id: json['id'],
    conversationId: json['conversation_id'],
    userId: json['user_id'],
    userName: json['user_id'].toString(), // Utilisateur comme nom par défaut
    content: json['content'],
    createdAt: DateTime.parse(json['created_at']),
    isRead: json['is_read'] ?? false,
  );
}
}