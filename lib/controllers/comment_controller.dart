import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/comment.dart';

class CommentController {
  final int courseId;
  final int sectionId;
  final int postId;
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  CommentController({
    required this.courseId,
    required this.sectionId,
    required this.postId,
  });

  Future<String?> _getToken() async {
    return await _storage.read(key: 'session_token');
  }

  Future<List<Comment>> fetchComments() async {
    try {
      String? token = await _getToken();
      if (token == null) throw Exception('No session token found.');

      final response = await http.get(
        Uri.parse(
            'http://feeds.ppu.edu/api/v1/courses/$courseId/sections/$sectionId/posts/$postId/comments'),
        headers: {'Authorization': ' $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['comments'];
        SharedPreferences prefs = await SharedPreferences.getInstance();

        return data.map((json) {
          bool isLiked = prefs.getBool('liked_${json['id']}') ?? false;
          return Comment.fromJson(json, isLiked);
        }).toList();
      } else {
        throw Exception('Failed to fetch comments.');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> toggleLike(Comment comment) async {
    try {
      String? token = await _getToken();
      if (token == null) throw Exception('No session token found.');

      final newStatus = comment.isLiked ? 'unlike' : 'like';
      final response = await http.post(
        Uri.parse(
            'http://feeds.ppu.edu/api/v1/courses/$courseId/sections/$sectionId/posts/$postId/comments/${comment.id}/$newStatus'),
        headers: {'Authorization': ' $token'},
      );

      if (response.statusCode == 200) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('liked_${comment.id}', !comment.isLiked);
      } else {
        throw Exception('Failed to toggle like status.');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> addComment(String body) async {
    try {
      String? token = await _getToken();
      if (token == null) throw Exception('No session token found.');

      final response = await http.post(
        Uri.parse(
            'http://feeds.ppu.edu/api/v1/courses/$courseId/sections/$sectionId/posts/$postId/comments'),
        headers: {'Authorization': ' $token', 'Content-Type': 'application/json'},
        body: json.encode({'body': body}),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        // Optionally handle the comment ID returned in response
        print('Comment added with ID: ${responseData['comment_id']}');
      } else {
        throw Exception('Failed to add comment.');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> updateComment(int commentId, String updatedBody) async {
    try {
      String? token = await _getToken();
      if (token == null) throw Exception('No session token found.');

      final response = await http.put(
        Uri.parse(
            'http://feeds.ppu.edu/api/v1/courses/$courseId/sections/$sectionId/posts/$postId/comments/$commentId'),
        headers: {'Authorization': ' $token', 'Content-Type': 'application/json'},
        body: json.encode({'body': updatedBody}),
      );

      if (response.statusCode == 200) {
        print('Comment updated');
      } else {
        throw Exception('Failed to update comment.');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> deleteComment(int commentId) async {
    try {
      String? token = await _getToken();
      if (token == null) throw Exception('No session token found.');

      final response = await http.delete(
        Uri.parse(
            'http://feeds.ppu.edu/api/v1/courses/$courseId/sections/$sectionId/posts/$postId/comments/$commentId'),
        headers: {'Authorization': ' $token'},
      );

      if (response.statusCode == 200) {
        print('Comment deleted');
      } else {
        throw Exception('Failed to delete comment.');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<int> getLikesCount(int commentId) async {
    try {
      String? token = await _getToken();
      if (token == null) throw Exception('No session token found.');

      final response = await http.get(
        Uri.parse(
            'http://feeds.ppu.edu/api/v1/courses/$courseId/sections/$sectionId/posts/$postId/comments/$commentId/likes'),
        headers: {'Authorization': ' $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['likes_count'];
      } else {
        throw Exception('Failed to fetch likes count.');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<bool> checkIfLiked(int commentId) async {
    try {
      String? token = await _getToken();
      if (token == null) throw Exception('No session token found.');

      final response = await http.get(
        Uri.parse(
            'http://feeds.ppu.edu/api/v1/courses/$courseId/sections/$sectionId/posts/$postId/comments/$commentId/like'),
        headers: {'Authorization': ' $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['liked'];
      } else {
        throw Exception('Failed to check like status.');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
