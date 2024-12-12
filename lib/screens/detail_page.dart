import 'package:flutter/material.dart';
import 'package:register/config/app_config.dart';
import 'package:register/config/theme.dart';
import 'package:register/controllers/listing_controller.dart';
import 'package:register/models/comment_model.dart';
import 'package:register/models/listing_model.dart';
import 'package:register/models/user.dart';
import 'package:register/screens/reservation_screen.dart';
import 'package:register/services/comment_service.dart';
import 'package:register/widgets/listings/comment_section_widget.dart';
import 'package:register/widgets/listings/feature_widget.dart';
import 'package:register/widgets/listings/owner_info_widget.dart';
import 'package:register/widgets/comments/comment_section.dart';

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
  late final PageController _pageController;
  late final ListingController _listingController;
  final CommentService _commentService = CommentService();

  int _currentImageIndex = 0;
  final TextEditingController _commentController = TextEditingController();

  List<Comment> _comments = [];
  bool _isLoading = false;
  bool _isPosting = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _listingController = ListingController(context, _commentController);
    _fetchComments();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _fetchComments() async {
    if (mounted) {
      setState(() => _isLoading = true);
    }

    try {
      final comments = await _commentService.getListingComments(
          widget.listing.id, widget.user.token ?? '');

      if (mounted) {
        setState(() {
          _comments = comments;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Erreur de récupération des commentaires : $e');
      if (mounted) {
        setState(() {
          _comments = []; // Liste vide en cas d'erreur
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Impossible de charger les commentaires : $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _postComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    if (mounted) {
      setState(() => _isPosting = true);
    }

    try {
      final newComment = await _commentService.postComment(
        listingId: widget.listing.id,
        content: content,
        token: widget.user.token ?? '',
      );

      if (mounted && newComment != null) {
        setState(() {
          // Créez manuellement un nouvel objet Comment avec les informations de l'utilisateur actuel
          final commentWithUser = Comment(
            id: newComment.id,
            userId: widget.user.id,
            listingId: widget.listing.id,
            content: content,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            user: widget.user, // Utilisez l'utilisateur actuel
          );

          _comments.insert(0, commentWithUser);
          _commentController.clear();
          _isPosting = false;
          FocusScope.of(context).unfocus();
        });
      }
    } catch (e) {
      _handleError('Erreur lors de l\'envoi du commentaire', e);
    }
  }

  void _handleError(String message, dynamic error) {
    if (mounted) {
      setState(() {
        _isLoading = false;
        _isPosting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$message: $error'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  String _getFullImageUrl(String relativePath) {
    if (relativePath.isEmpty) return '';
    final baseUrl = AppConfig.baseUrl.replaceAll('/api', '');
    return '$baseUrl/storage/$relativePath';
  }

  Widget _buildThumbnailGallery() {
    if (widget.listing.photos.isEmpty) {
      return const SizedBox(
        height: 80,
        child: Center(child: Text('Aucune photo disponible')),
      );
    }

    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.listing.photos.length,
        itemBuilder: (context, index) {
          final imageUrl = _getFullImageUrl(widget.listing.photos[index]);
          return _buildThumbnail(index, imageUrl);
        },
      ),
    );
  }

  Widget _buildThumbnail(int index, String imageUrl) {
    return GestureDetector(
      onTap: () => _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      ),
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
          child: imageUrl.isNotEmpty
              ? Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _buildErrorImage(),
                )
              : _buildErrorImage(),
        ),
      ),
    );
  }

  Widget _buildErrorImage() {
    return Container(
      color: Colors.grey[200],
      child: const Icon(Icons.error),
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
          _buildSliverAppBar(context),
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
                _buildCommentSection(),
                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomContactButton(listingOwner),
    );
  }

  SliverAppBar _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: _buildCircularIconButton(
          Icons.arrow_back, () => Navigator.pop(context)),
      actions: [
        _buildCircularIconButton(Icons.favorite_border,
            () {} // TODO: Implement favorite functionality
            ),
      ],
      floating: true,
      pinned: true,
      expandedHeight: 400,
      flexibleSpace: FlexibleSpaceBar(
        background: _buildImageGallery(),
      ),
    );
  }

  Widget _buildCircularIconButton(IconData icon, VoidCallback onPressed) {
    return IconButton(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(35),
        ),
        child: Icon(icon, color: Colors.black),
      ),
      onPressed: onPressed,
    );
  }

  Widget _buildImageGallery() {
    return Stack(
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
            final imageUrl = _getFullImageUrl(widget.listing.photos[index]);
            return Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _buildErrorImage(),
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
    );
  }

  Widget _buildCommentSection() {
    return CommentSection(
      commentController: _commentController,
      onPostComment: _postComment,
      comments: _comments,
      isLoading: _isLoading,
    );
  }

  Widget _buildBottomContactButton(User listingOwner) {
    return Container(
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
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReservationPage(
                listingId: widget.listing.id,
                userId: widget.user.id,
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          'Réserver', // J'ai aussi modifié le texte du bouton
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
