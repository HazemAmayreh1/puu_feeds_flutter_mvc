class CourseSection {
  final int id;
  final String name;
  final String course;
  final String lecturer;

  CourseSection({
    required this.id,
    required this.name,
    required this.course,
    required this.lecturer,
  });

  factory CourseSection.fromJson(Map<String, dynamic> json) {
    return CourseSection(
      id: json['id'],
      name: json['name'],
      course: json['course'],
      lecturer: json['lecturer'] ?? 'N/A',
    );
  }
}
