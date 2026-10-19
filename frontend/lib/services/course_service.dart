import 'package:flutter/material.dart';

import '../core/constants/api_config.dart';
import '../models/assignment_model.dart';
import '../models/extras_model.dart';
import '../models/course_model.dart';
import '../models/post_model.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class CourseService {
  static final _courses = [
    CourseModel(
      id: 1,
      name: 'Audit Sistem Informasi',
      teacher: 'Rahadian Bisma',
      colorTop: Color(0xFF0F5A9C),
      colorBottom: Color(0xFF0B3D6B),
      art: CourseArt.book,
    ),
    CourseModel(
      id: 2,
      name: 'Literasi Digital187',
      section: 'Rabu, 07.00 - Selesai',
      teacher: 'Asmunin',
      colorTop: Color(0xFF3C5BB0),
      colorBottom: Color(0xFF4C7CE0),
      art: CourseArt.graduation,
    ),
    CourseModel(
      id: 3,
      name: 'KSI-G',
      teacher: 'Cendra Putra, Ph.D',
      colorTop: Color(0xFF454B52),
      colorBottom: Color(0xFF5C6670),
      art: CourseArt.devices,
    ),
    CourseModel(
      id: 4,
      name: 'Manajemen Layanan Pelanggan',
      section: 'S1 SI MLP03 RABU Jam 07:00 - 12:00 A10.…',
      teacher: 'Dwi Fatrianto Suyatno',
      colorTop: Color(0xFF1E6B5B),
      colorBottom: Color(0xFF14564A),
      art: CourseArt.mail,
    ),
    CourseModel(
      id: 5,
      name: 'Keamanan sistem informasi',
      section: '2024',
      teacher: 'Dosen Pengampu',
      colorTop: Color(0xFF0F5A9C),
      colorBottom: Color(0xFF0B3D6B),
      art: CourseArt.book,
    ),
    CourseModel(
      id: 6,
      name: '2024 G - Analisis dan Perancangan Sistem',
      teacher: 'Dosen Pengampu',
      colorTop: Color(0xFF3C5BB0),
      colorBottom: Color(0xFF4C7CE0),
      art: CourseArt.graduation,
    ),
    CourseModel(
      id: 7,
      name: 'SBD 2024G',
      teacher: 'Dosen Pengampu',
      colorTop: Color(0xFF454B52),
      colorBottom: Color(0xFF5C6670),
      art: CourseArt.devices,
    ),
  ];

  Future<List<CourseModel>> getCourses() async {
    if (!ApiConfig.useDummy) {
      final data = await ApiService.get('/courses');
      return (data['data'] as List)
          .map((e) => CourseModel.fromJson(e, userId: ApiService.userId))
          .toList();
    }
    await Future.delayed(const Duration(milliseconds: 400));
    return _courses;
  }

  Future<List<PostModel>> getPosts(int courseId) async {
    if (!ApiConfig.useDummy) {
      final data = await ApiService.get('/courses/$courseId/posts');
      return (data['data'] as List).map((e) => PostModel.fromJson(e)).toList();
    }
    if (courseId != 1) return [];
    return [
      PostModel(
        id: 1,
        authorName: 'Rahadian Bisma',
        content: 'Tugas Audit Program dan Audit Plan',
        createdAt: DateTime(2026, 10, 15, 11, 31),
        isAssignmentNotice: true,
      ),
      PostModel(
        id: 2,
        authorName: 'Rahadian Bisma',
        content:
            'Tugas Audit plan. silahkan dikumpulkan disini.\n'
            'cukup ketua kelompok yang mengumpulkan,\n'
            'Tuliskan\n\n'
            '• Objek Audit/Standart\n'
            '• nama anggota,\n'
            '• nim,\n'
            '• kelas',
        createdAt: DateTime(2026, 10, 15, 8, 54),
      ),
    ];
  }

  Future<List<AssignmentModel>> getAssignments(int courseId) async {
    if (!ApiConfig.useDummy) {
      final data = await ApiService.get('/courses/$courseId/assignments');
      return (data['data'] as List)
          .map((e) => AssignmentModel.fromJson(e))
          .toList();
    }
    if (courseId != 1) return [];
    return [
      AssignmentModel(
        id: 1,
        courseId: 1,
        title: 'Tugas Audit Program dan Audit Plan',
        description:
            'Kumpulkan audit plan kelompok. Cukup ketua kelompok '
            'yang mengumpulkan.',
      ),
    ];
  }

  Future<List<UserModel>> getPeople(int courseId) async {
    if (!ApiConfig.useDummy) {
      final data = await ApiService.get('/courses/$courseId/people');
      return (data['data'] as List).map((e) => UserModel.fromJson(e)).toList();
    }
    const names = [
      '001_TATA IVANKA',
      '002_YOHANA NOVI',
      '004_MUSA PANJAITAN',
      '005_Naila Zazkia Rizqina',
      '006_FERISCA APRILIA PUTRI',
      '006_Fitri Aisyah Ramadani',
      '007_ SINTA AFIFAH KHOIRUN',
    ];
    const colors = [
      AppAvatarColors.brown,
      AppAvatarColors.red,
      AppAvatarColors.grey,
      Color(0xFF8AB4F8),
      Color(0xFF8AB4F8),
      AppAvatarColors.red,
      AppAvatarColors.brown,
    ];
    return List.generate(
      names.length,
      (i) =>
          UserModel(id: 100 + i, name: names[i], email: '', color: colors[i]),
    );
  }

  // ---------- Tulis ke API (mode Laravel) ----------
  CourseModel _course(dynamic res) =>
      CourseModel.fromJson(res['data'], userId: ApiService.userId);

  static String _policy(ForumPostPolicy p) => switch (p) {
    ForumPostPolicy.studentsPostAndComment => 'students_post_and_comment',
    ForumPostPolicy.studentsCommentOnly => 'students_comment_only',
    ForumPostPolicy.teacherOnly => 'teacher_only',
  };

  static String _notify(ClassworkNotifyMode m) => m.name;

  Future<CourseModel> createCourse(Map<String, dynamic> body) async =>
      _course(await ApiService.post('/courses', body));

  Future<CourseModel> joinCourse(String code) async =>
      _course(await ApiService.post('/courses/join', {'code': code}));

  Future<CourseModel> updateCourse(
    int id, {
    required String name,
    required String description,
    required String section,
    required String room,
    required String subject,
    required String level,
    required bool inviteEnabled,
    required ForumPostPolicy postPolicy,
    required ClassworkNotifyMode notifyMode,
  }) async => _course(
    await ApiService.put('/courses/$id', {
      'name': name,
      'description': description,
      'section': section,
      'room': room,
      'subject': subject,
      'level': level,
      'invite_enabled': inviteEnabled,
      'post_policy': _policy(postPolicy),
      'notify_mode': _notify(notifyMode),
    }),
  );

  Future<CourseModel> resetCode(int id) async =>
      _course(await ApiService.post('/courses/$id/reset-code', {}));

  Future<PostModel> createPost(int courseId, String content) async {
    final res = await ApiService.post('/courses/$courseId/posts', {
      'content': content,
    });
    return PostModel.fromJson(res['data']);
  }

  Future<void> submit(int assignmentId, List<Attachment> files) async {
    await ApiService.post('/assignments/$assignmentId/submit', {
      'attachments': [
        for (final f in files) {'type': f.type.name, 'name': f.name},
      ],
    });
  }

  Future<void> unsubmit(int assignmentId) async {
    await ApiService.delete('/assignments/$assignmentId/submit');
  }

  // ---------- Tugas kelas: tugas / kuis / pertanyaan / materi ----------
  AssignmentModel _asg(dynamic res) => AssignmentModel.fromJson(res['data']);

  Future<AssignmentModel> createClasswork(
    int courseId,
    Map<String, dynamic> body,
  ) async => _asg(await ApiService.post('/courses/$courseId/assignments', body));

  Future<AssignmentModel> reuseClasswork(int courseId, int sourceId) async =>
      _asg(
        await ApiService.post('/courses/$courseId/assignments/reuse', {
          'assignment_id': sourceId,
        }),
      );

  Future<AssignmentModel> getAssignment(int id) async =>
      _asg(await ApiService.get('/assignments/$id'));

  Future<void> deleteAssignment(int id) async {
    await ApiService.delete('/assignments/$id');
  }

  Future<List<TopicModel>> getTopics(int courseId) async {
    final data = await ApiService.get('/courses/$courseId/topics');
    return (data['data'] as List).map((e) => TopicModel.fromJson(e)).toList();
  }

  Future<TopicModel> createTopic(int courseId, String name) async {
    final res = await ApiService.post('/courses/$courseId/topics', {
      'name': name,
    });
    return TopicModel.fromJson(res['data']);
  }

  Future<void> deleteTopic(int courseId, int topicId) async {
    await ApiService.delete('/courses/$courseId/topics/$topicId');
  }

  Future<AssignmentModel> submitAnswer(int id, String answer) async =>
      _asg(await ApiService.post('/assignments/$id/submit', {'answer': answer}));

  Future<AssignmentModel> submitQuiz(int id, List<int?> answers) async =>
      _asg(await ApiService.post('/assignments/$id/submit', {'answers': answers}));

  Future<List<StudentWork>> getSubmissions(int id) async {
    final data = await ApiService.get('/assignments/$id/submissions');
    return (data['data'] as List).map((e) => StudentWork.fromJson(e)).toList();
  }

  Future<void> grade(int id, int userId, int? score) async {
    await ApiService.put('/assignments/$id/submissions/$userId', {
      'score': score,
    });
  }
}
