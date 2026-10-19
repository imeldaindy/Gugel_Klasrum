import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../models/course_model.dart';
import '../../providers/course_provider.dart';
import '../../widgets/class_form_fields.dart';

/// "Setelan kelas": detail kelas, kode undangan, forum.
class ClassSettingsScreen extends StatefulWidget {
  final CourseModel course;
  const ClassSettingsScreen({super.key, required this.course});

  @override
  State<ClassSettingsScreen> createState() => _ClassSettingsScreenState();
}

class _ClassSettingsScreenState extends State<ClassSettingsScreen> {
  late final ClassFormControllers _f;
  late bool _invite;
  late ForumPostPolicy _policy;
  late ClassworkNotifyMode _notify;

  CourseModel get _c => widget.course;

  @override
  void initState() {
    super.initState();
    _f = ClassFormControllers(
      name: _c.name,
      description: _c.description,
      section: _c.section,
      room: _c.room,
      subject: _c.subject,
      level: _c.level,
    );
    _invite = _c.inviteEnabled;
    _policy = _c.postPolicy;
    _notify = _c.notifyMode;
    for (final c in _f.all) {
      c.addListener(_refresh);
    }
  }

  void _refresh() => setState(() {});

  @override
  void dispose() {
    _f.dispose();
    super.dispose();
  }

  bool get _dirty =>
      _f.name.text.trim() != _c.name ||
      _f.description.text.trim() != _c.description ||
      _f.section.text.trim() != _c.section ||
      _f.room.text.trim() != _c.room ||
      _f.subject.text.trim() != _c.subject ||
      _f.level.text.trim() != _c.level ||
      _invite != _c.inviteEnabled ||
      _policy != _c.postPolicy ||
      _notify != _c.notifyMode;

  bool get _canSave => _dirty && _f.name.text.trim().isNotEmpty;

  Future<void> _save() async {
    final messenger = ScaffoldMessenger.of(context);
    final err = await context.read<CourseProvider>().updateCourse(
          _c,
          name: _f.name.text,
          description: _f.description.text,
          section: _f.section.text,
          room: _f.room.text,
          subject: _f.subject.text,
          level: _f.level.text,
          inviteEnabled: _invite,
          postPolicy: _policy,
          notifyMode: _notify,
        );
    if (!mounted) return;
    setState(() {});
    messenger.showSnackBar(
      SnackBar(content: Text(err ?? 'Setelan kelas disimpan')),
    );
  }

  Future<void> _copy(String text, String msg) async {
    final messenger = ScaffoldMessenger.of(context);
    await Clipboard.setData(ClipboardData(text: text));
    messenger.showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _reset() async {
    final prov = context.read<CourseProvider>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceHigh,
        title: const Text('Reset kode kelas?'),
        content: const Text(
            'Kode dan link undangan yang lama tidak akan berlaku lagi. '
            'Siswa yang sudah bergabung tetap berada di kelas.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Reset')),
        ],
      ),
    );
    if (ok == true) {
      final err = await prov.resetCode(_c);
      if (err != null && mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(err)));
      }
    }
  }

  Widget _section(String t) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 28, 16, 12),
        child: Text(t,
            style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary)),
      );

  Widget _menuRow<T>({
    required String title,
    required String subtitle,
    required List<MapEntry<T, String>> options,
    required ValueChanged<T> onSelected,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.fromLTRB(16, 4, 4, 4),
      title: Text(title, style: const TextStyle(fontSize: 18)),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(subtitle,
            style: const TextStyle(
                fontSize: 15, color: AppColors.textSecondary)),
      ),
      trailing: PopupMenuButton<T>(
        icon: const Icon(Icons.more_vert),
        color: AppColors.surfaceHigh,
        onSelected: onSelected,
        itemBuilder: (_) => options
            .map((o) => PopupMenuItem<T>(value: o.key, child: Text(o.value)))
            .toList(),
      ),
    );
  }

  static const _policyText = {
    ForumPostPolicy.studentsPostAndComment:
        'Siswa dapat memposting dan memberi komentar',
    ForumPostPolicy.studentsCommentOnly: 'Siswa hanya dapat memberi komentar',
    ForumPostPolicy.teacherOnly:
        'Hanya pengajar yang dapat memposting atau berkomentar',
  };

  static const _notifyText = {
    ClassworkNotifyMode.condensed: 'Tampilkan notifikasi yang dipadatkan',
    ClassworkNotifyMode.full: 'Tampilkan notifikasi lengkap',
    ClassworkNotifyMode.hidden: 'Jangan tampilkan notifikasi',
  };

  @override
  Widget build(BuildContext context) {
    // Rebuild saat kode di-reset.
    context.watch<CourseProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surfaceHigh,
        title: const Text('Setelan kelas'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: FilledButton(
              onPressed: _canSave ? _save : null,
              style: FilledButton.styleFrom(
                minimumSize: const Size(100, 44),
                shape: const StadiumBorder(),
              ),
              child: const Text('Simpan', style: TextStyle(fontSize: 17)),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          _section('Detail kelas'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClassDetailFields(ctrls: _f),
          ),
          const SizedBox(height: 12),
          _section('Kode undangan'),
          SwitchListTile(
            contentPadding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
            title:
                const Text('Kelola kode undangan', style: TextStyle(fontSize: 18)),
            subtitle: const Text('Setelan berlaku untuk link undangan dan kode kelas',
                style: TextStyle(fontSize: 15, color: AppColors.textSecondary)),
            value: _invite,
            onChanged: (v) => setState(() => _invite = v),
          ),
          Opacity(
            opacity: _invite ? 1 : 0.4,
            child: Column(
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.fromLTRB(16, 4, 8, 4),
                  title: Text('Kode kelas: ${_c.code}',
                      style: const TextStyle(fontSize: 18)),
                  onTap: () => _copy(_c.code, 'Kode kelas disalin'),
                  trailing: TextButton(
                    onPressed: _invite ? _reset : null,
                    child: const Text('Reset', style: TextStyle(fontSize: 17)),
                  ),
                ),
                ListTile(
                  contentPadding: const EdgeInsets.fromLTRB(16, 4, 8, 4),
                  title: const Text('Link undangan:',
                      style: TextStyle(fontSize: 18)),
                  subtitle: Text(_c.inviteLink,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 16, color: AppColors.textSecondary)),
                  onTap: _invite
                      ? () => _copy(_c.inviteLink, 'Link undangan disalin')
                      : null,
                  trailing: IconButton(
                    icon: const Icon(Icons.share_outlined),
                    onPressed: _invite
                        ? () => _copy(_c.inviteLink, 'Link undangan disalin')
                        : null,
                  ),
                ),
              ],
            ),
          ),
          if (!_invite)
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: Text(
                'Undangan dinonaktifkan: siswa tidak bisa bergabung dengan kode ini.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            ),
          const Padding(
              padding: EdgeInsets.only(top: 16), child: Divider()),
          _section('Forum'),
          _menuRow<ForumPostPolicy>(
            title: 'Postingan forum',
            subtitle: _policyText[_policy]!,
            options: _policyText.entries.toList(),
            onSelected: (v) => setState(() => _policy = v),
          ),
          _menuRow<ClassworkNotifyMode>(
            title: 'Tugas kelas di forum',
            subtitle: _notifyText[_notify]!,
            options: _notifyText.entries.toList(),
            onSelected: (v) => setState(() => _notify = v),
          ),
          const Padding(
              padding: EdgeInsets.only(top: 16), child: Divider()),
          _section('Kelola link Meet'),
          ListTile(
            contentPadding: const EdgeInsets.fromLTRB(16, 4, 8, 4),
            title: const Text('Link Meet Classroom',
                style: TextStyle(fontSize: 18)),
            subtitle: const Text(
                'Link Meet Classroom menawarkan fitur keamanan tambahan.',
                style: TextStyle(fontSize: 15, color: AppColors.textSecondary)),
            trailing: IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () => showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: AppColors.surfaceHigh,
                  title: const Text('Link Meet Classroom'),
                  content: const Text(
                      'Fitur ini belum tersedia di aplikasi ini.'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Tutup')),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
