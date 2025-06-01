import 'package:mobile_siakad/models/matakuliah_model.dart'; 
import 'package:mobile_siakad/services/api_client.dart';

class MahasiswaJadwalService {
  final ApiClient _apiClient;

  MahasiswaJadwalService(this._apiClient);

  Future<List<MataKuliah>> getJadwalLengkap({String? semester}) async { 
    try {
      print('=== SERVICE (MahasiswaJadwalService - getJadwalLengkap): Mengambil data ===');
      String endpoint = 'mahasiswa/jadwal'; 
      
      if (semester != null && semester.isNotEmpty) {
        endpoint += '?semester=${Uri.encodeQueryComponent(semester)}';
      }
      print('SERVICE: Endpoint getJadwalLengkap: $endpoint');

      final data = await _apiClient.get(endpoint); 

      if (data == null || data is! Map<String, dynamic> || data['jadwal'] == null || data['jadwal'] is! List) {
        print('SERVICE (getJadwalLengkap): Struktur data API tidak sesuai. Key "jadwal" (atau "matakuliah") tidak ditemukan atau bukan list.');
        print('SERVICE (getJadwalLengkap): Response mentah dari API: $data');
        return [];
      }
      
      final List<dynamic> jadwalListJson = data['jadwal'] as List<dynamic>; 
      
      List<MataKuliah> hasilJadwal = jadwalListJson.map((json) {
        try {
          return MataKuliah.fromJson(json as Map<String, dynamic>);
        } catch (e) {
          print('SERVICE (getJadwalLengkap): Error parsing item Jadwal: $json, error: $e');
          return null; 
        }
      }).whereType<MataKuliah>().toList(); 
      
      print('SERVICE (getJadwalLengkap): Total item jadwal setelah parsing: ${hasilJadwal.length}');
      return hasilJadwal;

    } catch (e) {
      print('SERVICE (getJadwalLengkap): Terjadi kesalahan: ${e.toString()}');
      throw Exception('Gagal mengambil data jadwal lengkap: ${e.toString()}');
    }
  }

  Future<List<MataKuliah>> getJadwalHariIni() async {
    try {
      print('=== SERVICE (MahasiswaJadwalService - getJadwalHariIni): Mengambil data ===');
      const String endpoint = 'mahasiswa/dashboard/jadwal-hari-ini'; 
      print('SERVICE: Endpoint getJadwalHariIni: $endpoint');

      final responseData = await _apiClient.get(endpoint);

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
