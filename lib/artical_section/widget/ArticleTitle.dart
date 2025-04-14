import 'package:flutter/material.dart';

class ArticleTitle extends StatelessWidget {
  final String title;
  final String date;

  const ArticleTitle({required this.title, required this.date});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12.0),
        Text(
          date,
          style: TextStyle(
            color: Colors.grey,
            fontSize: 12.0,
          ),
        ),
        SizedBox(height: 20.0),
      ],
    );
  }
}