class MataKuliah {
  final int idMk;
  final int idDosen;
  final int kelasId;
  final String kodeMk;
  final String namaMk;
  final int sks;
  final String semester;
  final String jamMulai;
  final String jamSelesai;
  final String hari;
  final int ruangId;
  final String createdAt;
  final String updatedAt;
  final Kelas kelas;
  final Ruang ruang;

  MataKuliah({
    required this.idMk,
    required this.idDosen,
    required this.kelasId,
    required this.kodeMk,
    required this.namaMk,
    required this.sks,
    required this.semester,
    required this.jamMulai,
    required this.jamSelesai,
    required this.hari,
    required this.ruangId,
    required this.createdAt,
    required this.updatedAt,
    required this.kelas,
    required this.ruang,
  });

  factory MataKuliah.fromJson(Map<String, dynamic> json) {
    return MataKuliah(
      idMk: json['id_mk'],
      idDosen: json['id_dosen'],
      kelasId: json['kelas_id'],
      kodeMk: json['kode_mk'],
      namaMk: json['nama_mk'],
      sks: json['sks'],
      semester: json['semester'],
      jamMulai: json['jam_mulai'],
      jamSelesai: json['jam_selesai'],
      hari: json['hari'],
      ruangId: json['ruang_id'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      kelas: Kelas.fromJson(json['kelas']),
      ruang: Ruang.fromJson(json['ruang']),
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

  Kelas({
    required this.idKelas,
    required this.namaKelas,
    required this.status,
    required this.idDosenWali,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Kelas.fromJson(Map<String, dynamic> json) {
    return Kelas(
      idKelas: json['id_kelas'],
      namaKelas: json['nama_kelas'],
      status: json['status'],
      idDosenWali: json['id_dosen_wali'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}

class Ruang {
  final int id;
  final String namaRuang;
  final int kapasitas;
  final String createdAt;
  final String updatedAt;

  Ruang({
    required this.id,
    required this.namaRuang,
    required this.kapasitas,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Ruang.fromJson(Map<String, dynamic> json) {
    return Ruang(
      id: json['id'],
      namaRuang: json['nama_ruang'],
      kapasitas: json['kapasitas'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}
