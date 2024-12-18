import 'package:flutter/material.dart';
import '/controllers/CourseSectionController.dart'; 
import '/models/CourseSectionModel.dart'; 
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../pages/course_posts_page.dart';

class CourseSectionPage extends StatefulWidget {
  final int courseId;

  CourseSectionPage({required this.courseId});

  @override
  _CourseSectionPageState createState() => _CourseSectionPageState();
}

class _CourseSectionPageState extends State<CourseSectionPage> {
  late CourseSectionController _controller;
  Map<int, bool> subscriptionStatus = {}; // حالة الاشتراك
  Map<int, int> subscriptionIds = {}; // تخزين subscription_id لكل section

  @override
  void initState() {
    super.initState();
    _controller = CourseSectionController();

    // تحميل حالة الاشتراك عند بدء الصفحة
    _controller.loadSubscriptionStatus(widget.courseId).then((status) {
      setState(() {
        subscriptionStatus = status;
      });
    });

    // تحميل subscriptionIds عند بدء الصفحة
    _controller.loadSubscriptionIds(widget.courseId).then((ids) {
      setState(() {
        subscriptionIds = ids;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.indigo,
        centerTitle: true,
        title: Text(
          'Course Sections',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<CourseSection>>(
        future: _controller.fetchSections(widget.courseId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Colors.white));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.redAccent)));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No sections available.', style: TextStyle(fontSize: 18, color: Colors.white)));
          } else {
            final sections = snapshot.data!;
            return ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: sections.length,
              itemBuilder: (context, index) {
                final section = sections[index];
                final sectionId = section.id;
                final isSubscribed = subscriptionStatus[sectionId] ?? false;

                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  color: Colors.white,
                  elevation: 8,
                  margin: EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          section.name,
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo),
                        ),
                        SizedBox(height: 8),
                        Text('Course: ${section.course}', style: TextStyle(fontSize: 16, color: Colors.grey[800])),
                        SizedBox(height: 8),
                        Text('Lecturer: ${section.lecturer}', style: TextStyle(fontSize: 16, color: Colors.grey[800])),
                        SizedBox(height: 8),
                        Text('Section ID: $sectionId', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                        SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CoursePostsPage(
                                      courseId: widget.courseId,
                                      sectionId: sectionId,
                                    ),
                                  ),
                                );
                              },
                              icon: Icon(Icons.assignment, color: Colors.indigo),
                              tooltip: 'View Posts',
                            ),
                            IconButton(
                              onPressed: () async {
                                try {
                                  if (isSubscribed) {
                                    // عند الحذف
                                    final subscriptionId = subscriptionIds[sectionId];
                                    if (subscriptionId != null) {
                                      await _controller.removeSubscription(widget.courseId, sectionId, subscriptionId);
                                      setState(() {
                                        subscriptionStatus[sectionId] = false; // تحديث حالة الاشتراك
                                        subscriptionIds.remove(sectionId); // إزالة الـ subscriptionId
                                      });

                                      // حفظ حالة الاشتراك بعد التحديث
                                      await _controller.saveSubscriptionStatus(widget.courseId, subscriptionStatus);

                                      // حذف الـ subscriptionId من التخزين المحلي
                                      await _controller.saveSubscriptionIds(widget.courseId, subscriptionIds);
                                    } else {
                                      print("Error: subscriptionId is null.");
                                    }
                                  } else {
                                    // عند الاشتراك
                                    final subscriptionId = await _controller.subscribeToSection(widget.courseId, sectionId);
                                    if (subscriptionId != null) {
                                      setState(() {
                                        subscriptionStatus[sectionId] = true; // تحديث حالة الاشتراك
                                        subscriptionIds[sectionId] = subscriptionId; // تخزين الـ subscriptionId
                                      });

                                      // حفظ حالة الاشتراك بعد التحديث
                                      await _controller.saveSubscriptionStatus(widget.courseId, subscriptionStatus);

                                      // حفظ الـ subscriptionId في التخزين المحلي
                                      await _controller.saveSubscriptionIds(widget.courseId, subscriptionIds);
                                    }
                                  }
                                } catch (e) {
                                  print('Error: $e');
                                }
                              },
                              icon: Icon(
                                isSubscribed ? Icons.remove_circle : Icons.add_circle,
                                color: isSubscribed ? Colors.red : Colors.green,
                              ),
                              tooltip: isSubscribed ? 'Unsubscribe' : 'Subscribe',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
