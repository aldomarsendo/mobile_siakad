import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/mahasiswa_model.dart';
import '../services/auth_service.dart';

class MahasiswaService {
  static const String baseUrl = 'https://siakad.pradita.my.id/api/mobile';

  Future<Mahasiswa?> getProfile() async {
    try {
      final token = await AuthService().getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/mahasiswa/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Mahasiswa.fromJson(data['mahasiswa']);
      } else {
        throw Exception('Failed to load mahasiswa profile: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error loading mahasiswa profile: $e');
    }
  }

  Future<void> updateProfile({
    required String nama,
    required String email,
  }) async {
    try {
      final token = await AuthService().getToken();
      if (token == null) throw Exception('No token found');

      print('Updating profile with nama: $nama, email: $email');

      // Try POST method first
      var response = await http.post(
        Uri.parse('$baseUrl/mahasiswa/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'nama': nama,
          'email': email,
        }),
      );

      print('POST response status: ${response.statusCode}');
      print('POST response body: ${response.body}');

      // If POST fails with 405, try PATCH
      if (response.statusCode == 405) {
        print('POST not allowed, trying PATCH...');
        response = await http.patch(
          Uri.parse('$baseUrl/mahasiswa/profile'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({
            'nama': nama,
            'email': email,
          }),
        );

        print('PATCH response status: ${response.statusCode}');
        print('PATCH response body: ${response.body}');
      }

      // If still 405, try different endpoint
      if (response.statusCode == 405) {
        print('PATCH not allowed, trying PUT to /mahasiswa/profile/update...');
        response = await http.put(
          Uri.parse('$baseUrl/mahasiswa/profile/update'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({
            'nama': nama,
            'email': email,
          }),
        );

        print('PUT /update response status: ${response.statusCode}');
        print('PUT /update response body: ${response.body}');
      }

      // If still 405, try POST to different endpoint
      if (response.statusCode == 405) {
        print('Trying POST to /mahasiswa/update-profile...');
        response = await http.post(
          Uri.parse('$baseUrl/mahasiswa/update-profile'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({
            'nama': nama,
            'email': email,
          }),
        );

        print('POST /update-profile response status: ${response.statusCode}');
        print('POST /update-profile response body: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Profile updated successfully');
      } else if (response.statusCode == 405) {
        print('All methods failed - API might not support profile updates');
        throw Exception('Profile update not supported by API. Please contact administrator.');
      } else {
        print('Failed to update profile: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to update profile: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Exception in updateProfile: $e');
      throw Exception('Error updating profile: $e');
    }
  }
}