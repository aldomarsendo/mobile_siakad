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
}
