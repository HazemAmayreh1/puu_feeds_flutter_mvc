import 'package:flutter/material.dart';
import '/controllers/feeds_controller.dart'; 
import '/models/course.dart'; 
import '../widgets/course_card.dart';  
import '../pages/course_section_page.dart'; 

class FeedsPage extends StatefulWidget {
  final int? courseId;  

  FeedsPage({this.courseId});  

  @override
  _FeedsPageState createState() => _FeedsPageState();
}

class _FeedsPageState extends State<FeedsPage> {
  List<Course> courses = [];
  final FeedsController controller = FeedsController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadCourses();
  }

  Future<void> loadCourses() async {
    List<Course> loadedCourses = await controller.fetchCourses();
    setState(() {
      courses = loadedCourses;
      isLoading = false;
    });
  }

  String getCourseImage(String courseName) {
    switch (courseName) {
      case 'Object Oriented Programming':
        return 'assets/course_images/object_oriented_programming.png';
      case 'Mobile Applications Developments':
        return 'assets/course_images/mobile_app_development.png';
      case 'Data Structures':
        return 'assets/course_images/data_structures.png';
      case 'Database Programming':
        return 'assets/course_images/database_programming.png';
      case 'Operating Systems':
        return 'assets/course_images/operating_systems.png';
      default:
        return 'assets/course_images/default_course_image.png'; 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.indigo,
        centerTitle: true,
        title: Text(
          'Available Courses',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        iconTheme: IconThemeData(
          color: Colors.white, 
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/home');  
          },
        ),
      ),
      backgroundColor: Colors.indigo,  
      body: Container(
        color: Colors.grey[100],
        child: Column(
          children: [
            isLoading
                ? Center(child: CircularProgressIndicator())
                : Expanded(
                    child: ListView.builder(
                      itemCount: courses.length,
                      itemBuilder: (context, index) {
                        var course = courses[index];
                        return GestureDetector(
                          onTap: () {
                            final courseId = int.tryParse(course.id) ?? 0;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CourseSectionPage(courseId: courseId),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                            child: CourseCard(
                              image: getCourseImage(course.name),  
                              name: course.name,
                              college: course.college,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
