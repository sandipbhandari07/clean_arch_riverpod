import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const _storage = FlutterSecureStorage();

  static Future<String?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('https://inventory.anoopinnovations.com/api/admin/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['data']['token'];
        await _storage.write(key: 'auth_token', value: token);
        return 'success';
      } else if (response.statusCode == 401) {
        return 'Incorrect password. Please try again.';
      } else if (response.statusCode == 404) {
        return 'Email not found. Please check and try again.';
      } else {
        final errorData = jsonDecode(response.body);
        return 'Login failed: ${errorData['message']}';
      }
    } catch (e) {
      return 'Error: $e';
    }
  }

  static Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
  }
}