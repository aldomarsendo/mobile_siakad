// lib/models/frs_model.dart

String? _parseStringSafe(dynamic value) {
  if (value == null) return null;
  return value.toString();
}

int _parseIntSafe(dynamic value, {int defaultValue = 0}) {
  if (value == null) return defaultValue;
  if (value is int) return value;
  if (value is String) return int.tryParse(value) ?? defaultValue;
  if (value is double) return value.toInt();
  return defaultValue;
}

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
      id: _parseIntSafe(json['id']),
      name: _parseStringSafe(json['name']) ?? 'N/A',
      email: _parseStringSafe(json['email']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
      };
  @override
  String toString() {
    return 'FrsUser(id: $id, name: $name, email: $email)';
  }
}

class FrsDosen {
  final int idDosen;
  final String nidn;
  final FrsUser? user;

  FrsDosen({
    required this.idDosen,
    required this.nidn,
    this.user,
  });

  factory FrsDosen.fromJson(Map<String, dynamic> json) {
    return FrsDosen(
      idDosen: _parseIntSafe(json['id_dosen']),
      nidn: _parseStringSafe(json['nidn']) ?? 'N/A',
      user: json['user'] != null && json['user'] is Map<String, dynamic>
          ? FrsUser.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id_dosen': idDosen,
        'nidn': nidn,
        'user': user?.toJson(),
      };
  @override
  String toString() {
    return 'FrsDosen(idDosen: $idDosen, nidn: $nidn, userName: ${user?.name})';
  }
}

class FrsMasterMatakuliah {
  final int idMasterMk;
  final String kodeMk;
  final String namaMk;
  final int sks;
  final String? semesterDefault;

  FrsMasterMatakuliah({
    required this.idMasterMk,
    required this.kodeMk,
    required this.namaMk,
    required this.sks,
    this.semesterDefault,
  });

  factory FrsMasterMatakuliah.fromJson(Map<String, dynamic> json) {
    return FrsMasterMatakuliah(
      idMasterMk: _parseIntSafe(json['id_master_mk'] ?? json['id_mk']),
      kodeMk: _parseStringSafe(json['kode_mk']) ?? 'N/A',
      namaMk: _parseStringSafe(json['nama_mk']) ?? 'N/A',
      sks: _parseIntSafe(json['sks_total'] ?? json['sks']),
      semesterDefault: _parseStringSafe(json['semester_default']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id_master_mk': idMasterMk,
        'kode_mk': kodeMk,
        'nama_mk': namaMk,
        'sks': sks,
        'semester_default': semesterDefault,
      };
  @override
  String toString() {
    return 'FrsMasterMatakuliah(kode: $kodeMk, nama: $namaMk, sks: $sks, semesterDefault: $semesterDefault)';
  }
}

class FrsJadwalKuliah {
  final int idJadwal;
  final FrsMasterMatakuliah? masterMatakuliah;
  final FrsDosen? dosen;
  final String? hari;
  final String? jamMulai;
  final String? jamSelesai;
  final String? namaRuang;
  final String? namaKelas;
  final String? semesterPelaksanaan;

  FrsJadwalKuliah({
    required this.idJadwal,
    this.masterMatakuliah,
    this.dosen,
    this.hari,
    this.jamMulai,
    this.jamSelesai,
    this.namaRuang,
    this.namaKelas,
    this.semesterPelaksanaan,
  });

  factory FrsJadwalKuliah.fromJson(Map<String, dynamic> json) {
    return FrsJadwalKuliah(
      idJadwal: _parseIntSafe(json['id_mk']),
      masterMatakuliah: json['master_matakuliah'] != null && json['master_matakuliah'] is Map<String, dynamic>
          ? FrsMasterMatakuliah.fromJson(json['master_matakuliah'] as Map<String, dynamic>)
          : null,
      dosen: json['dosen'] != null && json['dosen'] is Map<String, dynamic>
          ? FrsDosen.fromJson(json['dosen'] as Map<String, dynamic>)
          : null,
      hari: _parseStringSafe(json['hari']),
      jamMulai: _parseStringSafe(json['jam_mulai']),
      jamSelesai: _parseStringSafe(json['jam_selesai']),
      namaRuang: _parseStringSafe((json['ruang'] as Map<String, dynamic>?)?['nama_ruang'] ?? json['ruang']),
      namaKelas: _parseStringSafe((json['kelas'] as Map<String, dynamic>?)?['nama_kelas'] ?? json['kelas']),
      semesterPelaksanaan: _parseStringSafe(json['semester']), // API Anda mengirim 'semester'
    );
  }

  Map<String, dynamic> toJson() => {
        'id_mk': idJadwal,
        'master_matakuliah': masterMatakuliah?.toJson(),
        'dosen': dosen?.toJson(),
        'hari': hari,
        'jam_mulai': jamMulai,
        'jam_selesai': jamSelesai,
        'ruang': namaRuang,
        'kelas': namaKelas,
        'semester': semesterPelaksanaan,
      };
  @override
  String toString() {
    return 'FrsJadwalKuliah(id: $idJadwal, mk: ${masterMatakuliah?.namaMk}, semester: $semesterPelaksanaan)';
  }
}

class FrsMahasiswa {
  final int idMahasiswa;
  final String nrp;
  final FrsUser? user; // Dibuat nullable

  FrsMahasiswa({
    required this.idMahasiswa,
    required this.nrp,
    this.user,
  });

  factory FrsMahasiswa.fromJson(Map<String, dynamic> json) {
    return FrsMahasiswa(
      idMahasiswa: _parseIntSafe(json['id_mahasiswa']),
      nrp: _parseStringSafe(json['nrp'] ?? (json['user'] as Map<String, dynamic>?)?['nim']) ?? 'N/A',
      user: json['user'] != null && json['user'] is Map<String, dynamic>
          ? FrsUser.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }
  Map<String, dynamic> toJson() => {
        'id_mahasiswa': idMahasiswa,
        'nrp': nrp,
        'user': user?.toJson(),
      };
  @override
  String toString() {
    return 'FrsMahasiswa(id: $idMahasiswa, nrp: $nrp, userName: ${user?.name})';
  }
}

class FrsTahunAjaran {
  final int id;
  final String namaTahunAjaran;
  final String? semester; 

  FrsTahunAjaran({
    required this.id,
    required this.namaTahunAjaran,
    this.semester,
  });

  factory FrsTahunAjaran.fromJson(Map<String, dynamic> json) {
    return FrsTahunAjaran(
      id: _parseIntSafe(json['id']),
      namaTahunAjaran: _parseStringSafe(json['nama_tahun_ajaran']) ?? 'N/A',
      semester: _parseStringSafe(json['semester']),
    );
  }
   Map<String, dynamic> toJson() => {
        'id': id,
        'nama_tahun_ajaran': namaTahunAjaran,
        'semester': semester,
      };
  @override
  String toString() {
    return 'FrsTahunAjaran(id: $id, nama: $namaTahunAjaran, semester: $semester)';
  }
}

class FrsItem {
  final int idFrs;
  final String status;
  final FrsMahasiswa? mahasiswa;      
  final FrsJadwalKuliah? jadwalKuliah; 
  final String? createdAt;
  final String? updatedAt;
  final String? tahunAjaranFrs;
  final String? nilaiAkhir;
  final String? statusPenilaian;

  FrsItem({
    required this.idFrs,
    required this.status,
    this.mahasiswa,
    this.jadwalKuliah,
    this.createdAt,
    this.updatedAt,
    this.tahunAjaranFrs,
    this.nilaiAkhir,
    this.statusPenilaian,
  });

  factory FrsItem.fromJson(Map<String, dynamic> json) {
    FrsMahasiswa? parsedMahasiswa;
    if (json['mahasiswa'] != null && json['mahasiswa'] is Map<String, dynamic>) {
      parsedMahasiswa = FrsMahasiswa.fromJson(json['mahasiswa'] as Map<String, dynamic>);
    }

    FrsJadwalKuliah? parsedJadwalKuliah;
    FrsTahunAjaran? parsedTahunAjaranObjek; 
    String? parsedTahunAjaranFrsString;   


    if (json['jadwal_kuliah'] != null && json['jadwal_kuliah'] is Map<String, dynamic>) {
      parsedJadwalKuliah = FrsJadwalKuliah.fromJson(json['jadwal_kuliah'] as Map<String, dynamic>);
      if (json['tahun_ajaran'] != null && json['tahun_ajaran'] is Map<String, dynamic>) {
        parsedTahunAjaranObjek = FrsTahunAjaran.fromJson(json['tahun_ajaran'] as Map<String, dynamic>);
        parsedTahunAjaranFrsString = parsedTahunAjaranObjek.namaTahunAjaran;
      } else {
         parsedTahunAjaranFrsString = _parseStringSafe(json['tahun_ajaran_frs']);
      }
    } 
    else if (json.containsKey('id_mk_jadwal')) { 
      FrsMasterMatakuliah? masterMatakuliahData = FrsMasterMatakuliah(
        idMasterMk: _parseIntSafe(json['id_mk_jadwal']),
        kodeMk: _parseStringSafe(json['kode_mk']) ?? 'N/A',
        namaMk: _parseStringSafe(json['nama_mk']) ?? 'N/A',
        sks: _parseIntSafe(json['sks']),
      );

      FrsDosen? dosenData;
      if (_parseStringSafe(json['dosen_pengampu']) != null) {
        dosenData = FrsDosen(
          idDosen: 0, nidn: 'N/A', 
          user: FrsUser(id: 0, name: _parseStringSafe(json['dosen_pengampu'])!)
        );
      }
      
      parsedJadwalKuliah = FrsJadwalKuliah(
        idJadwal: _parseIntSafe(json['id_mk_jadwal']),
        masterMatakuliah: masterMatakuliahData,
        dosen: dosenData,
        hari: _parseStringSafe(json['hari']),
        jamMulai: _parseStringSafe(json['jam_mulai']),
        jamSelesai: _parseStringSafe(json['jam_selesai']),
        namaRuang: _parseStringSafe(json['ruang']),
        semesterPelaksanaan: _parseStringSafe(json['semester_pelaksanaan']),
      );
      parsedTahunAjaranFrsString = _parseStringSafe(json['tahun_ajaran_frs']);
    }

    final item = FrsItem(
      idFrs: _parseIntSafe(json['id_frs']),
      status: _parseStringSafe(json['status_frs'] ?? json['status']) ?? 'pending',
      mahasiswa: parsedMahasiswa,
      jadwalKuliah: parsedJadwalKuliah,
      createdAt: _parseStringSafe(json['created_at']),
      updatedAt: _parseStringSafe(json['updated_at']),
      tahunAjaranFrs: parsedTahunAjaranFrsString,
      nilaiAkhir: _parseStringSafe((json['nilai'] as Map<String, dynamic>?)?['nilai_huruf'] ?? json['nilai_akhir']),
      statusPenilaian: _parseStringSafe((json['nilai'] as Map<String, dynamic>?)?['status_penilaian'] ?? json['status_penilaian']),
    );
    return item;
  }
  Map<String, dynamic> toJson() => { /* ... */ };
  @override
  String toString() {
    return 'FrsItem(id: $idFrs, status: $status, MK: ${jadwalKuliah?.masterMatakuliah?.namaMk})';
  }
}