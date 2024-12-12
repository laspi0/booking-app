import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'token_service.dart';

class FavoriteService {
  static const String baseUrl = AppConfig.baseUrl;

  static Future<bool> addFavorite(int listingId) async {
    final url = Uri.parse('$baseUrl/favorites/$listingId');
    final token = await TokenService.getToken();

    if (token == null) {
      throw Exception('Aucun token trouvé');
    }

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        throw Exception('Erreur lors de l\'ajout aux favoris');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  static Future<bool> removeFavorite(int listingId) async {
    final url = Uri.parse('$baseUrl/favorites/$listingId');
    final token = await TokenService.getToken();

    if (token == null) {
      throw Exception('Aucun token trouvé');
    }

    try {
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Erreur lors de la suppression des favoris');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  static Future<List<int>> getFavoriteListings() async {
    final url = Uri.parse('$baseUrl/favorites');
    final token = await TokenService.getToken();

    if (token == null) {
      throw Exception('Aucun token trouvé');
    }

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map<int>((item) => item['listing_id'] as int).toList();
      } else {
        throw Exception('Erreur lors de la récupération des favoris');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }
}