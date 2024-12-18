class Subscription {
  final String section;
  final String course;
  final String lecturer;
  final String subscriptionDate;

  Subscription({
    required this.section,
    required this.course,
    required this.lecturer,
    required this.subscriptionDate,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      section: json['section'] ?? 'Unnamed Section',
      course: json['course'] ?? 'Unnamed Course',
      lecturer: json['lecturer'] ?? 'Unknown Lecturer',
      subscriptionDate: json['subscription_date'] ?? 'Unknown Date',
    );
  }
}
