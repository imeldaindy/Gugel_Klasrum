import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/date_helper.dart';
import '../../models/assignment_model.dart';
import '../../models/course_model.dart';
import '../../models/extras_model.dart';
import '../../providers/course_provider.dart';

const _chipBg = Color(0xFF004A77);
const _chipFg = Color(0xFFC2E7FF);

/// Satu soal kuis yang sedang disusun.
class _QuizDraft {
  final text = TextEditingController();
  final points = TextEditingController(text: '1');
  final options = <TextEditingController>[
    TextEditingController(),
    TextEditingController(),
  ];
  int? correct;

  void dispose() {
    text.dispose();
    points.dispose();
    for (final o in options) {
      o.dispose();
    }
  }
}

/// Form membuat Tugas / Kuis / Pertanyaan / Materi (khusus pengajar).
class ClassworkFormScreen extends StatefulWidget {
  final CourseModel course;
  final ClassworkType type;
  const ClassworkFormScreen({
    super.key,
    required this.course,
    required this.type,
  });

  @override
  State<ClassworkFormScreen> createState() => _ClassworkFormScreenState();
}

class _ClassworkFormScreenState extends State<ClassworkFormScreen> {
  final _title = TextEditingController();
  final _desc = TextEditingController();

  int? _points = 100;
  DateTime? _deadline;
  TopicModel? _topic;
  Set<int> _students = {}; // kosong = semua pelajar
  final List<Attachment> _files = [];
  bool _saving = false;

  // Pertanyaan
  String _questionType = 'short_answer';
  final List<TextEditingController> _choices = [
    TextEditingController(),
    TextEditingController(),
  ];

  // Kuis
  final List<_QuizDraft> _quiz = [_QuizDraft()];

  ClassworkType get _type => widget.type;

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    for (final c in _choices) {
      c.dispose();
    }
    for (final q in _quiz) {
      q.dispose();
    }
    super.dispose();
  }

  String get _titleHint => switch (_type) {
    ClassworkType.assignment => 'Judul tugas (wajib diisi)',
    ClassworkType.quiz => 'Judul kuis (wajib diisi)',
    ClassworkType.question => 'Pertanyaan (wajib diisi)',
    ClassworkType.material => 'Judul materi (wajib diisi)',
  };

  String get _submitLabel => _type == ClassworkType.material ? 'Posting' : 'Tugaskan';

  void _snack(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  String _iso(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)}T${two(d.hour)}:${two(d.minute)}:00';
  }

  // ---------- Kirim ----------
  Future<void> _submit() async {
    final title = _title.text.trim();
    if (title.isEmpty) {
      _snack('Judul wajib diisi');
      return;
    }

    final body = <String, dynamic>{
      'type': _type.name,
      'title': title,
      'description': _desc.text.trim(),
      'topic_id': _topic?.id,
      'student_ids': _students.toList(),
      'attachments': [
        for (final f in _files)
          {'type': f.type.name, 'name': f.name, 'url': f.url},
      ],
    };

    if (_type != ClassworkType.material) {
      body['deadline'] = _deadline == null ? null : _iso(_deadline!);
    }
    if (_type == ClassworkType.assignment || _type == ClassworkType.question) {
      body['points'] = _points;
    }

    if (_type == ClassworkType.question) {
      body['question_type'] = _questionType;
      if (_questionType == 'multiple_choice') {
        final ch = _choices
            .map((c) => c.text.trim())
            .where((t) => t.isNotEmpty)
            .toList();
        if (ch.length < 2) {
          _snack('Pilihan ganda minimal punya 2 pilihan');
          return;
        }
        body['choices'] = ch;
      }
    }

    if (_type == ClassworkType.quiz) {
      final qs = <Map<String, dynamic>>[];
      for (var i = 0; i < _quiz.length; i++) {
        final q = _quiz[i];
        final text = q.text.text.trim();
        final opts = <String>[];
        int? correct;
        for (var k = 0; k < q.options.length; k++) {
          final t = q.options[k].text.trim();
          if (t.isEmpty) continue;
          if (q.correct == k) correct = opts.length;
          opts.add(t);
        }
        if (text.isEmpty) {
          _snack('Soal ${i + 1}: teks soal belum diisi');
          return;
        }
        if (opts.length < 2) {
          _snack('Soal ${i + 1}: minimal 2 pilihan jawaban');
          return;
        }
        if (correct == null) {
          _snack('Soal ${i + 1}: tandai kunci jawaban yang benar');
          return;
        }
        qs.add({
          'text': text,
          'options': opts,
          'correct_index': correct,
          'points': int.tryParse(q.points.text.trim()) ?? 1,
        });
      }
      body['questions'] = qs;
    }

    setState(() => _saving = true);
    final err = await context.read<CourseProvider>().createClasswork(
      widget.course.id,
      body,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (err != null) {
      _snack(err);
      return;
    }
    Navigator.pop(context, true);
  }

  // ---------- Picker ----------
  Future<void> _pickStudents() async {
    final people = context.read<CourseProvider>().peopleOf(widget.course.id);
    if (people.isEmpty) {
      _snack('Belum ada pelajar di kelas ini');
      return;
    }
    final selected = {..._students};
    final res = await showDialog<Set<int>>(
      context: context,
      builder: (d) => StatefulBuilder(
        builder: (d, setS) => AlertDialog(
          title: const Text('Tugaskan kepada'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: [
                CheckboxListTile(
                  value: selected.isEmpty,
                  title: const Text('Semua pelajar'),
                  onChanged: (_) => setS(selected.clear),
                ),
                const Divider(height: 1),
                for (final u in people)
                  CheckboxListTile(
                    value: selected.contains(u.id),
                    title: Text(u.name),
                    onChanged: (v) => setS(() {
                      v == true ? selected.add(u.id) : selected.remove(u.id);
                    }),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(d),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(d, selected),
              child: const Text('Selesai'),
            ),
          ],
        ),
      ),
    );
    if (res != null) setState(() => _students = res);
  }

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _deadline ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_deadline ?? DateTime(2000, 1, 1, 23, 59)),
    );
    if (time == null) return;
    setState(
      () => _deadline = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      ),
    );
  }

  Future<void> _editPoints() async {
    final ctrl = TextEditingController(text: '${_points ?? 100}');
    final v = await showDialog<int>(
      context: context,
      builder: (d) => AlertDialog(
        title: const Text('Poin'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(d),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(
              d,
              (int.tryParse(ctrl.text.trim()) ?? 0).clamp(0, 1000),
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    ctrl.dispose();
    if (v != null) setState(() => _points = v);
  }

  Future<void> _pickTopic() async {
    final prov = context.read<CourseProvider>();
    final topics = prov.topicsOf(widget.course.id);
    const none = -1, create = -2;
    final id = await showDialog<int>(
      context: context,
      builder: (d) => SimpleDialog(
        title: const Text('Topik'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(d, none),
            child: const Text('Tanpa topik'),
          ),
          for (final t in topics)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(d, t.id),
              child: Text(t.name),
            ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(d, create),
            child: const Text(
              '+ Topik baru',
              style: TextStyle(color: AppColors.link),
            ),
          ),
        ],
      ),
    );
    if (id == null || !mounted) return;
    if (id == none) {
      setState(() => _topic = null);
    } else if (id == create) {
      final name = await askTopicName(context);
      if (name == null || !mounted) return;
      final err = await prov.createTopic(widget.course.id, name);
      if (!mounted) return;
      if (err != null) {
        _snack(err);
        return;
      }
      setState(() => _topic = prov.topicsOf(widget.course.id).last);
    } else {
      setState(() => _topic = topics.firstWhere((t) => t.id == id));
    }
  }

  Future<void> _addAttachment() async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (s) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('Sisipkan link'),
              onTap: () => Navigator.pop(s, 'link'),
            ),
            ListTile(
              leading: const Icon(Icons.upload),
              title: const Text('Upload file'),
              onTap: () => Navigator.pop(s, 'file'),
            ),
            ListTile(
              leading: const Icon(Icons.add_to_drive_outlined),
              title: const Text('Tambahkan dari Drive'),
              onTap: () => Navigator.pop(s, 'drive'),
            ),
          ],
        ),
      ),
    );
    if (choice == null || !mounted) return;

    if (choice == 'link') {
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
      if (link != null && link.isNotEmpty) {
        setState(
          () => _files.add(
            Attachment(type: AttachmentType.link, name: link, url: link),
          ),
        );
      }
    } else if (choice == 'file') {
      try {
        final r = await FilePicker.platform.pickFiles(allowMultiple: true);
        if (r != null) {
          setState(() {
            for (final f in r.files) {
              _files.add(Attachment(type: AttachmentType.file, name: f.name));
            }
          });
        }
      } catch (_) {
        _snack('Gagal membuka pemilih file');
      }
    } else {
      final name = await showDialog<String>(
        context: context,
        builder: (d) => SimpleDialog(
          title: const Text('Pilih file dari Drive'),
          children: [
            for (final n in const [
              'Modul Pembelajaran.pdf',
              'Slide Pertemuan.pptx',
              'Daftar Referensi.docx',
            ])
              SimpleDialogOption(
                onPressed: () => Navigator.pop(d, n),
                child: Text(n),
              ),
          ],
        ),
      );
      if (name != null) {
        setState(
          () => _files.add(Attachment(type: AttachmentType.drive, name: name)),
        );
      }
    }
  }

  // ---------- UI ----------
  Widget _chip(String label, {VoidCallback? onTap, VoidCallback? onClear}) {
    return Material(
      color: _chipBg,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 17, color: _chipFg),
                ),
              ),
              if (onClear != null) ...[
                const SizedBox(width: 8),
                InkWell(
                  onTap: onClear,
                  child: const Icon(Icons.close, size: 18, color: _chipFg),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _linkButton(String text, VoidCallback onTap) => Align(
    alignment: Alignment.centerLeft,
    child: TextButton(
      onPressed: onTap,
      child: Text(text, style: const TextStyle(fontSize: 18)),
    ),
  );

  Widget _questionSection() {
    final isMcq = _questionType == 'multiple_choice';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'short_answer', label: Text('Jawaban singkat')),
            ButtonSegment(value: 'multiple_choice', label: Text('Pilihan ganda')),
          ],
          selected: {_questionType},
          onSelectionChanged: (s) => setState(() => _questionType = s.first),
        ),
        if (isMcq) ...[
          const SizedBox(height: 12),
          for (var i = 0; i < _choices.length; i++)
            Row(
              children: [
                const Icon(Icons.radio_button_unchecked, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _choices[i],
                    decoration: InputDecoration(hintText: 'Pilihan ${i + 1}'),
                  ),
                ),
                if (_choices.length > 2)
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() {
                      _choices.removeAt(i).dispose();
                    }),
                  ),
              ],
            ),
          if (_choices.length < 8)
            _linkButton(
              'Tambah pilihan',
              () => setState(() => _choices.add(TextEditingController())),
            ),
        ],
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _quizSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        const Text('Soal', style: TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        const Text(
          'Ketuk ikon centang untuk menandai kunci jawaban. Kuis dinilai otomatis.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 8),
        for (var i = 0; i < _quiz.length; i++) _quizCard(i),
        _linkButton('Tambah soal', () => setState(() => _quiz.add(_QuizDraft()))),
      ],
    );
  }

  Widget _quizCard(int i) {
    final q = _quiz[i];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.outline),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Soal ${i + 1}', style: const TextStyle(fontSize: 16)),
              const Spacer(),
              SizedBox(
                width: 80,
                child: TextField(
                  controller: q.points,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Poin'),
                ),
              ),
              if (_quiz.length > 1)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => setState(() => _quiz.removeAt(i).dispose()),
                ),
            ],
          ),
          TextField(
            controller: q.text,
            minLines: 1,
            maxLines: 4,
            decoration: const InputDecoration(hintText: 'Tulis soal'),
          ),
          const SizedBox(height: 8),
          for (var k = 0; k < q.options.length; k++)
            Row(
              children: [
                IconButton(
                  tooltip: 'Kunci jawaban',
                  icon: Icon(
                    q.correct == k
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: q.correct == k ? AppColors.teal : null,
                  ),
                  onPressed: () => setState(() => q.correct = k),
                ),
                Expanded(
                  child: TextField(
                    controller: q.options[k],
                    decoration: InputDecoration(hintText: 'Pilihan ${k + 1}'),
                  ),
                ),
                if (q.options.length > 2)
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() {
                      q.options.removeAt(k).dispose();
                      if (q.correct == k) {
                        q.correct = null;
                      } else if (q.correct != null && q.correct! > k) {
                        q.correct = q.correct! - 1;
                      }
                    }),
                  ),
              ],
            ),
          if (q.options.length < 6)
            _linkButton(
              'Tambah pilihan',
              () => setState(() => q.options.add(TextEditingController())),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final showPoints =
        _type == ClassworkType.assignment || _type == ClassworkType.question;
    final showDeadline = _type != ClassworkType.material;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surfaceHigh,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFA8C7FA),
                foregroundColor: const Color(0xFF062E6F),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
              onPressed: _saving ? null : _submit,
              child: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_submitLabel, style: const TextStyle(fontSize: 18)),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          TextField(
            controller: _title,
            style: const TextStyle(fontSize: 24),
            minLines: 1,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: _titleHint,
              hintStyle: const TextStyle(fontSize: 24),
              border: InputBorder.none,
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.people_outline, size: 28),
                const SizedBox(width: 16),
                Flexible(child: _chip(widget.course.name)),
                const SizedBox(width: 10),
                Flexible(
                  child: _chip(
                    _students.isEmpty
                        ? 'Semua pelajar'
                        : '${_students.length} pelajar',
                    onTap: _pickStudents,
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          const SizedBox(height: 16),
          TextField(
            controller: _desc,
            minLines: 2,
            maxLines: 8,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.notes),
              hintText: _type == ClassworkType.question
                  ? 'Petunjuk (opsional)'
                  : 'Deskripsi',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          if (_type == ClassworkType.question) _questionSection(),
          if (_type == ClassworkType.quiz) _quizSection(),
          const SizedBox(height: 12),
          for (final f in _files)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                f.type == AttachmentType.link
                    ? Icons.link
                    : f.type == AttachmentType.drive
                    ? Icons.add_to_drive_outlined
                    : Icons.insert_drive_file_outlined,
              ),
              title: Text(f.name, maxLines: 1, overflow: TextOverflow.ellipsis),
              trailing: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => setState(() => _files.remove(f)),
              ),
            ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.attach_file),
            title: const Text(
              'Tambahkan lampiran',
              style: TextStyle(fontSize: 18, color: AppColors.link),
            ),
            onTap: _addAttachment,
          ),
          const Divider(),
          if (showPoints) ...[
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: _points == null
                  ? TextButton(
                      onPressed: () => setState(() => _points = 100),
                      child: const Text(
                        'Tanpa poin (ketuk untuk menambah)',
                        style: TextStyle(fontSize: 17),
                      ),
                    )
                  : OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.outline),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      onPressed: _editPoints,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$_points poin',
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(width: 12),
                          InkWell(
                            onTap: () => setState(() => _points = null),
                            child: const Icon(Icons.close, size: 20),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
          if (showDeadline) ...[
            const SizedBox(height: 8),
            _deadline == null
                ? _linkButton('Atur tanggal batas waktu', _pickDeadline)
                : Align(
                    alignment: Alignment.centerLeft,
                    child: _chip(
                      '${DateHelper.date(_deadline!)}, ${DateHelper.time(_deadline!)}',
                      onTap: _pickDeadline,
                      onClear: () => setState(() => _deadline = null),
                    ),
                  ),
          ],
          const SizedBox(height: 8),
          _topic == null
              ? _linkButton('Tambahkan topik', _pickTopic)
              : Align(
                  alignment: Alignment.centerLeft,
                  child: _chip(
                    _topic!.name,
                    onTap: _pickTopic,
                    onClear: () => setState(() => _topic = null),
                  ),
                ),
        ],
      ),
    );
  }
}

/// Dialog nama topik baru. Mengembalikan null bila dibatalkan / kosong.
Future<String?> askTopicName(BuildContext context) async {
  final ctrl = TextEditingController();
  final name = await showDialog<String>(
    context: context,
    builder: (d) => AlertDialog(
      title: const Text('Topik baru'),
      content: TextField(
        controller: ctrl,
        autofocus: true,
        decoration: const InputDecoration(hintText: 'Nama topik'),
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
  return (name == null || name.isEmpty) ? null : name;
}
