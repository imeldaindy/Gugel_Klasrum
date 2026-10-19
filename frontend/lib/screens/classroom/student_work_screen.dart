import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_colors.dart';
import '../../models/assignment_model.dart';
import '../../models/extras_model.dart';
import '../../providers/course_provider.dart';
import '../../widgets/user_avatar.dart';

/// Pengajar: daftar pekerjaan siswa + pemberian nilai.
class StudentWorkScreen extends StatefulWidget {
  final AssignmentModel assignment;
  const StudentWorkScreen({super.key, required this.assignment});

  @override
  State<StudentWorkScreen> createState() => _StudentWorkScreenState();
}

class _StudentWorkScreenState extends State<StudentWorkScreen> {
  late Future<List<StudentWork>> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<CourseProvider>().submissionsOf(widget.assignment);
  }

  void _reload() => setState(() {
    _future = context.read<CourseProvider>().submissionsOf(widget.assignment);
  });

  String _subtitle(StudentWork w) {
    final status = w.done ? 'Diserahkan' : 'Belum diserahkan';
    return w.score == null
        ? status
        : '$status • Nilai: ${w.score}/${widget.assignment.points ?? '-'}';
  }

  Future<void> _open(StudentWork w) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: _WorkSheet(assignment: widget.assignment, work: w),
      ),
    );
    if (saved == true) {
      _reload();
      if (mounted) {
        context.read<CourseProvider>().refreshAssignment(widget.assignment);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surfaceHigh,
        title: const Text('Pekerjaan siswa'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _reload),
        ],
      ),
      body: FutureBuilder<List<StudentWork>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('${snap.error}', textAlign: TextAlign.center),
              ),
            );
          }
          final list = snap.data ?? [];
          if (list.isEmpty) {
            return const Center(child: Text('Belum ada siswa'));
          }
          final done = list.where((w) => w.done).length;
          return ListView(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  '$done dari ${list.length} siswa sudah menyerahkan',
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              for (final w in list)
                ListTile(
                  leading: UserAvatar(
                    name: w.user.name,
                    color: w.user.color,
                    photoUrl: w.user.photoUrl,
                  ),
                  title: Text(w.user.name),
                  subtitle: Text(_subtitle(w)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _open(w),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _WorkSheet extends StatefulWidget {
  final AssignmentModel assignment;
  final StudentWork work;
  const _WorkSheet({required this.assignment, required this.work});

  @override
  State<_WorkSheet> createState() => _WorkSheetState();
}

class _WorkSheetState extends State<_WorkSheet> {
  late final _score = TextEditingController(
    text: widget.work.score?.toString() ?? '',
  );
  bool _saving = false;

  @override
  void dispose() {
    _score.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final text = _score.text.trim();
    final value = text.isEmpty ? null : int.tryParse(text);
    if (text.isNotEmpty && value == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nilai harus berupa angka')),
      );
      return;
    }
    setState(() => _saving = true);
    final err = await context.read<CourseProvider>().gradeWork(
      widget.assignment,
      widget.work.user.id,
      value,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      return;
    }
    Navigator.pop(context, true);
  }

  Widget _content() {
    final a = widget.assignment;
    final w = widget.work;
    if (!w.done) {
      return const Text(
        'Siswa ini belum menyerahkan pekerjaan.',
        style: TextStyle(color: AppColors.textSecondary),
      );
    }
    switch (a.type) {
      case ClassworkType.question:
        return Text(w.answer ?? '-', style: const TextStyle(fontSize: 17));
      case ClassworkType.quiz:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < a.questions.length; i++)
              _quizRow(a.questions[i], i, w.answers),
          ],
        );
      default:
        if (w.attachments.isEmpty) {
          return const Text('Diserahkan tanpa lampiran.');
        }
        return Column(
          children: [
            for (final f in w.attachments)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  f.type == AttachmentType.link
                      ? Icons.link
                      : Icons.insert_drive_file_outlined,
                ),
                title: Text(f.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                onTap: f.url == null
                    ? null
                    : () => launchUrl(
                        Uri.parse(f.url!),
                        mode: LaunchMode.externalApplication,
                      ),
              ),
          ],
        );
    }
  }

  Widget _quizRow(QuizQuestionModel q, int i, List<int?>? answers) {
    final pick = (answers != null && i < answers.length) ? answers[i] : null;
    final right = pick != null && pick == q.correctIndex;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${i + 1}. ${q.text}'),
          Text(
            'Jawaban: ${pick == null ? '(kosong)' : q.options[pick]}',
            style: TextStyle(color: right ? AppColors.teal : Colors.redAccent),
          ),
          if (!right && q.correctIndex != null)
            Text(
              'Kunci: ${q.options[q.correctIndex!]}',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.work.user.name, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 16),
            _content(),
            const SizedBox(height: 20),
            TextField(
              controller: _score,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Nilai',
                suffixText: '/ ${widget.assignment.points ?? '-'}',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: const Color(0xFFA8C7FA),
                foregroundColor: const Color(0xFF062E6F),
                shape: const StadiumBorder(),
              ),
              onPressed: _saving ? null : _save,
              child: const Text('Simpan nilai'),
            ),
          ],
        ),
      ),
    );
  }
}
