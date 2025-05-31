import 'dart:convert';
import '../api_client.dart'; 
// Menggunakan MahasiswaJadwalItem dari model yang Anda berikan
import '../../models/mahasiswa_jadwal_model.dart'; 

class MahasiswaDashboardService {
  final ApiClient _apiClient;

  MahasiswaDashboardService({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Mengambil jadwal kuliah mahasiswa untuk hari ini.
  /// Endpoint: GET mobile/mahasiswa/dashboard/jadwal-hari-ini
  Future<List<MahasiswaJadwalItem>> getJadwalHariIni() async {
    try {
      print('=== SERVICE (MahasiswaDashboardService - getJadwalHariIni): Mengambil data ===');
      final dynamic responseData = await _apiClient.get('mahasiswa/dashboard/jadwal-hari-ini');
      
      List<dynamic> jadwalDataList = [];

      // Respons API adalah list langsung dari objek jadwal
      if (responseData is List) {
        jadwalDataList = responseData;
      } else if (responseData is Map<String, dynamic>) {
        // Penanganan jika API suatu saat berubah menjadi objek dengan key tertentu
        if (responseData.containsKey('jadwal_hari_ini') && responseData['jadwal_hari_ini'] is List) {
          jadwalDataList = responseData['jadwal_hari_ini'] as List<dynamic>;
        } else if (responseData.containsKey('data') && responseData['data'] is List) {
          jadwalDataList = responseData['data'] as List<dynamic>;
        } else {
           print("Struktur respons jadwal hari ini tidak dikenal atau key tidak ditemukan: $responseData");
           // Bisa mengembalikan list kosong atau throw error, tergantung kebutuhan
           // return []; 
        }
      } else {
         print("Tipe respons jadwal hari ini tidak dikenal: $responseData");
         // return [];
      }
      
      // Parsing setiap item dalam list menjadi MahasiswaJadwalItem
      List<MahasiswaJadwalItem> jadwalList = jadwalDataList
          .map((item) {
            try {
              return MahasiswaJadwalItem.fromJson(item as Map<String, dynamic>);
            } catch (e) {
              print("Error parsing item jadwal hari ini: $item, error: $e");
              return null; // Kembalikan null jika ada error parsing item individual
            }
          })
          .whereType<MahasiswaJadwalItem>() // Filter item yang null (gagal parsing)
          .toList();
      
      // Sorting berdasarkan jamMulai
      jadwalList.sort((a, b) => a.jamMulai.compareTo(b.jamMulai));
      
      print('SERVICE (getJadwalHariIni): Total jadwal hari ini setelah parsing: ${jadwalList.length}');
      return jadwalList;

    } catch (e, stackTrace) {
      print('Error fetching jadwal hari ini: $e');
      print('StackTrace: $stackTrace');
      throw Exception('Gagal memuat jadwal hari ini: ${e.toString().replaceFirst("Exception: ", "")}');
    }
  }
}
