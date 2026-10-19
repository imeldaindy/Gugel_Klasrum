import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/utils/date_helper.dart';
import '../models/post_model.dart';
import 'user_avatar.dart';

class PostCard extends StatelessWidget {
  final PostModel post;
  final VoidCallback? onTap;
  final VoidCallback? onComment;
  const PostCard({super.key, required this.post, this.onTap, this.onComment});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: post.isAssignmentNotice
                      ? _assignmentHeader()
                      : _postHeader(),
                ),
                if (!post.isAssignmentNotice)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Text(
                      post.content,
                      style: const TextStyle(
                        fontSize: 17,
                        height: 1.45,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(),
          InkWell(
            onTap: onComment,
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(16),
            ),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Tambahkan komentar kelas',
                style: TextStyle(fontSize: 17, color: AppColors.link),
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }

  Widget _assignmentHeader() {
    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: const BoxDecoration(
            color: AppColors.classAvatar,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.assignment_outlined,
            color: Color(0xFFD3E3FD),
            size: 30,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tugas baru: ${post.content}',
                style: const TextStyle(
                  fontSize: 20,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DateHelper.time(post.createdAt),
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _postHeader() {
    return Row(
      children: [
        UserAvatar(
          name: post.authorName,
          color: const Color(0xFF78909C),
          size: 56,
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              post.authorName,
              style: const TextStyle(
                fontSize: 20,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              DateHelper.time(post.createdAt),
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
