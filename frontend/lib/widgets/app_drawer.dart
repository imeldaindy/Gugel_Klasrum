import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../providers/course_provider.dart';
import '../screens/calendar/calendar_screen.dart';
import '../screens/classroom/class_detail_screen.dart';
import '../screens/notification/notification_screen.dart';
import '../screens/offline/offline_files_screen.dart';
import '../screens/todo/todo_screen.dart';

class AppLogo extends StatelessWidget {
  final double size;
  const AppLogo({super.key, this.size = 26});

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'Gugel',
            style: TextStyle(
              fontSize: size + 2,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          TextSpan(
            text: ' Classroom',
            style: TextStyle(
              fontSize: size - 2,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class AppDrawer extends StatelessWidget {
  final int? currentCourseId;
  const AppDrawer({super.key, this.currentCourseId});

  void _push(BuildContext context, Widget page) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final courses = context.watch<CourseProvider>().courses;

    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 16, 16, 20),
              child: AppLogo(),
            ),
            _DrawerItem(
              icon: Icons.home_rounded,
              title: 'Kelas',
              selected: currentCourseId == null,
              onTap: () {
                Navigator.pop(context);
                Navigator.popUntil(context, (r) => r.isFirst);
              },
            ),
            _DrawerItem(
              icon: Icons.calendar_today_outlined,
              title: 'Kalender',
              onTap: () => _push(context, const CalendarScreen()),
            ),
            _DrawerItem(
              icon: Icons.notifications_none_rounded,
              title: 'Notifikasi',
              onTap: () => _push(context, const NotificationScreen()),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 28, 16, 12),
              child: Text(
                'Terdaftar',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            _DrawerItem(
              icon: Icons.fact_check_outlined,
              title: 'Daftar tugas',
              onTap: () => _push(context, const TodoScreen()),
            ),
            ...courses.map(
              (c) => _DrawerItem(
                leading: CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.classAvatar,
                  child: Text(
                    c.name[0].toUpperCase(),
                    style: const TextStyle(fontSize: 15, color: Colors.white),
                  ),
                ),
                title: c.name,
                subtitle: c.section.isEmpty ? null : c.section,
                selected: currentCourseId == c.id,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.popUntil(context, (r) => r.isFirst);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ClassDetailScreen(course: c),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            _DrawerItem(
              icon: Icons.task_alt_rounded,
              title: 'File offline',
              onTap: () => _push(context, const OfflineFilesScreen()),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData? icon;
  final Widget? leading;
  final String title;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _DrawerItem({
    this.icon,
    this.leading,
    required this.title,
    this.subtitle,
    this.selected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: selected ? AppColors.activePill : Colors.transparent,
        shape: const StadiumBorder(),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: subtitle == null ? 14 : 9,
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 32,
                  child:
                      leading ??
                      Icon(icon, color: AppColors.textPrimary, size: 26),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
