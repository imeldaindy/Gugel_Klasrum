import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

/// Kumpulan controller untuk form "Detail kelas".
class ClassFormControllers {
  final name = TextEditingController();
  final description = TextEditingController();
  final section = TextEditingController();
  final room = TextEditingController();
  final subject = TextEditingController();
  final level = TextEditingController();

  ClassFormControllers({
    String name = '',
    String description = '',
    String section = '',
    String room = '',
    String subject = '',
    String level = '',
  }) {
    this.name.text = name;
    this.description.text = description;
    this.section.text = section;
    this.room.text = room;
    this.subject.text = subject;
    this.level.text = level;
  }

  List<TextEditingController> get all =>
      [name, description, section, room, subject, level];

  void dispose() {
    for (final c in all) {
      c.dispose();
    }
  }
}

/// Kolom teks outline dengan tombol hapus (x), seperti di Google Classroom.
class ClearableField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? errorText;
  final bool autofocus;
  final TextInputAction? textInputAction;

  const ClearableField({
    super.key,
    required this.controller,
    required this.label,
    this.errorText,
    this.autofocus = false,
    this.textInputAction = TextInputAction.next,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (_, value, __) => TextField(
        controller: controller,
        autofocus: autofocus,
        textInputAction: textInputAction,
        style: const TextStyle(fontSize: 18, color: AppColors.textPrimary),
        decoration: InputDecoration(
          labelText: label,
          errorText: errorText,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
          suffixIcon: value.text.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.cancel_outlined, size: 30),
                  color: AppColors.textPrimary,
                  onPressed: controller.clear,
                ),
        ),
      ),
    );
  }
}

/// Enam kolom "Detail kelas": nama (wajib), deskripsi, bagian, ruang,
/// mata pelajaran, tingkat.
class ClassDetailFields extends StatelessWidget {
  final ClassFormControllers ctrls;
  final String? nameError;
  final bool autofocusName;

  const ClassDetailFields({
    super.key,
    required this.ctrls,
    this.nameError,
    this.autofocusName = false,
  });

  @override
  Widget build(BuildContext context) {
    const gap = SizedBox(height: 20);
    return Column(
      children: [
        ClearableField(
          controller: ctrls.name,
          label: 'Nama kelas (wajib)',
          errorText: nameError,
          autofocus: autofocusName,
        ),
        gap,
        ClearableField(controller: ctrls.description, label: 'Deskripsi kelas'),
        gap,
        ClearableField(controller: ctrls.section, label: 'Bagian'),
        gap,
        ClearableField(controller: ctrls.room, label: 'Ruang'),
        gap,
        ClearableField(controller: ctrls.subject, label: 'Mata pelajaran'),
        gap,
        ClearableField(
          controller: ctrls.level,
          label: 'Tingkat',
          textInputAction: TextInputAction.done,
        ),
      ],
    );
  }
}
