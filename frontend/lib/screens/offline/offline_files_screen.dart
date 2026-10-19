import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../widgets/app_drawer.dart';

class OfflineFilesScreen extends StatelessWidget {
  const OfflineFilesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(title: const Text('File offline')),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.task_alt_rounded,
              size: 72,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 16),
            Text(
              'Tidak ada file offline',
              style: TextStyle(fontSize: 18, color: AppColors.textPrimary),
            ),
            SizedBox(height: 8),
            Text(
              'File yang Anda simpan akan muncul di sini',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
