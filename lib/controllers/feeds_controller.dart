import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:project_flutter/models/course.dart';

class FeedsController {
  final _storage = FlutterSecureStorage();

  Future<List<Course>> fetchCourses() async {
    List<Course> courses = [];
    try {
      String? token = await _storage.read(key: 'session_token');
      
      if (token == null) {
        throw Exception('No session token found.');
      }

     final response = await http.get(
        Uri.parse('http://feeds.ppu.edu/api/v1/courses'),
        headers: {'Authorization': token},
      );


      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        if (responseData['courses'] != null) {
          final List<dynamic> data = responseData['courses'];
          courses = data.map((courseData) => Course.fromJson(courseData)).toList();
        } else {
          throw Exception('No courses found in the response.');
        }
      } else {
     
        throw Exception('Failed to load courses. Status: ${response.statusCode}');
      }
  
    } catch (e) {

      print('Error fetching courses: $e');
    }
    return courses;
  }
}
