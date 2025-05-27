import 'package:mobile_siakad/models/matakuliah_model.dart'; 
import 'package:mobile_siakad/services/auth_service.dart';   
import 'package:mobile_siakad/services/api_client.dart';

class DosenJadwalService {
  final ApiClient _apiClient;

  DosenJadwalService(AuthService authService, this._apiClient); 

  Future<List<MataKuliah>> getMataKuliah() async {
    try {
      print('=== SERVICE (DosenJadwalService): MULAI MENGAMBIL DATA JADWAL ===');
      
      const String endpoint = 'dosen/jadwal'; 
      print('SERVICE: Endpoint yang akan diakses: $endpoint');

      final responseData = await _apiClient.get(endpoint); 

      if (responseData == null || responseData['jadwal'] == null || responseData['jadwal'] is! Map) {
          print('SERVICE: Struktur data API tidak sesuai atau key "jadwal" tidak ditemukan/bukan map.');
          print('SERVICE: Response mentah dari API: $responseData');
          return []; 
      }

      final Map<String, dynamic> jadwalPerHari = responseData['jadwal'] as Map<String, dynamic>;
      print('SERVICE: Data jadwal per hari diterima dari API: ${jadwalPerHari.length} hari ditemukan.');

      List<MataKuliah> semuaMataKuliah = [];
      jadwalPerHari.forEach((hari, listMkJson) {
        if (listMkJson is List) {
          for (var mkJson in listMkJson) {
            if (mkJson is Map<String, dynamic>) {
              try {
                semuaMataKuliah.add(MataKuliah.fromJson(mkJson));
              } catch (e) {
                print('SERVICE: Error parsing MataKuliah JSON untuk hari $hari: $e. Data MK: $mkJson');
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
