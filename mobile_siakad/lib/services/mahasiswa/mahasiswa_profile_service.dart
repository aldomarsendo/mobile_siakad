import 'package:mobile_siakad/models/mahasiswa_profile_model.dart';

import '../api_client.dart'; 

class MahasiswaProfileService {
  final ApiClient _apiClient;

  MahasiswaProfileService(this._apiClient);

  
  Future<MahasiswaProfile> getProfile() async {
    try {
      const String endpoint = 'mahasiswa/profile'; 
      final responseData = await _apiClient.get(endpoint);

      if (responseData != null &&
          responseData is Map<String, dynamic> &&
          responseData['profile'] != null &&
          responseData['profile'] is Map<String, dynamic>) {
        return MahasiswaProfile.fromJson(responseData['profile'] as Map<String, dynamic>);
      } else {
        print('MahasiswaProfileService.getProfile: Respons API tidak valid atau key "profile" tidak ditemukan. Respons: $responseData');
        throw Exception('Gagal memuat profil: Format respons tidak sesuai.');
      }
    } catch (e) {
      print('Error di MahasiswaProfileService.getProfile: $e');
      throw Exception('Gagal memuat profil: ${e.toString().replaceFirst("Exception: ", "")}');
    }
  }

  Future<String> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    try {
      const String endpoint = 'mahasiswa/profile'; 
      final Map<String, dynamic> body = {
        'current_password': currentPassword,
        'password': newPassword,
        'password_confirmation': newPasswordConfirmation,
      };

      final responseData = await _apiClient.put(endpoint, body: body);

      if (responseData != null && 
          responseData is Map<String, dynamic> && 
          responseData['message'] != null &&
          responseData['message'] is String) {
        return responseData['message'] as String;
      } else {
        print('MahasiswaProfileService.updatePassword: Respons API tidak valid. Respons: $responseData');
        throw Exception('Gagal memperbarui password: Format respons tidak sesuai.');
      }
    } catch (e) {
      print('Error di MahasiswaProfileService.updatePassword: $e');
      throw Exception('Gagal memperbarui password: ${e.toString().replaceFirst("Exception: ", "")}');
    }
  }
}
