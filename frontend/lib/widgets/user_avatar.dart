import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String name;
  final Color color;
  final double size;
  final String? photoUrl;

  const UserAvatar({
    super.key,
    required this.name,
    required this.color,
    this.size = 40,
    this.photoUrl,
  });

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: color,
      backgroundImage: photoUrl != null ? NetworkImage(photoUrl!) : null,
      child: photoUrl == null
          ? Text(
              initial,
              style: TextStyle(fontSize: size * 0.45, color: Colors.white),
            )
          : null,
    );
  }
}
