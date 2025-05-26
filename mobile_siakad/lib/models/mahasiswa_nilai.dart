// lib/models/mahasiswa_nilai_model.dart

class MahasiswaNilaiItem {
  final int idFrs;
  final int idMkJadwal;
  final String kodeMk;
  final String namaMk;
  final int sks;
  final String? semesterMkDiambil; 
  final num? nilaiAngka;
  final String? nilaiHuruf;
  final String? statusPenilaian;
  final String? tahunAjaranFrs;

  MahasiswaNilaiItem({
    required this.idFrs,
    required this.idMkJadwal,
    required this.kodeMk,
    required this.namaMk,
    required this.sks,
    this.semesterMkDiambil,
    this.nilaiAngka,
    this.nilaiHuruf,
    this.statusPenilaian,
    this.tahunAjaranFrs,
  });

  factory MahasiswaNilaiItem.fromJson(Map<String, dynamic> json) {
    num? parsedNilaiAngka;
    if (json['nilai_angka'] != null) {
      if (json['nilai_angka'] is String) {
        parsedNilaiAngka = num.tryParse(json['nilai_angka'] as String);
      } else if (json['nilai_angka'] is num) {
        parsedNilaiAngka = json['nilai_angka'] as num;
      }
    }

    return MahasiswaNilaiItem(
      idFrs: json['id_frs'] as int? ?? 0,
      idMkJadwal: json['id_mk_jadwal'] as int? ?? 0,
      kodeMk: json['kode_mk'] as String? ?? 'N/A',
      namaMk: json['nama_mk'] as String? ?? 'N/A',
      sks: json['sks'] as int? ?? 0,
      semesterMkDiambil: json['semester_mk_diambil'] as String?, 
      nilaiAngka: parsedNilaiAngka,
      nilaiHuruf: json['nilai_huruf'] as String?,
      statusPenilaian: json['status_penilaian'] as String?,
      tahunAjaranFrs: json['tahun_ajaran_frs'] as String?, 
    );
  }
}

class GetMahasiswaNilaiResponse {
  final List<MahasiswaNilaiItem> semuaNilai;
  final String message;
  final double? ipkKumulatifGlobal; 

  GetMahasiswaNilaiResponse({
    required this.semuaNilai,
    required this.message,
    this.ipkKumulatifGlobal,
  });

  factory GetMahasiswaNilaiResponse.fromJson(Map<String, dynamic> json) {
    var list = json['semua_nilai'] as List? ?? [];
    List<MahasiswaNilaiItem> nilaiItems = list.map((i) => MahasiswaNilaiItem.fromJson(i as Map<String, dynamic>)).toList();

    return GetMahasiswaNilaiResponse(
      semuaNilai: nilaiItems,
      message: json['message'] as String? ?? '',
      ipkKumulatifGlobal: (json['ipk_kumulatif_global'] as num?)?.toDouble(),
    );
  }
}