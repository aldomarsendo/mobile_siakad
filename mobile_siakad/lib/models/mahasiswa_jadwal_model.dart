// lib/models/mahasiswa_jadwal_model.dart

// Helper functions
String? _parseStringSafe(dynamic value) {
  if (value == null) return null;
  // Handle cases where "null" string might be sent by API
  if (value is String && value.toLowerCase() == 'null') return null;
  return value.toString();
}

int _parseIntSafe(dynamic value, {int defaultValue = 0}) {
  if (value == null) return defaultValue;
  if (value is int) return value;
  if (value is String) {
    if (value.toLowerCase() == 'null') return defaultValue;
    return int.tryParse(value) ?? defaultValue;
  }
  if (value is double) return value.toInt(); // Allow parsing from double
  return defaultValue;
}

class MahasiswaJadwalItem {
  final int idMkJadwal;
  final String kodeMk;
  final String namaMk;
  final int sks;
  final String semester;
  final String hari;
  final String jamMulai;
  final String jamSelesai;
  final String dosenPengampu;
  final String ruang;
  final String kelasMatakuliah;
  final String prodiMk;

  MahasiswaJadwalItem({
    required this.idMkJadwal,
    required this.kodeMk,
    required this.namaMk,
    required this.sks,
    required this.semester,
    required this.hari,
    required this.jamMulai,
    required this.jamSelesai,
    required this.dosenPengampu,
    required this.ruang,
    required this.kelasMatakuliah,
    required this.prodiMk,
  });

  factory MahasiswaJadwalItem.fromJson(Map<String, dynamic> json) {
    return MahasiswaJadwalItem(
      idMkJadwal: _parseIntSafe(json['id_mk_jadwal']),
      kodeMk: _parseStringSafe(json['kode_mk']) ?? 'N/A',
      namaMk: _parseStringSafe(json['nama_mk']) ?? 'N/A',
      sks: _parseIntSafe(json['sks']),
      semester: _parseStringSafe(json['semester']) ?? 'N/A',
      hari: _parseStringSafe(json['hari']) ?? 'N/A',
      jamMulai: _parseStringSafe(json['jam_mulai']) ?? '--:--',
      jamSelesai: _parseStringSafe(json['jam_selesai']) ?? '--:--',
      dosenPengampu: _parseStringSafe(json['dosen_pengampu']) ?? 'N/A',
      ruang: _parseStringSafe(json['ruang']) ?? 'N/A',
      kelasMatakuliah: _parseStringSafe(json['kelas_matakuliah']) ?? 'N/A',
      prodiMk: _parseStringSafe(json['prodi_mk']) ?? 'N/A',
    );
  }

  Map<String, dynamic> toJson() => {
        'id_mk_jadwal': idMkJadwal,
        'kode_mk': kodeMk,
        'nama_mk': namaMk,
        'sks': sks,
        'semester': semester,
        'hari': hari,
        'jam_mulai': jamMulai,
        'jam_selesai': jamSelesai,
        'dosen_pengampu': dosenPengampu,
        'ruang': ruang,
        'kelas_matakuliah': kelasMatakuliah,
        'prodi_mk': prodiMk,
      };
  
  @override
  String toString() {
    return 'MahasiswaJadwalItem(id: $idMkJadwal, nama: $namaMk, hari: $hari, jam: $jamMulai-$jamSelesai)';
  }
}

class ApiMahasiswaJadwalResponse {
  final Map<String, List<MahasiswaJadwalItem>> jadwal; // Keyed by day name
  final String message;

  ApiMahasiswaJadwalResponse({
    required this.jadwal,
    required this.message,
  });

  factory ApiMahasiswaJadwalResponse.fromJson(Map<String, dynamic> json) {
    final Map<String, List<MahasiswaJadwalItem>> jadwalMap = {};
    
    // Check if 'jadwal' key exists and is a Map
    if (json['jadwal'] != null && json['jadwal'] is Map) {
      // Cast to Map<String, dynamic> for safety, though keys might be dynamic from API
      (json['jadwal'] as Map).forEach((hari, listJadwalJson) {
        if (listJadwalJson is List) {
          jadwalMap[hari.toString()] = listJadwalJson
              .map((itemJson) {
                // Ensure itemJson is correctly typed before passing to MahasiswaJadwalItem.fromJson
                if (itemJson is Map<String, dynamic>) {
                  return MahasiswaJadwalItem.fromJson(itemJson);
                } else if (itemJson is Map) { // Handle Map<dynamic, dynamic>
                  return MahasiswaJadwalItem.fromJson(Map<String, dynamic>.from(itemJson));
                }
                // Return a placeholder or throw error if itemJson is not a map
                // For now, let's filter out invalid items silently, or log an error
                print('ApiMahasiswaJadwalResponse: Invalid item format in jadwal list for day $hari: $itemJson');
                return null; 
              })
              .whereType<MahasiswaJadwalItem>() // Filter out nulls if any invalid items were skipped
              .toList();
        }
      });
    }
    
    return ApiMahasiswaJadwalResponse(
      jadwal: jadwalMap,
      message: _parseStringSafe(json['message']) ?? '',
    );
  }
}

// REMOVED erroneous import statements from the end of the file:
// import 'package:mobile_siakad/models/mahasiswa_jadwal_model.dart';
// import 'package:mobile_siakad/services/api_client.dart';
