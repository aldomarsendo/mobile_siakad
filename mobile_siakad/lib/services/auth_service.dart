import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  static const String baseUrl = 'https://siakad.pradita.my.id/api/mobile';
  static const String _tokenKey = 'token';
  static const String _userKey = 'user';

  Future<User?> login(String email, String password, String deviceName) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
          'device_name': deviceName,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('API Response: $data'); // Log response untuk debugging
        
        // Convert id to string if it's int
        if (data['user'] != null && data['user']['id'] is int) {
          print('Converting ID from int to string');
          data['user']['id'] = data['user']['id'].toString();
        }

        // Handle null values
        final userData = {
          'user': data['user'] ?? {},
          'token': data['token'] ?? '',
          'role': data['user']['roles']?.first['name'] ?? 'user'
        };

        // Check if user data is valid
        if (userData['user'] == null || userData['user'].isEmpty) {
          throw Exception('Invalid user data from API');
        }

        final user = User.fromJson(userData);
        
        // Save token and user data
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, userData['token']);
        await prefs.setString(_userKey, jsonEncode(userData)); // Simpan userData langsung

        return user;
      } else {
        final errorData = jsonDecode(response.body);
        print('API Error Response: $errorData'); // Log error response untuk debugging
        throw Exception('Login failed: ${errorData['message'] ?? response.body}');
      }
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      
      if (token != null) {
        final response = await http.post(
          Uri.parse('$baseUrl/logout'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          // Clear token and user data
          await prefs.remove(_tokenKey);
          await prefs.remove(_userKey);
        }
      }
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }

  Future<User?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString(_userKey);
      
      if (userData != null) {
        return User.fromJson(jsonDecode(userData));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static String getDeviceName() {
    // Get device name from platform
    return 'mobile_app';
  }
}