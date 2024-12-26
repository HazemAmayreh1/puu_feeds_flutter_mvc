import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';

class LoginController {
  final _storage = FlutterSecureStorage();

  Future<String?> login(User user) async {
    try {
      final response = await http.post(
        Uri.parse('http://feeds.ppu.edu/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(user.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['session_token'] != null) {
          final token = data['session_token'];
          await _storage.write(key: 'session_token', value: token);
          return null; 
        } else {
          return 'Invalid email or password';
        }
      } else {
        return 'Invalid email or password';
      }
    } catch (e) {
      return 'Failed to connect. Please try again.';
    }
  }
}
