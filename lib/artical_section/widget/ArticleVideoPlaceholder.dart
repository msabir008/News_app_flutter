import 'package:flutter/material.dart';

class ArticleVideoPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Container(
        height: 220,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Center(
          child: Icon(
            Icons.play_circle_outline,
            color: Colors.white,
            size: 50,
          ),
        ),
      ),
    );
  }
}