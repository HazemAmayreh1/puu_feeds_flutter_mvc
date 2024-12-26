import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:project_flutter/models/course_section_model.dart';

class CourseSectionController {
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  Future<Map<int, bool>> loadSubscriptionStatus(int courseId) async {
    try {
      String? subscriptionData = await _storage.read(key: 'subscription_status_$courseId');
      print('Loading subscription status for course $courseId: $subscriptionData');
      if (subscriptionData != null && subscriptionData.isNotEmpty) {
        Map<String, dynamic> decodedData = jsonDecode(subscriptionData);
        return decodedData.map((key, value) => MapEntry(int.parse(key), value));
      }
      return {};  
    } catch (e) {
      print('Error loading subscription status: $e');
      return {};  
    }
  }

  Future<void> saveSubscriptionStatus(int courseId, Map<int, bool> status) async {
    try {
      String encodedData = jsonEncode(status.map((key, value) => MapEntry(key.toString(), value)));
      print('Saving subscription status for course $courseId: $encodedData');
      await _storage.write(key: 'subscription_status_$courseId', value: encodedData);
    } catch (e) {
      print('Error saving subscription status: $e');
    }
  }

  Future<Map<int, int>> loadSubscriptionIds(int courseId) async {
    try {
      String? subscriptionIdData = await _storage.read(key: 'subscription_ids_$courseId');
      if (subscriptionIdData != null && subscriptionIdData.isNotEmpty) {
        Map<String, dynamic> decodedData = jsonDecode(subscriptionIdData);
        return decodedData.map((key, value) => MapEntry(int.parse(key), value));
      }
      return {};  
    } catch (e) {
      print('Error loading subscription IDs: $e');
      return {}; 
    }
  }

  Future<void> saveSubscriptionIds(int courseId, Map<int, int> subscriptionIds) async {
    try {
      String encodedData = jsonEncode(subscriptionIds.map((key, value) => MapEntry(key.toString(), value)));
      await _storage.write(key: 'subscription_ids_$courseId', value: encodedData);
    } catch (e) {
      print('Error saving subscription IDs: $e');
    }
  }

  Future<List<CourseSection>> fetchSections(int courseId) async {
    try {
      String? token = await _storage.read(key: 'session_token');
      if (token == null || token.isEmpty) {
        throw Exception('Session token not found.');
      }

      final response = await http.get(
        Uri.parse('http://feeds.ppu.edu/api/v1/courses/$courseId/sections'),
        headers: {'Authorization': token},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.containsKey('sections')) {
          return List<CourseSection>.from(
            data['sections'].map((section) => CourseSection.fromJson(section)),
          );
        } else {
          throw Exception('No sections found in the API response.');
        }
      } else {
        throw Exception('Failed to load sections. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching sections: $e');
    }
  }

  Future<int?> subscribeToSection(int courseId, int sectionId) async {
    String? token = await _storage.read(key: 'session_token');
    if (token == null || token.isEmpty) {
      throw Exception('Session token not found.');
    }

    final response = await http.post(
      Uri.parse('http://feeds.ppu.edu/api/v1/courses/$courseId/sections/$sectionId/subscribe'),
      headers: {'Authorization': token},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data.containsKey('subscription_id')) {
        int subscriptionId = data['subscription_id'];
        await _storage.write(
          key: 'subscription_id_${courseId}_$sectionId',  
          value: subscriptionId.toString()
        );

        return subscriptionId;  
      } else {
        throw Exception('No subscription ID found.');
      }
    } else {
      throw Exception('Failed to subscribe to section. Status: ${response.statusCode}');
    }
  }

  Future<void> removeSubscription(int courseId, int sectionId, int subscriptionId) async {
    String? token = await _storage.read(key: 'session_token');
    if (token == null || token.isEmpty) {
      throw Exception('Session token not found.');
    }

    final response = await http.delete(
      Uri.parse('http://feeds.ppu.edu/api/v1/courses/$courseId/sections/$sectionId/subscribe/$subscriptionId'),
      headers: {'Authorization': token},
    );

    if (response.statusCode == 200) {
      await _storage.delete(key: 'subscription_id_${courseId}_$sectionId');
    } else {
      throw Exception('Failed to unsubscribe from section. Status: ${response.statusCode}');
    }
  }
}
