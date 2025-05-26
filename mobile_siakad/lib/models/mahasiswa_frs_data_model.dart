import 'package:mobile_siakad/models/frs_model.dart'; 

class AvailableMatakuliahItem {
  final int idMkJadwal;
  final String kodeMk;
  final String namaMk;
  final int sks;
  final String? semesterDefault;
  final String? semesterPelaksanaan; 
  final String? dosenPengampu;
  final String? prodiMk;
  final String? ruang;
  final String? hari;
  final String? jamMulai;
  final String? jamSelesai;

  AvailableMatakuliahItem({
    required this.idMkJadwal,
    required this.kodeMk,
    required this.namaMk,
    required this.sks,
    this.semesterDefault,
    this.semesterPelaksanaan,
    this.dosenPengampu,
    this.prodiMk,
    this.ruang,
    this.hari,
    this.jamMulai,
    this.jamSelesai,
  });

  factory AvailableMatakuliahItem.fromJson(Map<String, dynamic> json) {
    // Helper untuk konversi aman ke String jika tipenya int
    String? _parseStringOrInt(dynamic value) {
      if (value == null) return null;
      if (value is String) return value;
      if (value is int || value is double || value is num) return value.toString();
      return value.toString(); // Fallback, mungkin perlu penanganan lebih
    }

    return AvailableMatakuliahItem(
      idMkJadwal: json['id_mk_jadwal'] as int? ?? 0,
      kodeMk: json['kode_mk'] as String? ?? 'N/A',
      namaMk: json['nama_mk'] as String? ?? 'N/A',
      sks: json['sks'] as int? ?? 0,
      semesterDefault: _parseStringOrInt(json['semester_default']),      // <-- PERBAIKAN
      semesterPelaksanaan: _parseStringOrInt(json['semester_pelaksanaan']),// <-- PERBAIKAN
      dosenPengampu: json['dosen_pengampu'] as String?, // Jika ini juga bisa angka, gunakan _parseStringOrInt
      prodiMk: json['prodi_mk'] as String?,
      ruang: json['ruang'] as String?,
      hari: json['hari'] as String?,
      jamMulai: json['jam_mulai'] as String?,
      jamSelesai: json['jam_selesai'] as String?,
    );
  }
}

// Model untuk membungkus respons dari getAvailableMatakuliah
class GetAvailableMatakuliahResponse {
  final List<AvailableMatakuliahItem> matakuliah;
  final String message;

  GetAvailableMatakuliahResponse({
    required this.matakuliah,
    required this.message,
  });

  factory GetAvailableMatakuliahResponse.fromJson(Map<String, dynamic> json) {
    var list = json['matakuliah'] as List? ?? [];
    List<AvailableMatakuliahItem> items = list.map((i) => AvailableMatakuliahItem.fromJson(i as Map<String, dynamic>)).toList();
    return GetAvailableMatakuliahResponse(
      matakuliah: items,
      message: json['message'] as String? ?? '',
    );
  }
}

// Model untuk membungkus respons dari getMyFRS
class GetMyFrsResponse {
  final List<FrsItem> frs; // Menggunakan FrsItem dari frs_model.dart
  final String message;

  GetMyFrsResponse({required this.frs, required this.message});

  factory GetMyFrsResponse.fromJson(Map<String, dynamic> json) {
    var list = json['frs'] as List? ?? [];
    List<FrsItem> items = list.map((i) => FrsItem.fromJson(i as Map<String, dynamic>)).toList();
    return GetMyFrsResponse(
      frs: items,
      message: json['message'] as String? ?? '',
    );
  }
}

// Model untuk membungkus respons dari createFRS
class CreateFrsResponse {
  final FrsItem frsItem; // Menggunakan FrsItem dari frs_model.dart
  final String message;

  CreateFrsResponse({required this.frsItem, required this.message});

  factory CreateFrsResponse.fromJson(Map<String, dynamic> json) {
    return CreateFrsResponse(
      frsItem: FrsItem.fromJson(json['frs_item'] as Map<String, dynamic>? ?? {}),
      message: json['message'] as String? ?? '',
    );
  }
}

