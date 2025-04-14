import 'package:flutter/material.dart';

class ArticleImageBlock extends StatelessWidget {
  final String imageUrl;

  const ArticleImageBlock({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Image.network(
          imageUrl,
          width: double.infinity,
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
    );
  }
}