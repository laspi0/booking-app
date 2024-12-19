import 'package:flutter/material.dart';
import 'package:register/models/comment_model.dart';

class CommentSection extends StatelessWidget {
  final TextEditingController commentController;
  final Future<void> Function() onPostComment;
  final List<Comment> comments;
  final bool isLoading;

  const CommentSection({
    Key? key,
    required this.commentController,
    required this.onPostComment,
    required this.comments,
    required this.isLoading,
  }) : super(key: key);

  void _showCommentsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CommentsBottomSheet(
        commentController: commentController,
        onPostComment: onPostComment,
        comments: comments,
        isLoading: isLoading,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showCommentsBottomSheet(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Icon(Icons.comment_outlined, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            Text(
              '${comments.length} commentaire${comments.length > 1 ? 's' : ''}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommentsBottomSheet extends StatelessWidget {
  final TextEditingController commentController;
  final Future<void> Function() onPostComment;
  final List<Comment> comments;
  final bool isLoading;

  const _CommentsBottomSheet({
    Key? key,
    required this.commentController,
    required this.onPostComment,
    required this.comments,
    required this.isLoading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: _buildCommentsList(scrollController),
                ),
                _buildCommentInput(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Commentaires',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Divider(height: 1, color: Colors.grey[200]),
      ],
    );
  }

  Widget _buildCommentsList(ScrollController controller) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (comments.isEmpty) {
      return const Center(
        child: Text(
          'Aucun commentaire pour le moment',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
        ),
      );
    }

    return ListView.separated(
      controller: controller,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: comments.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) => _CommentItem(comment: comments[index]),
    );
  }

  Widget _buildCommentInput(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: commentController,
              decoration: InputDecoration(
                hintText: 'Écrivez un commentaire...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: onPostComment,
            icon: const Icon(Icons.send),
            color: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }
}

class _CommentItem extends StatelessWidget {
  final Comment comment;

  const _CommentItem({
    Key? key,
    required this.comment,
  }) : super(key: key);

  String _formatDate(DateTime date) {
    const months = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                radius: 20,
                child: Text(
                  (comment.user?.name ?? 'A')[0].toUpperCase(),
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.user?.name ?? 'Anonyme',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatDate(comment.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            comment.content,
            style: const TextStyle(fontSize: 15, height: 1.4),
          ),
        ],
      ),
    );
  }
}