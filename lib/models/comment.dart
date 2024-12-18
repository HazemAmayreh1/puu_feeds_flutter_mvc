class Comment {
  final int id;
  final String author;
  final String body;
  final String datePosted;
  int likesCount;
  bool isLiked;

  Comment({
    required this.id,
    required this.author,
    required this.body,
    required this.datePosted,
    required this.likesCount,
    required this.isLiked,
  });

  factory Comment.fromJson(Map<String, dynamic> json, bool liked) {
    return Comment(
      id: json['id'],
      author: json['author'] ?? 'Anonymous',
      body: json['body'] ?? '',
      datePosted: json['date_posted'] ?? '',
      likesCount: json['likes_count'] ?? 0,
      isLiked: liked,
    );
  }
}
