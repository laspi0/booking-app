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
  bool isLoading = true;
  String? error;

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

  // Méthodes
  Future<void> fetchListings(Function setState) async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final fetchedListings = await _listingService.getListings();

      setState(() {
        listings = fetchedListings;
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
    // Trouvez l'index du listing dans la liste
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
        // Mettre à jour TOUS les listings avec le même ID
        listings = listings.map((l) {
          if (l.id == listingId) {
            l.isFavorited = newFavoritedState;
          }
          return l;
        }).toList();
      });
    } else {
      // Gérer l'échec de la mise à jour
      debugPrint('Échec de la mise à jour du favori');
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
