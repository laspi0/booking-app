import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/reservation.dart';
import 'token_service.dart';
import '../config/app_config.dart';

class ReservationService {
  Future<List<Reservation>> fetchReservations() async {
    print('--- Fetching Reservations ---');
    final token = await TokenService.getToken();
    print('Token obtenu : $token');

    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/reservations'), // Corrigé
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    print('Code réponse : ${response.statusCode}');
    print('Réponse : ${response.body}');

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      print('Réservations reçues : ${data.length}');
      return data.map((json) => Reservation.fromJson(json)).toList();
    } else {
      print('Erreur lors de la récupération des réservations');
      throw Exception('Failed to load reservations');
    }
  }

  Future<List<DateTime>> fetchUnavailableDates(int listingId) async {
    final url = Uri.parse('${AppConfig.baseUrl}/listings/$listingId/unavailable-dates');
    try {
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      });
      
      if (response.statusCode == 200) {
        final List<dynamic> dates = jsonDecode(response.body);
        return dates.map((date) => DateTime.parse(date)).toList();
      } else {
        throw Exception('Échec du chargement des dates. Code : ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération des dates : $e');
    }
  }

  Future<Reservation> createReservation(Map reservationData) async {
    print('--- Creating Reservation ---');
    print('Données envoyées : $reservationData');

    final token = await TokenService.getToken();
    print('Token obtenu : $token');

    final response = await http.post(
      Uri.parse('${AppConfig.baseUrl}/reservations'), // Corrigé
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(reservationData),
    );

    print('Code réponse : ${response.statusCode}');
    print('Réponse : ${response.body}');

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      print('Réservation créée avec succès : $data');
      return Reservation.fromJson(data);
    } else {
      print('Erreur lors de la création de la réservation');
      print('Détails de l\'erreur : ${response.body}');
      throw Exception('Failed to create reservation');
    }
  }

  Future<Reservation> fetchReservation(int id) async {
    print('--- Fetching Reservation by ID: $id ---');
    final token = await TokenService.getToken();
    print('Token obtenu : $token');

    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/reservations/$id'), // Corrigé
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    print('Code réponse : ${response.statusCode}');
    print('Réponse : ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('Détails de la réservation : $data');
      return Reservation.fromJson(data);
    } else {
      print('Erreur lors de la récupération de la réservation');
      throw Exception('Failed to load reservation');
    }
  }
}
