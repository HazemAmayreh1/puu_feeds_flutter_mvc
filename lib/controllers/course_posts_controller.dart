import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:project_flutter/models/post.dart';  // استيراد النموذج

class CoursePostsController {
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  // جلب البيانات من الـ API وتحويلها إلى قائمة من المشاركات
  Future<List<Post>> fetchPosts(int courseId, int sectionId) async {
    try {
      String? token = await _storage.read(key: 'session_token');
      if (token == null) {
        throw Exception('No session token found.');
      }

      final response = await http.get(
        Uri.parse(
            'http://feeds.ppu.edu/api/v1/courses/$courseId/sections/$sectionId/posts'),
        headers: {
          'Authorization': token, 
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> postList = json.decode(response.body)['posts'];
        return postList.map((postJson) => Post.fromJson(postJson)).toList();
      } else {
        throw Exception('Failed to load posts. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load posts: $e');
    }
  }

  // إضافة منشور جديد
  Future<int?> createPost(int courseId, int sectionId, String body) async {
    try {
      String? token = await _storage.read(key: 'session_token');
      if (token == null) {
        throw Exception('No session token found.');
      }

      final response = await http.post(
        Uri.parse('http://feeds.ppu.edu/api/v1/courses/$courseId/sections/$sectionId/posts'),
        headers: {
          'Authorization': token,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'body': body}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['post_id'];
      } else {
        throw Exception('Failed to create post. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to create post: $e');
    }
  }

  // تحديث منشور موجود
  Future<void> updatePost(int courseId, int sectionId, int postId, String updatedBody) async {
    try {
      String? token = await _storage.read(key: 'session_token');
      if (token == null) {
        throw Exception('No session token found.');
      }

      final response = await http.put(
        Uri.parse('http://feeds.ppu.edu/api/v1/courses/$courseId/sections/$sectionId/posts/$postId'),
        headers: {
          'Authorization': token,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'body': updatedBody}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'Post updated') {
          print('Post updated successfully');
        } else {
          throw Exception('Failed to update post.');
        }
      } else {
        throw Exception('Failed to update post. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to update post: $e');
    }
  }

  // حذف منشور
  Future<void> deletePost(int courseId, int sectionId, int postId) async {
    try {
      String? token = await _storage.read(key: 'session_token');
      if (token == null) {
        throw Exception('No session token found.');
      }

      final response = await http.delete(
        Uri.parse('http://feeds.ppu.edu/api/v1/courses/$courseId/sections/$sectionId/posts/$postId'),
        headers: {
          'Authorization': token,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'Post deleted') {
          print('Post deleted successfully');
        } else {
          throw Exception('Failed to delete post.');
        }
      } else {
        throw Exception('Failed to delete post. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to delete post: $e');
    }
  }
}
