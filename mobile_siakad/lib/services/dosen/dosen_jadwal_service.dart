import 'dart:convert';
import 'package:mobile_siakad/models/matakuliah_model.dart';
import 'package:mobile_siakad/services/auth_service.dart';
import 'package:mobile_siakad/services/api_client.dart';

class DosenJadwalService {
  final AuthService _authService;
  final ApiClient _apiClient;

  DosenJadwalService(this._authService, this._apiClient);

  Future<List<MataKuliah>> getMataKuliah({String? tahunAjaran, String? semester}) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('No token available. Silakan login terlebih dahulu.');
      }
      print('Token: $token');
      print('=== MULAI MENGAMBIL DATA MATA KULIAH ===');

      String endpoint = 'dosen/matakuliah';
      if (tahunAjaran != null || semester != null) {
        endpoint += '?';
        if (tahunAjaran != null) endpoint += 'tahun_ajaran=$tahunAjaran';
        if (semester != null) endpoint += '&semester=$semester';
      }

      final data = await _apiClient.get(endpoint); // Hapus parameter headers

      final List<dynamic> matakuliahList = data['matakuliah'];
      print('=== INFORMASI JADWAL DAN MATA KULIAH ===');
      print('Total mata kuliah: ${matakuliahList.length}');
      print('');

      for (var i = 0; i < matakuliahList.length; i++) {
        final mk = MataKuliah.fromJson(matakuliahList[i]);
        print('Mata Kuliah ${i + 1}:');
        print('Kode: ${mk.kodeMk}');
        print('Nama: ${mk.namaMk}');
        print('SKS: ${mk.sks}');
      }

      return matakuliahList.map((json) => MataKuliah.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching jadwal: ${e.toString()}');
      throw Exception('Error: ${e.toString()}');
    }
  }
}