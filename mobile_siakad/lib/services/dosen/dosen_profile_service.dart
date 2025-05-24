

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
  String? name, // Ubah dari 'required String name' menjadi 'String? name'
  String? email, // Jika ada, juga jadikan opsional jika sesuai
  String? password,
  String? passwordConfirmation,
}) async {
  try {
    final body = <String, dynamic>{};

    if (name != null && name.isNotEmpty) {
      body['nama'] = name; // 'nama' sesuai dengan key yang diharapkan backend Laravel Anda
    }
    // if (email != null && email.isNotEmpty) { // Jika email juga bisa diupdate
    //   body['email'] = email;
    // }

    if (password != null && password.isNotEmpty) {
      body['password'] = password;
      // Backend Laravel dengan validasi 'confirmed' mengharapkan 'password_confirmation'
      body['password_confirmation'] = passwordConfirmation ?? ""; 
    }

    if (body.isEmpty) {
      print('Tidak ada data yang diupdate.');
      // Anda bisa langsung return atau throw error jika tidak ada yang diupdate,
      // tergantung kebutuhan. Tapi jika hanya password yang diupdate, body tidak akan kosong.
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