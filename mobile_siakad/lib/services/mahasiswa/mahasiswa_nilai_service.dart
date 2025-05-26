import 'package:mobile_siakad/models/mahasiswa_nilai.dart';
import 'package:mobile_siakad/services/api_client.dart';

class MahasiswaNilaiService {
  final ApiClient _apiClient;

  MahasiswaNilaiService(this._apiClient);

  Future<GetMahasiswaNilaiResponse> getNilaiMahasiswa() async {
    try {
      final String endpoint = 'mahasiswa/nilai'; 
      final responseData = await _apiClient.get(endpoint);

      if (responseData != null && responseData is Map<String, dynamic>) {
        return GetMahasiswaNilaiResponse.fromJson(responseData);
      } else {
        throw Exception('Gagal memuat data nilai: Respons API tidak valid.');
      }
    } catch (e) {
      throw Exception('Gagal memuat data nilai: ${e.toString().replaceFirst("Exception: ", "")}');
    }
  }
}