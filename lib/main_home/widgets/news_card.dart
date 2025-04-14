import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:share_plus/share_plus.dart';
import '../../artical_section/ArticleDetailScreen.dart';
import '../../video_player_section/video_player.dart';
import '../utils/api_service.dart';
import '../utils/data_fromet.dart';

class NewsCard extends StatelessWidget {
  final dynamic post;
  final String? userId;
  final Map<String, dynamic> reactions;
  final Function(String, String) onToggleReaction;
  final ApiService apiService;

  const NewsCard({
    Key? key,
    required this.post,
    required this.userId,
    required this.reactions,
    required this.onToggleReaction,
    required this.apiService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine image URL
    String imageUrl = post['thumb'] != null
        ? post['thumb']
        : 'assets/images/placeholder.png';

    String itemId = post['id']?.toString() ?? '';
    bool isVideo = post['type'] == 'video';

    // Get reactions for this post
    int likeCount = 0;
    int dislikeCount = 0;

    if (reactions.containsKey(itemId)) {
      likeCount = reactions[itemId]?.where((r) => r['type'] == 'like')?.length ?? 0;
      dislikeCount = reactions[itemId]?.where((r) => r['type'] == 'dislike')?.length ?? 0;
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 3, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          if (isVideo) {
            _openVideoPlayer(context, post);
          } else {
            _openArticleDetail(context, post);
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageSection(isVideo, imageUrl),
            _buildContentSection(context, itemId, likeCount, dislikeCount),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(bool isVideo, String imageUrl) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
          ),
          child: Image.network(
            imageUrl,
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Image.asset(
                'assets/images/placeholder.png',
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              );
            },
          ),
        ),
        // Category tag
        Positioned(
          top: 10,
          left: 10,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              (post['type'] ?? 'News').toUpperCase(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        // Play button for video
        if (isVideo)
          Positioned.fill(
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  shape: BoxShape.circle,
                ),
                padding: EdgeInsets.all(12),
                child: Icon(
                  Icons.play_arrow,
                  color: Colors.grey.shade700,
                  size: 32,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildContentSection(BuildContext context, String itemId, int likeCount, int dislikeCount) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            post['title'] ?? 'Untitled',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              height: 1.3,
            ),
          ),
          SizedBox(height: 12),
          // Time and category information
          Row(
            children: [
              Text(
                post['type'] ?? 'News',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                ),
              ),
              Text(
                ' • ',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                ),
              ),
              Text(
                DateFormatter.formatDate(post['published_at']),
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildReactionButton(context, itemId, likeCount.toString()),
              _buildDislikeButton(itemId, dislikeCount.toString()),
              _buildCommentButton(itemId, '0'),
              _buildShareButton(context, itemId, post),
            ],
          ),
        ],
      ),
    );
  }

  // Reaction Button with API Integration and Reaction Picker
  Widget _buildReactionButton(BuildContext context, String itemId, String count) {
    bool isLiked = false;
    String userReactionType = 'like'; // Default reaction type

    // Check if user has liked or reacted to this post
    if (userId != null && reactions.containsKey(itemId)) {
      var userReaction = reactions[itemId]?.firstWhere(
            (r) => r['user_id'].toString() == userId,
        orElse: () => null,
      );

      if (userReaction != null) {
        isLiked = true;
        userReactionType = userReaction['type'] ?? 'like';
      }
    }

    return InkWell(
      onTap: () {
        // Show reaction picker
        _showReactionPicker(context, itemId);
      },
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Row(
          children: [
            // Display appropriate reaction icon if user has reacted
            if (isLiked && userReactionType != 'like' && userReactionType != 'dislike')
              Image.network(
                'https://new.hardknocknews.tv/assets/images/reactions/${userReactionType.toLowerCase()}.gif',
                width: 24,
                height: 24,
                errorBuilder: (context, error, stackTrace) {
                  return SvgPicture.asset(
                    'assets/images/like2.svg',
                    width: 20,
                    height: 20,
                    color: Colors.black,
                  );
                },
              )
            else
              SvgPicture.asset(
                isLiked ? 'assets/images/like2.svg' : 'assets/images/like1.svg',
                width: 20,
                height: 20,
                color: isLiked ? Colors.black : Colors.black,
              ),
            SizedBox(width: 6),
            Text(
              count,
              style: TextStyle(
                color: isLiked ? Colors.black : Colors.black,
                fontSize: 14,
                fontWeight: isLiked ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReactionPicker(BuildContext context, String itemId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Choose a Reaction",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 15,
                  runSpacing: 15,
                  children: [
                    _buildReactionItem(context, itemId, 'awesome', 'AWESOME!', '/assets/images/reactions/awesome.gif'),
                    _buildReactionItem(context, itemId, 'nice', 'NICE', '/assets/images/reactions/nice.png'),
                    _buildReactionItem(context, itemId, 'loved', 'LOVED', '/assets/images/reactions/loved.gif'),
                    _buildReactionItem(context, itemId, 'lol', 'LOL', '/assets/images/reactions/lol.gif'),
                    _buildReactionItem(context, itemId, 'funny', 'FUNNY', '/assets/images/reactions/funny.gif'),
                    _buildReactionItem(context, itemId, 'fail', 'FAIL!', '/assets/images/reactions/fail.gif'),
                    _buildReactionItem(context, itemId, 'omg', 'OMG!', '/assets/images/reactions/wow.gif'),
                    _buildReactionItem(context, itemId, 'ew', 'EW!', '/assets/images/reactions/cry.gif'),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildReactionItem(BuildContext context, String itemId, String reactionType, String name, String iconPath) {
    return InkWell(
      onTap: () {
        onToggleReaction(itemId, reactionType);
        Navigator.pop(context);
      },
      child: Column(
        children: [
          Image.network(
            'https://new.hardknocknews.tv$iconPath',
            width: 40,
            height: 40,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 40,
                height: 40,
                color: Colors.grey[300],
                child: Icon(Icons.sentiment_satisfied_alt, color: Colors.grey[600]),
              );
            },
          ),
          SizedBox(height: 5),
          Text(
            name,
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  // Dislike Button with API Integration and Toggle Functionality
  Widget _buildDislikeButton(String itemId, String count) {
    bool isDisliked = false;

    // Check if user has disliked this post
    if (userId != null && reactions.containsKey(itemId)) {
      isDisliked = reactions[itemId]?.any((r) =>
      r['type'] == 'dislike' && r['user_id'].toString() == userId) ?? false;
    }

    return InkWell(
      onTap: () {
        // Toggle dislike reaction
        if (itemId.isNotEmpty) {
          onToggleReaction(itemId, 'dislike');
        }
      },
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Row(
          children: [
            SvgPicture.asset(
              isDisliked ? 'assets/images/dislike2.svg' : 'assets/images/dislike1.svg',
              width: 20,
              height: 20,
              color: isDisliked ? Colors.black : Colors.black,
            ),
            SizedBox(width: 6),
            Text(
              count,
              style: TextStyle(
                color: isDisliked ? Colors.black : Colors.black,
                fontSize: 14,
                fontWeight: isDisliked ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentButton(String itemId, String count) {
    return InkWell(
      onTap: () {
        // Add comment functionality
      },
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Row(
          children: [
            SvgPicture.asset(
              'assets/images/comment.svg',
              width: 20,
              height: 20,
              color: Colors.black,
            ),
            SizedBox(width: 6),
            Text(
              count,
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareButton(BuildContext context, String itemId, dynamic post) {
    return InkWell(
      onTap: () {
        _sharePost(context, post);
      },
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Row(
          children: [
            SvgPicture.asset(
              'assets/images/share.svg',
              width: 20,
              height: 20,
              color: Colors.black,
            ),
            SizedBox(width: 6),
            Text(
              'Share',
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sharePost(BuildContext context, dynamic post) async {
    final String title = post['title'] ?? 'Check out this post';
    final String url = 'https://new.hardknocknews.tv/post/${post['id']}';
    final String shareText = '$title\n\n$url';

    try {
      await Share.share(shareText, subject: title);
    } catch (e) {
      print('Error sharing post: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to share post at this time')),
      );
    }
  }

  void _openVideoPlayer(BuildContext context, dynamic post) {
    var videoEntry = post['entries']?.firstWhere(
          (entry) => entry['type'] == 'video',
      orElse: () => null,
    );

    if (videoEntry != null && videoEntry['video'] != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoPlayerScreen(
            videoPath: 'https://new.hardknocknews.tv/${videoEntry['video']}',
            title: post['title'] ?? 'Video',
            description: post['body'] ?? '',
            relatedVideos: [], // You can implement related videos logic
          ),
        ),
      );
    }
  }

  void _openArticleDetail(BuildContext context, dynamic post) {
    String? videoUrl = null;

    // Find video URL if available
    var videoEntry = post['entries']?.firstWhere(
          (entry) => entry['type'] == 'video',
      orElse: () => null,
    );

    if (videoEntry != null && videoEntry['video'] != null) {
      videoUrl = videoEntry['video'];
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArticleDetailScreen(
          title: post['title'] ?? 'Article',
          description: _getArticleBody(post),
          image: post['thumb'] ?? 'assets/images/placeholder.png',
          category: post['type'] ?? 'News',
          itemId: post['id']?.toString() ?? '',
          reactions: reactions,
          onToggleReaction: onToggleReaction,
          apiService: apiService,
          userId: userId,
          videoUrl: videoUrl,
        ),
      ),
    );
  }
  String _getArticleBody(dynamic post) {
    var textEntry = post['entries']?.firstWhere(
          (entry) => entry['type'] == 'text',
      orElse: () => null,
    );

    return textEntry != null ? textEntry['body'] ?? post['body'] ?? '' : post['body'] ?? '';
  }
}