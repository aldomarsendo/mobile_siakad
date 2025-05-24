// Asumsi file ini adalah lib/models/mahasiswa_model.dart atau file serupa

class Mahasiswa {
  final int idMahasiswa;
  final int userId;
  final int idKelas;
  final String nrp;
  final String nama;
  final String prodi;
  final String? email;
  final String createdAt;
  final String updatedAt;
  final String kelas; // Ini adalah nama kelas, bukan objek Kelas
  final String dosenWali; // Ini adalah nama dosen wali, bukan objek DosenWali

  Mahasiswa({
    required this.idMahasiswa,
    required this.userId,
    required this.idKelas,
    required this.nrp,
    required this.nama,
    required this.prodi,
    this.email,
    required this.createdAt,
    required this.updatedAt,
    required this.kelas,
    required this.dosenWali,
  });

  factory Mahasiswa.fromJson(Map<String, dynamic> json) {
    return Mahasiswa(
      idMahasiswa: json['id_mahasiswa'] as int? ?? 0,
      userId: json['user_id'] as int? ?? 0,
      idKelas: json['id_kelas'] as int? ?? 0,
      nrp: json['nrp'] as String? ?? '',
      nama: json['nama'] as String? ?? '',
      prodi: json['prodi'] as String? ?? '',
      email: json['email']?.toString(),
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
      kelas: json['kelas'] as String? ?? '', // Pastikan key 'kelas' sesuai JSON
      dosenWali: json['dosen_wali'] as String? ?? '', // Pastikan key 'dosen_wali' sesuai JSON
    );
  }

  // Metode toJson untuk Mahasiswa (opsional untuk kasus ini, tapi baik untuk dimiliki)
  Map<String, dynamic> toJson() {
    return {
      'id_mahasiswa': idMahasiswa,
      'user_id': userId,
      'id_kelas': idKelas,
      'nrp': nrp,
      'nama': nama,
      'prodi': prodi,
      'email': email,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'kelas': kelas,
      'dosen_wali': dosenWali,
    };
  }
}

class Kelas {
  final int idKelas;
  final String namaKelas;
  final String status;
  final int idDosenWali; // Foreign Key ke Dosen
  final String createdAt;
  final String updatedAt;
  final DosenWali? dosenWali; // Objek DosenWali untuk kelas ini

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

  // TAMBAHKAN METHOD toJson UNTUK KELAS
  Map<String, dynamic> toJson() {
    return {
      'id_kelas': idKelas,
      'nama_kelas': namaKelas,
      'status': status,
      'id_dosen_wali': idDosenWali,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'dosen_wali': dosenWali?.toJson(), // Panggil toJson pada objek dosenWali jika ada
    };
  }
}

class DosenWali {
  final int idDosen;
  final int userId;
  final String nidn;
  // final String name; // Jika ada nama dosen di sini, tambahkan
  final bool isDosenWali;
  final String createdAt;
  final String updatedAt;

  DosenWali({
    required this.idDosen,
    required this.userId,
    required this.nidn,
    // required this.name,
    required this.isDosenWali,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DosenWali.fromJson(Map<String, dynamic> json) {
    return DosenWali(
      idDosen: json['id_dosen'] as int? ?? 0,
      userId: json['user_id'] as int? ?? 0,
      nidn: json['nidn'] as String? ?? '',
      // name: json['name'] as String? ?? '', // Jika ada nama
      isDosenWali: (json['is_dosen_wali'] == 1 || json['is_dosen_wali'] == true),
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
    );
  }

  // TAMBAHKAN METHOD toJson UNTUK DOSENWALI
  Map<String, dynamic> toJson() {
    return {
      'id_dosen': idDosen,
      'user_id': userId,
      'nidn': nidn,
      // 'name': name, // Jika ada nama
      'is_dosen_wali': isDosenWali,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}