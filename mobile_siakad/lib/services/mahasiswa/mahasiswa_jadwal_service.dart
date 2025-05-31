import 'dart:convert'; 
import 'package:mobile_siakad/models/mahasiswa_jadwal_model.dart'; 
// Impor model tahun ajaran dari artifact yang sudah ada di Canvas
import 'package:mobile_siakad/models/tahun_ajaran_model.dart'; 
import 'package:mobile_siakad/services/api_client.dart';
import 'package:mobile_siakad/services/auth_service.dart';

class MahasiswaJadwalService {
  final AuthService _authService; 
  final ApiClient _apiClient;

  MahasiswaJadwalService(this._authService, this._apiClient);

  /// Mengambil daftar tahun ajaran yang tersedia untuk mahasiswa.
  /// GANTI 'mahasiswa/tahun-ajaran-list' dengan endpoint API Anda yang sebenarnya untuk mendapatkan daftar tahun ajaran.
  /// Jika API Anda tidak memiliki endpoint khusus untuk ini, Anda mungkin perlu mendapatkan
  /// tahun ajaran dari sumber lain atau menghardcode jika daftarnya statis.
  Future<ApiTahunAjaranResponse> getListTahunAjaran() async {
    try {
      print('=== SERVICE (MahasiswaJadwalService - getListTahunAjaran): Mengambil data ===');
      // PASTIKAN ENDPOINT INI BENAR DAN MENGEMBALIKAN LIST TAHUN AJARAN
      // Contoh: 'mahasiswa/tahun-ajaran' atau 'general/tahun-ajaran'
      const String endpoint = 'mahasiswa/list-tahun-ajaran'; // Ganti dengan endpoint yang benar
      print('SERVICE: Endpoint getListTahunAjaran: $endpoint');

      final dynamic responseData = await _apiClient.get(endpoint);
      
      Map<String, dynamic> jsonData;
      if (responseData is String) {
        jsonData = jsonDecode(responseData) as Map<String, dynamic>;
      } else if (responseData is Map<String, dynamic>) {
        jsonData = responseData;
      } else {
        print('SERVICE (getListTahunAjaran): Tipe data respons tidak dikenal: ${responseData.runtimeType}');
        throw Exception('Tipe data respons tidak dikenal dari API tahun ajaran.');
      }
      
      // Pastikan key 'tahun_ajaran' (atau 'data') sesuai dengan respons API Anda
      if (jsonData['tahun_ajaran'] == null && jsonData['data'] == null) {
         print('SERVICE (getListTahunAjaran): Key "tahun_ajaran" atau "data" tidak ditemukan dalam respons.');
         // Anda bisa mengembalikan list kosong atau melempar error spesifik
         return ApiTahunAjaranResponse(tahunAjaranList: [], message: jsonData['message'] as String? ?? "Data tahun ajaran tidak ditemukan.");
      }
      
      return ApiTahunAjaranResponse.fromJson(jsonData);

    } catch (e, stackTrace) {
      print('SERVICE (getListTahunAjaran): Terjadi kesalahan: ${e.toString()}');
      print('SERVICE (getListTahunAjaran): StackTrace: $stackTrace');
      throw Exception('Gagal mengambil daftar tahun ajaran: ${e.toString()}');
    }
  }


  /// Mengambil jadwal kuliah mahasiswa berdasarkan ID tahun ajaran.
  /// Jika idTahunAjaran null, API diharapkan mengembalikan jadwal untuk tahun ajaran aktif.
  Future<ApiMahasiswaJadwalResponse> getJadwalKuliahMahasiswa({String? idTahunAjaran}) async {
    try {
      print('=== SERVICE (MahasiswaJadwalService - getJadwalKuliahMahasiswa): Mengambil data ===');
      String endpoint = 'mahasiswa/jadwal'; 
      if (idTahunAjaran != null && idTahunAjaran.isNotEmpty) {
        // Sesuaikan nama parameter query jika berbeda, misal 'tahun_ajaran_id' atau 'id_ta'
        // Berdasarkan model MahasiswaNilaiItem, API mungkin menggunakan 'tahun_ajaran_frs' atau sejenisnya
        // Untuk jadwal, API Anda mungkin mengharapkan 'id_tahun_ajaran'
        endpoint += '?id_tahun_ajaran=${Uri.encodeQueryComponent(idTahunAjaran)}'; 
      }
      print('SERVICE: Endpoint getJadwalKuliahMahasiswa: $endpoint');

      final dynamic responseData = await _apiClient.get(endpoint);
      
      Map<String, dynamic> jsonData;
      if (responseData is String) {
        jsonData = jsonDecode(responseData) as Map<String, dynamic>;
      } else if (responseData is Map<String, dynamic>) {
        jsonData = responseData;
      } else {
        print('SERVICE (getJadwalKuliahMahasiswa): Tipe data respons tidak dikenal: ${responseData.runtimeType}');
        throw Exception('Tipe data respons tidak dikenal dari API jadwal.');
      }

      // Validasi apakah key 'jadwal' ada dan merupakan Map
      if (jsonData['jadwal'] == null || jsonData['jadwal'] is! Map<String, dynamic>) {
        print('SERVICE (getJadwalKuliahMahasiswa): Struktur data API tidak sesuai. Key "jadwal" tidak ditemukan atau bukan Map.');
        print('SERVICE (getJadwalKuliahMahasiswa): Response mentah dari API: $jsonData');
        return ApiMahasiswaJadwalResponse(
          jadwal: {}, 
          message: jsonData['message'] as String? ?? 'Struktur data jadwal tidak sesuai dari API.'
        );
      }
      
      final ApiMahasiswaJadwalResponse jadwalResponse = ApiMahasiswaJadwalResponse.fromJson(jsonData);
      
      print('SERVICE (getJadwalKuliahMahasiswa): Pesan dari API: ${jadwalResponse.message}');
      print('SERVICE (getJadwalKuliahMahasiswa): Jumlah hari dengan jadwal setelah parsing: ${jadwalResponse.jadwal.keys.length}');
      return jadwalResponse;

    } catch (e, stackTrace) { 
      print('SERVICE (getJadwalKuliahMahasiswa): Terjadi kesalahan: ${e.toString()}');
      print('SERVICE (getJadwalKuliahMahasiswa): StackTrace: $stackTrace');
      throw Exception('Gagal mengambil data jadwal kuliah mahasiswa: ${e.toString()}');
    }
  }
}
