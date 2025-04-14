// description_widget.dart
import 'package:flutter/material.dart';

class DescriptionWidget extends StatefulWidget {
  final String description;

  const DescriptionWidget({
    Key? key,
    required this.description,
  }) : super(key: key);

  @override
  _DescriptionWidgetState createState() => _DescriptionWidgetState();
}

class _DescriptionWidgetState extends State<DescriptionWidget> {
  bool _expandDescription = false;

  void _toggleDescription() {
    setState(() {
      _expandDescription = !_expandDescription;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.description,
            maxLines: _expandDescription ? null : 2,
            overflow: _expandDescription ? TextOverflow.visible : TextOverflow.ellipsis,
            style: TextStyle(fontSize: 14),
          ),
          InkWell(
            onTap: _toggleDescription,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                _expandDescription ? "Show less" : "Show description",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}