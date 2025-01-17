import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:register/screens/detail_page.dart';
import '../../../config/theme.dart';
import '../../../controllers/home_tab_controller.dart';
import '../../../models/listing_model.dart';
import '../../../models/user.dart';

class HomeTab extends StatefulWidget {
  final User user;

  const HomeTab({super.key, required this.user});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final HomeTabController _controller = HomeTabController();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  final FocusNode _searchFocusNode = FocusNode(); // Ajoutez cette ligne

  @override
  void initState() {
    super.initState();

    _controller.fetchListings(setState);
    _searchFocusNode.dispose(); // Ajoutez cette ligne
  }

  // Méthode de rafraîchissement
  Future<void> _refreshListings() async {
    await _controller.fetchListings(setState);
  }

  Widget _buildListingImage(String? imageUrl) {
    final fullImageUrl = _controller.getFullImageUrl(imageUrl);

    if (fullImageUrl.isEmpty) {
      return Container(
        height: 200,
        color: Colors.grey[200],
        child: const Center(
          child: Icon(Icons.image_not_supported, color: Colors.grey),
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: fullImageUrl,
      height: 200,
      width: double.infinity,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        height: 200,
        color: Colors.grey[200],
        child: const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      errorWidget: (context, url, error) {
        debugPrint('Error loading image: $error for URL: $url');
        return Container(
          height: 200,
          color: Colors.grey[200],
          child: const Center(
            child: Icon(Icons.error_outline, color: Colors.grey),
          ),
        );
      },
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.red[300], size: 64),
          const SizedBox(height: 16),
          Text(
            _controller.error ?? 'Une erreur est survenue',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _controller.fetchListings(setState),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String text, {bool isSelected = false}) {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      child: Text(
        text,
        style: TextStyle(
          color: isSelected ? AppTheme.primaryColor : Colors.grey,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildFeature(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

 Widget _buildListingCard(Listing listing, int index) {
  return GestureDetector(
    onTap: () {
      final token = widget.user.token;
      if (token != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ListingDetailPage(
              listing: listing,
              user: widget.user,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez vous connecter pour voir les détails'),
            backgroundColor: Colors.red,
          ),
        );
      }
    },
    child: Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Container(
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  _buildListingImage(
                    listing.photos.isNotEmpty ? listing.photos[0] : null,
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${listing.price.toStringAsFixed(0)} FCFA',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            listing.title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            listing.isFavorited
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: AppTheme.primaryColor,
                          ),
                          onPressed: () {
                            _controller.toggleFavorite(listing.id, setState);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Colors.grey,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            listing.address,
                            style: const TextStyle(color: Colors.grey),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildFeature(
                          Icons.square_foot,
                          '${listing.measurement} m²',
                        ),
                        const SizedBox(width: 12),
                        _buildFeature(
                          Icons.home,
                          listing.type,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            listing.address,
                            style: const TextStyle(color: Colors.grey),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _buildFeatureWidget(IconData icon, String text) {
  return Row(
    children: [
      Icon(
        icon,
        color: Colors.grey,
        size: 16,
      ),
      const SizedBox(width: 4),
      Text(
        text,
        style: const TextStyle(color: Colors.grey),
      ),
    ],
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _controller.isLoading
            ? const Center(child: CircularProgressIndicator())
            : _controller.error != null
                ? _buildErrorState()
                : RefreshIndicator(
                    key: _refreshIndicatorKey,
                    onRefresh: _refreshListings,
                    color: AppTheme.primaryColor,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          color: Colors.white,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      margin: const EdgeInsets.only(right: 12),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.search,
                                            color: Colors.grey[600],
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: TextField(
                                              decoration: InputDecoration(
                                                hintText:
                                                    'Rechercher un logement',
                                                hintStyle: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 16,
                                                ),
                                                border: InputBorder.none,
                                                enabledBorder: InputBorder.none,
                                                focusedBorder: InputBorder.none,
                                                fillColor: Colors.grey[
                                                    200], // Même couleur que le Container
                                                filled:
                                                    true, // Active le remplissage
                                                contentPadding: EdgeInsets.zero,
                                              ),
                                              style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.black,
                                              ),
                                              onChanged: (value) {
                                                _controller.searchListings(
                                                    value, setState);
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add),
                                    color: AppTheme.primaryColor,
                                    onPressed: () =>
                                        _controller.navigateToAddPage(context),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    ..._controller.types
                                        .map((type) => _buildTab(
                                              type,
                                              isSelected: type == 'Récent',
                                            )),
                                    ..._controller.quartiers
                                        .map((quartier) => _buildTab(quartier)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Container(
                            color: Colors.grey[50],
                            child: ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(16),
                              itemCount: _controller.filteredListings.length,
                              itemBuilder: (context, index) {
                                final listing =
                                    _controller.filteredListings[index];
                                return _buildListingCard(listing, index);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}
