import 'package:mobile_siakad/models/berita_model.dart';
import 'package:mobile_siakad/services/api_client.dart';
import 'package:mobile_siakad/services/auth_service.dart';

class DosenBeritaService {
  final AuthService _authService;
  final ApiClient _apiClient;

  DosenBeritaService(this._authService, this._apiClient);

  Future<BeritaResponse> getBerita({int page = 1}) async {
    try {
      final jsonResponse = await _apiClient.get('dosen/berita?page=$page');
      
      print('BeritaService - API Response: $jsonResponse');
      
      if (jsonResponse is Map<String, dynamic>) {
        return BeritaResponse.fromJson(jsonResponse);
      } else {
        throw Exception('Invalid response format from API');
      }
      
    } catch (e) {
      print('Error in BeritaService.getBerita: $e');
      if (e.toString().contains('401') || e.toString().contains('Unauthorized')) {
        throw Exception('Sesi telah berakhir. Silakan login kembali.');
      } else if (e.toString().contains('500')) {
        throw Exception('Terjadi kesalahan server. Silakan coba lagi nanti.');
      } else if (e.toString().contains('network') || e.toString().contains('connection')) {
        throw Exception('Tidak dapat terhubung ke server. Periksa koneksi internet Anda.');
      }
      rethrow;
    }
  }

  Future<Berita> getBeritaBySlug(String slug) async {
    try {
      print('BeritaService - Fetching berita with slug: $slug');
      
      final jsonResponse = await _apiClient.get('dosen/berita/$slug');
      
      print('BeritaService - API Response Detail: $jsonResponse');
      
      if (jsonResponse is! Map<String, dynamic>) {
        throw Exception('Invalid response format from API');
      }
      
      final responseMap = jsonResponse as Map<String, dynamic>;
      
      // Check various possible response structures
      Map<String, dynamic>? beritaData;
      
      if (responseMap.containsKey('berita') && responseMap['berita'] != null) {
        beritaData = responseMap['berita'] as Map<String, dynamic>;
      } else if (responseMap.containsKey('data') && responseMap['data'] != null) {
        beritaData = responseMap['data'] as Map<String, dynamic>;
      } else if (responseMap.containsKey('id')) {
        // Direct berita object without wrapper
        beritaData = responseMap;
      }
      
      if (beritaData != null) {
        return Berita.fromJson(beritaData);
      } else {
        print('Error: Berita data not found in response');
        print('Response structure: ${responseMap.keys.toList()}');
        print('Full response: $responseMap');
        throw Exception('Data berita tidak ditemukan dalam respons server.');
      }
      
    } catch (e) {
      print('Error in BeritaService.getBeritaBySlug: $e');
      
      // Handle specific error cases
      if (e.toString().contains('404') || 
          e.toString().contains('No query results') ||
          e.toString().contains('tidak ditemukan')) {
        throw BeritaNotFoundException('Berita dengan slug $slug tidak ditemukan atau telah dihapus.');
      } else if (e.toString().contains('401') || e.toString().contains('Unauthorized')) {
        throw Exception('Sesi telah berakhir. Silakan login kembali.');
      } else if (e.toString().contains('403') || e.toString().contains('Forbidden')) {
        throw Exception('Anda tidak memiliki akses untuk melihat berita ini.');
      } else if (e.toString().contains('500')) {
        throw Exception('Terjadi kesalahan server. Silakan coba lagi nanti.');
      } else if (e.toString().contains('network') || e.toString().contains('connection')) {
        throw Exception('Tidak dapat terhubung ke server. Periksa koneksi internet Anda.');
      }
      
      rethrow;
    }
  }

  // Enhanced method to validate if berita exists before navigation
  Future<bool> checkBeritaExists(String slug) async {
    try {
      await getBeritaBySlug(slug);
      return true;
    } catch (e) {
      if (e is BeritaNotFoundException) {
        return false;
      }
      // For other errors (network, auth, etc.), we assume the berita might exist
      // but there's a temporary issue, so we return true to allow the attempt
      return true;
    }
  }

  // Alternative method: Try to get berita from the cached list first
  Future<Berita?> getBeritaFromList(String slug) async {
    try {
      final response = await getBerita();
      return response.data.firstWhere(
        (berita) => berita.slug == slug,
        orElse: () => throw BeritaNotFoundException('Berita tidak ditemukan dalam daftar'),
      );
    } catch (e) {
      return null;
    }
  }

  // Hybrid method: Try to get from API first, fallback to list
  Future<Berita> getBeritaBySlugWithFallback(String slug) async {
    try {
      // First try the direct API call
      return await getBeritaBySlug(slug);
    } catch (e) {
      if (e is BeritaNotFoundException) {
        // If not found via direct API, try to get from the list
        final beritaFromList = await getBeritaFromList(slug);
        if (beritaFromList != null) {
          return beritaFromList;
        }
      }
      rethrow;
    }
  }
}

// Custom exception for better error handling
class BeritaNotFoundException implements Exception {
  final String message;
  BeritaNotFoundException(this.message);
  
  @override
  String toString() => message;
}