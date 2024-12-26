class Course {
  final String id;
  final String name;
  final String college;
  final String imageUrl;

  Course({
    required this.id,
    required this.name,
    required this.college,
    required this.imageUrl,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'].toString(), 
      name: json['name'],
      college: json['college'], 
      imageUrl: json['image_url'] ?? 'assets/course_images/default_course_image.png', 
    );
  }
}
