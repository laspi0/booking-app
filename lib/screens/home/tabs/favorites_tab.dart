import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:register/models/user.dart';

import '../../../config/app_config.dart';
import '../../../config/theme.dart';

class FavoritesTab extends StatefulWidget {
  final User user;
  
  const FavoritesTab({super.key, required this.user});

  @override
  _FavoritesTabState createState() => _FavoritesTabState();
}

class _FavoritesTabState extends State<FavoritesTab> {
  List<dynamic> favorites = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchFavorites();
  }

  String getFullImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      debugPrint('Image path est null ou vide');
      return '';
    }
    
    // Configurer correctement votre base URL
    final baseUrl = AppConfig.baseUrl.replaceAll('/api', '');
    final fullImageUrl = '$baseUrl/storage/$imagePath';
    
    debugPrint('Image Path: $imagePath');
    debugPrint('Base URL: $baseUrl');
    debugPrint('Full Image URL: $fullImageUrl');
    
    return fullImageUrl;
  }

  Future<void> fetchFavorites() async {
    try {
      if (widget.user.token == null) {
        setState(() {
          error = 'Non authentifié';
          isLoading = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/favorites'),
        headers: {
          'Authorization': 'Bearer ${widget.user.token}',
          'Accept': 'application/json',
        },
      );

      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        setState(() {
          favorites = data;
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Erreur lors du chargement des favoris: ${response.body}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Erreur: $e';
        isLoading = false;
      });
      debugPrint('Erreur détaillée: $e');
    }
  }

  Future<void> removeFavorite(int listingId) async {
    try {
      final response = await http.delete(
        Uri.parse('${AppConfig.baseUrl}/favorites/$listingId'),
        headers: {
          'Authorization': 'Bearer ${widget.user.token}',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          favorites.removeWhere(
              (favorite) => favorite['listing_id'] == listingId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Favori supprimé avec succès'),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la suppression: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildImageWidget(dynamic listing) {
    // Vérification de la présence et de la non-vacuité des photos
    if (listing['photos'] == null || 
        (listing['photos'] as List).isEmpty) {
      return Container(
        width: 100,
        height: 100,
        color: Colors.grey[200],
        child: const Center(
          child: Icon(
            Icons.image_not_supported, 
            color: Colors.grey,
            size: 40,
          ),
        ),
      );
    }

    // Prend la première photo
    final firstPhoto = listing['photos'][0]['path'];
    final fullImageUrl = getFullImageUrl(firstPhoto);

    return Image.network(
      fullImageUrl,
      width: 100,
      height: 100,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                : null,
            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        debugPrint('Erreur de chargement de l\'image: $error');
        return Container(
          width: 100,
          height: 100,
          color: Colors.grey[200],
          child: const Center(
            child: Icon(
              Icons.image_not_supported, 
              color: Colors.grey,
              size: 40,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 1,
              ),
            ],
          ),
          child: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            title: const Text(
              'Favorites',
              style: TextStyle(
                color: Colors.black,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search, color: Colors.black),
                onPressed: () {},
              ),
            ],
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
              ),
            )
          : error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        error!,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: fetchFavorites,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : favorites.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.favorite_border,
                            size: 48,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Aucun favori pour le moment',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      itemCount: favorites.length,
                      itemBuilder: (context, index) {
                        final favorite = favorites[index];
                        final listing = favorite['listing'];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                offset: const Offset(0, 2),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Row(
                              children: [
                                _buildImageWidget(listing),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          listing['title'] ?? 'Sans titre',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: AppTheme.primaryColor.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: const Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.star,
                                                    size: 14,
                                                    color: AppTheme.primaryColor,
                                                  ),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    '4.8',
                                                    style: TextStyle(
                                                      color: AppTheme.primaryColor,
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const Spacer(),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.favorite,
                                                color: AppTheme.primaryColor,
                                                size: 22,
                                              ),
                                              onPressed: () => removeFavorite(listing['id']),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Text(
                                              '${listing['price']}',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                                color: AppTheme.primaryColor,
                                              ),
                                            ),
                                            Text(
                                              ' FCFA/nuit',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}