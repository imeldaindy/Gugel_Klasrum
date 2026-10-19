import 'package:flutter/material.dart';

import '../core/constants/api_config.dart';
import '../models/assignment_model.dart';
import '../models/course_model.dart';
import '../models/extras_model.dart';
import '../models/post_model.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/course_service.dart';
import 'auth_provider.dart';

class CourseProvider extends ChangeNotifier {
  final AuthProvider _auth;
  final _service = CourseService();

  CourseProvider(this._auth) {
    // Saat ganti / tambah akun, daftar kelas ikut menyesuaikan.
    _lastUid = _auth.current?.id;
    _auth.addListener(_onAuthChanged);
  }

  int? _lastUid;

  void _onAuthChanged() {
    final uid = _auth.current?.id;
    if (!ApiConfig.useDummy && uid != _lastUid) {
      _lastUid = uid;
      _all = [];
      _posts.clear();
      _assignments.clear();
      _people.clear();
      _topics.clear();
      notifyListeners();
      if (uid != null) loadAll();
      return;
    }
    notifyListeners();
  }

  String _msg(Object e) => e is ApiException ? e.message : e.toString();

  Future<void> _loadDetails(int id) async {
    _posts[id] = await _service.getPosts(id);
    _assignments[id] = await _service.getAssignments(id);
    _people[id] = await _service.getPeople(id);
    if (!ApiConfig.useDummy) _topics[id] = await _service.getTopics(id);
  }

  @override
  void dispose() {
    _auth.removeListener(_onAuthChanged);
    super.dispose();
  }

  /// Semua kelas yang ada di aplikasi (dipakai bersama oleh semua akun,
  /// sehingga kode undangan dari satu akun bisa dipakai akun lain).
  List<CourseModel> _all = [];
  bool loading = false;
  String? error;

  int? get _uid => _auth.current?.id;

  bool _visibleTo(CourseModel c, int? uid) =>
      c.ownerId == null || c.ownerId == uid || c.memberIds.contains(uid);

  /// Kelas milik / diikuti akun yang sedang aktif.
  List<CourseModel> get courses =>
      _all.where((c) => _visibleTo(c, _uid)).toList();

  bool isOwner(CourseModel c) => c.ownerId != null && c.ownerId == _uid;

  bool isOwnerOfId(int courseId) {
    final c = _all.where((e) => e.id == courseId).firstOrNull;
    return c != null && isOwner(c);
  }

  final Map<int, List<PostModel>> _posts = {};
  final Map<int, List<AssignmentModel>> _assignments = {};
  final Map<int, List<UserModel>> _people = {};
  final Map<int, List<TopicModel>> _topics = {};

  final Map<String, List<ClassComment>> _comments = {};
  final Map<int, List<Attachment>> _attachments = {};

  Future<void> loadAll() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final loaded = await _service.getCourses();
      // Pertahankan kelas yang dibuat pengguna saat refresh.
      final local = ApiConfig.useDummy
          ? _all.where((c) => c.ownerId != null).toList()
          : <CourseModel>[];
      final loadedIds = loaded.map((c) => c.id).toSet();
      _all = [...loaded, ...local.where((c) => !loadedIds.contains(c.id))];
      for (final c in loaded) {
        await _loadDetails(c.id);
      }
    } catch (e) {
      error = e.toString();
    }
    loading = false;
    notifyListeners();
  }

  List<PostModel> postsOf(int id) => _posts[id] ?? [];
  List<AssignmentModel> assignmentsOf(int id) => _assignments[id] ?? [];
  List<UserModel> peopleOf(int id) {
    final c = _all.where((e) => e.id == id).firstOrNull;
    if (ApiConfig.useDummy && c != null && c.ownerId != null) {
      // Kelas buatan pengguna: teman sekelas = akun yang bergabung (selain pengajar).
      return _auth.accounts
          .where((u) => c.memberIds.contains(u.id) && u.id != c.ownerId)
          .toList();
    }
    return _people[id] ?? [];
  }

  List<TopicModel> topicsOf(int id) => _topics[id] ?? [];

  /// Daftar "Harus dikumpulkan": tanpa materi & tanpa kelas yang diajar sendiri.
  List<AssignmentModel> get allAssignments => _assignments.entries
      .where((e) => !isOwnerOfId(e.key))
      .expand((e) => e.value)
      .where((a) => !a.isMaterial)
      .toList();

  /// Mengembalikan null jika sukses, atau pesan error.
  Future<String?> addPost(int courseId, String author, String content) async {
    if (!ApiConfig.useDummy) {
      try {
        final p = await _service.createPost(courseId, content);
        _posts[courseId] = [p, ...(_posts[courseId] ?? [])];
        notifyListeners();
        return null;
      } catch (e) {
        return _msg(e);
      }
    }
    final list = _posts[courseId] ?? [];
    list.insert(
      0,
      PostModel(
        id: DateTime.now().millisecondsSinceEpoch,
        authorName: author,
        content: content,
        createdAt: DateTime.now(),
      ),
    );
    _posts[courseId] = list;
    notifyListeners();
    return null;
  }

  Future<String?> markDone(AssignmentModel a) async {
    if (!ApiConfig.useDummy) {
      try {
        await _service.submit(a.id, attachmentsOf(a.id));
      } catch (e) {
        return _msg(e);
      }
    }
    a.status = AssignmentStatus.done;
    notifyListeners();
    return null;
  }

  Future<String?> unmarkDone(AssignmentModel a) async {
    if (!ApiConfig.useDummy) {
      try {
        await _service.unsubmit(a.id);
      } catch (e) {
        return _msg(e);
      }
    }
    a.status = AssignmentStatus.assigned;
    notifyListeners();
    return null;
  }

  // ---------- Komentar kelas (key: 'a_<id tugas>' / 'p_<id post>') ----------
  List<ClassComment> commentsOf(String key) => _comments[key] ?? [];

  void addComment(String key, String text, String author) {
    if (text.trim().isEmpty) return;
    _comments
        .putIfAbsent(key, () => [])
        .add(ClassComment(author: author, text: text.trim()));
    notifyListeners();
  }

  // ---------- Lampiran tugas ----------
  List<Attachment> attachmentsOf(int assignmentId) =>
      _attachments[assignmentId] ?? [];

  void addAttachment(int assignmentId, Attachment a) {
    _attachments.putIfAbsent(assignmentId, () => []).add(a);
    notifyListeners();
  }

  void removeAttachment(int assignmentId, Attachment a) {
    _attachments[assignmentId]?.remove(a);
    notifyListeners();
  }

  // ---------- Gabung / buat kelas ----------
  int _nextCourseId() => _all.isEmpty
      ? 1
      : _all.map((c) => c.id).reduce((a, b) => a > b ? a : b) + 1;

  String _uniqueCode() {
    var code = CourseModel.generateCode();
    while (_all.any((c) => c.code == code)) {
      code = CourseModel.generateCode();
    }
    return code;
  }

  CourseModel? courseById(int id) =>
      _all.where((c) => c.id == id).firstOrNull;

  /// Ambil kode dari input: bisa kode biasa atau link undangan (…?cjc=kode).
  String _extractCode(String input) {
    final t = input.trim();
    final uri = Uri.tryParse(t);
    final cjc = uri?.queryParameters['cjc'];
    return (cjc ?? t).trim();
  }

  /// Mengembalikan null jika sukses, atau pesan error.
  Future<String?> joinCourse(String codeOrLink) async {
    final uid = _uid;
    if (uid == null) return 'Silakan masuk terlebih dahulu.';
    final code = _extractCode(codeOrLink);
    if (!RegExp(r'^[a-zA-Z0-9]{5,8}$').hasMatch(code)) {
      return 'Kode kelas tidak valid. Gunakan 5-8 huruf atau angka.';
    }
    if (!ApiConfig.useDummy) {
      try {
        final joined = await _service.joinCourse(code.toLowerCase());
        _all = [..._all.where((e) => e.id != joined.id), joined];
        await _loadDetails(joined.id);
        notifyListeners();
        return null;
      } catch (e) {
        return _msg(e);
      }
    }
    final c = _all
        .where((e) => e.code.toLowerCase() == code.toLowerCase())
        .firstOrNull;
    if (c == null) return 'Kelas tidak ditemukan. Periksa kembali kode kelas.';
    if (!c.inviteEnabled) {
      return 'Undangan untuk kelas ini sedang dinonaktifkan oleh pengajar.';
    }
    if (c.ownerId == uid) return 'Anda adalah pengajar di kelas ini.';
    if (c.memberIds.contains(uid) || c.ownerId == null) {
      return 'Anda sudah bergabung di kelas ini.';
    }
    c.memberIds.add(uid);
    notifyListeners();
    return null;
  }

  /// Membuat kelas baru. Pembuat otomatis menjadi pengajar.
  /// Di mode API, melempar ApiException bila gagal.
  Future<CourseModel?> createCourse({
    required String name,
    String description = '',
    String section = '',
    String room = '',
    String subject = '',
    String level = '',
  }) async {
    final user = _auth.current;
    if (user == null) return null;
    if (!ApiConfig.useDummy) {
      final created = await _service.createCourse({
        'name': name.trim(),
        'description': description.trim(),
        'section': section.trim(),
        'room': room.trim(),
        'subject': subject.trim(),
        'level': level.trim(),
      });
      _all = [..._all, created];
      _posts[created.id] = [];
      _assignments[created.id] = [];
      _people[created.id] = [];
      notifyListeners();
      return created;
    }
    final c = CourseModel.local(
      id: _nextCourseId(),
      name: name.trim(),
      description: description.trim(),
      section: section.trim(),
      room: room.trim(),
      subject: subject.trim(),
      level: level.trim(),
      teacher: user.name,
      ownerId: user.id,
      code: _uniqueCode(),
    );
    _all = [..._all, c];
    _posts[c.id] = [];
    _assignments[c.id] = [];
    _people[c.id] = [];
    notifyListeners();
    return c;
  }

  /// Simpan perubahan di Setelan kelas.
  /// Mengembalikan null jika sukses, atau pesan error.
  Future<String?> updateCourse(
    CourseModel c, {
    required String name,
    required String description,
    required String section,
    required String room,
    required String subject,
    required String level,
    required bool inviteEnabled,
    required ForumPostPolicy postPolicy,
    required ClassworkNotifyMode notifyMode,
  }) async {
    if (!ApiConfig.useDummy) {
      try {
        await _service.updateCourse(
          c.id,
          name: name.trim(),
          description: description.trim(),
          section: section.trim(),
          room: room.trim(),
          subject: subject.trim(),
          level: level.trim(),
          inviteEnabled: inviteEnabled,
          postPolicy: postPolicy,
          notifyMode: notifyMode,
        );
      } catch (e) {
        return _msg(e);
      }
    }
    c.name = name.trim();
    c.description = description.trim();
    c.section = section.trim();
    c.room = room.trim();
    c.subject = subject.trim();
    c.level = level.trim();
    c.inviteEnabled = inviteEnabled;
    c.postPolicy = postPolicy;
    c.notifyMode = notifyMode;
    notifyListeners();
    return null;
  }

  /// Buat kode kelas baru; kode lama otomatis tidak berlaku.
  Future<String?> resetCode(CourseModel c) async {
    if (!ApiConfig.useDummy) {
      try {
        c.code = (await _service.resetCode(c.id)).code;
      } catch (e) {
        return _msg(e);
      }
    } else {
      c.code = _uniqueCode();
    }
    notifyListeners();
    return null;
  }

  // ---------- Tugas kelas (butuh server Laravel) ----------
  static const _needApi =
      'Fitur ini membutuhkan koneksi ke server (ApiConfig.useDummy = false).';

  Future<String?> createClasswork(
    int courseId,
    Map<String, dynamic> body,
  ) async {
    if (ApiConfig.useDummy) return _needApi;
    try {
      final a = await _service.createClasswork(courseId, body);
      _assignments[courseId] = [...assignmentsOf(courseId), a];
      _posts[courseId] = await _service.getPosts(courseId);
      notifyListeners();
      return null;
    } catch (e) {
      return _msg(e);
    }
  }

  Future<String?> reuseClasswork(int courseId, int sourceId) async {
    if (ApiConfig.useDummy) return _needApi;
    try {
      final a = await _service.reuseClasswork(courseId, sourceId);
      _assignments[courseId] = [...assignmentsOf(courseId), a];
      _topics[courseId] = await _service.getTopics(courseId);
      _posts[courseId] = await _service.getPosts(courseId);
      notifyListeners();
      return null;
    } catch (e) {
      return _msg(e);
    }
  }

  Future<String?> createTopic(int courseId, String name) async {
    if (ApiConfig.useDummy) return _needApi;
    try {
      final t = await _service.createTopic(courseId, name);
      _topics[courseId] = [...topicsOf(courseId), t];
      notifyListeners();
      return null;
    } catch (e) {
      return _msg(e);
    }
  }

  Future<String?> deleteTopic(int courseId, int topicId) async {
    if (ApiConfig.useDummy) return _needApi;
    try {
      await _service.deleteTopic(courseId, topicId);
      _topics[courseId] = topicsOf(
        courseId,
      ).where((t) => t.id != topicId).toList();
      _assignments[courseId] = await _service.getAssignments(courseId);
      notifyListeners();
      return null;
    } catch (e) {
      return _msg(e);
    }
  }

  Future<String?> deleteAssignment(AssignmentModel a) async {
    if (ApiConfig.useDummy) return _needApi;
    try {
      await _service.deleteAssignment(a.id);
      _assignments[a.courseId] = assignmentsOf(
        a.courseId,
      ).where((e) => e.id != a.id).toList();
      notifyListeners();
      return null;
    } catch (e) {
      return _msg(e);
    }
  }

  /// Muat ulang satu item (mis. jumlah yang sudah menyerahkan).
  Future<void> refreshAssignment(AssignmentModel a) async {
    if (ApiConfig.useDummy) return;
    try {
      a.updateFrom(await _service.getAssignment(a.id));
      notifyListeners();
    } catch (_) {}
  }

  Future<String?> submitAnswer(AssignmentModel a, String answer) async {
    try {
      a.updateFrom(await _service.submitAnswer(a.id, answer));
      notifyListeners();
      return null;
    } catch (e) {
      return _msg(e);
    }
  }

  Future<String?> submitQuiz(AssignmentModel a, List<int?> answers) async {
    try {
      a.updateFrom(await _service.submitQuiz(a.id, answers));
      notifyListeners();
      return null;
    } catch (e) {
      return _msg(e);
    }
  }

  Future<List<StudentWork>> submissionsOf(AssignmentModel a) =>
      _service.getSubmissions(a.id);

  Future<String?> gradeWork(AssignmentModel a, int userId, int? score) async {
    try {
      await _service.grade(a.id, userId, score);
      return null;
    } catch (e) {
      return _msg(e);
    }
  }
}
