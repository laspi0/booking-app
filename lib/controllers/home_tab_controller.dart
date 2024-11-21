import 'package:flutter/material.dart';
import '../../../models/listing_model.dart';
import '../../../services/listing_service.dart';
import '../config/app_config.dart';
import '../screens/add_page.dart';

class HomeTabController {
  final ListingService _listingService = ListingService();
  
  // État
  List<Listing> listings = [];
  bool isLoading = true;
  String? error;

  // Données statiques
  final List<String> quartiers = [
    'Almadies', 'Mermoz', 'Ngor', 'Ouakam', 'Plateau', 
    'Point E', 'Sacré-Cœur', 'Grand Yoff', 'Liberté 6', 'Fann'
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