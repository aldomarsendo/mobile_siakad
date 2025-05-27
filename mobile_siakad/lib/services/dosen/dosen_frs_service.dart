import 'package:mobile_siakad/models/frs_model.dart';
import 'package:mobile_siakad/services/api_client.dart';

class DosenFrsService {
  final ApiClient _apiClient;

  DosenFrsService(this._apiClient);

  Future<List<FrsItem>> getPendingFrs() async {
    try {
      final responseData = await _apiClient.get('dosen/frs/pending');
      
      if (responseData != null && responseData is Map<String, dynamic> && responseData['pending_frs'] != null && responseData['pending_frs'] is List) {
        final List<dynamic> frsListJson = responseData['pending_frs'] as List<dynamic>;
        return frsListJson
            .map((json) => FrsItem.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Gagal memuat FRS pending: $e');
    }
  }
  Future<List<FrsItem>> getAllFrsForMahasiswa(int idMahasiswa) async {
  try {
    final responseData = await _apiClient.get('dosen/frs/mahasiswa/$idMahasiswa'); 

    if (responseData != null && responseData['frs_mahasiswa'] != null && responseData['frs_mahasiswa'] is List) {
      final List<dynamic> frsListJson = responseData['frs_mahasiswa'] as List<dynamic>;
      return frsListJson
          .map((json) => FrsItem.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      print('Key "frs_mahasiswa" tidak ditemukan atau bukan list pada respons: $responseData');
      return [];
    }
  } catch (e) {
    throw Exception('Gagal memuat semua FRS untuk mahasiswa: $e');
  }
}

Future<FrsItem> updateFrsStatus(int idFrs, String status) async { 
  try {
    final body = {
      'id_frs': idFrs,
      'status': status,
    };
    final responseData = await _apiClient.put('dosen/frs/approve', body: body); 
    
    if (responseData != null && responseData is Map<String, dynamic> && responseData['frs'] != null) {
      return FrsItem.fromJson(responseData['frs'] as Map<String, dynamic>);
    } else {
      print('updateFrsStatus: Respons API tidak valid atau key "frs" tidak ditemukan. Respons: $responseData');
      throw Exception('Gagal memperbarui status FRS atau respons API tidak valid.');
    }
  } catch (e) {
    print('Error di updateFrsStatus: $e');
    throw Exception('Gagal memperbarui status FRS: $e');
  }
}

  Future<FrsItem> editFrsByDosenWali({
    required int idFrs,
    required int idMkJadwalBaru,
    String? catatanWaliEdit,
  }) async {
    try {
      final String endpoint = 'mobile/dosen/frs/$idFrs/edit-by-wali';
      final Map<String, dynamic> body = {
        'id_mk_jadwal_baru': idMkJadwalBaru,
        if (catatanWaliEdit != null && catatanWaliEdit.isNotEmpty) 
          'catatan_wali_edit': catatanWaliEdit,
      };

      final responseData = await _apiClient.put(endpoint, body: body);

      if (responseData != null && responseData is Map<String, dynamic> && responseData['frs'] != null) {
        return FrsItem.fromJson(responseData['frs'] as Map<String, dynamic>);
      } else {
        print('editFrsByDosenWali: Respons API tidak valid atau key "frs" tidak ditemukan. Respons: $responseData');
        throw Exception('Gagal mengedit FRS atau respons API tidak valid.');
      }
    } catch (e) {
      print('Error di editFrsByDosenWali: $e');
      throw Exception('Gagal mengedit FRS: $e');
    }
  }
}
