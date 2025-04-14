import 'package:flutter/material.dart';
import 'package:html/parser.dart' as htmlparser;

class ArticleTextBlock extends StatelessWidget {
  final String text;

  const ArticleTextBlock({required this.text});

  @override
  Widget build(BuildContext context) {
    var document = htmlparser.parse(text);
    String parsedText = document.body?.text ?? text;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Text(
        parsedText,
        style: TextStyle(
          fontSize: 16.0,
          height: 1.6,
        ),
      ),
    );
  }
}