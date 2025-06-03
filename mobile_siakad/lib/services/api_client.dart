import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
const String baseUrl = 'https://sistem-akademik.pradita.my.id/api/mobile';

class ApiClient {
  final http.Client _client;

  ApiClient(this._client);

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization' : 'Bearer $token',
    };
  }

  Future<dynamic> get(String endpoint) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/$endpoint'),
        headers: await _getHeaders(),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<dynamic> post(String endpoint, {required Map<String, dynamic> body}) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/$endpoint'),
        headers: await _getHeaders(),
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<dynamic> put(String endpoint, {required Map<String, dynamic>body}) async {
    try {
      final response = await _client.put(
        Uri.parse('$baseUrl/$endpoint'),
        headers: await _getHeaders(),
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<dynamic> delete(String endpoint) async {
    try {
      final response = await _client.delete(
        Uri.parse('$baseUrl/$endpoint'),
        headers: await _getHeaders(),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  dynamic _handleResponse(http.Response response) {
    final body = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized: ${body['message'] ?? 'Please login again'}');
    } else {
      throw Exception('API Error (${response.statusCode}) - ${body['message'] ?? response.body}');
    }
  }
}

