import 'package:mobile_siakad/models/matakuliah_model.dart'; // Pastikan path ini benar
import 'package:mobile_siakad/services/auth_service.dart';   // AuthService mungkin tidak diperlukan lagi di sini jika token sudah dihandle ApiClient
import 'package:mobile_siakad/services/api_client.dart';

class DosenJadwalService {
  // final AuthService _authService; // Jika ApiClient sudah menangani token, ini mungkin tidak perlu
  final ApiClient _apiClient;

  // DosenJadwalService(this._authService, this._apiClient);
  DosenJadwalService(AuthService authService, this._apiClient); // Terima AuthService jika masih diperlukan untuk hal lain


  /// Mengambil semua jadwal mata kuliah untuk dosen yang login.
  /// API diharapkan mengembalikan jadwal yang sudah dikelompokkan per hari.
  /// Service ini akan "meratakan" data tersebut menjadi satu List<MataKuliah>.
  Future<List<MataKuliah>> getMataKuliah() async {
    try {
      // final token = await _authService.getToken(); // Jika ApiClient menghandle token, ini tidak perlu
      // if (token == null) {
      //   throw Exception('No token available. Silakan login terlebih dahulu.');
      // }

      print('=== SERVICE (DosenJadwalService): MULAI MENGAMBIL DATA JADWAL ===');
      
      // Endpoint baru sesuai yang Anda berikan
      const String endpoint = 'dosen/jadwal'; 
      print('SERVICE: Endpoint yang akan diakses: $endpoint');

      final responseData = await _apiClient.get(endpoint); 

      if (responseData == null || responseData['jadwal'] == null || responseData['jadwal'] is! Map) {
          print('SERVICE: Struktur data API tidak sesuai atau key "jadwal" tidak ditemukan/bukan map.');
          print('SERVICE: Response mentah dari API: $responseData');
          return []; // Kembalikan list kosong
      }

      final Map<String, dynamic> jadwalPerHari = responseData['jadwal'] as Map<String, dynamic>;
      print('SERVICE: Data jadwal per hari diterima dari API: ${jadwalPerHari.length} hari ditemukan.');

      List<MataKuliah> semuaMataKuliah = [];
      jadwalPerHari.forEach((hari, listMkJson) {
        if (listMkJson is List) {
          for (var mkJson in listMkJson) {
            if (mkJson is Map<String, dynamic>) {
              try {
                // Penting: Pastikan MataKuliah.fromJson dapat mem-parsing struktur mkJson ini,
                // termasuk nested 'kelas', 'ruang', dan menangani 'id_dosen'.
                semuaMataKuliah.add(MataKuliah.fromJson(mkJson));
              } catch (e) {
                print('SERVICE: Error parsing MataKuliah JSON untuk hari $hari: $e. Data MK: $mkJson');
                // Anda bisa memilih untuk melanjutkan atau melempar error
              }
            }
          }
        }
      });
      
      print('SERVICE: Total mata kuliah setelah parsing dan flattening: ${semuaMataKuliah.length}');
      return semuaMataKuliah;

    } catch (e) {
      print('SERVICE: Error fetching jadwal di DosenJadwalService: ${e.toString()}');
      throw Exception('Gagal mengambil data jadwal: ${e.toString()}');
    }
  }
}
