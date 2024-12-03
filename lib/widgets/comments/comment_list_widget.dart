import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:register/models/comment_model.dart';

class CommentsList extends StatelessWidget {
  final List<Comment> comments;
  final bool isLoading;

  const CommentsList({
    Key? key,
    required this.comments,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (comments.isEmpty)
              const Center(
                child: Text(
                  'Aucun commentaire pour le moment',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: comments.length,
                itemBuilder: (context, index) {
                  final comment = comments[index];
                  return _buildCommentCard(comment);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentCard(Comment comment) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Text(
                    comment.user?.name?.isNotEmpty == true 
                        ? comment.user!.name![0].toUpperCase() 
                        : '?',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comment.user?.name ?? 'Utilisateur inconnu',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        comment.content.isNotEmpty
                            ? comment.content
                            : 'Contenu indisponible',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Posté le ${_formatDate(comment.createdAt ?? DateTime.now())}',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy à HH:mm').format(date);
  }
}