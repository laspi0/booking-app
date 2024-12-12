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
  void _showCommentsBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, controller) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Drag handle
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    width: 60,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  
                  // Title
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Text(
                      'Discussions',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  // Comments List
                  Expanded(
                    child: widget.isLoading
                        ? Center(
                            child: CircularProgressIndicator(
                              color: Theme.of(context).primaryColor,
                            ),
                          )
                        : ListView.separated(
                            controller: controller,
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            itemCount: widget.comments.length,
                            separatorBuilder: (context, index) => Divider(
                              color: Colors.grey[200],
                              height: 1,
                            ),
                            itemBuilder: (context, index) {
                              final comment = widget.comments[index];
                              return _buildCommentCard(comment);
                            },
                          ),
                  ),

                  // Comment Input
                  _buildCommentInput(),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCommentCard(Comment comment) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[200]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                child: Text(
                  (comment.user?.name ?? 'A')[0].toUpperCase(),
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.user?.name ?? 'Utilisateur anonyme',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
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
          SizedBox(height: 12),
          Text(
            comment.content,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[800],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                controller: widget.commentController,
                decoration: InputDecoration(
                  hintText: 'Écrivez votre commentaire...',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  border: InputBorder.none,
                ),
                maxLines: null,
              ),
            ),
          ),
          SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.send, color: Colors.white),
              onPressed: () {
                if (widget.commentController.text.isNotEmpty) {
                  widget.onPostComment();
                  widget.commentController.clear();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day} ${_getMonthName(date.month)} ${date.year}';
  }

  String _getMonthName(int month) {
    const months = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin', 
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: _showCommentsBottomSheet,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(
                  Icons.comment_outlined,
                  color: Theme.of(context).primaryColor,
                ),
                SizedBox(width: 10),
                Text(
                  '${widget.comments.length} commentaires',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}