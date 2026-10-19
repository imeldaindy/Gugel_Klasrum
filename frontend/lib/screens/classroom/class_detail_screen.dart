import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../models/course_model.dart';
import '../../providers/course_provider.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/more_menu_button.dart';
import 'assignments_tab.dart';
import 'class_settings_screen.dart';
import 'forum_tab.dart';
import 'people_tab.dart';

class ClassDetailScreen extends StatefulWidget {
  final CourseModel course;
  const ClassDetailScreen({super.key, required this.course});

  @override
  State<ClassDetailScreen> createState() => _ClassDetailScreenState();
}

class _ClassDetailScreenState extends State<ClassDetailScreen> {
  int _index = 0;

  void _showInfo() {
    final c = widget.course;
    final rows = <MapEntry<String, String>>[
      MapEntry('Pengajar', c.teacher),
      if (c.description.isNotEmpty) MapEntry('Deskripsi', c.description),
      if (c.section.isNotEmpty) MapEntry('Bagian', c.section),
      if (c.room.isNotEmpty) MapEntry('Ruang', c.room),
      if (c.subject.isNotEmpty) MapEntry('Mata pelajaran', c.subject),
      if (c.level.isNotEmpty) MapEntry('Tingkat', c.level),
    ];
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(c.name, style: const TextStyle(fontSize: 22)),
              const SizedBox(height: 12),
              for (final r in rows)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text('${r.key}: ${r.value}',
                      style: const TextStyle(
                          fontSize: 16, color: AppColors.textSecondary)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _appBar() {
    switch (_index) {
      case 0:
        final isOwner = context.watch<CourseProvider>().isOwner(widget.course);
        return AppBar(
          actions: [
            if (isOwner)
              IconButton(
                tooltip: 'Setelan kelas',
                icon: const Icon(Icons.settings_outlined),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ClassSettingsScreen(course: widget.course),
                    ),
                  );
                  if (mounted) setState(() {});
                },
              )
            else
              IconButton(
                tooltip: 'Info kelas',
                icon: const Icon(Icons.info_outline),
                onPressed: _showInfo,
              ),
            const MoreMenuButton(),
          ],
        );
      case 1:
        return AppBar(
          title: Text(
            widget.course.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.assignment_ind_outlined),
              onPressed: () {},
            ),
            const MoreMenuButton(),
          ],
        );
      default:
        return AppBar(
          title: Text(
            widget.course.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            const MoreMenuButton(),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(currentCourseId: widget.course.id),
      appBar: _appBar(),
      body: IndexedStack(
        index: _index,
        children: [
          ForumTab(course: widget.course),
          AssignmentsTab(course: widget.course),
          PeopleTab(course: widget.course),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.forum_outlined),
            selectedIcon: Icon(Icons.forum),
            label: 'Forum',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment),
            label: 'Tugas kelas',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Orang',
          ),
        ],
      ),
    );
  }
}
