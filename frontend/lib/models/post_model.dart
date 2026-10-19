class PostModel {
  final int id;
  final String authorName;
  final String content;
  final DateTime createdAt;
  final bool isAssignmentNotice;

  const PostModel({
    required this.id,
    required this.authorName,
    required this.content,
    required this.createdAt,
    this.isAssignmentNotice = false,
  });

  factory PostModel.fromJson(Map<String, dynamic> j) => PostModel(
    id: j['id'],
    authorName: j['author_name'] ?? '',
    content: j['content'] ?? '',
    createdAt: DateTime.parse(j['created_at']),
    isAssignmentNotice: j['is_assignment'] == true || j['is_assignment'] == 1,
  );
}
