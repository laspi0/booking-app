import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../config/app_config.dart';

class FavoritesState {
  final bool isLoading;
  final List<dynamic> favorites;
  final String? error;

  FavoritesState({
    this.isLoading = false,
    this.favorites = const [],
    this.error,
  });

  FavoritesState copyWith({
    bool? isLoading,
    List<dynamic>? favorites,
    String? error,
  }) {
    return FavoritesState(
      isLoading: isLoading ?? this.isLoading,
      favorites: favorites ?? this.favorites,
      error: error,
    );
  }
}

class FavoritesController extends ValueNotifier<FavoritesState> {
  final String token;

  FavoritesController(this.token) : super(FavoritesState(isLoading: true));

  Future<void> fetchFavorites() async {
    value = value.copyWith(isLoading: true, error: null);
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/favorites'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        value = value.copyWith(isLoading: false, favorites: data);
      } else {
        value = value.copyWith(
          isLoading: false,
          error: 'Erreur lors du chargement des favoris: ${response.body}',
        );
      }
    } catch (e) {
      value = value.copyWith(
        isLoading: false,
        error: 'Erreur: $e',
      );
    }
  }

  Future<void> removeFavorite(int listingId) async {
    try {
      final response = await http.delete(
        Uri.parse('${AppConfig.baseUrl}/favorites/$listingId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        value = value.copyWith(
          favorites: value.favorites.where((fav) => fav['listing_id'] != listingId).toList(),
        );
      }
    } catch (e) {
      // Gérer l'erreur, peut-être afficher une notification
    }
  }
}
