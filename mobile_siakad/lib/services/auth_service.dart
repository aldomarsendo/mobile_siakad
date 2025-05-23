import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';
import 'api_client.dart'; // <- Import ApiClient Anda

class AuthService {
  final ApiClient _apiClient;

  static const String _tokenKey = 'token';
  static const String _userKey = 'user';

  AuthService(this._apiClient);

  Future<User> login(String email, String password, String deviceName) async {
    try {
      final data = await _apiClient.post(
        'login',
        body: {
          'email': email,
          'password': password,
          'device_name': deviceName,
        },
      );

      if (data['user'] != null && data['user']['id'] is int) {
        data['user']['id'] = data['user']['id'].toString();
      }

      final userData = {
        'user': data['user'] ?? {},
        'token': data['token'] ?? '',
        'role': data['user']['roles']?.first['name'] ?? 'user'
      };

      if (userData['user'] == null || (userData['user'] as Map).isEmpty) {
        throw Exception('Invalid user data from API');
      }

      final user = User.fromJson(userData);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, user.token ?? '');
      await prefs.setString(_userKey, jsonEncode(userData));

      return user;
    } catch (e) {
      throw Exception('Login Failed: $e');
    }
  }

  Future<void> logout() async {
    try {
      await _apiClient.post('logout', body: {});
    } catch (e) {
      print('Failed to logout from API, but proceeding with local logout: $e');
    } finally {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userKey);
    }
  }

  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString(_userKey);
    if (userString != null) {
      return User.fromJson(jsonDecode(userString));
    }
    return null;
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static String getDeviceName() {
    return 'mobile_app';
  }
}