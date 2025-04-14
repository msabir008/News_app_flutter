import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ArticleInteractions extends StatelessWidget {
  final String itemId;
  final int likeCount;
  final int dislikeCount;
  final bool isLiked;
  final bool isDisliked;
  final String userReactionType;
  final int commentCount;
  final bool isSaved;
  final Function(String, String)? onToggleReaction;
  final VoidCallback onToggleSave;

  const ArticleInteractions({
    required this.itemId,
    required this.likeCount,
    required this.dislikeCount,
    required this.isLiked,
    required this.isDisliked,
    required this.userReactionType,
    required this.commentCount,
    required this.isSaved,
    this.onToggleReaction,
    required this.onToggleSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.shade300, width: 1.0),
          bottom: BorderSide(color: Colors.grey.shade300, width: 1.0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Was this article helpful?",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
          SizedBox(height: 12.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildReactionButton(context),
              _buildInteractionButton(
                icon: Icons.comment,
                text: "Comment ($commentCount)",
                isActive: false,
                onPressed: () {},
              ),
              _buildDislikeButton(),
              _buildInteractionButton(
                icon: isSaved ? Icons.bookmark : Icons.bookmark_border,
                text: "Save",
                isActive: isSaved,
                onPressed: onToggleSave,
              ),
              _buildInteractionButton(
                icon: Icons.share,
                text: "Share",
                isActive: false,
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReactionButton(BuildContext context) {
    return InkWell(
      onTap: () => _showReactionPicker(context),
      child: Column(
        children: [
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
              color: isLiked ? Colors.black : Colors.grey,
            ),
          SizedBox(height: 4.0),
          Text(
            "Like ($likeCount)",
            style: TextStyle(
              fontSize: 12.0,
              color: isLiked ? Colors.black : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  void _showReactionPicker(BuildContext context) {
    if (onToggleReaction == null) return;

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
                    _buildReactionItem(context, 'awesome', 'AWESOME!', '/assets/images/reactions/awesome.gif'),
                    _buildReactionItem(context, 'nice', 'NICE', '/assets/images/reactions/nice.png'),
                    _buildReactionItem(context, 'loved', 'LOVED', '/assets/images/reactions/loved.gif'),
                    _buildReactionItem(context, 'lol', 'LOL', '/assets/images/reactions/lol.gif'),
                    _buildReactionItem(context, 'funny', 'FUNNY', '/assets/images/reactions/funny.gif'),
                    _buildReactionItem(context, 'fail', 'FAIL!', '/assets/images/reactions/fail.gif'),
                    _buildReactionItem(context, 'omg', 'OMG!', '/assets/images/reactions/wow.gif'),
                    _buildReactionItem(context, 'ew', 'EW!', '/assets/images/reactions/cry.gif'),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildReactionItem(BuildContext context, String reactionType, String name, String iconPath) {
    return InkWell(
      onTap: () {
        if (onToggleReaction != null) {
          onToggleReaction!(itemId, reactionType);
        }
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

  Widget _buildDislikeButton() {
    return InkWell(
      onTap: () {
        if (itemId.isNotEmpty && onToggleReaction != null) {
          onToggleReaction!(itemId, 'dislike');
        }
      },
      child: Column(
        children: [
          SvgPicture.asset(
            isDisliked ? 'assets/images/dislike2.svg' : 'assets/images/dislike1.svg',
            width: 20,
            height: 20,
            color: isDisliked ? Colors.black : Colors.grey,
          ),
          SizedBox(height: 4.0),
          Text(
            "Dislike ($dislikeCount)",
            style: TextStyle(
              fontSize: 12.0,
              color: isDisliked ? Colors.black : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractionButton({
    required IconData icon,
    required String text,
    required bool isActive,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        IconButton(
          icon: Icon(
            icon,
            color: isActive ? Colors.black : Colors.grey,
          ),
          onPressed: onPressed,
        ),
        Text(
          text,
          style: TextStyle(
            fontSize: 12.0,
            color: isActive ? Colors.black : Colors.grey,
          ),
        ),
      ],
    );
  }
}