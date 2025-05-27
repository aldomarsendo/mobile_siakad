import 'package:mobile_siakad/models/matakuliah_model.dart'; 
import 'package:mobile_siakad/services/auth_service.dart';
import 'package:mobile_siakad/services/api_client.dart';

class DosenJadwalService {
  final AuthService _authService; 
  final ApiClient _apiClient;

  DosenJadwalService(this._authService, this._apiClient);

  /// Parameter [semester] bersifat opsional untuk filter.
  Future<List<MataKuliah>> getMataKuliah({String? semester}) async {
    try {
      print('=== SERVICE (DosenJadwalService - getMataKuliah): Mengambil data ===');
      String endpoint = 'dosen/matakuliah'; // Endpoint default
      
      // Tambahkan parameter query jika semester disediakan
      if (semester != null && semester.isNotEmpty) {
        endpoint += '?semester=${Uri.encodeQueryComponent(semester)}';
      }
      print('SERVICE: Endpoint getMataKuliah: $endpoint');

      final data = await _apiClient.get(endpoint); 

      // Validasi struktur data respons
      if (data == null || data is! Map<String, dynamic> || data['matakuliah'] == null || data['matakuliah'] is! List) {
          print('SERVICE (getMataKuliah): Struktur data API tidak sesuai. Key "matakuliah" tidak ditemukan atau bukan list.');
          print('SERVICE (getMataKuliah): Response mentah dari API: $data');
          return [];
      }
      
      final List<dynamic> matakuliahListJson = data['matakuliah'] as List<dynamic>;
      
      // Parsing JSON ke List<MataKuliah> dengan penanganan error per item
      List<MataKuliah> hasilMataKuliah = matakuliahListJson.map((json) {
        try {
          return MataKuliah.fromJson(json as Map<String, dynamic>);
        } catch (e) {
          print('SERVICE (getMataKuliah): Error parsing item MataKuliah: $json, error: $e');
          return null; 
        }
      }).whereType<MataKuliah>().toList(); 
      
      print('SERVICE (getMataKuliah): Total mata kuliah setelah parsing: ${hasilMataKuliah.length}');
      return hasilMataKuliah;

    } catch (e) {
      print('SERVICE (getMataKuliah): Terjadi kesalahan: ${e.toString()}');
      throw Exception('Gagal mengambil data mata kuliah: ${e.toString()}');
    }
  }

  /// Mengambil jadwal kuliah HARI INI untuk dosen yang login.
  Future<List<MataKuliah>> getJadwalHariIni() async {
    try {
      print('=== SERVICE (DosenJadwalService - getJadwalHariIni): Mengambil data ===');
      const String endpoint = 'dosen/dashboard/jadwal-hari-ini';
      print('SERVICE: Endpoint getJadwalHariIni: $endpoint');

      final responseData = await _apiClient.get(endpoint);

      // Validasi struktur data respons
      if (responseData != null && responseData is Map<String, dynamic> && responseData['jadwal_hari_ini'] != null && responseData['jadwal_hari_ini'] is List) {
        final List<dynamic> jadwalJsonList = responseData['jadwal_hari_ini'] as List<dynamic>;
        
        List<MataKuliah> jadwalHariIni = jadwalJsonList.map((json) {
          try {
            return MataKuliah.fromJson(json as Map<String, dynamic>);
          } catch(e) {
            print('SERVICE (getJadwalHariIni): Error parsing item jadwal hari ini: $json, error: $e');
            return null; 
          }
        }).whereType<MataKuliah>().toList(); 

        print('SERVICE (getJadwalHariIni): Total jadwal hari ini setelah parsing: ${jadwalHariIni.length}');
        return jadwalHariIni;
      } else {
        print('SERVICE (getJadwalHariIni): Struktur data API tidak sesuai. Key "jadwal_hari_ini" tidak ditemukan atau bukan list.');
        print('SERVICE (getJadwalHariIni): Response mentah dari API: $responseData');
        return [];
      }
    } catch (e) {
      print('SERVICE (getJadwalHariIni): Terjadi kesalahan: ${e.toString()}');
      throw Exception('Gagal mengambil jadwal hari ini: ${e.toString()}');
    }
  }
}
