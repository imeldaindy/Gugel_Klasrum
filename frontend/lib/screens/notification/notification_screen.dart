import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../widgets/app_drawer.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const items = [
      (
        'Audit Sistem Informasi',
        'Tugas baru: Tugas Audit Program dan Audit Plan',
        '11.31',
      ),
      (
        'Audit Sistem Informasi',
        'Rahadian Bisma memposting pengumuman baru',
        '08.54',
      ),
    ];

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(title: const Text('Notifikasi')),
      body: ListView.separated(
        itemCount: items.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (_, i) {
          final it = items[i];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: AppColors.classAvatar,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.assignment_outlined,
                color: Color(0xFFD3E3FD),
              ),
            ),
            title: Text(it.$2, style: const TextStyle(fontSize: 16)),
            subtitle: Text(
              it.$1,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            trailing: Text(
              it.$3,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          );
        },
      ),
    );
  }
}
