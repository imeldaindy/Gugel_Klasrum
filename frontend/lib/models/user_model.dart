import 'package:flutter/material.dart';

class UserModel {
  final int id;
  final String name;
  final String email;
  final Color color;
  final String? photoUrl;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.color = AppAvatarColors.teal,
    this.photoUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> j) => UserModel(
    id: j['id'],
    name: j['name'],
    email: j['email'] ?? '',
    photoUrl: j['photo_url'],
  );
}

class AppAvatarColors {
  static const teal = Color(0xFF00A58E);
  static const orange = Color(0xFFFF5722);
  static const green = Color(0xFF43A047);
  static const brown = Color(0xFF6D4C41);
  static const grey = Color(0xFF78909C);
  static const red = Color(0xFFE53935);
}
