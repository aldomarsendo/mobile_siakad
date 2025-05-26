import 'dart:convert';

// --- Helper Classes (FrsUser, FrsDosen sudah baik) ---
class FrsUser {
  final int id;
  final String name;
  final String? email;

  FrsUser({
    required this.id,
    required this.name,
    this.email,
  });

  factory FrsUser.fromJson(Map<String, dynamic> json) {
    return FrsUser(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'N/A',
      email: json['email'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
      };
}

class FrsDosen {
  final int idDosen;
  final String nidn;
  final FrsUser user;

  FrsDosen({
    required this.idDosen,
    required this.nidn,
    required this.user,
  });

  factory FrsDosen.fromJson(Map<String, dynamic> json) {
    return FrsDosen(
      idDosen: json['id_dosen'] as int? ?? 0,
      nidn: json['nidn'] as String? ?? 'N/A',
      user: FrsUser.fromJson(json['user'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
        'id_dosen': idDosen,
        'nidn': nidn,
        'user': user.toJson(),
      };
}

// --- FrsMasterMatakuliah (Menggantikan FrsMatakuliah untuk kejelasan) ---
// Model ini khusus untuk data dari 'master_matakuliah'
class FrsMasterMatakuliah {
  final int idMasterMk;
  final String kodeMk;
  final String namaMk;
  final int sks;

  FrsMasterMatakuliah({
    required this.idMasterMk,
    required this.kodeMk,
    required this.namaMk,
    required this.sks,
  });

  factory FrsMasterMatakuliah.fromJson(Map<String, dynamic> json) {
    return FrsMasterMatakuliah(
      idMasterMk: json['id_master_mk'] as int? ?? json['id_mk'] as int? ?? 0, // Sesuaikan dengan key ID dari master_matakuliah
      kodeMk: json['kode_mk'] as String? ?? 'N/A',
      namaMk: json['nama_mk'] as String? ?? 'N/A',
      sks: json['sks_total'] as int? ?? json['sks'] as int? ?? 0, // API Laravel Anda mungkin mengembalikan sks_total
    );
  }

  Map<String, dynamic> toJson() => {
        'id_master_mk': idMasterMk,
        'kode_mk': kodeMk,
        'nama_mk': namaMk,
        'sks': sks,
      };
}

// --- FrsJadwalKuliah (Model untuk objek 'jadwal_kuliah') ---
class FrsJadwalKuliah {
  final int idJadwal; // atau id_mk jika itu ID dari tabel jadwal_kuliah
  final FrsMasterMatakuliah? masterMatakuliah;
  final FrsDosen? dosen; // Dosen pengampu untuk jadwal ini
  // Tambahkan field lain dari jadwal_kuliah jika perlu (hari, jam, ruang, dll.)
  // final String? hari;
  // final String? jamMulai;

  FrsJadwalKuliah({
    required this.idJadwal,
    this.masterMatakuliah,
    this.dosen,
    // this.hari,
    // this.jamMulai,
  });

  factory FrsJadwalKuliah.fromJson(Map<String, dynamic> json) {
    return FrsJadwalKuliah(
      idJadwal: json['id_mk'] as int? ?? 0, // Asumsi 'id_mk' adalah ID dari jadwal_kuliah
      masterMatakuliah: json['master_matakuliah'] != null
          ? FrsMasterMatakuliah.fromJson(json['master_matakuliah'] as Map<String, dynamic>)
          : null,
      dosen: json['dosen'] != null
          ? FrsDosen.fromJson(json['dosen'] as Map<String, dynamic>)
          : null,
      // hari: json['hari'] as String?,
      // jamMulai: json['jam_mulai'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id_mk': idJadwal,
        'master_matakuliah': masterMatakuliah?.toJson(),
        'dosen': dosen?.toJson(),
        // 'hari': hari,
        // 'jam_mulai': jamMulai,
      };
}


// --- FrsMahasiswa (Sudah baik) ---
class FrsMahasiswa {
  final int idMahasiswa;
  final String nrp;
  final FrsUser user;

  FrsMahasiswa({
    required this.idMahasiswa,
    required this.nrp,
    required this.user,
  });

  factory FrsMahasiswa.fromJson(Map<String, dynamic> json) {
    return FrsMahasiswa(
      idMahasiswa: json['id_mahasiswa'] as int? ?? 0,
      nrp: json['nrp'] as String? ?? json['user']?['nim'] as String? ?? 'N/A', // Tambah fallback jika nrp tidak ada
      user: FrsUser.fromJson(json['user'] as Map<String, dynamic>? ?? {}),
    );
  }
   Map<String, dynamic> toJson() => {
        'id_mahasiswa': idMahasiswa,
        'nrp': nrp,
        'user': user.toJson(),
      };
}

// --- FrsItem (Model Utama) ---
class FrsItem {
  final int idFrs;
  final String status; // Ini adalah status FRS ('pending', 'disetujui', 'ditolak')
  final FrsMahasiswa? mahasiswa;
  final FrsJadwalKuliah? jadwalKuliah; // Objek jadwal kuliah yang terkait
  final String? createdAt;
  final String? updatedAt;
  // Foreign keys mungkin tidak perlu jika objek relasi sudah ada
  // final int idMahasiswaFk;
  // final int idMatakuliahFk; // Ini lebih merujuk ke id_jadwal_kuliah

  FrsItem({
    required this.idFrs,
    required this.status,
    this.mahasiswa,
    this.jadwalKuliah,
    this.createdAt,
    this.updatedAt,
    // required this.idMahasiswaFk,
    // required this.idMatakuliahFk,
  });

  factory FrsItem.fromJson(Map<String, dynamic> json) {
    return FrsItem(
      idFrs: json['id_frs'] as int? ?? 0,
      status: json['status'] as String? ?? 'pending', // Dari tabel FRS
      mahasiswa: json['mahasiswa'] != null
          ? FrsMahasiswa.fromJson(json['mahasiswa'] as Map<String, dynamic>)
          : null,
      jadwalKuliah: json['jadwal_kuliah'] != null
          ? FrsJadwalKuliah.fromJson(json['jadwal_kuliah'] as Map<String, dynamic>)
          : null,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      // idMahasiswaFk: json['id_mahasiswa'] as int? ?? 0,
      // idMatakuliahFk: json['id_jadwal_kuliah'] as int? ?? json['id_mk_jadwal'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id_frs': idFrs,
        'status': status,
        'mahasiswa': mahasiswa?.toJson(),
        'jadwal_kuliah': jadwalKuliah?.toJson(),
        'created_at': createdAt,
        'updated_at': updatedAt,
        // 'id_mahasiswa': idMahasiswaFk,
        // 'id_jadwal_kuliah': idMatakuliahFk,
      };
}
