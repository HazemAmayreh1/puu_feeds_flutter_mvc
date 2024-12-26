import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:project_flutter/models/post.dart';  

class CoursePostsController {
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  Future<List<Post>> fetchPosts(int courseId, int sectionId) async {
    try {
      String? token = await _storage.read(key: 'session_token');
      if (token == null) {
        throw Exception('No session token found.');
      }

      final url =
          'http://feeds.ppu.edu/api/v1/courses/$courseId/sections/$sectionId/posts';
      print('Fetching posts from URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': ' $token', 
        },
      );

      if (response.statusCode == 200) {
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
        final List<dynamic> postList = json.decode(response.body)['posts'];
        return postList.map((postJson) => Post.fromJson(postJson)).toList();
      } else {
        print('Failed to fetch posts. Status: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to load posts. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching posts: $e');
      throw Exception('Failed to load posts: $e');
    }
  }

  Future<int?> createPost(int courseId, int sectionId, String body) async {
    try {
      String? token = await _storage.read(key: 'session_token');
      if (token == null) {
        throw Exception('No session token found.');
      }

      final url =
          'http://feeds.ppu.edu/api/v1/courses/$courseId/sections/$sectionId/posts';
      print('Creating post at URL: $url');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': ' $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'body': body}),
      );

      if (response.statusCode == 200) {
        print('Response body: ${response.body}');
        final data = json.decode(response.body);
        return data['post_id'];
      } else {
        print('Failed to create post. Status: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to create post. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error creating post: $e');
      throw Exception('Failed to create post: $e');
    }
  }

  Future<void> updatePost(
      int courseId, int sectionId, int postId, String updatedBody) async {
    try {
      String? token = await _storage.read(key: 'session_token');
      if (token == null) {
        throw Exception('No session token found.');
      }

      final url =
          'http://feeds.ppu.edu/api/v1/courses/$courseId/sections/$sectionId/posts/$postId';
      print('Updating post at URL: $url');

      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Authorization': ' $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'body': updatedBody}),
      );

      if (response.statusCode == 200) {
        print('Response body: ${response.body}');
        final data = json.decode(response.body);
        if (data['status'] == 'Post updated') {
          print('Post updated successfully');
        } else {
          throw Exception('Failed to update post.');
        }
      } else {
        print('Failed to update post. Status: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to update post. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating post: $e');
      throw Exception('Failed to update post: $e');
    }
  }

  
  Future<void> deletePost(int courseId, int sectionId, int postId) async {
    try {
      String? token = await _storage.read(key: 'session_token');
      if (token == null) {
        throw Exception('No session token found.');
      }

      final url =
          'http://feeds.ppu.edu/api/v1/courses/$courseId/sections/$sectionId/posts/$postId';
      print('Deleting post at URL: $url');

      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Authorization': ' $token',
        },
      );

      if (response.statusCode == 200) {
        print('Response body: ${response.body}');
        final data = json.decode(response.body);
        if (data['status'] == 'Post deleted') {
          print('Post deleted successfully');
        } else {
          throw Exception('Failed to delete post.');
        }
      } else {
        print('Failed to delete post. Status: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to delete post. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting post: $e');
      throw Exception('Failed to delete post: $e');
    }
  }
}
