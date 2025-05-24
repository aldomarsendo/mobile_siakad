import '../../models/mahasiswa_model.dart';
import '../api_client.dart'; 

class MahasiswaProfileService {
  final ApiClient _apiClient;

  MahasiswaProfileService(this._apiClient);

  Future<Mahasiswa> getProfile() async {
    try {
      final response = await _apiClient.get('mahasiswa/profile');
      
      if (response is Map<String, dynamic>) {
        final mahasiswaData = response['profile'];
        if (mahasiswaData != null) {
          return Mahasiswa.fromJson(mahasiswaData);
        }
      }
      
      throw Exception('No mahasiswa data found in API response');
    } catch (e) {
      print('Error in MahasiswaProfileService.getProfile: $e');
      throw Exception('Failed to load mahasiswa profile: $e');
    }
  }

  Future<void> updateProfile({
    required String nama,
    required String email,
  }) async {
    try {
      final body = {
        'nama': nama,
        'email': email,
      };

      await _apiClient.post('mahasiswa/profile', body: body);
      
      print('Mahasiswa profile updated successfully.');

    } catch (e) {
      print('Error in MahasiswaProfileService.updateProfile: $e');
      throw Exception('Failed to update mahasiswa profile: $e');
    }
  }
}
