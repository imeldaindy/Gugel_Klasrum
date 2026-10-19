import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/course_provider.dart';
import '../../widgets/account_switcher_sheet.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/course_card.dart';
import '../../widgets/more_menu_button.dart';
import '../../widgets/todo_summary_card.dart';
import '../../widgets/user_avatar.dart';
import '../classroom/class_detail_screen.dart';
import '../classroom/join_create_screens.dart';
import '../todo/todo_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<CourseProvider>();
    final user = context.watch<AuthProvider>().current;

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const AppLogo(),
        actions: [
          if (user != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => AccountSwitcherSheet.show(context),
                child: UserAvatar(name: user.name, color: user.color, size: 42),
              ),
            ),
          const MoreMenuButton(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.fab,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        onPressed: () => showJoinCreateSheet(context),
        child: const Icon(Icons.add, size: 32),
      ),
      body: prov.loading && prov.courses.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: prov.loadAll,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                children: [
                  TodoSummaryCard(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TodoScreen()),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...prov.courses.map(
                    (c) => CourseCard(
                      course: c,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ClassDetailScreen(course: c),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
