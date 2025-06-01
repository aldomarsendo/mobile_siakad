import 'package:mobile_siakad/models/berita_model.dart';
import 'package:mobile_siakad/services/api_client.dart';
import 'package:mobile_siakad/services/auth_service.dart';

class MahasiswaBeritaService {
  final AuthService _authService;
  final ApiClient _apiClient;

  MahasiswaBeritaService(this._authService, this._apiClient);

  Future<BeritaResponse> getBerita({int page = 1}) async {
    try {
      final jsonResponse = await _apiClient.get('mahasiswa/berita?page=$page');
      
      print('MahasiswaBeritaService - API Response (List): $jsonResponse');
      
      if (jsonResponse is Map<String, dynamic>) {
        // Asumsi BeritaResponse.fromJson bisa menangani struktur respons API berita mahasiswa
        return BeritaResponse.fromJson(jsonResponse);
      } else {
        throw Exception('Format respons API tidak valid');
      }
      
    } catch (e) {
      print('Error di MahasiswaBeritaService.getBerita: $e');
      // Error handling spesifik bisa dipertahankan atau disesuaikan
      if (e.toString().contains('401') || e.toString().contains('Unauthorized')) {
        throw Exception('Sesi telah berakhir. Silakan login kembali.');
      } else if (e.toString().contains('500')) {
        throw Exception('Terjadi kesalahan pada server. Silakan coba lagi nanti.');
      } else if (e.toString().contains('network') || e.toString().contains('connection')) {
        throw Exception('Tidak dapat terhubung ke server. Periksa koneksi internet Anda.');
      }
      // Lempar ulang error jika tidak ditangani secara spesifik
      rethrow; 
    }
  }

  Future<Berita> getBeritaBySlug(String slug) async {
    try {
      final jsonResponse = await _apiClient.get('mahasiswa/berita/$slug');
      
      if (jsonResponse is! Map<String, dynamic>) {
        throw Exception('Format respons API tidak valid');
      }
      
      final responseMap = jsonResponse; // Sudah pasti Map<String, dynamic>
      
      // Logika parsing yang kompleks ini dipertahankan,
      // dengan asumsi API detail berita mahasiswa juga bisa memiliki struktur yang bervariasi.
      // Jika API mahasiswa lebih konsisten, bagian ini bisa disederhanakan.
      Map<String, dynamic>? beritaData;
      
      if (responseMap.containsKey('berita') && responseMap['berita'] is Map<String, dynamic>) {
        beritaData = responseMap['berita'] as Map<String, dynamic>;
      } else if (responseMap.containsKey('data') && responseMap['data'] is Map<String, dynamic>) {
        beritaData = responseMap['data'] as Map<String, dynamic>;
      } else if (responseMap.containsKey('id')) { // Cek jika respons adalah objek berita langsung
        beritaData = responseMap;
      }
      
      if (beritaData != null) {
        return Berita.fromJson(beritaData);
      } else {
        print('Error: Data berita tidak ditemukan dalam respons.');
        print('Struktur kunci respons: ${responseMap.keys.toList()}');
        print('Respons penuh: $responseMap');
        // Gunakan BeritaNotFoundException jika tersedia dan relevan
        throw BeritaNotFoundException('Data berita (Slug: $slug) tidak ditemukan dalam respons server.');
      }
      
    } catch (e) {
      print('Error di MahasiswaBeritaService.getBeritaBySlug: $e');
      
      if (e is BeritaNotFoundException) rethrow; // Lempar ulang jika sudah BeritaNotFoundException

      // Penanganan error spesifik
      if (e.toString().contains('404') || 
          e.toString().contains('No query results') ||
          e.toString().contains('tidak ditemukan')) {
        throw BeritaNotFoundException('Berita dengan slug $slug tidak ditemukan.');
      } else if (e.toString().contains('401') || e.toString().contains('Unauthorized')) {
        throw Exception('Sesi telah berakhir. Silakan login kembali.');
      } else if (e.toString().contains('403') || e.toString().contains('Forbidden')) {
        throw Exception('Anda tidak memiliki akses untuk melihat berita ini.');
      } else if (e.toString().contains('500')) {
        throw Exception('Terjadi kesalahan pada server. Silakan coba lagi nanti.');
      } else if (e.toString().contains('network') || e.toString().contains('connection')) {
        throw Exception('Tidak dapat terhubung ke server. Periksa koneksi internet Anda.');
      }
      
      rethrow;
    }
  }

  Future<bool> checkBeritaExists(String slug) async {
    try {
      await getBeritaBySlug(slug);
      return true;
    } catch (e) {
      if (e is BeritaNotFoundException) {
        return false;
      }
      // Pertimbangkan kembali logika ini: apakah error lain harus dianggap 'exists'?
      // Mungkin lebih baik melempar ulang error lain atau mengembalikan false.
      // Untuk saat ini, saya pertahankan logika Anda.
      print('checkBeritaExists encountered an error other than NotFound: $e. Assuming exists for now.');
      return true; 
    }
  }

  Future<Berita?> getBeritaFromList(String slug) async {
    try {
      final response = await getBerita(); 
      return response.data.firstWhere(
        (berita) => berita.slug == slug,
        // orElse: () => throw BeritaNotFoundException('Berita tidak ditemukan dalam daftar halaman pertama'),
      );
    } catch (e) {
      // Jika error (termasuk jika tidak ditemukan oleh firstWhere tanpa orElse), kembalikan null
      print('Error di getBeritaFromList atau berita tidak ditemukan: $e');
      return null;
    }
  }

  Future<Berita> getBeritaByIdWithFallback(String slug) async {
    try {
      return await getBeritaBySlug(slug);
    } catch (e) {
      if (e is BeritaNotFoundException) {
        print('getBeritaByIdWithFallback: Gagal via API langsung, mencoba dari list...');
        final beritaFromList = await getBeritaFromList(slug);
        if (beritaFromList != null) {
          return beritaFromList;
        }
      }
      rethrow; 
    }
  }
}

class BeritaNotFoundException implements Exception {
  final String message;
  BeritaNotFoundException(this.message);
  
  @override
  String toString() => message;
}
