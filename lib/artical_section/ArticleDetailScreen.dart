import 'package:flutter/material.dart';
import 'package:newsapp1/artical_section/widget/ArticleCommentsSection.dart';
import 'package:newsapp1/artical_section/widget/ArticleDescription.dart';
import 'package:newsapp1/artical_section/widget/ArticleImageBlock.dart';
import 'package:newsapp1/artical_section/widget/ArticleInteractions.dart';
import 'package:newsapp1/artical_section/widget/ArticleTextBlock.dart';
import 'package:newsapp1/artical_section/widget/ArticleTitle.dart';
import 'package:newsapp1/artical_section/widget/ArticleVideoPlaceholder.dart';
import 'package:newsapp1/artical_section/widget/ArticleVideoPlayer.dart';
import 'package:newsapp1/artical_section/widget/RelatedArticlesSection.dart';
import 'package:newsapp1/artical_section/widget/article_header_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../breaking_news/newsbreak1.dart';
import '../main_home/utils/api_service.dart';

class ArticleDetailScreen extends StatefulWidget {
  final String title;
  final String description;
  final String image;
  final String category;
  final String itemId;
  final Map<String, dynamic> reactions;
  final Function(String, String)? onToggleReaction;
  final ApiService? apiService;
  final String? userId;
  final String? videoUrl;
  final List<dynamic>? entries;

  const ArticleDetailScreen({
    Key? key,
    required this.title,
    required this.description,
    required this.image,
    required this.category,
    this.itemId = '',
    this.reactions = const {},
    this.onToggleReaction,
    this.apiService,
    this.userId,
    this.videoUrl,
    this.entries,
  }) : super(key: key);

  @override
  _ArticleDetailScreenState createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  bool isSaved = false;
  bool showFullDescription = false;
  late int likeCount;
  late int dislikeCount;
  late bool isLiked;
  late bool isDisliked;
  late String userReactionType;
  int commentCount = 0;
  List<String> extraImageUrls = [];
  List<Map<String, dynamic>> contentBlocks = [];
  List<dynamic> comments = [];
  bool isLoadingComments = false;
  TextEditingController commentController = TextEditingController();

  // Video player controllers
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeReactionState();
    _initializeVideoPlayer();
    _processEntries();
    _fetchComments();
  }

  // Parse user data - works with double JSON encoding
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

  // Get user credentials from shared preferences
  Future<Map<String, String>> getUserCredentials() async {
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

    return {
      'username': username ?? '',
      'email': email ?? '',
    };
  }

  // Sort comments by date (newest first)
  void _sortComments() {
    comments.sort((a, b) {
      String dateA = '';
      String dateB = '';

      if (a is Map) {
        dateA = a['created_at'] ?? a['date'] ?? '';
      }

      if (b is Map) {
        dateB = b['created_at'] ?? b['date'] ?? '';
      }

      return dateB.compareTo(dateA); // Newest first
    });
  }

  Future<void> _fetchComments() async {
    if (widget.itemId.isEmpty) return;

    setState(() => isLoadingComments = true);

    try {
      // Create the content ID in the same format as Angular
      String contentId = 'Post_${widget.itemId}';

      final apiUrl = 'https://new.hardknocknews.tv/easy/public/api/comments/content';

      // Debug log
      print('Fetching comments from: $apiUrl/$contentId');

      final response = await http.get(
        Uri.parse('$apiUrl/$contentId'),
      );

      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Process the response similar to Angular approach
        setState(() {
          if (data is Map && data.containsKey('data')) {
            comments = data['data'] ?? [];
          } else if (data is List) {
            comments = data;
          } else {
            comments = [];
          }

          _sortComments(); // Sort comments after fetching
          commentCount = comments.length;
        });
      } else {
        throw Exception('Failed to load comments: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching comments: $error');
      setState(() {
        comments = [];
        commentCount = 0;
      });
    } finally {
      setState(() => isLoadingComments = false);
    }
  }

  Future<void> _postComment() async {
    if (commentController.text.isEmpty || widget.itemId.isEmpty) return;

    // Get user credentials using our helper method
    final credentials = await getUserCredentials();
    final username = credentials['username'];
    final email = credentials['email'];

    // Check if user is logged in
    if (username == null || username.isEmpty || email == null || email.isEmpty) {
      _showLoginDialog();
      return;
    }

    setState(() => isLoadingComments = true);

    try {
      // Prepare comment data
      final commentData = {
        'comment': commentController.text,
        'type': 'addcomment',
        'content_id': 'Post_${widget.itemId}',
        'content_url': 'https://new.hardknocknews.tv/post/${widget.itemId}',
        'access_domain': 'new.hardknocknews.tv',
        'user_username': username,
        'user_email': email
      };

      print('Posting comment data: $commentData');

      // Try first with regular form data
      var response = await http.post(
        Uri.parse('https://new.hardknocknews.tv/easy/public/api/comments_api/submit'),
        body: commentData,
      );

      print('Response status: ${response.statusCode}, body: ${response.body}');

      // If that fails with a client or server error, try with JSON
      if (response.statusCode >= 400) {
        print('Trying with JSON content type...');
        response = await http.post(
          Uri.parse('https://new.hardknocknews.tv/easy/public/api/comments_api/submit'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(commentData),
        );
        print('JSON response status: ${response.statusCode}, body: ${response.body}');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Success
        commentController.clear();
        await Future.delayed(Duration(milliseconds: 500));
        _fetchComments();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Comment posted successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        throw Exception('Failed to post comment: ${response.statusCode} - ${response.body}');
      }
    } catch (error) {
      print('Error posting comment: $error');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to post comment. Please try again.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    } finally {
      setState(() => isLoadingComments = false);
    }
  }

  // Function to show login dialog when user is not logged in
  void _showLoginDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Login Required'),
          content: Text('You need to login to post a comment.'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Login'),
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate to login page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NewsbreakLoginPage1()),
                );
              },
            ),
          ],
        );
      },
    );
  }

  // Method to check if the current user is the author of a comment
  Future<bool> isUserCommentAuthor(dynamic comment) async {
    if (comment is! Map) return false;

    final credentials = await getUserCredentials();
    final username = credentials['username'];
    final email = credentials['email'];

    if (username == null || username.isEmpty) return false;

    // Check if username or email matches the comment author
    String commentUsername = comment['user_name'] ?? comment['username'] ?? '';
    String commentEmail = comment['user_email'] ?? '';

    return (username == commentUsername) || (email != null && email.isNotEmpty && email == commentEmail);
  }

  // Add this method to edit comments
  Future<void> _editComment(String commentId, String newText) async {
    // Get user credentials
    final credentials = await getUserCredentials();
    final username = credentials['username'];
    final email = credentials['email'];

    // Check if user is logged in
    if (username == null || username.isEmpty || email == null || email.isEmpty) {
      _showLoginDialog();
      return;
    }

    setState(() => isLoadingComments = true);

    try {
      // Prepare edit comment data
      final commentData = {
        'comment': newText,
        'type': 'editcomment',
        'comment_id': commentId,
        'content_id': 'Post_${widget.itemId}',
        'content_url': 'https://new.hardknocknews.tv/post/${widget.itemId}',
        'access_domain': 'new.hardknocknews.tv',
        'user_username': username,
        'user_email': email
      };

      print('Editing comment: $commentData');

      final response = await http.post(
        Uri.parse('https://new.hardknocknews.tv/easy/public/api/comments_api/submit'),
        body: commentData,
      );

      print('Edit response status: ${response.statusCode}, body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        await Future.delayed(Duration(milliseconds: 500));
        _fetchComments(); // Refresh comments after edit

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Comment updated successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        throw Exception('Failed to edit comment: ${response.statusCode} - ${response.body}');
      }
    } catch (error) {
      print('Error editing comment: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update comment. Please try again.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    } finally {
      setState(() => isLoadingComments = false);
    }
  }

  // Add this method to delete a comment
  Future<void> _deleteComment(String commentId) async {
    // Get user credentials
    final credentials = await getUserCredentials();
    final username = credentials['username'];
    final email = credentials['email'];

    // Check if user is logged in
    if (username == null || username.isEmpty || email == null || email.isEmpty) {
      _showLoginDialog();
      return;
    }

    // Show confirmation dialog
    bool confirmDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Comment'),
        content: Text('Are you sure you want to delete this comment?'),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: Text('Delete', style: TextStyle(color: Colors.red)),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    ) ?? false;

    if (!confirmDelete) return;

    setState(() => isLoadingComments = true);

    try {
      final commentData = {
        'type': 'deletecomment',
        'comment_id': commentId,
        'content_id': 'Post_${widget.itemId}',
        'access_domain': 'new.hardknocknews.tv',
        'user_username': username,
        'user_email': email
      };

      final response = await http.post(
        Uri.parse('https://new.hardknocknews.tv/easy/public/api/comments_api/submit'),
        body: commentData,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        await Future.delayed(Duration(milliseconds: 500));
        _fetchComments(); // Refresh comments after delete

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Comment deleted successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        throw Exception('Failed to delete comment: ${response.statusCode} - ${response.body}');
      }
    } catch (error) {
      print('Error deleting comment: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete comment. Please try again.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    } finally {
      setState(() => isLoadingComments = false);
    }
  }

  void _processEntries() {
    if (widget.entries == null || widget.entries!.isEmpty) return;

    for (var entry in widget.entries!) {
      if (entry['type'] == 'image' && entry['image'] != null) {
        String imageUrl = _setImageUrl(entry['image']);
        extraImageUrls.add(imageUrl);
        contentBlocks.add({'type': 'image', 'content': imageUrl});
      } else if (entry['type'] == 'text' && entry['body'] != null) {
        extraImageUrls.add(entry['body']);
        contentBlocks.add({'type': 'text', 'content': entry['body']});
      } else if (entry['type'] == 'video' && entry['video'] != null && widget.videoUrl == null) {
        String videoUrl = _setVideoUrl(entry['video']);
        contentBlocks.add({'type': 'video', 'content': videoUrl});
      }
    }
  }

  String _setImageUrl(String image) {
    if (image.isEmpty) return '';
    return image.startsWith('http') ? image : 'https://new.hardknocknews.tv/$image';
  }

  void _initializeReactionState() {
    likeCount = 0;
    dislikeCount = 0;
    isLiked = false;
    isDisliked = false;
    userReactionType = 'like';

    if (widget.reactions.containsKey(widget.itemId)) {
      likeCount = widget.reactions[widget.itemId]?.where((r) => r['type'] == 'like')?.length ?? 0;
      dislikeCount = widget.reactions[widget.itemId]?.where((r) => r['type'] == 'dislike')?.length ?? 0;

      if (widget.userId != null) {
        var userReaction = widget.reactions[widget.itemId]?.firstWhere(
              (r) => r['user_id'].toString() == widget.userId,
          orElse: () => null,
        );

        if (userReaction != null) {
          userReactionType = userReaction['type'] ?? 'like';
          isLiked = userReactionType == 'like';
          isDisliked = userReactionType == 'dislike';
        }
      }
    }
  }

  String _setVideoUrl(String video) {
    if (video.isEmpty) return '';
    return video.startsWith('http') ? video : 'https://new.hardknocknews.tv/$video';
  }

  void _initializeVideoPlayer() {
    if (widget.videoUrl != null && widget.videoUrl!.isNotEmpty) {
      final String formattedVideoUrl = _setVideoUrl(widget.videoUrl!);
      _videoPlayerController = VideoPlayerController.network(formattedVideoUrl);

      _videoPlayerController!.initialize().then((_) {
        setState(() {
          _chewieController = ChewieController(
            videoPlayerController: _videoPlayerController!,
            aspectRatio: _videoPlayerController!.value.aspectRatio,
            autoPlay: false,
            looping: false,
            showControls: true,
            materialProgressColors: ChewieProgressColors(
              playedColor: Colors.black,
              handleColor: Colors.black,
              backgroundColor: Colors.grey,
              bufferedColor: Colors.grey.shade300,
            ),
            placeholder: Center(child: CircularProgressIndicator()),
            autoInitialize: true,
          );
          _isVideoInitialized = true;
        });
      });
    }
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            backgroundColor: Colors.black,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.category.toUpperCase(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: ArticleHeaderImage(image: widget.image),
            ),
            leading: IconButton(
              icon: CircleAvatar(
                backgroundColor: Colors.black38,
                child: Icon(Icons.arrow_back, color: Colors.white),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ArticleTitle(title: widget.title, date: "March 9, 2025 • 5 min read"),

                  if (widget.description.isNotEmpty)
                    ArticleDescription(
                      description: widget.description,
                      showFullDescription: showFullDescription,
                      onShowMore: () => setState(() => showFullDescription = true),
                    ),

                  if (widget.videoUrl != null && widget.videoUrl!.isNotEmpty && _isVideoInitialized)
                    ArticleVideoPlayer(chewieController: _chewieController!),

                  ...contentBlocks.map((block) {
                    if (block['type'] == 'image') {
                      return ArticleImageBlock(imageUrl: block['content']);
                    } else if (block['type'] == 'text') {
                      return ArticleTextBlock(text: block['content']);
                    } else if (block['type'] == 'video') {
                      return ArticleVideoPlaceholder();
                    }
                    return SizedBox.shrink();
                  }).toList(),

                  ArticleInteractions(
                    itemId: widget.itemId,
                    likeCount: likeCount,
                    dislikeCount: dislikeCount,
                    isLiked: isLiked,
                    isDisliked: isDisliked,
                    userReactionType: userReactionType,
                    commentCount: commentCount,
                    isSaved: isSaved,
                    onToggleReaction: widget.onToggleReaction,
                    onToggleSave: () => setState(() => isSaved = !isSaved),
                  ),

                  ArticleCommentsSection(
                    commentCount: commentCount,
                    comments: comments,
                    isLoadingComments: isLoadingComments,
                    commentController: commentController,
                    onPostComment: _postComment,
                    onFetchComments: _fetchComments,
                    onEditComment: _editComment,
                    onDeleteComment: _deleteComment,
                  ),

                  RelatedArticlesSection(category: widget.category, image: widget.image),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}