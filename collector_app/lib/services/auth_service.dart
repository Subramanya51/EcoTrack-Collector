import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthService {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8080',
  );
  static const String loginPath = '/collector/login';

  Future<Map<String, dynamic>> login(
    String collectorId,
    String password,
  ) async {
    try {
      print('--- Attempting Login for: $collectorId ---');
      final response = await http.post(
        Uri.parse('$baseUrl$loginPath'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'User-Agent':
              'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
        },
        body: jsonEncode({'collectorId': collectorId, 'password': password}),
      );

      print('--- Login Response Code: ${response.statusCode} ---');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        String token = response.body;
        String? serverCollectorId;

        try {
          final data = jsonDecode(response.body);
          if (data is Map) {
            if (data.containsKey('token')) {
              token = data['token'];
            } else if (data.containsKey('jwt')) {
              token = data['jwt'];
            }

            // Extract ID from server if available, otherwise use input
            if (data.containsKey('id')) {
              serverCollectorId = data['id'].toString();
            } else if (data.containsKey('collectorId')) {
              serverCollectorId = data['collectorId'].toString();
            }
          } else if (data is String) {
            token = data;
          }
        } catch (e) {
          print('--- Response body is not JSON, using raw body as token ---');
        }

        // ID, city and zone come from the JWT issued by the backend
        final claims = JwtDecoder.decode(token);
        final finalId =
            (claims['sub'] as String?) ??
            (serverCollectorId ?? collectorId).toUpperCase();
        await _saveToken(
          token,
          finalId,
          claims['city'] as String?,
          claims['zone'] as String?,
        );

        return {'success': true, 'token': token};
      } else {
        print('--- Login Failed: ${response.body} ---');
        String errorMessage = 'Login failed (${response.statusCode})';
        try {
          final data = jsonDecode(response.body);
          if (data is Map && data.containsKey('message')) {
            errorMessage = data['message'];
          } else if (data is Map && data.containsKey('error')) {
            errorMessage = data['error'];
          }
        } catch (_) {}

        return {'success': false, 'error': errorMessage};
      }
    } catch (e) {
      print('--- Login Error Exception: $e ---');
      return {'success': false, 'error': 'Connection error: $e'};
    }
  }

  Future<void> _saveToken(
    String token,
    String collectorId,
    String? city,
    String? zone,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
    await prefs.setString('collector_id', collectorId);
    if (city != null) {
      await prefs.setString('city', city);
    } else {
      await prefs.remove('city');
    }
    if (zone != null) {
      await prefs.setString('zone', zone);
    } else {
      await prefs.remove('zone');
    }
  }

  Future<String?> getCity() async =>
      (await SharedPreferences.getInstance()).getString('city');
  Future<String?> getZone() async =>
      (await SharedPreferences.getInstance()).getString('zone');

  Future<String?> getCollectorId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('collector_id');
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<bool> isTokenValid() async {
    final token = await getToken();
    if (token == null) return false;

    try {
      return !JwtDecoder.isExpired(token);
    } catch (e) {
      print('Error decoding token: $e');
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final collectorId = prefs.getString('collector_id');

    if (collectorId != null) {
      try {
        await FirebaseDatabase.instance
            .ref('Collector_Locations/$collectorId')
            .update({'status': 'OFFLINE', 'timestamp': ServerValue.timestamp});
      } catch (e) {
        print('Error setting offline status on logout: $e');
      }
    }

    await prefs.remove('jwt_token');
    await prefs.remove('collector_id');
    await prefs.remove('city');
    await prefs.remove('zone');
  }
}
