import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/conversation.dart';
import '../models/message.dart';
import '../config/app_config.dart';
import 'token_service.dart';

class ConversationService {
  static Future<Map<String, String>> _getHeaders() async {
    final token = await TokenService.getToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  static Future<List<Conversation>> getConversations() async {
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/conversations'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => Conversation.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load conversations');
    }
  }

  static Future<Conversation> startConversation({
    required int userId,
    required int listingId,
  }) async {
    final response = await http.post(
      Uri.parse('${AppConfig.baseUrl}/listings/$listingId/start-conversation'),
      headers: await _getHeaders(),
      body: json.encode({
        'user_id': userId,
      }),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['conversation'] != null) {
        return Conversation.fromJson(jsonResponse['conversation']);
      } else {
        throw Exception('Conversation data is null');
      }
    } else {
      throw Exception(json.decode(response.body)['message'] ??
          'Failed to start conversation');
    }
  }

  static Future<List<Message>> getMessages(int conversationId) async {
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/conversations/$conversationId/messages'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => Message.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load messages');
    }
  }

  static Future<Conversation?> getConversationByUsers(
      int userId1, int userId2) async {
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/conversations/users/$userId1/$userId2'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return Conversation.fromJson(jsonResponse);
    } else if (response.statusCode == 404) {
      return null; // Aucune conversation trouvée
    } else {
      throw Exception('Failed to load conversation');
    }
  }

  static Future<Message> sendMessage(int conversationId, String content) async {
    final response = await http.post(
      Uri.parse('${AppConfig.baseUrl}/conversations/$conversationId/messages'),
      headers: await _getHeaders(),
      body: json.encode({'content': content}),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return Message.fromJson(responseData['data']);
    } else {
      throw Exception(
          json.decode(response.body)['message'] ?? 'Failed to send message');
    }
  }

  static Future<void> markAsRead(int conversationId) async {
    final response = await http.post(
      Uri.parse(
          '${AppConfig.baseUrl}/conversations/$conversationId/mark-as-read'),
      headers: await _getHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to mark messages as read');
    }
  }
}
