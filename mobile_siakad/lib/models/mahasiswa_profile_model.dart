class MahasiswaProfile {
  final int idMahasiswa;
  final int userId;
  final String nrp;
  final String nama;
  final String? email;
  final String? prodi; 
  final String? kelas; 
  final String? tahunAjaranKelas;
  final String? dosenWali;
  final String ipkKumulatif; 
  final int batasSksSemesterIni;
  final String? createdAt;
  final String? updatedAt;

  MahasiswaProfile({
    required this.idMahasiswa,
    required this.userId,
    required this.nrp,
    required this.nama,
    this.email,
    this.prodi,
    this.kelas,
    this.tahunAjaranKelas,
    this.dosenWali,
    required this.ipkKumulatif,
    required this.batasSksSemesterIni,
    this.createdAt,
    this.updatedAt,
  });

  factory MahasiswaProfile.fromJson(Map<String, dynamic> json) {

    String? parseStringSafe(dynamic value) {
      if (value == null) return null;
      return value.toString();
    }
    int parseIntSafe(dynamic value, {int defaultValue = 0}) {
      if (value == null) return defaultValue;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? defaultValue;
      if (value is double) return value.toInt();
      return defaultValue;
    }

    return MahasiswaProfile(
      idMahasiswa: parseIntSafe(json['id_mahasiswa']),
      userId: parseIntSafe(json['user_id']),
      nrp: parseStringSafe(json['nrp']) ?? 'N/A',
      nama: parseStringSafe(json['nama']) ?? 'N/A',
      email: parseStringSafe(json['email']),
      prodi: parseStringSafe(json['prodi']),
      kelas: parseStringSafe(json['kelas']),
      tahunAjaranKelas: parseStringSafe(json['tahun_ajaran_kelas']),
      dosenWali: parseStringSafe(json['dosen_wali']),
      ipkKumulatif: parseStringSafe(json['ipk_kumulatif']) ?? '0.00',
      batasSksSemesterIni: parseIntSafe(json['batas_sks_semester_ini'], defaultValue: 24),
      createdAt: parseStringSafe(json['created_at']),
      updatedAt: parseStringSafe(json['updated_at']),
    );
  }
}

class GetMahasiswaProfileResponse {
  final MahasiswaProfile profile;
  final String message;

  GetMahasiswaProfileResponse({required this.profile, required this.message});

  factory GetMahasiswaProfileResponse.fromJson(Map<String, dynamic> json) {
    return GetMahasiswaProfileResponse(
      profile: MahasiswaProfile.fromJson(json['profile'] as Map<String, dynamic>? ?? {}),
      message: json['message'] as String? ?? '',
    );
  }
}