import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class ArticleDescription extends StatelessWidget {
  final String description;
  final bool showFullDescription;
  final VoidCallback onShowMore;

  const ArticleDescription({
    required this.description,
    required this.showFullDescription,
    required this.onShowMore,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HtmlWidget(
          description,
          textStyle: TextStyle(
            fontSize: 16.0,
            height: 1.6,
          ),
        ),
        if (!showFullDescription)
          InkWell(
            onTap: onShowMore,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Text(
                    "See More",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.0,
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.black,
                    size: 16.0,
                  ),
                ],
              ),
            ),
          ),
        SizedBox(height: 20.0),
      ],
    );
  }
}