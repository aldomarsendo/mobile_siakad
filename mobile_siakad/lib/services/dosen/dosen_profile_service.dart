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
  String? name, 
  String? email, 
  String? password,
  String? passwordConfirmation,
}) async {
  try {
    final body = <String, dynamic>{};

    if (name != null && name.isNotEmpty) {
      body['nama'] = name; 
    }
    
    if (password != null && password.isNotEmpty) {
      body['password'] = password;
      
      body['password_confirmation'] = passwordConfirmation ?? ""; 
    }

    if (body.isEmpty) {
      print('Tidak ada data yang diupdate.');
      return; 
    }

    await _apiClient.put('dosen/profile', body: body);
    print('Dosen profile updated successfully with data: ${body.toString()}');
  } catch (e) {
    print('Error in DosenProfileService.updateProfile: $e');
    throw Exception('Gagal memperbarui profil dosen: $e');
  }
}
}