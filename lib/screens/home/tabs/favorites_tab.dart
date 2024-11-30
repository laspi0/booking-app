import 'package:flutter/material.dart';
import 'package:register/controllers/favorites_controller.dart';
import 'package:register/widgets/favorites/favorites_list.dart';
import '../../../config/theme.dart';

class FavoritesTab extends StatefulWidget {
  final String token;

  const FavoritesTab({super.key, required this.token});

  @override
  State<FavoritesTab> createState() => _FavoritesTabState();
}

class _FavoritesTabState extends State<FavoritesTab> {
  late FavoritesController _controller;

  @override
  void initState() {
    super.initState();
    _controller = FavoritesController(widget.token);
    _controller.fetchFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Favorites',
          style: TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ValueListenableBuilder<FavoritesState>(
        valueListenable: _controller,
        builder: (context, state, _) {
          if (state.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
              ),
            );
          }

          if (state.error != null) {
            return _buildErrorWidget(state.error!);
          }

          if (state.favorites.isEmpty) {
            return _buildEmptyFavorites();
          }

          return FavoritesList(
            favorites: state.favorites,
            onRemove: _controller.removeFavorite,
          );
        },
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(error, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _controller.fetchFavorites,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyFavorites() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 48, color: Colors.grey),
          SizedBox(height: 16),
          Text('Aucun favori pour le moment', style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
