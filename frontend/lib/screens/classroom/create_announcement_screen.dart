import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../models/course_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/course_provider.dart';
import '../../widgets/user_avatar.dart';

class CreateAnnouncementScreen extends StatefulWidget {
  final CourseModel course;
  const CreateAnnouncementScreen({super.key, required this.course});

  @override
  State<CreateAnnouncementScreen> createState() =>
      _CreateAnnouncementScreenState();
}

class _CreateAnnouncementScreenState extends State<CreateAnnouncementScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _post() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final user = context.read<AuthProvider>().current;
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);
    final err = await context.read<CourseProvider>().addPost(
      widget.course.id,
      user?.name ?? 'Saya',
      text,
    );
    if (err != null) {
      messenger.showSnackBar(SnackBar(content: Text(err)));
      return;
    }
    nav.pop();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().current;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Pengumuman'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton(onPressed: _post, child: const Text('Posting')),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                if (user != null)
                  UserAvatar(name: user.name, color: user.color, size: 44),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.course.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _controller,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                style: const TextStyle(fontSize: 17),
                decoration: const InputDecoration(
                  hintText: 'Umumkan sesuatu kepada kelas',
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
