import 'package:flutter/material.dart';
import 'package:register/models/comment_model.dart';
class CommentSection extends StatefulWidget {
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

  @override
  _CommentSectionState createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Commentaires',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[900],
          ),
        ),
        const SizedBox(height: 10),
        if (widget.isLoading)
          const Center(child: CircularProgressIndicator())
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.comments.length,
            itemBuilder: (context, index) {
              final comment = widget.comments[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text(
                    comment.user?.name ?? 'Utilisateur anonyme',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(comment.content),
                  trailing: Text(
                    '${comment.createdAt.day}/${comment.createdAt.month}/${comment.createdAt.year}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              );
            },
          ),
        TextField(
          controller: widget.commentController,
          decoration: InputDecoration(
            labelText: 'Ajouter un commentaire',
            suffixIcon: IconButton(
              icon: const Icon(Icons.send),
              onPressed: () {
                widget.onPostComment();
              },
            ),
          ),
        ),
      ],
    );
  }
} 