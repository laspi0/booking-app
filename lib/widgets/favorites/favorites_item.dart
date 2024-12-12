import 'package:flutter/material.dart';
import 'package:register/config/app_config.dart';
import '../../../config/theme.dart';

class FavoritesItem extends StatelessWidget {
  final dynamic listing;
  final VoidCallback onRemove;

  const FavoritesItem({super.key, required this.listing, required this.onRemove});

  String getFullImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return '';
    return '${AppConfig.baseUrl.replaceAll('/api', '')}/storage/$imagePath';
  }

  @override
  Widget build(BuildContext context) {
    final firstPhoto = (listing['photos'] as List?)?.isNotEmpty == true
        ? listing['photos'][0]['path']
        : null;
    final imageUrl = getFullImageUrl(firstPhoto);

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
      child: Row(
        children: [
          _buildImageWidget(imageUrl),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listing['title'] ?? 'Sans titre',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star, size: 14, color: AppTheme.primaryColor),
                            SizedBox(width: 4),
                            Text('4.8', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.favorite, color: AppTheme.primaryColor),
                        onPressed: onRemove,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '${listing['price']}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.primaryColor),
                      ),
                      Text(
                        ' FCFA/nuit',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageWidget(String? imageUrl) {
    return imageUrl != null && imageUrl.isNotEmpty
        ? Image.network(
            imageUrl,
            width: 100,
            height: 100,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _placeholderImage();
            },
          )
        : _placeholderImage();
  }

  Widget _placeholderImage() {
    return Container(
      width: 100,
      height: 100,
      color: Colors.grey[300],
      child: const Icon(Icons.image, color: Colors.grey),
    );
  }
}
