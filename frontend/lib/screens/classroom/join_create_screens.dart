import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../models/course_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/course_provider.dart';
import '../../widgets/class_form_fields.dart';
import 'class_detail_screen.dart';

/// Panggil dari onPressed FAB di HomeScreen.
void showJoinCreateSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetCtx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          ListTile(
            leading: const Icon(Icons.group_add_outlined),
            title: const Text('Gabung ke kelas'),
            onTap: () {
              Navigator.pop(sheetCtx);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const JoinClassScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.add_box_outlined),
            title: const Text('Buat kelas'),
            onTap: () {
              Navigator.pop(sheetCtx);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateClassScreen()),
              );
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    ),
  );
}

class JoinClassScreen extends StatefulWidget {
  const JoinClassScreen({super.key});

  @override
  State<JoinClassScreen> createState() => _JoinClassScreenState();
}

class _JoinClassScreenState extends State<JoinClassScreen> {
  final _ctrl = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _join() async {
    final messenger = ScaffoldMessenger.of(context);
    final err = await context.read<CourseProvider>().joinCourse(_ctrl.text);
    if (!mounted) return;
    if (err != null) {
      setState(() => _error = err);
      return;
    }
    Navigator.pop(context);
    messenger.showSnackBar(
      const SnackBar(content: Text('Berhasil bergabung ke kelas')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().current;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surfaceHigh,
        title: const Text('Gabung ke kelas'),
        actions: [TextButton(onPressed: _join, child: const Text('Gabung'))],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Anda masuk sebagai',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(user?.name ?? '-', style: const TextStyle(fontSize: 18)),
          Text(
            user?.email ?? '',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          const Text(
            'Minta kode kelas atau link undangan kepada pengajar, lalu masukkan di sini.',
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _ctrl,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Kode kelas atau link undangan',
              errorText: _error,
              border: const OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() => _error = null),
          ),
          const SizedBox(height: 16),
          const Text(
            '• Kode terdiri dari 5-8 huruf atau angka, tanpa spasi\n• Anda juga bisa menempelkan link undangan dari pengajar',
            style: TextStyle(color: AppColors.textSecondary, height: 1.6),
          ),
        ],
      ),
    );
  }
}

class CreateClassScreen extends StatefulWidget {
  const CreateClassScreen({super.key});

  @override
  State<CreateClassScreen> createState() => _CreateClassScreenState();
}

class _CreateClassScreenState extends State<CreateClassScreen> {
  final _f = ClassFormControllers();
  bool _showErr = false;

  @override
  void initState() {
    super.initState();
    _f.name.addListener(() {
      if (_showErr && _f.name.text.trim().isNotEmpty) {
        setState(() => _showErr = false);
      }
    });
  }

  @override
  void dispose() {
    _f.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (_f.name.text.trim().isEmpty) {
      setState(() => _showErr = true);
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);
    CourseModel? created;
    try {
      created = await context.read<CourseProvider>().createCourse(
        name: _f.name.text,
        description: _f.description.text,
        section: _f.section.text,
        room: _f.room.text,
        subject: _f.subject.text,
        level: _f.level.text,
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.toString())));
      return;
    }
    if (created == null) return;
    final CourseModel course = created;
    // Langsung buka kelas yang baru dibuat.
    nav.pushReplacement(
      MaterialPageRoute(builder: (_) => ClassDetailScreen(course: course)),
    );
    messenger.showSnackBar(
      SnackBar(content: Text('Kelas dibuat. Kode kelas: ${course.code}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surfaceHigh,
        title: const Text('Buat kelas'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: FilledButton(
              onPressed: _create,
              style: FilledButton.styleFrom(
                minimumSize: const Size(90, 44),
                shape: const StadiumBorder(),
              ),
              child: const Text('Buat', style: TextStyle(fontSize: 17)),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(0, 8, 0, 16),
            child: Text(
              'Detail kelas',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          ClassDetailFields(
            ctrls: _f,
            autofocusName: true,
            nameError: _showErr ? 'Nama kelas wajib diisi' : null,
          ),
        ],
      ),
    );
  }
}
