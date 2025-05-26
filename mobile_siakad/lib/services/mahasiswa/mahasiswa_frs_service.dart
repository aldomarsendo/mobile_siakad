import 'package:mobile_siakad/models/mahasiswa_frs_data_model.dart'; 
import 'package:mobile_siakad/services/api_client.dart';

class MahasiswaFrsService {
  final ApiClient _apiClient;

  MahasiswaFrsService(this._apiClient);

  /// Mengambil daftar mata kuliah (jadwal) yang tersedia untuk FRS.
  Future<GetAvailableMatakuliahResponse> getAvailableMatakuliah() async {
    try {
      const String endpoint = 'mahasiswa/matakuliah/available';
      final responseData = await _apiClient.get(endpoint);

      if (responseData != null && responseData is Map<String, dynamic>) {
        return GetAvailableMatakuliahResponse.fromJson(responseData);
      } else {
        print('MahasiswaFrsService.getAvailableMatakuliah: Respons API tidak valid atau tipe tidak sesuai. Respons: $responseData');
        throw Exception('Gagal memuat mata kuliah tersedia: Respons API tidak valid.');
      }
    } catch (e) {
      print('Error di MahasiswaFrsService.getAvailableMatakuliah: $e');
      throw Exception('Gagal memuat mata kuliah tersedia: ${e.toString().replaceFirst("Exception: ", "")}');
    }
  }

  /// Mengambil FRS mahasiswa yang sedang login untuk tahun ajaran aktif.
  Future<GetMyFrsResponse> getMyFrs() async {
    try {
      const String endpoint = 'mahasiswa/frs';
      final responseData = await _apiClient.get(endpoint);

      if (responseData != null && responseData is Map<String, dynamic>) {
        return GetMyFrsResponse.fromJson(responseData);
      } else {
        print('MahasiswaFrsService.getMyFrs: Respons API tidak valid. Respons: $responseData');
        throw Exception('Gagal memuat FRS: Respons API tidak valid.');
      }
    } catch (e) {
      print('Error di MahasiswaFrsService.getMyFrs: $e');
      throw Exception('Gagal memuat FRS: ${e.toString().replaceFirst("Exception: ", "")}');
    }
  }

  /// Membuat entri FRS baru untuk mata kuliah (jadwal) yang dipilih.
  /// [idMkJadwal] adalah ID dari tabel jadwal_kuliah (matakuliah.id_mk di Laravel).
  Future<CreateFrsResponse> createFrs(int idMkJadwal) async {
    try {
      const String endpoint = 'mahasiswa/frs';
      final Map<String, dynamic> body = {
        'id_mk_jadwal': idMkJadwal,
      };

      final responseData = await _apiClient.post(endpoint, body: body);

      if (responseData != null && responseData is Map<String, dynamic> && responseData['frs_item'] != null) {
        return CreateFrsResponse.fromJson(responseData);
      } else {
        print('MahasiswaFrsService.createFrs: Respons API tidak valid atau key "frs_item" tidak ditemukan. Respons: $responseData');
        throw Exception('Gagal menambahkan FRS: Respons API tidak valid.');
      }
    } catch (e) {
      print('Error di MahasiswaFrsService.createFrs: $e');
      String errorMessage = e.toString().replaceFirst("Exception: ", "");
      // Teruskan pesan error spesifik dari API jika ada (misal periode FRS ditutup)
      if (errorMessage.contains("Periode pengisian FRS") || 
          errorMessage.contains("Mata kuliah ini sudah ada") ||
          errorMessage.contains("Mata kuliah (jadwal) tidak valid")) {
         throw Exception(errorMessage); 
      }
      throw Exception('Gagal menambahkan FRS: $errorMessage');
    }
  }

  /// Menghapus entri FRS berdasarkan ID FRS.
  /// Mengembalikan pesan sukses dari API.
  Future<String> deleteFrs(int idFrs) async {
    try {
      final String endpoint = 'mahasiswa/frs/$idFrs';
      final responseData = await _apiClient.delete(endpoint);

      if (responseData != null && responseData is Map<String, dynamic> && responseData['message'] != null) {
        return responseData['message'] as String;
      } else {
        print('MahasiswaFrsService.deleteFrs: Respons API tidak valid. Respons: $responseData');
        throw Exception('Gagal menghapus FRS: Respons API tidak valid.');
      }
    } catch (e) {
      print('Error di MahasiswaFrsService.deleteFrs: $e');
      String errorMessage = e.toString().replaceFirst("Exception: ", "");
      // Teruskan pesan error spesifik dari API
      if (errorMessage.contains("Periode FRS sedang tidak aktif") || 
          errorMessage.contains("Hanya FRS dengan status") ||
          errorMessage.contains("Data FRS tidak ditemukan")) {
         throw Exception(errorMessage);
      }
      throw Exception('Gagal menghapus FRS: $errorMessage');
    }
  }
}