import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user.dart';

class TokenService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  // Sauvegarde du token
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Récupération du token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Suppression du token et des données utilisateur
  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  // Sauvegarde des données utilisateur
  static Future<void> saveUserData(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final userData = jsonEncode({
      'id': user.id,
      'name': user.name,
      'email': user.email,
      'number': user.number,
      'token': user.token,
    });
    await prefs.setString(_userKey, userData);
  }

  // Récupération des données utilisateur
  static Future<User?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_userKey);
    if (userData != null) {
      final data = jsonDecode(userData);
      return User.fromJson({'user': data, 'token': data['token']});
    }
    return null;
  }
}
