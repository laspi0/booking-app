// services/conversation_service.dart
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

  static Future<Conversation> startConversation(int listingId) async {
    final response = await http.post(
      Uri.parse('${AppConfig.baseUrl}/listings/$listingId/start-conversation'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return Conversation.fromJson(jsonResponse['conversation']);
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

 static Future<Message> sendMessage(int conversationId, String content) async {
  try {
    final response = await http.post(
      Uri.parse('${AppConfig.baseUrl}/conversations/$conversationId/messages'),
      headers: await _getHeaders(),
      body: json.encode({'content': content}),
    );

    print('Status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 201 || response.statusCode == 200) {
      final responseData = json.decode(response.body);
      print('Parsed response type: ${responseData.runtimeType}');
      print('Parsed response keys: ${responseData.keys}');

      // Defensive parsing with detailed error information
      if (responseData is Map<String, dynamic>) {
        if (responseData.containsKey('data')) {
          final messageData = responseData['data'];
          print('Message data: $messageData');
          print('Message data type: ${messageData.runtimeType}');
          
          return Message.fromJson(messageData);
        } else {
          print('No data key found, attempting direct parsing');
          return Message.fromJson(responseData);
        }
      } else {
        throw Exception('Unexpected response format: ${responseData.runtimeType}');
      }
    } else {
      throw Exception('Server error: ${response.body}');
    }
  } catch (e, stackTrace) {
    print('Detailed error in sendMessage: $e');
    print('Stack trace: $stackTrace');
    rethrow;
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
