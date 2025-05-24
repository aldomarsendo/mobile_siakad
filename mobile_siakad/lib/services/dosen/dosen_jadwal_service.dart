import 'package:mobile_siakad/models/matakuliah_model.dart';
import 'package:mobile_siakad/services/auth_service.dart';
import 'package:mobile_siakad/services/api_client.dart';

class DosenJadwalService {
  final AuthService _authService;
  final ApiClient _apiClient;

  DosenJadwalService(this._authService, this._apiClient);

  Future<List<MataKuliah>> getMataKuliah({String? semester}) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('No token available. Silakan login terlebih dahulu.');
      }

      print('=== SERVICE: MULAI MENGAMBIL DATA MATA KULIAH ===');
      print('SERVICE: Meminta data untuk Semester: $semester');

      String endpoint = 'dosen/matakuliah';
      List<String> queryParams = [];

      if (semester != null && semester.isNotEmpty) {
        queryParams.add('semester=${Uri.encodeQueryComponent(semester)}');
      }

      if (queryParams.isNotEmpty) {
        endpoint += '?${queryParams.join('&')}';
      }

      print('SERVICE: Endpoint yang akan diakses: $endpoint');

      final data = await _apiClient.get(endpoint); 

      if (data == null || data['matakuliah'] == null || data['matakuliah'] is! List) {
          print('SERVICE: Struktur data API tidak sesuai atau key "matakuliah" tidak ditemukan/bukan list.');
          print('SERVICE: Response mentah dari API: $data');
          return []; // Kembalikan list kosong atau lempar error yang lebih spesifik
      }

      final List<dynamic> matakuliahListJson = data['matakuliah'];
      print('SERVICE: Total item mentah diterima dari API untuk "matakuliah": ${matakuliahListJson.length}');

      // Parsing JSON ke List<MataKuliah>
      List<MataKuliah> hasilMataKuliah = matakuliahListJson
          .map((json) => MataKuliah.fromJson(json as Map<String, dynamic>))
          .toList();
      
      print('SERVICE: Total mata kuliah setelah parsing: ${hasilMataKuliah.length}');

      return hasilMataKuliah;

    } catch (e) {
      print('SERVICE: Error fetching jadwal di DosenJadwalService: ${e.toString()}');
      throw Exception('Gagal mengambil data jadwal: ${e.toString()}');
    }
  }
}
