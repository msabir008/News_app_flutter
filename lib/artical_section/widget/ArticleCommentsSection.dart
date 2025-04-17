import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ArticleCommentsSection extends StatelessWidget {
  final int commentCount;
  final List<dynamic> comments;
  final bool isLoadingComments;
  final TextEditingController commentController;
  final Function onPostComment;
  final Function onFetchComments;
  final Function(String, String)? onEditComment;
  final Function(String)? onDeleteComment;

  const ArticleCommentsSection({
    Key? key,
    required this.commentCount,
    required this.comments,
    required this.isLoadingComments,
    required this.commentController,
    required this.onPostComment,
    required this.onFetchComments,
    this.onEditComment,
    this.onDeleteComment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 24),
        Text(
          'Comments ($commentCount)',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),

        // Comment input field
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: commentController,
                decoration: InputDecoration(
                  hintText: 'Add a comment...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                maxLines: 3,
                minLines: 1,
              ),
            ),
            SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => onPostComment(),
              child: Text('Post'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ],
        ),

        SizedBox(height: 16),

        // Comments list
        if (isLoadingComments)
          Center(child: CircularProgressIndicator())
        else if (comments.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'No comments yet. Be the first to comment!',
                style: TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: comments.length,
            separatorBuilder: (context, index) => Divider(),
            itemBuilder: (context, index) {
              final comment = comments[index];
              return CommentItem(
                comment: comment,
                onEdit: onEditComment,
                onDelete: onDeleteComment,
              );
            },
          ),

        if (commentCount > 0 && !isLoadingComments)
          TextButton(
            onPressed: () => onFetchComments(),
            child: Text('Refresh Comments'),
          ),
      ],
    );
  }
}


class CommentItem extends StatefulWidget {
  final dynamic comment;
  final Function(String, String)? onEdit;
  final Function(String)? onDelete;

  const CommentItem({
    Key? key,
    required this.comment,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  _CommentItemState createState() => _CommentItemState();
}

class _CommentItemState extends State<CommentItem> {
  bool isEditing = false;
  late TextEditingController editController;
  bool isCurrentUserComment = false;

  @override
  void initState() {
    super.initState();
    // Handle both possible data structures (String or Map)
    String commentText = '';
    if (widget.comment is Map) {
      commentText = widget.comment['comment'] ?? '';
    } else if (widget.comment is String) {
      commentText = widget.comment;
    }
    editController = TextEditingController(text: commentText);

    // Check if this comment belongs to current user
    _checkIfCurrentUserComment();
  }

  @override
  void dispose() {
    editController.dispose();
    super.dispose();
  }

  // Method to parse user data with double JSON encoding
  Map<String, dynamic> getParsedUser(String data) {
    try {
      // First parse to remove outer quotes
      final firstParse = json.decode(data);
      // Second parse to get the actual object
      if (firstParse is String) {
        return json.decode(firstParse);
      } else if (firstParse is Map) {
        return Map<String, dynamic>.from(firstParse);
      }
      return {};
    } catch (e) {
      print('Error parsing user data: $e');
      return {};
    }
  }

  // Check if the current user is the author of this comment
  Future<void> _checkIfCurrentUserComment() async {
    if (widget.comment is! Map) {
      setState(() => isCurrentUserComment = false);
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      String? username;
      String? email;

      // Try to get username and email directly
      username = prefs.getString('username');
      email = prefs.getString('email');

      // If not found directly, try from user object with double parsing
      if (username == null || email == null || username.isEmpty || email.isEmpty) {
        final userJson = prefs.getString('user');
        if (userJson != null) {
          try {
            final userData = getParsedUser(userJson);
            username = userData['username'] ?? '';
            email = userData['email'] ?? '';
          } catch (e) {
            print('Error parsing user JSON: $e');
          }
        }
      }

      if (username == null || username.isEmpty) {
        setState(() => isCurrentUserComment = false);
        return;
      }

      // Check if username or email matches the comment author
      String commentUsername = widget.comment['user_name'] ?? widget.comment['username'] ?? '';
      String commentEmail = widget.comment['user_email'] ?? '';

      setState(() {
        isCurrentUserComment = (username == commentUsername) ||
            (email != null && email.isNotEmpty && email == commentEmail);
      });
    } catch (e) {
      print('Error checking if comment belongs to current user: $e');
      setState(() => isCurrentUserComment = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Handle both possible data structures
    String username = '';
    String date = '';
    String commentId = '';
    String commentText = '';

    if (widget.comment is Map) {
      // Check for all possible keys where username might be stored
      username = widget.comment['user_name'] ?? widget.comment['username'] ?? '';

      // If still empty, try checking nested user object if it exists
      if (username.isEmpty && widget.comment['user'] != null) {
        final user = widget.comment['user'];
        if (user is Map) {
          username = user['name'] ?? user['username'] ?? '';
        }
      }

      // Only use 'Anonymous' if we couldn't find a username anywhere
      if (username.isEmpty) {
        username = 'Anonymous';
      }

      date = widget.comment['date'] ?? widget.comment['created_at'] ?? '';
      commentId = (widget.comment['id'] ?? widget.comment['comment_id'] ?? '').toString();
      commentText = widget.comment['comment'] ?? '';
    } else if (widget.comment is String) {
      // When comment is just a string, we can't extract a username
      username = 'Anonymous';
      commentText = widget.comment;
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.grey.shade300,
                child: Text(
                  username.isNotEmpty ? username[0].toUpperCase() : 'A',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      username,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (date.isNotEmpty)
                      Text(
                        date,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                  ],
                ),
              ),
              if (isCurrentUserComment && widget.onEdit != null && widget.onDelete != null)
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      setState(() {
                        isEditing = true;
                      });
                    } else if (value == 'delete') {
                      widget.onDelete?.call(commentId);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Text('Edit'),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                  ],
                ),
            ],
          ),
          SizedBox(height: 8),
          if (isEditing)
            Column(
              children: [
                TextField(
                  controller: editController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.all(8),
                  ),
                  maxLines: 3,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          isEditing = false;
                        });
                      },
                      child: Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (widget.onEdit != null && commentId.isNotEmpty) {
                          widget.onEdit!(commentId, editController.text);
                        }
                        setState(() {
                          isEditing = false;
                        });
                      },
                      child: Text('Save'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            )
          else
            Text(commentText),
        ],
      ),
    );
  }
}