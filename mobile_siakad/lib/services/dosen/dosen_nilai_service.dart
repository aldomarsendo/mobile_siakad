// lib/services/dosen/dosen_nilai_service.dart
import 'package:mobile_siakad/models/nilai_model.dart'; // Model yang baru dibuat
import 'package:mobile_siakad/services/api_client.dart';
import 'package:mobile_siakad/services/auth_service.dart'; // Jika perlu untuk token

class DosenNilaiService {
  final ApiClient _apiClient;
  final AuthService _authService; 

  DosenNilaiService(this._apiClient, this._authService);

  /// Mengambil daftar mahasiswa beserta detail FRS dan nilai mereka untuk mata kuliah tertentu di kelas tertentu.
  /// Endpoint: GET /mobile/dosen/matakuliah/{id_mk}/mahasiswa?id_kelas={id_kelas}
  Future<List<MahasiswaNilaiEntry>> getMahasiswaForNilaiByKelas(int idMk, int idKelas) async {
    try {
      // final token = await _authService.getToken(); // Handle token jika perlu
      // if (token == null) throw Exception("Token tidak tersedia");

      final String endpoint = 'dosen/matakuliah/$idMk/mahasiswa?id_kelas=$idKelas';
      print('SERVICE (DosenNilaiService - getMahasiswaForNilai): Endpoint: $endpoint');

      final responseData = await _apiClient.get(endpoint);

      // PERBAIKAN: Baca list mahasiswa dari key "mahasiswa" dalam respons Map
      if (responseData != null && 
          responseData is Map<String, dynamic> && 
          responseData['mahasiswa'] != null && 
          responseData['mahasiswa'] is List) {
        
        final List<dynamic> mahasiswaJsonList = responseData['mahasiswa'] as List<dynamic>;
        
        if (mahasiswaJsonList.isEmpty) {
          print('SERVICE (DosenNilaiService - getMahasiswaForNilai): Tidak ada data mahasiswa di dalam list "mahasiswa".');
          return []; // Kembalikan list kosong jika list mahasiswa dari API kosong
        }

        return mahasiswaJsonList
            .map((json) {
                try {
                  return MahasiswaNilaiEntry.fromJson(json as Map<String, dynamic>);
                } catch (e) {
                  print('SERVICE (DosenNilaiService - getMahasiswaForNilai): Error parsing item mahasiswa: $json, error: $e');
                  return null; // Kembalikan null jika ada error parsing satu item
                }
            })
            .whereType<MahasiswaNilaiEntry>() // Filter item yang null (gagal parse)
            .toList();
      } 
      // Hapus kondisi 'else if' sebelumnya yang mencari 'mahasiswa_list_nilai' atau responseData is List
      else {
        print('SERVICE (DosenNilaiService - getMahasiswaForNilai): Data mahasiswa tidak ditemukan atau format tidak sesuai. Key "mahasiswa" tidak ada atau bukan List. Respons: $responseData');
        return [];
      }
    } catch (e) {
      print('SERVICE (DosenNilaiService - getMahasiswaForNilai): Error: $e');
      throw Exception('Gagal memuat daftar mahasiswa untuk penilaian: $e');
    }
  }

  /// Mengirimkan atau memperbarui nilai mahasiswa.
  /// Endpoint: PUT /mobile/dosen/nilai
  Future<Nilai> submitNilaiMahasiswa(int idFrs, int nilaiAngka) async {
    try {
      final body = {
        'id_frs': idFrs,
        'nilai_angka': nilaiAngka,
      };
      print('SERVICE (DosenNilaiService - submitNilai): Body: $body');

      final responseData = await _apiClient.put('dosen/nilai', body: body);

      if (responseData != null && responseData['nilai'] != null) {
        return Nilai.fromJson(responseData);
      } else {
        throw Exception('Gagal menyimpan nilai atau respons API tidak valid.');
      }
    } catch (e) {
      print('SERVICE (DosenNilaiService - submitNilai): Error: $e');
      throw Exception('Gagal menyimpan nilai: $e');
    }
  }
}
