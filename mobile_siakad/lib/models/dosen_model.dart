// lib/models/dosen_model.dart
import 'package:flutter/foundation.dart'; // Untuk @immutable dan listEquals
import 'package:mobile_siakad/models/mahasiswa_model.dart'; // Pastikan ini mengimpor Kelas dan DosenWali jika digunakan oleh Kelas

// Model Kelas (jika belum ada atau untuk referensi jika diimpor dari mahasiswa_model.dart)
// Pastikan definisi Kelas yang digunakan konsisten.
// Jika Kelas sudah ada di mahasiswa_model.dart dan diimpor dengan benar, Anda tidak perlu duplikasi ini.
// Namun, untuk kejelasan, saya sertakan contoh minimal.
/*
@immutable
class Kelas {
  final int idKelas;
  final String namaKelas;
  final String status;
  final int idDosenWali;
  final String createdAt;
  final String updatedAt;
  final DosenWali? dosenWali; // Objek DosenWali untuk kelas ini

  const Kelas({
    required this.idKelas,
    required this.namaKelas,
    required this.status,
    required this.idDosenWali,
    required this.createdAt,
    required this.updatedAt,
    this.dosenWali,
  });

  factory Kelas.fromJson(Map<String, dynamic> json) {
    return Kelas(
      idKelas: json['id_kelas'] as int? ?? 0,
      namaKelas: json['nama_kelas'] as String? ?? 'N/A',
      status: json['status'] as String? ?? 'N/A',
      idDosenWali: json['id_dosen_wali'] as int? ?? 0,
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
      dosenWali: json['dosen_wali'] != null
          ? DosenWali.fromJson(json['dosen_wali'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_kelas': idKelas,
      'nama_kelas': namaKelas,
      'status': status,
      'id_dosen_wali': idDosenWali,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'dosen_wali': dosenWali?.toJson(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Kelas &&
        other.idKelas == idKelas &&
        other.namaKelas == namaKelas &&
        other.status == status &&
        other.idDosenWali == idDosenWali &&
        other.dosenWali == dosenWali; // Perbandingan objek dosenWali juga
  }

  @override
  int get hashCode => 
    idKelas.hashCode ^ 
    namaKelas.hashCode ^ 
    status.hashCode ^ 
    idDosenWali.hashCode ^
    dosenWali.hashCode;
}

@immutable
class DosenWali {
  final int idDosen;
  final int userId;
  final String nidn;
  final bool isDosenWali;
  // Tambahkan field lain jika ada dari JSON API
  // final String? name; 

  const DosenWali({
    required this.idDosen,
    required this.userId,
    required this.nidn,
    required this.isDosenWali,
    // this.name,
  });

  factory DosenWali.fromJson(Map<String, dynamic> json) {
    return DosenWali(
      idDosen: json['id_dosen'] as int? ?? 0,
      userId: json['user_id'] as int? ?? 0,
      nidn: json['nidn'] as String? ?? '',
      isDosenWali: (json['is_dosen_wali'] == 1 || json['is_dosen_wali'] == true),
      // name: json['user']?['name'] as String?, // Contoh jika nama ada di nested 'user'
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_dosen': idDosen,
      'user_id': userId,
      'nidn': nidn,
      'is_dosen_wali': isDosenWali,
      // 'name': name,
    };
  }
   @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DosenWali &&
        other.idDosen == idDosen &&
        other.userId == userId &&
        other.nidn == nidn &&
        other.isDosenWali == isDosenWali;
  }

  @override
  int get hashCode => idDosen.hashCode ^ userId.hashCode ^ nidn.hashCode ^ isDosenWali.hashCode;
}
*/


@immutable
class Dosen {
  final int idDosen;
  final int userId;
  final String nidn;
  final String name;
  final String email;
  final bool isDosenWali;
  final String? tanggalLahir;
  final String? jenisKelamin;
  final List<Kelas>? kelasWali; 
  final String createdAt;
  final String updatedAt;

  const Dosen({
    required this.idDosen,
    required this.userId,
    required this.nidn,
    required this.name,
    required this.email,
    required this.isDosenWali,
    this.tanggalLahir,
    this.jenisKelamin,
    this.kelasWali,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Dosen.fromJson(Map<String, dynamic> json) {
    List<Kelas>? parsedKelasWali;
    if (json['is_dosen_wali'] == true && json['kelas_wali'] != null && json['kelas_wali'] is List) {
      if ((json['kelas_wali'] as List).isNotEmpty && (json['kelas_wali'] as List).first is Map<String,dynamic>) {
         parsedKelasWali = (json['kelas_wali'] as List)
          .map((kelasJson) => Kelas.fromJson(kelasJson as Map<String, dynamic>))
          .toList();
      } else if ((json['kelas_wali'] as List).isEmpty) {
        parsedKelasWali = [];
      }
    }

    return Dosen(
      idDosen: json['id_dosen'] as int? ?? 0,
      userId: json['user_id'] as int? ?? 0,
      nidn: json['nidn']?.toString() ?? '',
      name: json['nama']?.toString() ?? '', 
      email: json['email']?.toString() ?? '',
      isDosenWali: (json['is_dosen_wali'] == 1 || json['is_dosen_wali'] == true),
      tanggalLahir: json['tanggal_lahir']?.toString(),
      jenisKelamin: json['jenis_kelamin']?.toString(),
      kelasWali: parsedKelasWali,
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_dosen': idDosen,
      'user_id': userId,
      'nidn': nidn,
      'nama': name, 
      'email': email,
      'is_dosen_wali': isDosenWali,
      'tanggal_lahir': tanggalLahir,
      'jenis_kelamin': jenisKelamin,
      'kelas_wali': kelasWali?.map((kelas) => kelas.toJson()).toList(),
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  Dosen copyWith({
    int? idDosen,
    int? userId,
    String? nidn,
    String? name,
    String? email,
    bool? isDosenWali,
    ValueGetter<String?>? tanggalLahir, // Menggunakan ValueGetter untuk nullable
    ValueGetter<String?>? jenisKelamin,
    ValueGetter<List<Kelas>?>? kelasWali,
    String? createdAt,
    String? updatedAt,
  }) {
    return Dosen(
      idDosen: idDosen ?? this.idDosen,
      userId: userId ?? this.userId,
      nidn: nidn ?? this.nidn,
      name: name ?? this.name,
      email: email ?? this.email,
      isDosenWali: isDosenWali ?? this.isDosenWali,
      tanggalLahir: tanggalLahir != null ? tanggalLahir() : this.tanggalLahir,
      jenisKelamin: jenisKelamin != null ? jenisKelamin() : this.jenisKelamin,
      kelasWali: kelasWali != null ? kelasWali() : this.kelasWali,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Dosen(idDosen: $idDosen, userId: $userId, nidn: $nidn, name: $name, email: $email, isDosenWali: $isDosenWali, tanggalLahir: $tanggalLahir, jenisKelamin: $jenisKelamin, kelasWali: $kelasWali, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is Dosen &&
      other.idDosen == idDosen &&
      other.userId == userId &&
      other.nidn == nidn &&
      other.name == name &&
      other.email == email &&
      other.isDosenWali == isDosenWali &&
      other.tanggalLahir == tanggalLahir &&
      other.jenisKelamin == jenisKelamin &&
      listEquals(other.kelasWali, kelasWali) && // Untuk perbandingan list
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return idDosen.hashCode ^
      userId.hashCode ^
      nidn.hashCode ^
      name.hashCode ^
      email.hashCode ^
      isDosenWali.hashCode ^
      tanggalLahir.hashCode ^
      jenisKelamin.hashCode ^
      kelasWali.hashCode ^ // hashCode untuk list bisa sederhana atau menggunakan kombinasi dari elemennya
      createdAt.hashCode ^
      updatedAt.hashCode;
  }
}
