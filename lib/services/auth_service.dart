import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import 'token_service.dart';
import '../config/app_config.dart';

class AuthService {
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      final responseData = jsonDecode(response.body);

      print('Response Data: $responseData'); // Debugging line

      if (response.statusCode == 200) {
        if (responseData['user'] == null || responseData['access_token'] == null) {
          return {
            'success': false,
            'message': 'Response missing user or token information',
          };
        }

        final user = User.fromJson(responseData);

        await TokenService.saveToken(user.token ?? '');

        return {
          'success': true,
          'message': 'Connexion réussie!',
          'user': responseData, // Pass the entire responseData
        };
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Email ou mot de passe incorrect',
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Une erreur est survenue',
        };
      }
    } catch (e) {
      print('Login Error: $e'); // Debugging line
      return {
        'success': false,
        'message': 'Erreur de connexion: $e',
      };
    }
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String? number,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          if (number != null) 'number': number,
        }),
      ).timeout(const Duration(seconds: 10));

      final responseData = jsonDecode(response.body);

      print('Register Response Data: $responseData'); // Debugging line

      if (response.statusCode == 201 || response.statusCode == 200) {
        final user = responseData;
        await TokenService.saveToken(user['token'] ?? '');

        return {
          'success': true,
          'message': 'Inscription réussie!',
          'user': user,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Une erreur est survenue',
        };
      }
    } catch (e) {
      print('Register Error: $e'); // Debugging line
      return {
        'success': false,
        'message': 'Erreur de connexion: $e',
      };
    }
  }

  Future<void> logout() async {
    try {
      final token = await TokenService.getToken();
      if (token != null) {
        await http.post(
          Uri.parse('${AppConfig.baseUrl}/logout'),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        );
      }
    } catch (e) {
      // Handle logout error
      print('Logout Error: $e'); // Debugging line
    } finally {
      await TokenService.removeToken();
    }
  }
}
