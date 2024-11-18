// models/conversation.dart

class Conversation {
  final int id;
  final int listingId;
  final int senderId;
  final int recipientId;
  final String senderName;
  final String recipientName;
  final String listingTitle;
  final int unreadMessages;
  final DateTime lastMessageAt;

  Conversation({
    required this.id,
    required this.listingId,
    required this.senderId,
    required this.recipientId,
    required this.senderName,
    required this.recipientName,
    required this.listingTitle,
    this.unreadMessages = 0,
    required this.lastMessageAt,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'],
      listingId: json['listing_id'],
      senderId: json['sender_id'],
      recipientId: json['recipient_id'],
      senderName: json['sender']['name'],
      recipientName: json['recipient']['name'],
      listingTitle: json['listing']['title'],
      unreadMessages: json['unread_messages'] ?? 0,
      lastMessageAt: DateTime.parse(json['updated_at']),
    );
  }
}