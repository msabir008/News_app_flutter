// profile_avatar_widget.dart
import 'package:flutter/material.dart';

class ProfileAvatarWidget extends StatelessWidget {
  final String firstLetter;

  const ProfileAvatarWidget({
    Key? key,
    required this.firstLetter,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Stack(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.grey[300],
              child: Text(
                firstLetter,
                style: const TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  shape: BoxShape.circle,
                ),
                padding: EdgeInsets.all(4),
                child: Icon(
                  Icons.camera_alt,
                  color: Colors.grey[700],
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}