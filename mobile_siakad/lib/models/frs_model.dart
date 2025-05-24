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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }

  @override
  String toString() {
    return 'FrsUser(id: $id, name: $name, email: $email)';
  }
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

  Map<String, dynamic> toJson() {
    return {
      'id_dosen': idDosen,
      'nidn': nidn,
      'user': user.toJson(),
    };
  }

   @override
  String toString() {
    return 'FrsDosen(idDosen: $idDosen, nidn: $nidn, user: ${user.toString()})';
  }
}

// Kelas untuk merepresentasikan informasi Matakuliah yang terkait dengan FRS
class FrsMatakuliah {
  final int idMk;        // Biasanya 'id_mk' atau 'id_matakuliah' di JSON
  final String kodeMk;
  final String namaMk;
  final int sks;
  final FrsDosen? dosen; // Dosen bisa jadi tidak selalu ada atau tidak selengkap ini di semua response

  FrsMatakuliah({
    required this.idMk,
    required this.kodeMk,
    required this.namaMk,
    required this.sks,
    this.dosen,
  });

  factory FrsMatakuliah.fromJson(Map<String, dynamic> json) {
    return FrsMatakuliah(
      // Backend mungkin mengembalikan 'id_mk' atau 'id_matakuliah' untuk primary key matakuliah.
      idMk: json['id_mk'] as int? ?? json['id_matakuliah'] as int? ?? 0,
      kodeMk: json['kode_mk'] as String? ?? 'N/A',
      namaMk: json['nama_mk'] as String? ?? 'N/A',
      sks: json['sks'] as int? ?? 0,
      dosen: json['dosen'] != null
          ? FrsDosen.fromJson(json['dosen'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_mk': idMk,
      'kode_mk': kodeMk,
      'nama_mk': namaMk,
      'sks': sks,
      'dosen': dosen?.toJson(),
    };
  }

   @override
  String toString() {
    return 'FrsMatakuliah(idMk: $idMk, kodeMk: $kodeMk, namaMk: $namaMk, sks: $sks, dosen: ${dosen?.toString()})';
  }
}

// Kelas untuk merepresentasikan informasi Mahasiswa yang terkait dengan FRS
class FrsMahasiswa {
  final int idMahasiswa;
  final String nrp;
  // Tambahkan field lain dari model Mahasiswa jika ada di JSON dan dibutuhkan
  // final int? idKelas;
  final FrsUser user; // Informasi user dari mahasiswa

  FrsMahasiswa({
    required this.idMahasiswa,
    required this.nrp,
    // this.idKelas,
    required this.user,
  });

  factory FrsMahasiswa.fromJson(Map<String, dynamic> json) {
    return FrsMahasiswa(
      idMahasiswa: json['id_mahasiswa'] as int? ?? 0,
      nrp: json['nrp'] as String? ?? 'N/A',
      // idKelas: json['id_kelas'] as int?,
      user: FrsUser.fromJson(json['user'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_mahasiswa': idMahasiswa,
      'nrp': nrp,
      // 'id_kelas': idKelas,
      'user': user.toJson(),
    };
  }

  @override
  String toString() {
    return 'FrsMahasiswa(idMahasiswa: $idMahasiswa, nrp: $nrp, user: ${user.toString()})';
  }
}

// Kelas utama untuk FRS (atau bisa dinamakan FrsDetail, FrsData, dll.)
class FrsItem {
  final int idFrs;
  final int idMahasiswaFk; // Foreign key id_mahasiswa dari tabel frs
  final int idMatakuliahFk; // Foreign key id_matakuliah dari tabel frs
  final String status;
  final FrsMahasiswa mahasiswa;    // Objek detail mahasiswa
  final FrsMatakuliah matakuliah; // Objek detail matakuliah
  final String? createdAt;
  final String? updatedAt;
  // Anda bisa menambahkan field lain dari tabel FRS jika ada, contoh:
  // final String? semesterDiambil;
  // final String? tahunAjaran;

  FrsItem({
    required this.idFrs,
    required this.idMahasiswaFk,
    required this.idMatakuliahFk,
    required this.status,
    required this.mahasiswa,
    required this.matakuliah,
    this.createdAt,
    this.updatedAt,
    // this.semesterDiambil,
    // this.tahunAjaran,
  });

  factory FrsItem.fromJson(Map<String, dynamic> json) {
    return FrsItem(
      idFrs: json['id_frs'] as int? ?? 0,
      // Eloquent biasanya tetap menyertakan foreign key di model utama
      // meskipun relasinya sudah di-load.
      idMahasiswaFk: json['id_mahasiswa'] as int? ?? 0,
      idMatakuliahFk: json['id_matakuliah'] as int? ?? 0,
      status: json['status'] as String? ?? 'pending',
      mahasiswa: FrsMahasiswa.fromJson(json['mahasiswa'] as Map<String, dynamic>? ?? {}),
      matakuliah: FrsMatakuliah.fromJson(json['matakuliah'] as Map<String, dynamic>? ?? {}),
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      // semesterDiambil: json['semester_diambil'] as String?,
      // tahunAjaran: json['tahun_ajaran'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_frs': idFrs,
      'id_mahasiswa': idMahasiswaFk,
      'id_matakuliah': idMatakuliahFk,
      'status': status,
      'mahasiswa': mahasiswa.toJson(),
      'matakuliah': matakuliah.toJson(),
      'created_at': createdAt,
      'updated_at': updatedAt,
      // 'semester_diambil': semesterDiambil,
      // 'tahun_ajaran': tahunAjaran,
    };
  }

   @override
  String toString() {
    return 'FrsItem(idFrs: $idFrs, status: $status, mahasiswa: ${mahasiswa.toString()}, matakuliah: ${matakuliah.toString()}, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}