import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../models/assignment_model.dart';
import '../../providers/course_provider.dart';

/// Siswa mengerjakan kuis. Jawaban dinilai otomatis oleh server.
class QuizScreen extends StatefulWidget {
  final AssignmentModel assignment;
  const QuizScreen({super.key, required this.assignment});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late final List<int?> _answers = List<int?>.filled(
    widget.assignment.questions.length,
    null,
  );
  bool _sending = false;

  Future<void> _send() async {
    final unanswered = _answers.where((a) => a == null).length;
    final ok = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        title: const Text('Kirim jawaban?'),
        content: Text(
          unanswered > 0
              ? '$unanswered soal belum dijawab. Kuis tidak dapat diulang setelah dikirim.'
              : 'Kuis tidak dapat diulang setelah dikirim.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(d, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(d, true),
            child: const Text('Kirim'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    setState(() => _sending = true);
    final a = widget.assignment;
    final err = await context.read<CourseProvider>().submitQuiz(a, _answers);
    if (!mounted) return;
    setState(() => _sending = false);
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (d) => AlertDialog(
        title: const Text('Kuis dikirim'),
        content: Text('Skor Anda: ${a.myScore ?? 0} dari ${a.points ?? 0} poin'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(d),
            child: const Text('Selesai'),
          ),
        ],
      ),
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.assignment;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surfaceHigh,
        title: Text(a.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (var i = 0; i < a.questions.length; i++)
            Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${i + 1}. ${a.questions[i].text}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  Text(
                    '${a.questions[i].points} poin',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 6),
                  for (var k = 0; k < a.questions[i].options.length; k++)
                    InkWell(
                      onTap: () => setState(() => _answers[i] = k),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Icon(
                              _answers[i] == k
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_unchecked,
                              color: _answers[i] == k ? AppColors.link : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                a.questions[i].options[k],
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              backgroundColor: const Color(0xFFA8C7FA),
              foregroundColor: const Color(0xFF062E6F),
              shape: const StadiumBorder(),
            ),
            onPressed: _sending ? null : _send,
            child: _sending
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Kirim jawaban', style: TextStyle(fontSize: 17)),
          ),
        ],
      ),
    );
  }
}
