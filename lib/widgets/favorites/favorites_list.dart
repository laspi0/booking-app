import 'package:flutter/material.dart';
import 'favorites_item.dart';

class FavoritesList extends StatelessWidget {
  final List<dynamic> favorites;
  final Function(int) onRemove;

  const FavoritesList({super.key, required this.favorites, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final favorite = favorites[index];
        final listing = favorite['listing'];

        return FavoritesItem(
          listing: listing,
          onRemove: () => onRemove(listing['id']),
        );
      },
    );
  }
}
