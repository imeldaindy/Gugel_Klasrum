import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../models/course_model.dart';
import '../../providers/course_provider.dart';
import '../../widgets/course_card.dart';
import '../../widgets/post_card.dart';
import 'create_announcement_screen.dart';
import 'post_detail_screen.dart';

class ForumTab extends StatelessWidget {
  final CourseModel course;
  const ForumTab({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<CourseProvider>();
    final posts = prov.postsOf(course.id);
    final canPost = prov.isOwner(course) ||
        course.postPolicy == ForumPostPolicy.studentsPostAndComment;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Container(
          height: 135,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.bannerBlue,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -12,
                bottom: -12,
                child: Icon(
                  CourseCard.artIcon(course.art),
                  size: 120,
                  color: Colors.white.withValues(alpha: 0.25),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  course.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 28, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (canPost)
        Material(
          color: AppColors.announceButton,
          shape: const StadiumBorder(),
          child: InkWell(
            customBorder: const StadiumBorder(),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CreateAnnouncementScreen(course: course),
              ),
            ),
            child: const SizedBox(
              height: 56,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.edit_outlined, color: Color(0xFFC2E7FF), size: 22),
                  SizedBox(width: 12),
                  Text(
                    'Pengumuman baru',
                    style: TextStyle(fontSize: 18, color: Color(0xFFC2E7FF)),
                  ),
                ],
              ),
            ),
          ),
        ),
        ...posts.map(
          (p) => PostCard(
            post: p,
            onTap: () => openPost(context, course, p),
            onComment: () => openPostComments(context, p),
          ),
        ),
      ],
    );
  }
}
