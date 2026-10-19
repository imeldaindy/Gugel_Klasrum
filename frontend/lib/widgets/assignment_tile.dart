import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../models/assignment_model.dart';

class AssignmentTile extends StatelessWidget {
  final AssignmentModel assignment;
  final VoidCallback onTap;
  final bool isTeacher;

  const AssignmentTile({
    super.key,
    required this.assignment,
    required this.onTap,
    this.isTeacher = false,
  });

  IconData get _icon => switch (assignment.type) {
    ClassworkType.assignment => Icons.assignment_outlined,
    ClassworkType.quiz => Icons.quiz_outlined,
    ClassworkType.question => Icons.contact_support_outlined,
    ClassworkType.material => Icons.book_outlined,
  };

  String get _subtitle {
    if (assignment.isMaterial) return 'Materi';
    final prefix = assignment.type == ClassworkType.assignment
        ? ''
        : '${assignment.type.label} • ';
    return '$prefix${assignment.deadlineLabel}';
  }

  String get _trailing {
    if (assignment.isMaterial) return '';
    if (isTeacher) {
      return '${assignment.turnedIn}/${assignment.totalStudents}\ndiserahkan';
    }
    return assignment.statusLabel;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: Container(
        width: 56,
        height: 56,
        decoration: const BoxDecoration(
          color: AppColors.classAvatar,
          shape: BoxShape.circle,
        ),
        child: Icon(_icon, color: const Color(0xFFD3E3FD), size: 30),
      ),
      title: Text(
        assignment.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 20, color: AppColors.textPrimary),
      ),
      subtitle: Text(
        _subtitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 16, color: AppColors.textSecondary),
      ),
      trailing: Text(
        _trailing,
        textAlign: TextAlign.right,
        style: const TextStyle(fontSize: 15, color: AppColors.textSecondary),
      ),
    );
  }
}
