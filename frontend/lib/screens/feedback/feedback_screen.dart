import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _ctrl = TextEditingController();
  bool _screenshot = true;
  bool _sysInfo = true;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _send() {
    final messenger = ScaffoldMessenger.of(context);
    if (_ctrl.text.trim().isEmpty) {
      messenger.showSnackBar(
          const SnackBar(content: Text('Tulis masukan Anda terlebih dahulu')));
      return;
    }
    Navigator.pop(context);
    messenger.showSnackBar(
        const SnackBar(content: Text('Terima kasih! Masukan Anda terkirim.')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surfaceHigh,
        title: const Text('Kirim masukan'),
        actions: [IconButton(icon: const Icon(Icons.send), onPressed: _send)],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _ctrl,
            maxLines: 8,
            decoration: const InputDecoration(
              hintText: 'Jelaskan masukan Anda (wajib diisi)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          CheckboxListTile(
            value: _screenshot,
            onChanged: (v) => setState(() => _screenshot = v ?? false),
            title: const Text('Sertakan screenshot'),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          CheckboxListTile(
            value: _sysInfo,
            onChanged: (v) => setState(() => _sysInfo = v ?? false),
            title: const Text('Sertakan log & info sistem'),
            controlAffinity: ListTileControlAffinity.leading,
          ),
        ],
      ),
    );
  }
}
