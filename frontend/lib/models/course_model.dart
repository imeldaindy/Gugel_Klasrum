import 'dart:convert';

import 'package:flutter/material.dart';

enum CourseArt { book, graduation, devices, mail }

/// Siapa yang boleh memposting di forum kelas.
enum ForumPostPolicy { studentsPostAndComment, studentsCommentOnly, teacherOnly }

/// Cara notifikasi tugas kelas tampil di forum.
enum ClassworkNotifyMode { condensed, full, hidden }

class CourseModel {
  final int id;
  String name;
  String description;
  String section;
  String room;
  String subject;
  String level;
  String teacher;
  final Color colorTop;
  final Color colorBottom;
  final CourseArt art;

  /// Id pembuat kelas. null = kelas bawaan (terlihat oleh semua akun).
  final int? ownerId;

  /// Id akun yang sudah bergabung lewat kode / link undangan.
  final Set<int> memberIds;

  /// Kode kelas untuk bergabung.
  String code;

  /// Jika false, kode & link undangan tidak bisa dipakai untuk bergabung.
  bool inviteEnabled;

  ForumPostPolicy postPolicy;
  ClassworkNotifyMode notifyMode;

  CourseModel({
    required this.id,
    required this.name,
    this.description = '',
    this.section = '',
    this.room = '',
    this.subject = '',
    this.level = '',
    required this.teacher,
    required this.colorTop,
    required this.colorBottom,
    required this.art,
    this.ownerId,
    Set<int>? memberIds,
    String? code,
    this.inviteEnabled = true,
    this.postPolicy = ForumPostPolicy.studentsPostAndComment,
    this.notifyMode = ClassworkNotifyMode.condensed,
  })  : memberIds = memberIds ?? <int>{},
        code = code ?? generateCode();

  static const _alphabet = 'abcdefghijklmnopqrstuvwxyz0123456789';

  /// Kode 8 karakter (huruf kecil + angka), mis. "kojmq6pd".
  static String generateCode() {
    final seed = DateTime.now().microsecondsSinceEpoch;
    var x = seed ^ (seed << 13);
    final b = StringBuffer();
    for (var i = 0; i < 8; i++) {
      x = (x * 1103515245 + 12345) & 0x7fffffff;
      b.write(_alphabet[(x >> 8) % _alphabet.length]);
    }
    return b.toString();
  }

  /// Link undangan, formatnya meniru Google Classroom (…/c/<id>?cjc=<kode>).
  String get inviteLink {
    final enc = base64Url
        .encode('class-$id-$code'.codeUnits)
        .replaceAll('=', '');
    return 'https://classroom.google.com/c/$enc?cjc=$code';
  }

  static const _palette = [
    [Color(0xFF0F5A9C), Color(0xFF0B3D6B)],
    [Color(0xFF3C5BB0), Color(0xFF4C7CE0)],
    [Color(0xFF454B52), Color(0xFF5C6670)],
    [Color(0xFF1E6B5B), Color(0xFF14564A)],
  ];

  /// Dipakai untuk kelas yang dibuat secara lokal (mode dummy).
  factory CourseModel.local({
    required int id,
    required String name,
    String description = '',
    String section = '',
    String room = '',
    String subject = '',
    String level = '',
    required String teacher,
    required int ownerId,
    String? code,
  }) {
    final p = _palette[id % _palette.length];
    return CourseModel(
      id: id,
      name: name,
      description: description,
      section: section,
      room: room,
      subject: subject,
      level: level,
      teacher: teacher,
      colorTop: p[0],
      colorBottom: p[1],
      art: CourseArt.values[id % CourseArt.values.length],
      ownerId: ownerId,
      memberIds: {ownerId},
      code: code,
    );
  }

  factory CourseModel.fromJson(Map<String, dynamic> j, {int? userId}) {
    final id = j['id'] as int;
    final p = _palette[id % _palette.length];
    final isTeacher = j['role'] == 'teacher';
    return CourseModel(
      id: id,
      name: j['name'],
      description: j['description'] ?? '',
      section: j['section'] ?? '',
      room: j['room'] ?? '',
      subject: j['subject'] ?? '',
      level: j['level'] ?? '',
      teacher: j['teacher'] ?? '',
      colorTop: p[0],
      colorBottom: p[1],
      art: CourseArt.values[id % CourseArt.values.length],
      ownerId: isTeacher ? userId : null,
      memberIds: userId == null ? <int>{} : {userId},
      code: j['code'] ?? '',
      inviteEnabled: j['invite_enabled'] ?? true,
      postPolicy: switch (j['post_policy']) {
        'students_comment_only' => ForumPostPolicy.studentsCommentOnly,
        'teacher_only' => ForumPostPolicy.teacherOnly,
        _ => ForumPostPolicy.studentsPostAndComment,
      },
      notifyMode: switch (j['notify_mode']) {
        'full' => ClassworkNotifyMode.full,
        'hidden' => ClassworkNotifyMode.hidden,
        _ => ClassworkNotifyMode.condensed,
      },
    );
  }
}
