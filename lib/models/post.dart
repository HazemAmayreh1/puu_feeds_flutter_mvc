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


  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] ??0,
      body: json['body'] ?? "",
      author: json['author'] ?? "",
      datePosted: json['date_posted'] ,
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'body': body,
      'author': author,
      'date_posted': datePosted,
    };
  }
}
