import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'https://ecotrack-rm92.onrender.com';
  static const String loginPath = '/collector/login';

  Future<String?> login(String collectorId, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$loginPath'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'collectorId': collectorId,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        // The user said the response is JWT_TOKEN. 
        // Usually, this is either the raw body or a JSON field.
        // Assuming it's the raw body if it's just the string, 
        // or let's try to parse it if it's JSON.
        String token = response.body;
        
        // If it's JSON like {"token": "..."}, we should parse it.
        // But the prompt says "Response from endpoint:JWT_TOKEN".
        // I'll handle both cases or assume it's the body if it's not JSON.
        try {
           final data = jsonDecode(response.body);
           if (data is Map && data.containsKey('token')) {
             token = data['token'];
           } else if (data is String) {
             token = data;
           }
        } catch (e) {
          // If not JSON, use raw body
        }

        await _saveToken(token);
        return token;
      } else {
        print('Login failed with status: ${response.statusCode}');
        print('Body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }
}
