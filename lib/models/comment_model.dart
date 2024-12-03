import 'package:register/models/user.dart';

class Comment {
  final int id;
  final int userId;
  final int listingId;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final User? user;

  Comment({
    required this.id,
    required this.userId,
    required this.listingId,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.user,
  });

  factory Comment.fromJson(Map<String, dynamic>? json) {
    // Gestion rigoureuse des valeurs nulles ou incorrectes
    if (json == null) {
      throw ArgumentError('JSON cannot be null');
    }

    return Comment(
      id: _safeInt(json, 'id'),
      userId: _safeInt(json, 'user_id'),
      listingId: _safeInt(json, 'listing_id'),
      content: _safeString(json, 'content'),
      createdAt: _safeDateTime(json, 'created_at'),
      updatedAt: _safeDateTime(json, 'updated_at'),
      user: json['user'] != null 
          ? User.fromJson(json['user'] as Map<String, dynamic>) 
          : null,
    );
  }

  // Méthodes utilitaires pour une conversion sécurisée
  static int _safeInt(Map<String, dynamic> json, String key, [int defaultValue = 0]) {
    final value = json[key];
    return value is int ? value : defaultValue;
  }

  static String _safeString(Map<String, dynamic> json, String key, [String defaultValue = '']) {
    final value = json[key];
    return value is String ? value : defaultValue;
  }

  static DateTime _safeDateTime(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }
}