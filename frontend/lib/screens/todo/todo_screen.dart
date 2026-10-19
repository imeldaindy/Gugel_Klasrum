import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../models/assignment_model.dart';
import '../../providers/course_provider.dart';
import '../../widgets/assignment_tile.dart';
import '../classroom/assignment_detail_screen.dart';

class TodoScreen extends StatelessWidget {
  const TodoScreen({super.key});

  Widget _list(BuildContext context, AssignmentStatus status) {
    final list = context
        .watch<CourseProvider>()
        .allAssignments
        .where((a) => a.status == status)
        .toList();

    if (list.isEmpty) {
      return const Center(
        child: Text(
          'Tidak ada tugas',
          style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
        ),
      );
    }
    return ListView(
      children: list
          .map(
            (a) => AssignmentTile(
              assignment: a,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AssignmentDetailScreen(assignment: a),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Daftar tugas'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Ditugaskan'),
              Tab(text: 'Terlewat'),
              Tab(text: 'Selesai'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _list(context, AssignmentStatus.assigned),
            _list(context, AssignmentStatus.missing),
            _list(context, AssignmentStatus.done),
          ],
        ),
      ),
    );
  }
}
