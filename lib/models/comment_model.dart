class CommentModel {
  final String id;
  final String text;
  final String authorName;
  final String authorAvatar;
  final String timeAgo;

  CommentModel({
    required this.id,
    required this.text,
    required this.authorName,
    required this.authorAvatar,
    required this.timeAgo,
  });
}
