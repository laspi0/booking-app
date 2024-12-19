import 'package:flutter/material.dart';
import '../../../models/listing_model.dart';
import '../../../services/listing_service.dart';
import '../config/app_config.dart';
import '../screens/add_page.dart';
import '../services/favorite_service.dart';

class HomeTabController {
  final ListingService _listingService = ListingService();

  // État
  List<Listing> listings = [];
  List<Listing> filteredListings = [];
  bool isLoading = true;
  String? error;
  String searchQuery = '';

  // Données statiques
  final List<String> quartiers = [
    'Almadies',
    'Mermoz',
    'Ngor',
    'Ouakam',
    'Plateau',
    'Point E',
    'Sacré-Cœur',
    'Grand Yoff',
    'Liberté 6',
    'Fann'
  ];

  final List<String> types = ['Récent', 'Populaire', 'Meilleures offres'];

  void searchListings(String query, Function setState) {
    searchQuery = query.toLowerCase();
    setState(() {
      if (searchQuery.isEmpty) {
        filteredListings = List.from(listings);
      } else {
        filteredListings = listings.where((listing) {
          return listing.title.toLowerCase().contains(searchQuery) ||
                 listing.address.toLowerCase().contains(searchQuery) ||
                 listing.price.toString().contains(searchQuery);
        }).toList();
      }
    });
  }

  Future<void> fetchListings(Function setState) async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });
      final fetchedListings = await _listingService.getListings();
      final favoriteListingIds = await FavoriteService.getFavoriteListings();
      setState(() {
        listings = fetchedListings.map((listing) {
          listing.isFavorited = favoriteListingIds.contains(listing.id);
          return listing;
        }).toList();
        filteredListings = List.from(listings);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> toggleFavorite(int listingId, Function setState) async {
    try {
      final listingIndex = listings.indexWhere((l) => l.id == listingId);
      if (listingIndex == -1) return;
      final listing = listings[listingIndex];
      final newFavoritedState = !listing.isFavorited;
      bool success;
      if (newFavoritedState) {
        success = await FavoriteService.addFavorite(listingId);
      } else {
        success = await FavoriteService.removeFavorite(listingId);
      }
      if (success) {
        setState(() {
          listings[listingIndex].isFavorited = newFavoritedState;
          // Mettre à jour également la liste filtrée
          final filteredIndex = filteredListings.indexWhere((l) => l.id == listingId);
          if (filteredIndex != -1) {
            filteredListings[filteredIndex].isFavorited = newFavoritedState;
          }
        });
      }
    } catch (e) {
      debugPrint('Erreur lors de la mise à jour des favoris: $e');
    }
  }

  String getFullImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return '';
    final baseUrlWithoutApi = AppConfig.baseUrl.replaceAll('/api', '');
    final fullImageUrl = '$baseUrlWithoutApi/storage/$imageUrl';
    debugPrint('Loading image from: $fullImageUrl');
    return fullImageUrl;
  }

  void navigateToAddPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddPage(),
      ),
    );
  }
}