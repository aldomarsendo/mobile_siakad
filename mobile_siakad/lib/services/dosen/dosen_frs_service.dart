import 'package:mobile_siakad/models/frs_model.dart'; // Pastikan path ini benar
import 'package:mobile_siakad/services/api_client.dart';

class DosenFrsService {
  final ApiClient _apiClient;

  DosenFrsService(this._apiClient);

  /// Mengambil semua FRS yang berstatus pending untuk Dosen Wali.
  /// Di Flutter, kita akan filter berdasarkan id_mahasiswa yang dipilih.
  Future<List<FrsItem>> getPendingFrs() async {
    try {
      // Endpoint untuk mengambil FRS pending
      final responseData = await _apiClient.get('dosen/frs/pending');
      
      // Periksa apakah responseData ada, merupakan Map, dan memiliki key 'pending_frs' yang berupa List
      if (responseData != null && responseData is Map<String, dynamic> && responseData['pending_frs'] != null && responseData['pending_frs'] is List) {
        final List<dynamic> frsListJson = responseData['pending_frs'] as List<dynamic>;
        // Mapping setiap item JSON ke objek FrsItem
        return frsListJson
            .map((json) => FrsItem.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        // Jika data tidak ditemukan atau format tidak sesuai
        print('Data FRS pending tidak ditemukan atau format tidak sesuai dari API: $responseData');
        return []; // Kembalikan list kosong
      }
    } catch (e) {
      // Tangani error jika terjadi
      print('Error in DosenFrsService.getPendingFrs: $e');
      throw Exception('Gagal memuat FRS pending: $e');
    }
  }
  Future<List<FrsItem>> getAllFrsForMahasiswa(int idMahasiswa) async {
  try {
    // Panggil endpoint baru, contoh: 'dosen/frs/mahasiswa/$idMahasiswa'
    // Pastikan nama endpoint ini sesuai dengan yang Anda buat di backend
    final responseData = await _apiClient.get('dosen/frs/mahasiswa/$idMahasiswa'); 

    if (responseData != null && responseData['frs_items'] != null && responseData['frs_items'] is List) {
      final List<dynamic> frsListJson = responseData['frs_items'] as List<dynamic>;
      return frsListJson
          .map((json) => FrsItem.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      print('Data semua FRS untuk mahasiswa $idMahasiswa tidak ditemukan atau format tidak sesuai: $responseData');
      return [];
    }
  } catch (e) {
    print('Error fetching all FRS for mahasiswa $idMahasiswa: $e');
    throw Exception('Gagal memuat semua FRS untuk mahasiswa: $e');
  }
}

  /// Menyetujui atau menolak FRS tertentu.
  /// Mengembalikan FrsItem yang sudah diupdate dari server.
  Future<FrsItem> updateFrsStatus(int idFrs, String status) async {
    // status bisa 'disetujui' atau 'ditolak'
    try {
      final body = {
        'id_frs': idFrs,
        'status': status, // 'disetujui' atau 'ditolak'
      };
      // Endpoint untuk approve/reject FRS
      final responseData = await _apiClient.put('dosen/frs/approve', body: body);
      
      // Periksa apakah responseData ada, merupakan Map, dan memiliki key 'frs'
      if (responseData != null && responseData is Map<String, dynamic> && responseData['frs'] != null) {
        // Parsing FRS item yang diupdate dari respons
        return FrsItem.fromJson(responseData['frs'] as Map<String, dynamic>);
      } else {
        // Jika respons tidak valid
        throw Exception('Gagal memperbarui status FRS atau respons API tidak valid.');
      }
    } catch (e) {
      // Tangani error jika terjadi
      print('Error in DosenFrsService.updateFrsStatus (id: $idFrs, status: $status): $e');
      throw Exception('Gagal memperbarui status FRS: $e');
    }
  }

  // CATATAN PENTING:
  // Untuk menampilkan FRS yang 'disetujui' dan 'ditolak' secara historis (bukan hanya yang baru diubah statusnya),
  // Anda akan memerlukan endpoint baru di backend dan metode baru di service ini. Misalnya:
  //
  // Future<List<FrsItem>> getAllFrsForMahasiswa(int idMahasiswa) async {
  //   try {
  //     // Asumsi endpoint baru: 'dosen/frs/mahasiswa/{id_mahasiswa}'
  //     final responseData = await _apiClient.get('dosen/frs/mahasiswa/$idMahasiswa');
  //     if (responseData != null && responseData['frs_list'] != null && responseData['frs_list'] is List) {
  //       final List<dynamic> frsListJson = responseData['frs_list'] as List<dynamic>;
  //       return frsListJson.map((json) => FrsItem.fromJson(json as Map<String, dynamic>)).toList();
  //     } else {
  //       return [];
  //     }
  //   } catch (e) {
  //     print('Error fetching all FRS for mahasiswa $idMahasiswa: $e');
  //     throw Exception('Gagal memuat semua FRS mahasiswa: $e');
  //   }
  // }
}
