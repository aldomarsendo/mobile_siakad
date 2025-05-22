import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/dosen_model.dart';
import '../services/auth_service.dart';

class DosenService {
  static const String baseUrl = 'https://siakad.pradita.my.id/api/mobile';

  Future<Dosen?> getProfile() async {
    try {
      final token = await AuthService().getToken();
      
      if (token == null) {
        return null;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/dosen/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Parsed data: $data');
        
        // Check if 'dosen' key exists and is not null
        if (data['dosen'] != null) {
          print('Dosen data found, parsing...');
          try {
            final dosen = Dosen.fromJson(data['dosen']);
            print('Successfully parsed dosen: ${dosen.name}');
            return dosen;
          } catch (parseError) {
            print('Error parsing dosen data: $parseError');
            print('Dosen data structure: ${data['dosen']}');
            throw Exception('Failed to parse dosen data: $parseError');
          }
        } else {
          throw Exception('No dosen data found in response');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please login again');
      } else {
        throw Exception('Failed to load dosen profile: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Exception in getProfile: $e');
      throw Exception('Error loading dosen profile: $e');
    }
  }

  Future<void> updateProfile({
    required String name,
    required String email,
  }) async {
    try {
      final token = await AuthService().getToken();
      if (token == null) throw Exception('No token found');

      print('Updating profile with name: $name, email: $email');

      // Try POST method first (most common for updates)
      var response = await http.post(
        Uri.parse('$baseUrl/dosen/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
        }),
      );

      print('POST response status: ${response.statusCode}');
      print('POST response body: ${response.body}');

      // If POST fails with 405, try PATCH
      if (response.statusCode == 405) {
        print('POST not allowed, trying PATCH...');
        response = await http.patch(
          Uri.parse('$baseUrl/dosen/profile'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({
            'name': name,
            'email': email,
          }),
        );

        print('PATCH response status: ${response.statusCode}');
        print('PATCH response body: ${response.body}');
      }

      // If still 405, try different endpoint
      if (response.statusCode == 405) {
        print('PATCH not allowed, trying PUT to /dosen/profile/update...');
        response = await http.put(
          Uri.parse('$baseUrl/dosen/profile/update'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({
            'name': name,
            'email': email,
          }),
        );

        print('PUT /update response status: ${response.statusCode}');
        print('PUT /update response body: ${response.body}');
      }

      // If still 405, try POST to different endpoint
      if (response.statusCode == 405) {
        print('Trying POST to /dosen/update-profile...');
        response = await http.post(
          Uri.parse('$baseUrl/dosen/update-profile'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({
            'name': name,
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