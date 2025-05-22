import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/dosen_model.dart';
import '../services/auth_service.dart';

class DosenService {
  static const String baseUrl = 'https://siakad.pradita.my.id/api/mobile';

  Future<Dosen?> getProfile() async {
    try {
      final token = await AuthService().getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/dosen/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Dosen.fromJson(data['dosen']);
      } else {
        throw Exception('Failed to load dosen profile: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error loading dosen profile: $e');
    }
  }
}
