import 'package:mobile_siakad/models/nilai_model.dart';
import 'package:mobile_siakad/services/api_client.dart';

class DosenNilaiService {
  final ApiClient _apiClient;

  DosenNilaiService(this._apiClient);

  Future<GetMahasiswaNilaiResponse> getMahasiswaByMatakuliah(int idMkJadwal) async {
    try {
      final String endpoint = 'dosen/matakuliah/$idMkJadwal/mahasiswa';
      final responseData = await _apiClient.get(endpoint);
      
      if (responseData != null && responseData is Map<String, dynamic>) {
        return GetMahasiswaNilaiResponse.fromJson(responseData);
      } else {
        print('getMahasiswaByMatakuliah: Respons API tidak valid atau tipe tidak sesuai. Respons: $responseData');
        throw Exception('Gagal memuat daftar mahasiswa: Respons API tidak valid.');
      }
    } catch (e) {
      print('Error di getMahasiswaByMatakuliah (service): $e');
      throw Exception('Gagal memuat daftar mahasiswa untuk input nilai: ${e.toString().replaceFirst("Exception: ", "")}');
    }
  }

  Future<SubmittedNilaiItem> inputNilai({
    required int idFrs,
    required num nilaiAngka, 
  }) async {
    try {
      const String endpoint = 'dosen/nilai';
      final Map<String, dynamic> body = {
        'id_frs': idFrs,
        'nilai_angka': nilaiAngka,
      };

      final responseData = await _apiClient.put(endpoint, body: body);

      if (responseData != null && 
          responseData is Map<String, dynamic> && 
          responseData['nilai_diinput'] != null &&
          responseData['nilai_diinput'] is Map<String, dynamic>) {
        return SubmittedNilaiItem.fromJson(responseData['nilai_diinput'] as Map<String, dynamic>);
      } else {
        print('inputNilai: Respons API tidak valid atau key "nilai_diinput" tidak ditemukan/valid. Respons: $responseData');
        throw Exception('Gagal menginput nilai: Respons API tidak valid.');
      }
    } catch (e) {
      print('Error di inputNilai (service): $e');
      throw Exception('Gagal menginput nilai: ${e.toString().replaceFirst("Exception: ", "")}');
    }
  }
}