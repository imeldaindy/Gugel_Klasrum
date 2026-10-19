import '../core/utils/date_helper.dart';
import 'extras_model.dart';
import 'user_model.dart';

enum AssignmentStatus { assigned, missing, done }

enum ClassworkType { assignment, quiz, question, material }

extension ClassworkTypeX on ClassworkType {
  String get label => switch (this) {
    ClassworkType.assignment => 'Tugas',
    ClassworkType.quiz => 'Kuis',
    ClassworkType.question => 'Pertanyaan',
    ClassworkType.material => 'Materi',
  };

  static ClassworkType parse(String? s) => ClassworkType.values.firstWhere(
    (t) => t.name == s,
    orElse: () => ClassworkType.assignment,
  );
}

class TopicModel {
  final int id;
  final String name;
  const TopicModel({required this.id, required this.name});

  factory TopicModel.fromJson(Map<String, dynamic> j) =>
      TopicModel(id: j['id'], name: j['name']);
}

class QuizQuestionModel {
  final int? id;
  final String text;
  final List<String> options;
  final int points;
  final int? correctIndex; // hanya terisi untuk pengajar

  const QuizQuestionModel({
    this.id,
    required this.text,
    required this.options,
    this.points = 1,
    this.correctIndex,
  });

  factory QuizQuestionModel.fromJson(Map<String, dynamic> j) =>
      QuizQuestionModel(
        id: j['id'],
        text: j['text'],
        options: (j['options'] as List).map((e) => e.toString()).toList(),
        points: j['points'] ?? 1,
        correctIndex: j['correct_index'],
      );
}

/// Pekerjaan satu siswa (dilihat pengajar).
class StudentWork {
  final UserModel user;
  final bool done;
  final DateTime? submittedAt;
  final String? answer;
  final List<int?>? answers;
  int? score;
  final List<Attachment> attachments;

  StudentWork({
    required this.user,
    required this.done,
    this.submittedAt,
    this.answer,
    this.answers,
    this.score,
    this.attachments = const [],
  });

  factory StudentWork.fromJson(Map<String, dynamic> j) => StudentWork(
    user: UserModel.fromJson(j['user']),
    done: j['status'] == 'done',
    submittedAt: j['submitted_at'] == null
        ? null
        : DateTime.parse(j['submitted_at']),
    answer: j['answer'],
    answers: j['answers'] == null
        ? null
        : (j['answers'] as List).map((e) => e as int?).toList(),
    score: j['score'],
    attachments: AssignmentModel.parseAttachments(j['attachments']),
  );
}

class AssignmentModel {
  final int id;
  final int courseId;
  final ClassworkType type;
  final String title;
  final String description;
  final int? points;
  final DateTime? deadline;
  AssignmentStatus status;

  final int? topicId;
  final String? topic;
  final bool assignAll;
  final String? questionType; // short_answer | multiple_choice
  final List<String> choices;
  final List<Attachment> attachments;
  final List<QuizQuestionModel> questions;

  // Milik siswa
  String? myAnswer;
  List<int?>? myAnswers;
  int? myScore;

  // Milik pengajar
  int turnedIn;
  int totalStudents;

  AssignmentModel({
    required this.id,
    required this.courseId,
    required this.title,
    this.type = ClassworkType.assignment,
    this.description = '',
    this.points,
    this.deadline,
    this.status = AssignmentStatus.assigned,
    this.topicId,
    this.topic,
    this.assignAll = true,
    this.questionType,
    this.choices = const [],
    this.attachments = const [],
    this.questions = const [],
    this.myAnswer,
    this.myAnswers,
    this.myScore,
    this.turnedIn = 0,
    this.totalStudents = 0,
  });

  bool get isMaterial => type == ClassworkType.material;

  String get statusLabel {
    switch (status) {
      case AssignmentStatus.assigned:
        return 'Ditugaskan';
      case AssignmentStatus.missing:
        return 'Terlewat';
      case AssignmentStatus.done:
        return 'Selesai';
    }
  }

  String get deadlineLabel => deadline == null
      ? 'Tak ada batas waktu'
      : 'Tenggat ${DateHelper.date(deadline!)}';

  /// Salin data terbaru dari server ke objek yang sedang ditampilkan.
  void updateFrom(AssignmentModel o) {
    status = o.status;
    myAnswer = o.myAnswer;
    myAnswers = o.myAnswers;
    myScore = o.myScore;
    turnedIn = o.turnedIn;
    totalStudents = o.totalStudents;
  }

  static List<Attachment> parseAttachments(dynamic raw) =>
      ((raw ?? []) as List)
          .map(
            (e) => Attachment(
              type: AttachmentType.values.firstWhere(
                (t) => t.name == e['type'],
                orElse: () => AttachmentType.file,
              ),
              name: e['name'],
              url: e['url'],
            ),
          )
          .toList();

  factory AssignmentModel.fromJson(Map<String, dynamic> j) => AssignmentModel(
    id: j['id'],
    courseId: j['course_id'],
    type: ClassworkTypeX.parse(j['type']),
    title: j['title'],
    description: j['description'] ?? '',
    points: j['points'],
    deadline: j['deadline'] == null ? null : DateTime.parse(j['deadline']),
    status: switch (j['status']) {
      'done' => AssignmentStatus.done,
      'missing' => AssignmentStatus.missing,
      _ => AssignmentStatus.assigned,
    },
    topicId: j['topic_id'],
    topic: j['topic'],
    assignAll: j['assign_all'] ?? true,
    questionType: j['question_type'],
    choices: ((j['choices'] ?? []) as List).map((e) => e.toString()).toList(),
    attachments: parseAttachments(j['attachments']),
    questions: ((j['questions'] ?? []) as List)
        .map((e) => QuizQuestionModel.fromJson(e))
        .toList(),
    myAnswer: j['my_answer'],
    myAnswers: j['my_answers'] == null
        ? null
        : (j['my_answers'] as List).map((e) => e as int?).toList(),
    myScore: j['my_score'],
    turnedIn: j['turned_in'] ?? 0,
    totalStudents: j['total_students'] ?? 0,
  );
}
