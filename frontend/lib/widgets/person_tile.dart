import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import 'user_avatar.dart';

class PersonTile extends StatelessWidget {
  final String name;
  final Color color;

  const PersonTile({super.key, required this.name, required this.color});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: UserAvatar(name: name, color: color, size: 52),
      title: Text(
        name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 20, color: AppColors.textPrimary),
      ),
      onTap: () {},
    );
  }
}
