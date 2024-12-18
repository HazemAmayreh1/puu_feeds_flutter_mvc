import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:project_flutter/models/CourseSectionModel.dart';

class CourseSectionController {
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  // دالة لتحميل حالة الاشتراك
  Future<Map<int, bool>> loadSubscriptionStatus(int courseId) async {
    try {
      String? subscriptionData = await _storage.read(key: 'subscription_status_$courseId');
      print('Loading subscription status for course $courseId: $subscriptionData');
      if (subscriptionData != null && subscriptionData.isNotEmpty) {
        Map<String, dynamic> decodedData = jsonDecode(subscriptionData);
        return decodedData.map((key, value) => MapEntry(int.parse(key), value));
      }
      return {};  // إرجاع خريطة فارغة إذا لم توجد بيانات
    } catch (e) {
      print('Error loading subscription status: $e');
      return {};  // إرجاع خريطة فارغة في حالة حدوث خطأ
    }
  }

  // دالة لحفظ حالة الاشتراك
  Future<void> saveSubscriptionStatus(int courseId, Map<int, bool> status) async {
    try {
      String encodedData = jsonEncode(status.map((key, value) => MapEntry(key.toString(), value)));
      print('Saving subscription status for course $courseId: $encodedData');
      await _storage.write(key: 'subscription_status_$courseId', value: encodedData);
    } catch (e) {
      print('Error saving subscription status: $e');
    }
  }

  // دالة لتحميل subscriptionIds
  Future<Map<int, int>> loadSubscriptionIds(int courseId) async {
    try {
      String? subscriptionIdData = await _storage.read(key: 'subscription_ids_$courseId');
      if (subscriptionIdData != null && subscriptionIdData.isNotEmpty) {
        Map<String, dynamic> decodedData = jsonDecode(subscriptionIdData);
        return decodedData.map((key, value) => MapEntry(int.parse(key), value));
      }
      return {};  // إرجاع خريطة فارغة إذا لم توجد بيانات
    } catch (e) {
      print('Error loading subscription IDs: $e');
      return {};  // إرجاع خريطة فارغة في حالة حدوث خطأ
    }
  }

  // دالة لحفظ subscriptionIds
  Future<void> saveSubscriptionIds(int courseId, Map<int, int> subscriptionIds) async {
    try {
      String encodedData = jsonEncode(subscriptionIds.map((key, value) => MapEntry(key.toString(), value)));
      await _storage.write(key: 'subscription_ids_$courseId', value: encodedData);
    } catch (e) {
      print('Error saving subscription IDs: $e');
    }
  }

  // دالة لتحميل الأقسام
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

  // دالة للاشتراك في القسم
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

        // تخزين الـ subscriptionId باستخدام courseId و sectionId بشكل صحيح
        await _storage.write(
          key: 'subscription_id_${courseId}_$sectionId',  // تأكد من استخدام التنسيق الصحيح
          value: subscriptionId.toString()
        );

        return subscriptionId;  // إرجاع الـ subscriptionId
      } else {
        throw Exception('No subscription ID found.');
      }
    } else {
      throw Exception('Failed to subscribe to section. Status: ${response.statusCode}');
    }
  }

  // دالة لإلغاء الاشتراك
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
      // إزالة الـ subscriptionId من الـ FlutterSecureStorage عند إلغاء الاشتراك
      await _storage.delete(key: 'subscription_id_${courseId}_$sectionId');
    } else {
      throw Exception('Failed to unsubscribe from section. Status: ${response.statusCode}');
    }
  }
}
