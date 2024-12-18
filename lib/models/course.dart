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
      id: json['id'].toString(),  // التأكد من تحويل id إلى String
      name: json['name'],
      college: json['college'] ?? 'No college specified',  // قيمة افتراضية في حال كانت القيمة null
      imageUrl: json['image_url'] ?? 'assets/course_images/default_course_image.png',  // قيمة افتراضية للصورة
    );
  }
}
