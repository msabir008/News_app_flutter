// related_videos_widget.dart
import 'package:flutter/material.dart';

class RelatedVideosWidget extends StatelessWidget {
  final List<Map<String, dynamic>> relatedVideos;
  final Function(Map<String, dynamic>) onVideoSelected;

  const RelatedVideosWidget({
    Key? key,
    required this.relatedVideos,
    required this.onVideoSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (relatedVideos.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: Text(
            'No related videos available',
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
        ),
      );
    }

    return Column(
      children: relatedVideos.map((video) => _buildRelatedVideoItem(video, context)).toList(),
    );
  }

  Widget _buildRelatedVideoItem(Map<String, dynamic> video, BuildContext context) {
    return InkWell(
      onTap: () {
        if (video['isVideo']) {
          onVideoSelected(video);
        }
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    video['image'] ?? 'assets/images/placeholder.png',
                    width: 120,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/images/placeholder.png',
                        width: 120,
                        height: 70,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
                if (video['isVideo'])
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Text(
                        '3:45',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(width: 12),

            // Video details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video['title'] ?? 'Untitled Video',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '10K views • 1 day ago',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Menu icon
            Icon(
              Icons.more_vert,
              color: Colors.grey.shade600,
            ),
          ],
        ),
      ),
    );
  }
}