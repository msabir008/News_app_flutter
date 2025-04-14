import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  // Base URL for media and APIs
  final String _baseMediaUrl = 'https://new.hardknocknews.tv/upload/media/posts';
  final String _baseApiUrl = 'https://new.hardknocknews.tv/api';

  // Fetch all posts
  Future<List<dynamic>> fetchAllPosts() async {
    final response = await http.get(
      Uri.parse('${_baseApiUrl}/posts/all'),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return jsonResponse['posts'].map((post) {
        // Update thumb URL construction
        if (post['thumb'] != null) {
          post['thumb'] = '${_baseMediaUrl}/${post['thumb']}-s.jpg';
        }
        return post;
      }).toList();
    } else {
      throw Exception('Failed to load posts: ${response.statusCode}');
    }
  }


  // Fetch reactions for all posts
  Future<Map<String, dynamic>> fetchReactions() async {
    final response = await http.get(
      Uri.parse('${_baseApiUrl}/reactions'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load reactions: ${response.statusCode}');
    }
  }

  // Remove reaction by ID
  Future<bool> removeReaction(String reactionId) async {
    final response = await http.delete(
      Uri.parse('${_baseApiUrl}/reactions/remove/${reactionId}'),
    );

    return response.statusCode == 200;
  }
  Future<List<dynamic>> getCommentsByPost(String postId) async {
    try {
      final response = await http.get(
        Uri.parse('https://new.hardknocknews.tv/easy/public/api/comments/content/Post_$postId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          // Add any auth headers if needed
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['data'] ?? [];
      } else {
        print('Failed to load comments: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching comments: $e');
      return [];
    }
  }


  // Add reaction to a post
  Future<Map<String, dynamic>> addReaction(String userId, String postId, String reactionType) async {
    final response = await http.post(
      Uri.parse('${_baseApiUrl}/reactions/add'),
      body: {
        'user_id': userId,
        'post_id': postId,
        'reaction_type': reactionType,
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to add reaction: ${response.statusCode}');
    }
  }
}