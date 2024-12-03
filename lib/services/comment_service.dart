import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:register/config/app_config.dart';
import 'package:register/models/comment_model.dart';

class CommentService {
  Future<List<Comment>> getListingComments(int listingId, String token) async {
    try {
      final url = '${AppConfig.baseUrl}/listings/$listingId/comments';
      print('Fetching comments from URL: $url'); // Diagnostic print

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        // Vérification explicite du corps de la réponse
        if (response.body.isEmpty) {
          print('Response body is empty');
          return [];
        }

        // Utilisez dynamic pour permettre une manipulation plus flexible
        dynamic jsonResponse;
        try {
          jsonResponse = json.decode(response.body);
        } catch (parseError) {
          print('JSON parsing error: $parseError');
          return [];
        }

        // Vérification explicite du type de réponse
        if (jsonResponse is List) {
          return jsonResponse
              .map<Comment>((commentJson) {
                print('Processing comment JSON: $commentJson'); // Diagnostic print
                return Comment.fromJson(commentJson);
              })
              .toList();
        } else {
          print('Unexpected JSON response type: ${jsonResponse.runtimeType}');
          return [];
        }
      } else {
        print('Error fetching comments. Status code: ${response.statusCode}');
        print('Error response body: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Unexpected error in getListingComments: $e');
      return [];
    }
  }

  Future<Comment?> postComment({
    required int listingId, 
    required String content, 
    required String token
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/listings/$listingId/comments'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'content': content}),
      );

      if (response.statusCode == 201) {
        final jsonResponse = json.decode(response.body);
        return Comment.fromJson(jsonResponse);
      } else {
        print('Failed to post comment. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error posting comment: $e');
      return null;
    }
  }
}