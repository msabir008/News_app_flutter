// video_actions_widget.dart
import 'package:flutter/material.dart';

class VideoActionsWidget extends StatelessWidget {
  const VideoActionsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildActionButton(Icons.thumb_up_outlined, 'Like'),
          _buildActionButton(Icons.thumb_down_outlined, 'Dislike'),
          _buildActionButton(Icons.share, 'Share'),
          _buildActionButton(Icons.playlist_add, 'Save'),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}