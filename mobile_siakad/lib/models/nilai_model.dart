// lib/models/nilai_model.dart
import 'package:flutter/foundation.dart'; // Untuk @immutable, listEquals
import 'package:flutter/material.dart';  // Untuk TextEditingController
import 'package:mobile_siakad/models/frs_model.dart'; 
// Import User dari mahasiswa_model.dart jika MahasiswaNilaiEntry akan memiliki detail User
// import 'package:mobile_siakad/models/mahasiswa_model.dart'; 

/// Helper function to safely parse a value that might be a num or a String representation of a num.
int? _parseIntSafely(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) {
    // Coba parse sebagai int dulu
    int? intVal = int.tryParse(value);
    if (intVal != null) return intVal;
    // Jika gagal, coba parse sebagai double lalu toInt
    double? doubleVal = double.tryParse(value);
    if (doubleVal != null) return doubleVal.toInt();
  }
  return null; // Tidak bisa diparsing
}

@immutable
class Nilai {
  final int idNilai;
  final int idFrs;
  final int nilaiAngka;
  final String nilaiHuruf;
  final String statusPenilaian;
  final String? createdAt;
  final String? updatedAt;
  final FrsItem? frs; 

  const Nilai({
    required this.idNilai,
    required this.idFrs,
    required this.nilaiAngka,
    required this.nilaiHuruf,
    required this.statusPenilaian,
    this.createdAt,
    this.updatedAt,
    this.frs,
  });

  factory Nilai.fromJson(Map<String, dynamic> json) {
    final nilaiData = json['nilai'] is Map<String, dynamic> 
                      ? json['nilai'] as Map<String, dynamic> 
                      : json; 

    return Nilai(
      idNilai: nilaiData['id_nilai'] as int? ?? 0,
      idFrs: nilaiData['id_frs'] as int? ?? 0,
      nilaiAngka: _parseIntSafely(nilaiData['nilai_angka']) ?? 0, // Menggunakan helper
      nilaiHuruf: nilaiData['nilai_huruf'] as String? ?? '',
      statusPenilaian: nilaiData['status_penilaian'] as String? ?? 'belum_dinilai',
      createdAt: nilaiData['created_at'] as String?,
      updatedAt: nilaiData['updated_at'] as String?,
      frs: nilaiData['frs'] != null 
           ? FrsItem.fromJson(nilaiData['frs'] as Map<String, dynamic>) 
           : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_nilai': idNilai,
      'id_frs': idFrs,
      'nilai_angka': nilaiAngka,
      'nilai_huruf': nilaiHuruf,
      'status_penilaian': statusPenilaian,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'frs': frs?.toJson(),
    };
  }

  Nilai copyWith({
    int? idNilai,
    int? idFrs,
    int? nilaiAngka,
    String? nilaiHuruf,
    String? statusPenilaian,
    ValueGetter<String?>? createdAt,
    ValueGetter<String?>? updatedAt,
    ValueGetter<FrsItem?>? frs,
  }) {
    return Nilai(
      idNilai: idNilai ?? this.idNilai,
      idFrs: idFrs ?? this.idFrs,
      nilaiAngka: nilaiAngka ?? this.nilaiAngka,
      nilaiHuruf: nilaiHuruf ?? this.nilaiHuruf,
      statusPenilaian: statusPenilaian ?? this.statusPenilaian,
      createdAt: createdAt != null ? createdAt() : this.createdAt,
      updatedAt: updatedAt != null ? updatedAt() : this.updatedAt,
      frs: frs != null ? frs() : this.frs,
    );
  }

  @override
  String toString() {
    return 'Nilai(idNilai: $idNilai, idFrs: $idFrs, nilaiAngka: $nilaiAngka, nilaiHuruf: $nilaiHuruf, statusPenilaian: $statusPenilaian, createdAt: $createdAt, updatedAt: $updatedAt, frs: $frs)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is Nilai &&
      other.idNilai == idNilai &&
      other.idFrs == idFrs &&
      other.nilaiAngka == nilaiAngka &&
      other.nilaiHuruf == nilaiHuruf &&
      other.statusPenilaian == statusPenilaian &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt &&
      other.frs == frs;
  }

  @override
  int get hashCode {
    return idNilai.hashCode ^
      idFrs.hashCode ^
      nilaiAngka.hashCode ^
      nilaiHuruf.hashCode ^
      statusPenilaian.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode ^
      frs.hashCode;
  }
}

@immutable
class MahasiswaNilaiEntry {
  final int idMahasiswa;
  final String nrp;
  final String nama;
  final String prodi; 
  
  final int idFrs; 

  final int? nilaiAngkaAwal;
  final String? nilaiHurufAwal;
  final String statusPenilaianAwal;
  final int? idNilaiAwal;

  // Anotasi @JsonKey dihapus karena tidak menggunakan json_serializable
  final TextEditingController nilaiAngkaController;
  final String? nilaiHurufDisplay; 
  final bool isSaving;

  MahasiswaNilaiEntry({
    required this.idMahasiswa,
    required this.nrp,
    required this.nama,
    required this.prodi,
    required this.idFrs,
    this.nilaiAngkaAwal,
    this.nilaiHurufAwal,
    required this.statusPenilaianAwal,
    this.idNilaiAwal,
    TextEditingController? nilaiAngkaController,
    this.nilaiHurufDisplay,
    this.isSaving = false,
  }) : nilaiAngkaController = nilaiAngkaController ?? TextEditingController(text: nilaiAngkaAwal?.toString() ?? '');

  factory MahasiswaNilaiEntry.fromJson(Map<String, dynamic> json) {
    int? parsedNilaiAngka = _parseIntSafely(json['nilai_angka']); // Menggunakan helper
    String? parsedNilaiHuruf = json['nilai_huruf'] as String?;

    return MahasiswaNilaiEntry(
      idMahasiswa: json['id_mahasiswa'] as int? ?? 0,
      nrp: json['nrp'] as String? ?? 'N/A',
      nama: json['nama'] as String? ?? 'N/A',
      prodi: json['prodi'] as String? ?? '', 
      
      idFrs: json['id_frs'] as int? ?? 0, // Pastikan ini tidak 0 jika id_frs wajib ada

      nilaiAngkaAwal: parsedNilaiAngka, 
      nilaiHurufAwal: parsedNilaiHuruf,
      statusPenilaianAwal: json['status_penilaian'] as String? ?? 'belum_dinilai',
      idNilaiAwal: json['id_nilai'] as int?,
      nilaiHurufDisplay: parsedNilaiHuruf,
    );
  }

  MahasiswaNilaiEntry copyWith({
    int? idMahasiswa,
    String? nrp,
    String? nama,
    String? prodi,
    int? idFrs,
    ValueGetter<int?>? nilaiAngkaAwal,
    ValueGetter<String?>? nilaiHurufAwal,
    String? statusPenilaianAwal,
    ValueGetter<int?>? idNilaiAwal,
    String? nilaiHurufDisplay, 
    bool? isSaving,
  }) {
    final newNilaiAngkaAwal = nilaiAngkaAwal != null ? nilaiAngkaAwal() : this.nilaiAngkaAwal;
    return MahasiswaNilaiEntry(
      idMahasiswa: idMahasiswa ?? this.idMahasiswa,
      nrp: nrp ?? this.nrp,
      nama: nama ?? this.nama,
      prodi: prodi ?? this.prodi,
      idFrs: idFrs ?? this.idFrs,
      nilaiAngkaAwal: newNilaiAngkaAwal,
      nilaiHurufAwal: nilaiHurufAwal != null ? nilaiHurufAwal() : this.nilaiHurufAwal,
      statusPenilaianAwal: statusPenilaianAwal ?? this.statusPenilaianAwal,
      idNilaiAwal: idNilaiAwal != null ? idNilaiAwal() : this.idNilaiAwal,
      nilaiAngkaController: TextEditingController(text: newNilaiAngkaAwal?.toString() ?? this.nilaiAngkaController.text),
      nilaiHurufDisplay: nilaiHurufDisplay ?? this.nilaiHurufDisplay,
      isSaving: isSaving ?? this.isSaving,
    );
  }

  @override
  String toString() {
    return 'MahasiswaNilaiEntry(idMahasiswa: $idMahasiswa, nrp: $nrp, nama: $nama, idFrs: $idFrs, nilaiAngkaAwal: $nilaiAngkaAwal, nilaiHurufDisplay: $nilaiHurufDisplay, isSaving: $isSaving)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is MahasiswaNilaiEntry &&
      other.idMahasiswa == idMahasiswa &&
      other.nrp == nrp &&
      other.nama == nama &&
      other.prodi == prodi &&
      other.idFrs == idFrs &&
      other.nilaiAngkaAwal == nilaiAngkaAwal &&
      other.nilaiHurufAwal == nilaiHurufAwal &&
      other.statusPenilaianAwal == statusPenilaianAwal &&
      other.idNilaiAwal == idNilaiAwal &&
      other.nilaiHurufDisplay == nilaiHurufDisplay &&
      other.isSaving == isSaving;
  }

  @override
  int get hashCode {
    return idMahasiswa.hashCode ^
      nrp.hashCode ^
      nama.hashCode ^
      prodi.hashCode ^
      idFrs.hashCode ^
      nilaiAngkaAwal.hashCode ^
      nilaiHurufAwal.hashCode ^
      statusPenilaianAwal.hashCode ^
      idNilaiAwal.hashCode ^
      nilaiHurufDisplay.hashCode ^
      isSaving.hashCode;
  }
}

// Definisi class JsonKey yang sebelumnya dikomentari telah dihapus sepenuhnya.
