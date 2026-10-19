import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../models/course_model.dart';
import '../../models/user_model.dart';
import '../../providers/course_provider.dart';
import '../../widgets/person_tile.dart';

class PeopleTab extends StatelessWidget {
  final CourseModel course;
  const PeopleTab({super.key, required this.course});

  Widget _header(String text) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: const TextStyle(fontSize: 30, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 12),
        const Divider(),
        const SizedBox(height: 8),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final students = context.watch<CourseProvider>().peopleOf(course.id);

    return ListView(
      children: [
        _header('Pengajar'),
        PersonTile(name: course.teacher, color: AppAvatarColors.grey),
        _header('Teman Sekelas'),
        ...students.map((s) => PersonTile(name: s.name, color: s.color)),
        const SizedBox(height: 24),
      ],
    );
  }
}
