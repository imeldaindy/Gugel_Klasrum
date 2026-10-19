import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../screens/feedback/feedback_screen.dart';

/// Tombol titik tiga: Kirim masukan + Bantuan.
class MoreMenuButton extends StatelessWidget {
  const MoreMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      color: AppColors.surfaceHigh,
      onSelected: (v) {
        if (v == 'feedback') {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const FeedbackScreen()));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Pusat bantuan belum tersedia')));
        }
      },
      itemBuilder: (_) => const [
        PopupMenuItem(value: 'feedback', child: Text('Kirim masukan')),
        PopupMenuItem(value: 'help', child: Text('Bantuan')),
      ],
    );
  }
}
