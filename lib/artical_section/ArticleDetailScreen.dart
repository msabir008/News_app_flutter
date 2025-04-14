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
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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

  Future<void> _fetchComments() async {
    if (widget.itemId.isEmpty) return;

    setState(() => isLoadingComments = true);

    try {
      final response = await http.get(
        Uri.parse('https://new.hardknocknews.tv/easy/public/api/comments/content/Post_${widget.itemId}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          comments = data['data'] ?? [];
          commentCount = comments.length;
        });
      } else {
        throw Exception('Failed to load comments');
      }
    } catch (error) {
      print('Error fetching comments: $error');
    } finally {
      setState(() => isLoadingComments = false);
    }
  }

  Future<void> _postComment() async {
    if (commentController.text.isEmpty || widget.itemId.isEmpty) return;

    setState(() => isLoadingComments = true);

    try {
      final response = await http.post(
        Uri.parse('https://new.hardknocknews.tv/easy/public/api/comments'),
        body: {
          'content_id': widget.itemId,
          'content_type': 'Post',
          'comment': commentController.text,
        },
      );

      if (response.statusCode == 200) {
        commentController.clear();
        _fetchComments();
      } else {
        throw Exception('Failed to post comment');
      }
    } catch (error) {
      print('Error posting comment: $error');
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

  String _setVideoUrl(String video) {
    if (video.isEmpty) return '';
    return video.startsWith('http') ? video : 'https://new.hardknocknews.tv/$video';
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
