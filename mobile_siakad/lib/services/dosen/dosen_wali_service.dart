//import 'dart:convert'; // Tidak perlu jika ApiClient sudah menangani decode
import 'package:mobile_siakad/models/mahasiswa_model.dart'; // Pastikan path ini benar
import 'package:mobile_siakad/services/api_client.dart';

class DosenWaliService {
  final ApiClient _apiClient;

  DosenWaliService(this._apiClient);

  Future<List<Mahasiswa>> getMahasiswaWali() async {
    try {
      final responseData = await _apiClient.get('dosen/mahasiswa-wali');
      
      // Cek apakah responseData adalah Map dan memiliki key 'data' yang berupa List
      if (responseData != null && responseData is Map<String, dynamic> && responseData['data'] != null && responseData['data'] is List) {
        final List<dynamic> kelasWrapperListJson = responseData['data'] as List<dynamic>;
        List<Mahasiswa> allMahasiswaWali = [];

        // Iterasi setiap item dalam list 'data'
        for (var kelasWrapperItem in kelasWrapperListJson) {
          if (kelasWrapperItem is Map<String, dynamic> && kelasWrapperItem['kelas'] != null && kelasWrapperItem['kelas'] is Map<String, dynamic>) {
            final Map<String, dynamic> kelasJson = kelasWrapperItem['kelas'] as Map<String, dynamic>;
            
            // Cek apakah ada list 'mahasiswa' di dalam objek 'kelas'
            if (kelasJson['mahasiswa'] != null && kelasJson['mahasiswa'] is List) {
              final List<dynamic> mahasiswaJsonListPerKelas = kelasJson['mahasiswa'] as List<dynamic>;
              
              // Iterasi setiap mahasiswa dalam satu kelas dan tambahkan ke list utama
              for (var mhsJson in mahasiswaJsonListPerKelas) {
                if (mhsJson is Map<String, dynamic>) {
                  // Parsing objek mahasiswa
                  // Pastikan Mahasiswa.fromJson sudah benar menangani struktur mhsJson ini
                  allMahasiswaWali.add(Mahasiswa.fromJson(mhsJson));
                }
              }
            }
          }
        }
        print('Berhasil memparsing ${allMahasiswaWali.length} mahasiswa wali.');
        return allMahasiswaWali; // Kembalikan gabungan list mahasiswa dari semua kelas wali
      } else {
        // Jika format tidak sesuai, cetak pesan error beserta data respons untuk debugging
        print('Data mahasiswa wali tidak ditemukan atau format tidak sesuai (struktur utama salah): $responseData');
        return []; // Kembalikan list kosong atau throw exception
      }
    } catch (e) {
      print('Error in DosenWaliService.getMahasiswaWali: $e');
      throw Exception('Gagal memuat data mahasiswa wali: $e');
    }
  }
}