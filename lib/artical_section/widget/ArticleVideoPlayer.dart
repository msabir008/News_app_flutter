import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';

class ArticleVideoPlayer extends StatelessWidget {
  final ChewieController chewieController;

  const ArticleVideoPlayer({required this.chewieController});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Video",
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12.0),
        Container(
          height: 220,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Chewie(controller: chewieController),
          ),
        ),
        SizedBox(height: 24.0),
      ],
    );
  }
}