import '../../models/dosen_model.dart';
import '../api_client.dart';

class DosenProfileService {
  final ApiClient _apiClient;

  DosenProfileService(this._apiClient);

  Future<Dosen> getProfile() async {
    try {
      final data = await _apiClient.get('dosen/profile');

      if (data != null && data['dosen'] != null) {
        return Dosen.fromJson(data['dosen']);
      } else {
        throw Exception('No dosen data found in API response');
      }
    } catch (e) {
      print('Error in DosenProfileService.getProfile: $e');
      throw Exception('Failed to load dosen profile: $e');
    }
  }

  Future<void> updateProfile({
    required String name,
    required String email,
  }) async {
    try {
      final body = {
        'name': name,
        'email': email,
      };

      await _apiClient.post('dosen/profile', body: body);
      
      print('Dosen profile updated successfully.');

    } catch (e) {
      print('Error in DosenProfileService.updateProfile: $e');
      throw Exception('Failed to update dosen profile: $e');
    }
  }
}
