import 'package:mobile_siakad/models/mahasiswa_model.dart';
import 'package:mobile_siakad/services/api_client.dart';

class DosenWaliService {
  final ApiClient _apiClient;

  DosenWaliService(this._apiClient);

  Future<List<Mahasiswa>> getMahasiswaWali() async {
    try {
      final responseData = await _apiClient.get('dosen/mahasiswa-wali');
      
      if (responseData != null && responseData is Map<String, dynamic> && responseData['data'] != null && responseData['data'] is List) {
        final List<dynamic> kelasWrapperListJson = responseData['data'] as List<dynamic>;
        List<Mahasiswa> allMahasiswaWali = [];

        for (var kelasWrapperItem in kelasWrapperListJson) {
          if (kelasWrapperItem is Map<String, dynamic> && kelasWrapperItem['kelas'] != null && kelasWrapperItem['kelas'] is Map<String, dynamic>) {
            final Map<String, dynamic> kelasJson = kelasWrapperItem['kelas'] as Map<String, dynamic>;
            
            if (kelasJson['mahasiswa'] != null && kelasJson['mahasiswa'] is List) {
              final List<dynamic> mahasiswaJsonListPerKelas = kelasJson['mahasiswa'] as List<dynamic>;
              
              for (var mhsJson in mahasiswaJsonListPerKelas) {
                if (mhsJson is Map<String, dynamic>) {
                  
                  allMahasiswaWali.add(Mahasiswa.fromJson(mhsJson));
                }
              }
            }
          }
        }
        print('Berhasil memparsing ${allMahasiswaWali.length} mahasiswa wali.');
        return allMahasiswaWali; 
      } else {
        print('Data mahasiswa wali tidak ditemukan atau format tidak sesuai (struktur utama salah): $responseData');
        return []; 
      }
    } catch (e) {
      print('Error in DosenWaliService.getMahasiswaWali: $e');
      throw Exception('Gagal memuat data mahasiswa wali: $e');
    }
  }
}