import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_colors.dart';
import '../../models/assignment_model.dart';
import '../../models/extras_model.dart';
import '../../providers/course_provider.dart';
import '../../widgets/more_menu_button.dart';
import 'class_comments_screen.dart';
import 'quiz_screen.dart';
import 'student_work_screen.dart';

const _btnBg = Color(0xFFA8C7FA);
const _btnFg = Color(0xFF062E6F);

IconData _attIcon(AttachmentType t) => switch (t) {
  AttachmentType.link => Icons.link,
  AttachmentType.drive => Icons.add_to_drive_outlined,
  AttachmentType.photo => Icons.photo_camera_outlined,
  AttachmentType.scan => Icons.document_scanner_outlined,
  AttachmentType.created => Icons.description_outlined,
  AttachmentType.file => Icons.insert_drive_file_outlined,
};

class AssignmentDetailScreen extends StatefulWidget {
  final AssignmentModel assignment;
  const AssignmentDetailScreen({super.key, required this.assignment});

  @override
  State<AssignmentDetailScreen> createState() => _AssignmentDetailScreenState();
}

class _AssignmentDetailScreenState extends State<AssignmentDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Ambil data terbaru (jawaban saya / jumlah yang sudah menyerahkan).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<CourseProvider>().refreshAssignment(widget.assignment);
      }
    });
  }

  Future<void> _delete() async {
    final a = widget.assignment;
    final ok = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        title: Text('Hapus ${a.type.label.toLowerCase()}?'),
        content: const Text('Semua jawaban siswa ikut terhapus.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(d, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(d, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final err = await context.read<CourseProvider>().deleteAssignment(a);
    if (!mounted) return;
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      return;
    }
    Navigator.pop(context);
  }

  Widget _panel(bool isTeacher) {
    final a = widget.assignment;
    if (a.isMaterial) return const SizedBox.shrink();
    if (isTeacher) return _TeacherPanel(assignment: a);
    switch (a.type) {
      case ClassworkType.question:
        return _AnswerPanel(assignment: a);
      case ClassworkType.quiz:
        return _QuizPanel(assignment: a);
      default:
        return _YourWorkPanel(assignment: a);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cp = context.watch<CourseProvider>();
    final assignment = widget.assignment;
    final isTeacher = cp.isOwnerOfId(assignment.courseId);

    final meta = <String>[
      assignment.type.label,
      if (assignment.topic != null) assignment.topic!,
    ].join(' • ');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surfaceHigh,
        actions: [
          if (isTeacher)
            IconButton(
              tooltip: 'Hapus',
              icon: const Icon(Icons.delete_outline),
              onPressed: _delete,
            ),
          const MoreMenuButton(),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const SizedBox(height: 8),
                Text(
                  meta,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  assignment.title,
                  style: const TextStyle(fontSize: 30, height: 1.25),
                ),
                if (!assignment.isMaterial) ...[
                  const SizedBox(height: 10),
                  Text(
                    assignment.points == null
                        ? 'Tanpa poin'
                        : '${assignment.points} poin',
                    style: const TextStyle(
                      fontSize: 18,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    assignment.deadlineLabel,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                if (!isTeacher && assignment.myScore != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    'Nilai Anda: ${assignment.myScore}/${assignment.points ?? '-'}',
                    style: const TextStyle(fontSize: 18, color: AppColors.teal),
                  ),
                ],
                const SizedBox(height: 24),
                InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ClassCommentsScreen(commentKey: 'a_${assignment.id}'),
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Icon(Icons.chat_outlined, color: AppColors.link),
                        SizedBox(width: 12),
                        Text(
                          'Tambahkan komentar kelas',
                          style: TextStyle(color: AppColors.link, fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(),
                if (assignment.description.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    assignment.description,
                    style: const TextStyle(fontSize: 17, height: 1.5),
                  ),
                ],
                if (assignment.type == ClassworkType.question &&
                    assignment.questionType == 'multiple_choice' &&
                    isTeacher) ...[
                  const SizedBox(height: 16),
                  for (final c in assignment.choices)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.radio_button_unchecked, size: 20),
                          const SizedBox(width: 10),
                          Expanded(child: Text(c)),
                        ],
                      ),
                    ),
                ],
                if (assignment.type == ClassworkType.quiz && isTeacher) ...[
                  const SizedBox(height: 16),
                  Text(
                    '${assignment.questions.length} soal',
                    style: const TextStyle(fontSize: 18),
                  ),
                  for (var i = 0; i < assignment.questions.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${i + 1}. ${assignment.questions[i].text}'),
                          for (
                            var k = 0;
                            k < assignment.questions[i].options.length;
                            k++
                          )
                            Text(
                              '${assignment.questions[i].correctIndex == k ? '✓' : '•'} ${assignment.questions[i].options[k]}',
                              style: TextStyle(
                                color: assignment.questions[i].correctIndex == k
                                    ? AppColors.teal
                                    : AppColors.textSecondary,
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
                if (assignment.attachments.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const Text('Lampiran', style: TextStyle(fontSize: 18)),
                  for (final f in assignment.attachments)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(_attIcon(f.type)),
                      title: Text(
                        f.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: f.url == null
                          ? null
                          : () => launchUrl(
                              Uri.parse(f.url!),
                              mode: LaunchMode.externalApplication,
                            ),
                    ),
                ],
              ],
            ),
          ),
          _panel(isTeacher),
        ],
      ),
    );
  }
}

/// Panel bawah untuk pengajar: ringkasan + tombol lihat pekerjaan siswa.
class _TeacherPanel extends StatelessWidget {
  final AssignmentModel assignment;
  const _TeacherPanel({required this.assignment});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${assignment.turnedIn} dari ${assignment.totalStudents} siswa sudah menyerahkan',
                style: const TextStyle(fontSize: 17),
              ),
              const SizedBox(height: 14),
              FilledButton(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  backgroundColor: _btnBg,
                  foregroundColor: _btnFg,
                  shape: const StadiumBorder(),
                ),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => StudentWorkScreen(assignment: assignment),
                    ),
                  );
                  if (context.mounted) {
                    context.read<CourseProvider>().refreshAssignment(
                      assignment,
                    );
                  }
                },
                child: const Text(
                  'Lihat pekerjaan siswa',
                  style: TextStyle(fontSize: 17),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

/// Panel siswa untuk "Pertanyaan": jawaban singkat atau pilihan ganda.
class _AnswerPanel extends StatefulWidget {
  final AssignmentModel assignment;
  const _AnswerPanel({required this.assignment});

  @override
  State<_AnswerPanel> createState() => _AnswerPanelState();
}

class _AnswerPanelState extends State<_AnswerPanel> {
  late final _ctrl = TextEditingController(text: widget.assignment.myAnswer ?? '');
  String? _choice;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _choice = widget.assignment.myAnswer;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final a = widget.assignment;
    final answer = a.questionType == 'multiple_choice'
        ? (_choice ?? '')
        : _ctrl.text.trim();
    if (answer.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jawaban belum diisi')),
      );
      return;
    }
    setState(() => _sending = true);
    final err = await context.read<CourseProvider>().submitAnswer(a, answer);
    if (!mounted) return;
    setState(() => _sending = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(err ?? 'Jawaban dikirim')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.assignment;
    final cp = context.watch<CourseProvider>();
    final submitted = a.status == AssignmentStatus.done;
    final isMcq = a.questionType == 'multiple_choice';

    return Material(
      color: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Jawaban Anda', style: TextStyle(fontSize: 20)),
                    if (submitted)
                      const Text(
                        'Dikirim',
                        style: TextStyle(color: AppColors.teal),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                if (isMcq)
                  for (final c in a.choices)
                    InkWell(
                      onTap: submitted ? null : () => setState(() => _choice = c),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Icon(
                              _choice == c
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_unchecked,
                              color: _choice == c ? AppColors.link : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Text(c)),
                          ],
                        ),
                      ),
                    )
                else
                  TextField(
                    controller: _ctrl,
                    enabled: !submitted,
                    minLines: 2,
                    maxLines: 6,
                    decoration: const InputDecoration(
                      hintText: 'Tulis jawaban Anda',
                      border: OutlineInputBorder(),
                    ),
                  ),
                const SizedBox(height: 14),
                if (submitted)
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      side: const BorderSide(color: AppColors.outline),
                      shape: const StadiumBorder(),
                    ),
                    onPressed: () async {
                      final err = await cp.unmarkDone(a);
                      if (err != null && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(err)),
                        );
                      }
                    },
                    child: const Text('Batal kirim'),
                  )
                else
                  FilledButton(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      backgroundColor: _btnBg,
                      foregroundColor: _btnFg,
                      shape: const StadiumBorder(),
                    ),
                    onPressed: _sending ? null : _send,
                    child: const Text('Kirim', style: TextStyle(fontSize: 17)),
                  ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Panel siswa untuk "Kuis".
class _QuizPanel extends StatelessWidget {
  final AssignmentModel assignment;
  const _QuizPanel({required this.assignment});

  @override
  Widget build(BuildContext context) {
    context.watch<CourseProvider>();
    final done = assignment.status == AssignmentStatus.done;

    return Material(
      color: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                done
                    ? 'Kuis selesai • Skor ${assignment.myScore ?? 0}/${assignment.points ?? 0}'
                    : '${assignment.questions.length} soal',
                style: TextStyle(
                  fontSize: 18,
                  color: done ? AppColors.teal : AppColors.textPrimary,
                ),
              ),
              if (!done) ...[
                const SizedBox(height: 14),
                FilledButton(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    backgroundColor: _btnBg,
                    foregroundColor: _btnFg,
                    shape: const StadiumBorder(),
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => QuizScreen(assignment: assignment),
                    ),
                  ),
                  child: const Text('Mulai kuis', style: TextStyle(fontSize: 17)),
                ),
              ],
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _YourWorkPanel extends StatelessWidget {
  final AssignmentModel assignment;
  const _YourWorkPanel({required this.assignment});

  @override
  Widget build(BuildContext context) {
    final cp = context.watch<CourseProvider>();
    final files = cp.attachmentsOf(assignment.id);
    final submitted = assignment.status == AssignmentStatus.done;

    return Material(
      color: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Tugas Anda', style: TextStyle(fontSize: 20)),
                  Text(
                    submitted ? 'Diserahkan' : assignment.deadlineLabel,
                    style: TextStyle(
                      fontSize: 15,
                      color: submitted ? AppColors.teal : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 160),
                child: ListView(
                  shrinkWrap: true,
                  children: files
                      .map(
                        (f) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.outline),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            dense: true,
                            leading: Icon(_iconOf(f.type)),
                            title: Text(
                              f.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: submitted
                                ? null
                                : IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: () =>
                                        cp.removeAttachment(assignment.id, f),
                                  ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 4),
              _buttons(context, cp, files, submitted),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buttons(
    BuildContext context,
    CourseProvider cp,
    List<Attachment> files,
    bool submitted,
  ) {
    if (submitted) {
      return SizedBox(
        width: double.infinity,
        height: 52,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.outline),
            shape: const StadiumBorder(),
          ),
          onPressed: () async {
            final err = await cp.unmarkDone(assignment);
            if (err != null && context.mounted) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(err)));
            }
          },
          child: const Text('Batal serahkan'),
        ),
      );
    }
    if (files.isEmpty) {
      return SizedBox(
        width: double.infinity,
        height: 52,
        child: FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: _btnBg,
            foregroundColor: _btnFg,
            shape: const StadiumBorder(),
          ),
          icon: const Icon(Icons.add),
          label: const Text('Tambahkan tugas', style: TextStyle(fontSize: 17)),
          onPressed: () => _showAddSheet(context),
        ),
      );
    }
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              side: const BorderSide(color: AppColors.outline),
              shape: const StadiumBorder(),
            ),
            icon: const Icon(Icons.add),
            label: const Text('Tambah'),
            onPressed: () => _showAddSheet(context),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              backgroundColor: _btnBg,
              foregroundColor: _btnFg,
              shape: const StadiumBorder(),
            ),
            onPressed: () => _confirmSubmit(context, cp),
            child: const Text('Serahkan', style: TextStyle(fontSize: 17)),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmSubmit(BuildContext context, CourseProvider cp) async {
    final messenger = ScaffoldMessenger.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        title: const Text('Serahkan tugas?'),
        content: const Text('Pengajar akan dapat melihat pekerjaan Anda.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(d, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(d, true),
            child: const Text('Serahkan'),
          ),
        ],
      ),
    );
    if (ok == true) {
      final err = await cp.markDone(assignment);
      messenger.showSnackBar(
        SnackBar(content: Text(err ?? 'Tugas diserahkan')),
      );
    }
  }

  IconData _iconOf(AttachmentType t) {
    switch (t) {
      case AttachmentType.drive:
        return Icons.add_to_drive_outlined;
      case AttachmentType.photo:
        return Icons.photo_camera_outlined;
      case AttachmentType.scan:
        return Icons.document_scanner_outlined;
      case AttachmentType.link:
        return Icons.link;
      case AttachmentType.created:
        return Icons.description_outlined;
      case AttachmentType.file:
        return Icons.insert_drive_file_outlined;
    }
  }

  // ---------- Sheet "Tambahkan tugas" ----------
  void _showAddSheet(BuildContext context) {
    final cp = context.read<CourseProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final id = assignment.id;

    void add(AttachmentType t, String name, [String? path]) =>
        cp.addAttachment(id, Attachment(type: t, name: name, path: path));

    Future<void> pickCamera(AttachmentType t) async {
      try {
        final x = await ImagePicker().pickImage(source: ImageSource.camera);
        if (x != null) add(t, x.name, x.path);
      } catch (_) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Kamera tidak tersedia di perangkat ini'),
          ),
        );
      }
    }

    Future<String?> choose(String title, List<String> options) =>
        showDialog<String>(
          context: context,
          builder: (d) => SimpleDialog(
            title: Text(title),
            children: options
                .map(
                  (n) => SimpleDialogOption(
                    onPressed: () => Navigator.pop(d, n),
                    child: Text(n),
                  ),
                )
                .toList(),
          ),
        );

    final items = <_SheetItem>[
      _SheetItem(Icons.add_to_drive_outlined, 'Tambahkan dari Drive', () async {
        final n = await choose('Pilih file dari Drive', const [
          'Laporan Audit Plan.docx',
          'Audit Program.xlsx',
          'Presentasi Kelompok.pptx',
        ]);
        if (n != null) add(AttachmentType.drive, n);
      }),
      _SheetItem(
        Icons.photo_camera_outlined,
        'Kamera',
        () => pickCamera(AttachmentType.photo),
      ),
      _SheetItem(
        Icons.document_scanner_outlined,
        'Scanner',
        () => pickCamera(AttachmentType.scan),
      ),
      _SheetItem(Icons.upload, 'Upload', () async {
        try {
          final r = await FilePicker.platform.pickFiles(allowMultiple: true);
          if (r != null) {
            for (final f in r.files) {
              add(AttachmentType.file, f.name, kIsWeb ? null : f.path);
            }
          }
        } catch (_) {
          messenger.showSnackBar(
            const SnackBar(content: Text('Gagal membuka pemilih file')),
          );
        }
      }),
      _SheetItem(Icons.link, 'Sisipkan link', () async {
        final ctrl = TextEditingController();
        final link = await showDialog<String>(
          context: context,
          builder: (d) => AlertDialog(
            title: const Text('Sisipkan link'),
            content: TextField(
              controller: ctrl,
              autofocus: true,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(hintText: 'https://'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(d),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(d, ctrl.text.trim()),
                child: const Text('Tambahkan'),
              ),
            ],
          ),
        );
        ctrl.dispose();
        if (link != null && link.isNotEmpty) add(AttachmentType.link, link);
      }),
      _SheetItem(Icons.add, 'Buat', () async {
        final t = await choose('Buat baru', const [
          'Dokumen',
          'Slide',
          'Spreadsheet',
        ]);
        if (t != null) add(AttachmentType.created, '$t tanpa judul');
      }),
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetCtx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 24, 8, 24),
          child: GridView.count(
            shrinkWrap: true,
            crossAxisCount: 3,
            childAspectRatio: 0.95,
            physics: const NeverScrollableScrollPhysics(),
            children: items
                .map(
                  (it) => InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.pop(sheetCtx);
                      it.onTap();
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.outline),
                          ),
                          child: Icon(it.icon, size: 26),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          it.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}

class _SheetItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  _SheetItem(this.icon, this.label, this.onTap);
}
