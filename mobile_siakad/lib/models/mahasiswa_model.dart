class Mahasiswa {
  final int idMahasiswa;
  final int userId;
  final int idKelas;
  final String nrp;
  final String nama;
  final String prodi;
  final String? email; // Added
  final String? noHp; // Added
  final String? alamat; // Added
  final String createdAt;
  final String updatedAt;
  final Kelas? kelas;

  Mahasiswa({
    required this.idMahasiswa,
    required this.userId,
    required this.idKelas,
    required this.nrp,
    required this.nama,
    required this.prodi,
    this.email,
    this.noHp,
    this.alamat,
    required this.createdAt,
    required this.updatedAt,
    this.kelas,
  });

  factory Mahasiswa.fromJson(Map<String, dynamic> json) {
    return Mahasiswa(
      idMahasiswa: json['id_mahasiswa'],
      userId: json['user_id'],
      idKelas: json['id_kelas'],
      nrp: json['nrp'],
      nama: json['nama'],
      prodi: json['prodi'],
      email: json['email']?.toString(),
      noHp: json['no_hp']?.toString(),
      alamat: json['alamat']?.toString(),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      kelas: json['kelas'] != null ? Kelas.fromJson(json['kelas']) : null,
    );
  }
}

class Kelas {
  final int idKelas;
  final String namaKelas;
  final String status;
  final int idDosenWali;
  final String createdAt;
  final String updatedAt;
  final DosenWali? dosenWali;

  Kelas({
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
      idKelas: json['id_kelas'],
      namaKelas: json['nama_kelas'],
      status: json['status'],
      idDosenWali: json['id_dosen_wali'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      dosenWali: json['dosen_wali'] != null
          ? DosenWali.fromJson(json['dosen_wali'])
          : null,
    );
  }
}

class DosenWali {
  final int idDosen;
  final int userId;
  final String nidn;
  final bool isDosenWali;
  final String createdAt;
  final String updatedAt;

  DosenWali({
    required this.idDosen,
    required this.userId,
    required this.nidn,
    required this.isDosenWali,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DosenWali.fromJson(Map<String, dynamic> json) {
    return DosenWali(
      idDosen: json['id_dosen'],
      userId: json['user_id'],
      nidn: json['nidn'],
      isDosenWali: json['is_dosen_wali'] == 1,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}