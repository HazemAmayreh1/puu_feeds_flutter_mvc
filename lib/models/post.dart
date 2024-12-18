class Post {
  final int id;
  final String body;
  final String author;
  final String datePosted;

  Post({
    required this.id,
    required this.body,
    required this.author,
    required this.datePosted,
  });

  // لتحويل JSON إلى كائن Post
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      body: json['body'],
      author: json['author'],
      datePosted: json['date_posted'],
    );
  }

  // لتحويل كائن Post إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'body': body,
      'author': author,
      'date_posted': datePosted,
    };
  }
}
