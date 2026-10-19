enum AttachmentType { drive, photo, scan, file, link, created }

class Attachment {
  final AttachmentType type;
  final String name;
  final String? path;
  final String? url;
  const Attachment({
    required this.type,
    required this.name,
    this.path,
    this.url,
  });
}

class ClassComment {
  final String author;
  final String text;
  final DateTime time;
  ClassComment({required this.author, required this.text, DateTime? time})
      : time = time ?? DateTime.now();
}
