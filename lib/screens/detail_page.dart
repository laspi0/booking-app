import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../config/theme.dart';
import '../../../config/app_config.dart';
import '../../../models/listing_model.dart';

class ListingDetailPage extends StatefulWidget {
  final Listing listing;

  const ListingDetailPage({super.key, required this.listing});

  @override
  State<ListingDetailPage> createState() => _ListingDetailPageState();
}

class _ListingDetailPageState extends State<ListingDetailPage> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _getFullImageUrl(String relativePath) {
    if (relativePath.isEmpty) {
      debugPrint('Image path est vide');
      return '';
    }
    final baseUrl = AppConfig.baseUrl.replaceAll('/api', '');
    final fullImageUrl = '$baseUrl/storage/$relativePath';
    debugPrint('Image Path: $relativePath');
    debugPrint('Full Image URL: $fullImageUrl');
    return fullImageUrl;
  }

  Widget _buildImageCarousel() {
    if (widget.listing.photos.isEmpty) {
      return Container(
        height: 300,
        color: Colors.grey[200],
        child: const Center(
          child: Icon(Icons.image_not_supported, color: Colors.grey, size: 48),
        ),
      );
    }

    return Stack(
      children: [
        SizedBox(
          height: 300,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.listing.photos.length,
            onPageChanged: (index) {
              setState(() {
              });
            },
            itemBuilder: (context, index) {
              final imageUrl = _getFullImageUrl(widget.listing.photos[index]);
              return Image.network(
                imageUrl,
                width: double.infinity,
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
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(Icons.error_outline, color: Colors.grey),
                    ),
                  );
                },
              );
            },
          ),
        ),
        Positioned(
          bottom: 16,
          left: 0,
          right: 0,
          child: Center(
            child: SmoothPageIndicator(
              controller: _pageController,
              count: widget.listing.photos.length,
              effect: WormEffect(
                dotHeight: 8,
                dotWidth: 8,
                activeDotColor: AppTheme.primaryColor,
                dotColor: Colors.white.withOpacity(0.5),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeature(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.primaryColor),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        child,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: _buildImageCarousel(),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.listing.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${widget.listing.price.toStringAsFixed(0)} FCFA',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.grey, size: 16),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.listing.address,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    'Caractéristiques',
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _buildFeature(
                          Icons.square_foot,
                          '${widget.listing.measurement} m²',
                        ),
                        _buildFeature(Icons.apartment, widget.listing.type),
                        _buildFeature(Icons.check_circle_outline, widget.listing.status),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    'Description',
                    Text(
                      widget.listing.description,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Implement contact functionality
        },
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.phone),
        label: const Text('Contacter'),
      ),
    );
  }
}
