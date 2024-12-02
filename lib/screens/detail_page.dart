import 'package:flutter/material.dart';
import 'package:register/config/app_config.dart';
import 'package:register/config/theme.dart';
import 'package:register/controllers/listing_controller.dart';
import 'package:register/models/listing_model.dart';
import 'package:register/models/user.dart';
import 'package:register/widgets/listings/comment_section_widget.dart';
import 'package:register/widgets/listings/feature_widget.dart';
import 'package:register/widgets/listings/owner_info_widget.dart';


class ListingDetailPage extends StatefulWidget {
  final Listing listing;
  final User user;

  const ListingDetailPage({
    Key? key,
    required this.listing,
    required this.user,
  }) : super(key: key);

  @override
  State<ListingDetailPage> createState() => _ListingDetailPageState();
}

class _ListingDetailPageState extends State<ListingDetailPage> {
  late PageController _pageController;
  late ListingController _listingController;
  int _currentImageIndex = 0;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _listingController = ListingController(context, _commentController);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  String _getFullImageUrl(String relativePath) {
    if (relativePath.isEmpty) {
      debugPrint('Image path est vide');
      return '';
    }
    final baseUrl = AppConfig.baseUrl.replaceAll('/api', '');
    final fullImageUrl = '$baseUrl/storage/$relativePath';
    return fullImageUrl;
  }

  Widget _buildThumbnailGallery() {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.listing.photos.length,
        itemBuilder: (context, index) {
          final imageUrl = _getFullImageUrl(widget.listing.photos[index]);
          return GestureDetector(
            onTap: () {
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            child: Container(
              width: 60,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                border: _currentImageIndex == index
                    ? Border.all(color: AppTheme.primaryColor, width: 2)
                    : null,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildListingTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.listing.title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${widget.listing.price.toStringAsFixed(0)} FCFA',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatures() {
    return Wrap(
      spacing: 12,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: [
        FeatureWidget(
            icon: Icons.square_foot, text: '${widget.listing.measurement} m²'),
        FeatureWidget(icon: Icons.apartment, text: widget.listing.type),
        FeatureWidget(icon: Icons.location_on, text: widget.listing.address),
      ],
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.grey[900],
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          widget.listing.description,
          style: TextStyle(
            fontSize: 16,
            height: 1.6,
            color: Colors.grey[800],
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final listingOwner = widget.listing.owner ?? widget.user;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(35),
                ),
                child: const Icon(Icons.arrow_back, color: Colors.black),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(35),
                  ),
                  child: const Icon(Icons.favorite_border, color: Colors.black),
                ),
                onPressed: () {},
              ),
            ],
            floating: true,
            pinned: true,
            expandedHeight: 400,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentImageIndex = index;
                      });
                    },
                    itemCount: widget.listing.photos.length,
                    itemBuilder: (context, index) {
                      final imageUrl =
                          _getFullImageUrl(widget.listing.photos[index]);
                      return Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: _buildThumbnailGallery(),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                OwnerInfoWidget(
                  owner: listingOwner,
                  onPhoneCall: _listingController.makePhoneCall,
                ),
                const SizedBox(height: 20),
                _buildListingTitle(),
                const SizedBox(height: 8),
                _buildFeatures(),
                const SizedBox(height: 20),
                _buildDescription(),
                const SizedBox(height: 24),
                CommentSectionWidget(
                  commentController: _commentController,
                  onPostComment: () => _listingController.postComment(
                    widget.listing,
                    widget.user,
                  ),
                ),
                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Contacter le vendeur',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
