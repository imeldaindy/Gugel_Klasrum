import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/date_helper.dart';
import '../../models/course_model.dart';
import '../../models/post_model.dart';
import '../../providers/course_provider.dart';
import '../../widgets/more_menu_button.dart';
import '../../widgets/user_avatar.dart';
import 'assignment_detail_screen.dart';
import 'class_comments_screen.dart';

/// Dipanggil saat kartu di Forum ditekan.
/// Kartu "Tugas baru: ..." membuka detail tugas, pengumuman membuka detail pengumuman.
void openPost(BuildContext context, CourseModel course, PostModel post) {
  if (post.isAssignmentNotice) {
    final list = context.read<CourseProvider>().assignmentsOf(course.id);
    if (list.isNotEmpty) {
      final match = list.firstWhere(
        (a) => a.title == post.content,
        orElse: () => list.first,
      );
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => AssignmentDetailScreen(assignment: match)),
      );
      return;
    }
  }
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => PostDetailScreen(post: post)),
  );
}

void openPostComments(BuildContext context, PostModel post) {
  Navigator.push(
    context,
    MaterialPageRoute(
        builder: (_) => ClassCommentsScreen(commentKey: 'p_${post.id}')),
  );
}

class PostDetailScreen extends StatelessWidget {
  final PostModel post;
  const PostDetailScreen({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final key = 'p_${post.id}';
    final comments = context.watch<CourseProvider>().commentsOf(key);

    return Scaffold(
      backgroundColor: AppColors.surfaceHigh,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceHigh,
        actions: const [MoreMenuButton()],
      ),
      body: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Row(children: [
                    UserAvatar(
                        name: post.authorName,
                        color: const Color(0xFF78909C),
                        size: 56),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(post.authorName,
                            style: const TextStyle(fontSize: 20)),
                        Text(DateHelper.time(post.createdAt),
                            style: const TextStyle(
                                fontSize: 16,
                                color: AppColors.textSecondary)),
                      ],
                    ),
                  ]),
                  const SizedBox(height: 20),
                  Text(post.content,
                      style: const TextStyle(fontSize: 17, height: 1.45)),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 16),
                  const Text('Komentar kelas',
                      style: TextStyle(fontSize: 22)),
                  const SizedBox(height: 16),
                  if (comments.isEmpty)
                    const Text('Tidak ada komentar',
                        style: TextStyle(fontSize: 16))
                  else
                    CommentList(comments: comments, shrink: true),
                ],
              ),
            ),
            CommentInput(commentKey: key),
          ],
        ),
      ),
    );
  }
}
