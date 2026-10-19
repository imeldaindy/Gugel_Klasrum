import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/date_helper.dart';
import '../../models/extras_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/course_provider.dart';
import '../../widgets/user_avatar.dart';

/// Layar "Komentar kelas". key: 'a_<id tugas>' atau 'p_<id post>'.
class ClassCommentsScreen extends StatelessWidget {
  final String commentKey;
  const ClassCommentsScreen({super.key, required this.commentKey});

  @override
  Widget build(BuildContext context) {
    final comments = context.watch<CourseProvider>().commentsOf(commentKey);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surfaceHigh,
        title: const Text('Komentar kelas'),
      ),
      body: Column(
        children: [
          Expanded(
            child: comments.isEmpty
                ? const Center(
                    child: Text('Tidak ada komentar',
                        style: TextStyle(fontSize: 17)))
                : CommentList(comments: comments),
          ),
          CommentInput(commentKey: commentKey),
        ],
      ),
    );
  }
}

class CommentList extends StatelessWidget {
  final List<ClassComment> comments;
  final bool shrink;
  const CommentList({super.key, required this.comments, this.shrink = false});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: shrink,
      physics: shrink ? const NeverScrollableScrollPhysics() : null,
      padding: const EdgeInsets.all(16),
      itemCount: comments.length,
      itemBuilder: (_, i) {
        final c = comments[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UserAvatar(name: c.author, color: AppColors.teal, size: 36),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${c.author}  •  ${DateHelper.time(c.time)}',
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 13)),
                    const SizedBox(height: 2),
                    Text(c.text, style: const TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class CommentInput extends StatefulWidget {
  final String commentKey;
  const CommentInput({super.key, required this.commentKey});

  @override
  State<CommentInput> createState() => _CommentInputState();
}

class _CommentInputState extends State<CommentInput> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _send() {
    final name = context.read<AuthProvider>().current?.name ?? 'Saya';
    context.read<CourseProvider>().addComment(widget.commentKey, _ctrl.text, name);
    _ctrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(32),
      borderSide: const BorderSide(color: AppColors.outline),
    );
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: TextField(
          controller: _ctrl,
          textInputAction: TextInputAction.send,
          onSubmitted: (_) => _send(),
          decoration: InputDecoration(
            hintText: 'Tambahkan komentar kelas',
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            suffixIcon:
                IconButton(icon: const Icon(Icons.send_outlined), onPressed: _send),
            border: border,
            enabledBorder: border,
            focusedBorder: border,
          ),
        ),
      ),
    );
  }
}
