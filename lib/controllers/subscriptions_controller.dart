import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/subscription.dart';

class SubscriptionsController {
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  String? token;

  Future<List<Subscription>> fetchSubscriptions() async {
    try {
      token = await _storage.read(key: 'session_token');
      if (token == null || token!.isEmpty) {
        throw Exception('Session token not found. Please log in again.');
      }

      final response = await http.get(
        Uri.parse('http://feeds.ppu.edu/api/v1/subscriptions'),
        headers: {'Authorization': ' $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.containsKey('subscriptions')) {
          List subscriptionsList = data['subscriptions'];
          return subscriptionsList.map((sub) => Subscription.fromJson(sub)).toList();
        } else {
          throw Exception('No subscriptions found in the API response.');
        }
      } else {
        throw Exception('Failed to load subscriptions. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching subscriptions: $e');
    }
  }
}
