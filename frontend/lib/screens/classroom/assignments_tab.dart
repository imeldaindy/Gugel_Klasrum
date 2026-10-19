import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../models/assignment_model.dart';
import '../../models/course_model.dart';
import '../../providers/course_provider.dart';
import '../../widgets/assignment_tile.dart';
import 'assignment_detail_screen.dart';
import 'classwork_form_screen.dart';

class AssignmentsTab extends StatelessWidget {
  final CourseModel course;
  const AssignmentsTab({super.key, required this.course});

  void _snack(BuildContext context, String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  void _open(BuildContext context, AssignmentModel a) => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => AssignmentDetailScreen(assignment: a)),
  );

  // ---------- Menu "Buat" ----------
  void _showCreateSheet(BuildContext context) {
    final items = <(IconData, String, ClassworkType)>[
      (Icons.assignment_outlined, 'Tugas', ClassworkType.assignment),
      (Icons.quiz_outlined, 'Kuis', ClassworkType.quiz),
      (Icons.contact_support_outlined, 'Pertanyaan', ClassworkType.question),
      (Icons.book_outlined, 'Materi', ClassworkType.material),
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheet) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 24),
              const Text('Buat', style: TextStyle(fontSize: 28)),
              const SizedBox(height: 16),
              for (final it in items)
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 28),
                  leading: Icon(it.$1, size: 30),
                  title: Text(it.$2, style: const TextStyle(fontSize: 20)),
                  onTap: () async {
                    Navigator.pop(sheet);
                    final ok = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ClassworkFormScreen(course: course, type: it.$3),
                      ),
                    );
                    if (ok == true && context.mounted) {
                      _snack(context, '${it.$3.label} dibuat');
                    }
                  },
                ),
              const Divider(),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 28),
                leading: const Icon(Icons.repeat, size: 30),
                title: const Text(
                  'Gunakan kembali postingan',
                  style: TextStyle(fontSize: 20),
                ),
                onTap: () {
                  Navigator.pop(sheet);
                  _reuse(context);
                },
              ),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 28),
                leading: const Icon(Icons.table_rows_outlined, size: 30),
                title: const Text('Topik', style: TextStyle(fontSize: 20)),
                onTap: () {
                  Navigator.pop(sheet);
                  _newTopic(context);
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _newTopic(BuildContext context) async {
    final name = await askTopicName(context);
    if (name == null || !context.mounted) return;
    final err = await context.read<CourseProvider>().createTopic(
      course.id,
      name,
    );
    if (context.mounted) _snack(context, err ?? 'Topik "$name" dibuat');
  }

  /// Salin tugas/kuis/materi dari kelas lain yang diajar pengguna.
  Future<void> _reuse(BuildContext context) async {
    final cp = context.read<CourseProvider>();
    final others = cp.courses
        .where((c) => cp.isOwner(c) && c.id != course.id)
        .toList();
    if (others.isEmpty) {
      _snack(context, 'Tidak ada kelas lain yang Anda ajar');
      return;
    }

    final from = await showDialog<CourseModel>(
      context: context,
      builder: (d) => SimpleDialog(
        title: const Text('Pilih kelas'),
        children: [
          for (final c in others)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(d, c),
              child: Text(c.name),
            ),
        ],
      ),
    );
    if (from == null || !context.mounted) return;

    final items = cp.assignmentsOf(from.id);
    if (items.isEmpty) {
      _snack(context, 'Kelas "${from.name}" belum punya postingan');
      return;
    }

    final pick = await showDialog<AssignmentModel>(
      context: context,
      builder: (d) => SimpleDialog(
        title: const Text('Pilih postingan'),
        children: [
          for (final a in items)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(d, a),
              child: Text('${a.type.label}: ${a.title}'),
            ),
        ],
      ),
    );
    if (pick == null || !context.mounted) return;

    final err = await cp.reuseClasswork(course.id, pick.id);
    if (context.mounted) {
      _snack(context, err ?? '"${pick.title}" ditambahkan ke kelas ini');
    }
  }

  Widget _topicHeader(BuildContext context, TopicModel t, bool isOwner) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 4, 0),
          child: Row(
            children: [
              Expanded(
                child: Text(t.name, style: const TextStyle(fontSize: 24)),
              ),
              if (isOwner)
                PopupMenuButton<String>(
                  onSelected: (_) async {
                    final err = await context
                        .read<CourseProvider>()
                        .deleteTopic(course.id, t.id);
                    if (err != null && context.mounted) _snack(context, err);
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'del', child: Text('Hapus topik')),
                  ],
                ),
            ],
          ),
        ),
        const Divider(height: 8),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final cp = context.watch<CourseProvider>();
    final isOwner = cp.isOwner(course);
    final list = cp.assignmentsOf(course.id);
    final topics = cp.topicsOf(course.id);

    final children = <Widget>[];
    for (final a in list.where((a) => a.topicId == null)) {
      children.add(
        AssignmentTile(assignment: a, isTeacher: isOwner, onTap: () => _open(context, a)),
      );
    }
    for (final t in topics) {
      final items = list.where((a) => a.topicId == t.id).toList();
      if (items.isEmpty && !isOwner) continue;
      children.add(_topicHeader(context, t, isOwner));
      for (final a in items) {
        children.add(
          AssignmentTile(assignment: a, isTeacher: isOwner, onTap: () => _open(context, a)),
        );
      }
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: isOwner
          ? FloatingActionButton.extended(
              onPressed: () => _showCreateSheet(context),
              icon: const Icon(Icons.add),
              label: const Text('Buat'),
            )
          : null,
      body: children.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  isOwner
                      ? 'Belum ada tugas.\nKetuk "Buat" untuk menambahkan tugas, kuis, pertanyaan, atau materi.'
                      : 'Belum ada tugas',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 17,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.only(top: 8, bottom: 96),
              children: children,
            ),
    );
  }
}
