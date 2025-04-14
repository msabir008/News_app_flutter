import 'package:flutter/material.dart';

class ArticleCommentsSection extends StatelessWidget {
  final int commentCount;
  final List<dynamic> comments;
  final bool isLoadingComments;
  final TextEditingController commentController;
  final VoidCallback onPostComment;
  final VoidCallback onFetchComments;

  const ArticleCommentsSection({
    required this.commentCount,
    required this.comments,
    required this.isLoadingComments,
    required this.commentController,
    required this.onPostComment,
    required this.onFetchComments,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 24.0),
        Text(
          "Comments ($commentCount)",
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16.0),
        Container(
          height: 50.0,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(25.0),
          ),
          child: TextField(
            controller: commentController,
            decoration: InputDecoration(
              hintText: "Add a comment...",
              prefixIcon: CircleAvatar(
                radius: 14,
                backgroundColor: Colors.black,
                child: Icon(Icons.person, size: 16, color: Colors.white),
              ),
              suffixIcon: IconButton(
                icon: Icon(Icons.send, color: Colors.black),
                onPressed: onPostComment,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                vertical: 10.0,
                horizontal: 10.0,
              ),
            ),
          ),
        ),
        SizedBox(height: 20.0),
        if (isLoadingComments)
          Center(child: CircularProgressIndicator())
        else if (comments.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Center(
              child: Text(
                "No comments yet",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          ...comments.map((comment) {
            return _CommentItem(
              username: comment['user']['name'] ?? 'Anonymous',
              comment: comment['comment'] ?? '',
              time: _formatTimeAgo(comment['created_at'] ?? ''),
              likes: comment['likes_count'] ?? 0,
            );
          }).toList(),
        if (comments.isNotEmpty && comments.length < commentCount)
          Center(
            child: TextButton(
              onPressed: onFetchComments,
              child: Text(
                "View all $commentCount comments",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        SizedBox(height: 30.0),
      ],
    );
  }

  String _formatTimeAgo(String dateString) {
    return dateString; // Implement actual time formatting
  }
}

class _CommentItem extends StatelessWidget {
  final String username;
  final String comment;
  final String time;
  final int likes;

  const _CommentItem({
    required this.username,
    required this.comment,
    required this.time,
    required this.likes,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.grey.shade300,
            child: Icon(Icons.person, size: 20, color: Colors.grey.shade700),
          ),
          SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      username,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.0,
                      ),
                    ),
                    Text(
                      time,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12.0,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.0),
                Text(
                  comment,
                  style: TextStyle(fontSize: 14.0),
                ),
                SizedBox(height: 8.0),
                Row(
                  children: [
                    Icon(Icons.thumb_up, size: 12, color: Colors.grey),
                    SizedBox(width: 4.0),
                    Text(
                      "$likes",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12.0,
                      ),
                    ),
                    SizedBox(width: 16.0),
                    Text(
                      "Reply",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}