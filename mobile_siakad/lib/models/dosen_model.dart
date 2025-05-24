import 'mahasiswa_model.dart'; // PASTIKAN PATH INI BENAR atau Kelas ada di file terpisah

class Dosen {
  final int idDosen;
  final int userId;
  final String nidn;
  final String name;
  final String email;
  final bool isDosenWali;
  final String? tanggalLahir; // Tambahan field
  final String? jenisKelamin; // Tambahan field
  final List<Kelas>? kelasWali; // Tambahan field untuk daftar kelas yang diwali
  final String createdAt;
  final String updatedAt;

  Dosen({
    required this.idDosen,
    required this.userId,
    required this.nidn,
    required this.name,
    required this.email,
    required this.isDosenWali,
    this.tanggalLahir, // Dijadikan opsional di constructor
    this.jenisKelamin, // Dijadikan opsional di constructor
    this.kelasWali,    // Dijadikan opsional di constructor
    required this.createdAt,
    required this.updatedAt,
  });

  factory Dosen.fromJson(Map<String, dynamic> json) {
    List<Kelas>? parsedKelasWali;
    // Cek apakah dosen adalah wali dan ada data kelas_wali dalam bentuk list
    if (json['is_dosen_wali'] == true && json['kelas_wali'] != null && json['kelas_wali'] is List) {
      // Pastikan elemen dalam list adalah Map sebelum mencoba parsing
      if ((json['kelas_wali'] as List).isNotEmpty && (json['kelas_wali'] as List).first is Map<String,dynamic>) {
         parsedKelasWali = (json['kelas_wali'] as List)
          .map((kelasJson) => Kelas.fromJson(kelasJson as Map<String, dynamic>))
          .toList();
      } else if ((json['kelas_wali'] as List).isEmpty) {
        // Jika listnya kosong, inisialisasi dengan list kosong
        parsedKelasWali = [];
      }
      // Jika list tidak kosong tapi elemennya bukan Map, parsedKelasWali akan tetap null
      // atau Anda bisa menambahkan penanganan error/logging di sini.
    }

    return Dosen(
      idDosen: json['id_dosen'] as int? ?? 0,
      userId: json['user_id'] as int? ?? 0,
      nidn: json['nidn']?.toString() ?? '',
      name: json['nama']?.toString() ?? '', // Sesuai output backend 'nama'
      email: json['email']?.toString() ?? '',
      isDosenWali: (json['is_dosen_wali'] == 1 || json['is_dosen_wali'] == true),
      tanggalLahir: json['tanggal_lahir']?.toString(), // Parsing tanggal_lahir
      jenisKelamin: json['jenis_kelamin']?.toString(), // Parsing jenis_kelamin
      kelasWali: parsedKelasWali, // Menggunakan hasil parsing kelasWali
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_dosen': idDosen,
      'user_id': userId,
      'nidn': nidn,
      'nama': name, // Menggunakan 'nama' untuk konsistensi dengan fromJson
      'email': email,
      'is_dosen_wali': isDosenWali,
      'tanggal_lahir': tanggalLahir,
      'jenis_kelamin': jenisKelamin,
      // Jika kelasWali perlu dikirim kembali ke server saat update (biasanya tidak untuk relasi):
      'kelas_wali': kelasWali?.map((kelas) => kelas.toJson()).toList(),
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  // Opsional: Tambahkan method copyWith untuk memudahkan update state immutable
  Dosen copyWith({
    int? idDosen,
    int? userId,
    String? nidn,
    String? name,
    String? email,
    bool? isDosenWali,
    String? tanggalLahir,
    String? jenisKelamin,
    List<Kelas>? kelasWali,
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
      tanggalLahir: tanggalLahir ?? this.tanggalLahir,
      jenisKelamin: jenisKelamin ?? this.jenisKelamin,
      kelasWali: kelasWali ?? this.kelasWali,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}