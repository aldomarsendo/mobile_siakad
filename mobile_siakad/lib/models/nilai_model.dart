import 'package:mobile_siakad/models/frs_model.dart';

class NilaiJadwalKuliahDetail {
  final int idMk;
  final String? hari;
  final String? jamMulai;
  final String? jamSelesai;
  final String? semester;
  final FrsMasterMatakuliah? masterMatakuliah;
  final FrsDosen? dosen;
  final String? namaRuang;
  final String? namaKelas;

  NilaiJadwalKuliahDetail({
    required this.idMk,
    this.hari,
    this.jamMulai,
    this.jamSelesai,
    this.semester,
    this.masterMatakuliah,
    this.dosen,
    this.namaRuang,
    this.namaKelas,
  });

  factory NilaiJadwalKuliahDetail.fromJson(Map<String, dynamic> json) {
    return NilaiJadwalKuliahDetail(
      idMk: json['id_mk'] as int? ?? 0,
      hari: json['hari'] as String?,
      jamMulai: json['jam_mulai'] as String?,
      jamSelesai: json['jam_selesai'] as String?,
      semester: json['semester'] as String?,
      masterMatakuliah: json['master_matakuliah'] != null
          ? FrsMasterMatakuliah.fromJson(json['master_matakuliah'] as Map<String, dynamic>)
          : null,
      dosen: json['dosen'] != null
          ? FrsDosen.fromJson(json['dosen'] as Map<String, dynamic>)
          : null,
      namaRuang: (json['ruang'] as Map<String, dynamic>?)?['nama_ruang'] as String?,
      namaKelas: (json['kelas'] as Map<String, dynamic>?)?['nama_kelas'] as String?,
    );
  }
}

class MahasiswaUntukNilai {
  final int idFrs;
  final int idMahasiswa;
  final String nrp;
  final String namaMahasiswa;
  final int? idNilai;
  num? nilaiAngka; 
  String? nilaiHuruf;
  String statusPenilaian;

  MahasiswaUntukNilai({
    required this.idFrs,
    required this.idMahasiswa,
    required this.nrp,
    required this.namaMahasiswa,
    this.idNilai,
    this.nilaiAngka,
    this.nilaiHuruf,
    required this.statusPenilaian,
  });

  factory MahasiswaUntukNilai.fromJson(Map<String, dynamic> json) {
    num? parsedNilaiAngka;
    if (json['nilai_angka'] != null) {
      if (json['nilai_angka'] is String) {
        parsedNilaiAngka = num.tryParse(json['nilai_angka'] as String);
      } else if (json['nilai_angka'] is num) {
        parsedNilaiAngka = json['nilai_angka'] as num;
      }
    }

    return MahasiswaUntukNilai(
      idFrs: json['id_frs'] as int? ?? 0,
      idMahasiswa: json['id_mahasiswa'] as int? ?? 0,
      nrp: json['nrp'] as String? ?? 'N/A',
      namaMahasiswa: json['nama_mahasiswa'] as String? ?? 'N/A',
      idNilai: json['id_nilai'] as int?,
      nilaiAngka: parsedNilaiAngka, // <-- PERBAIKAN DI SINI
      nilaiHuruf: json['nilai_huruf'] as String?,
      statusPenilaian: json['status_penilaian'] as String? ?? 'belum_dinilai',
    );
  }
}

class GetMahasiswaNilaiResponse {
  final NilaiJadwalKuliahDetail? matakuliahDetail;
  final List<MahasiswaUntukNilai> mahasiswaList;
  final String message;

  GetMahasiswaNilaiResponse({
    this.matakuliahDetail,
    required this.mahasiswaList,
    required this.message,
  });

  factory GetMahasiswaNilaiResponse.fromJson(Map<String, dynamic> json) {
    var list = json['mahasiswa_list'] as List? ?? [];
    List<MahasiswaUntukNilai> mahasiswaItems = list.map((i) => MahasiswaUntukNilai.fromJson(i as Map<String, dynamic>)).toList();

    return GetMahasiswaNilaiResponse(
      matakuliahDetail: json['matakuliah_detail'] != null
          ? NilaiJadwalKuliahDetail.fromJson(json['matakuliah_detail'] as Map<String, dynamic>)
          : null,
      mahasiswaList: mahasiswaItems,
      message: json['message'] as String? ?? '',
    );
  }
}

class SubmittedNilaiItem {
  final int? idNilai;
  final int idFrs;
  final num nilaiAngka;
  final String nilaiHuruf;
  final String statusPenilaian;

  SubmittedNilaiItem({
    this.idNilai,
    required this.idFrs,
    required this.nilaiAngka,
    required this.nilaiHuruf,
    required this.statusPenilaian,
  });

  factory SubmittedNilaiItem.fromJson(Map<String, dynamic> json) {
    num parsedNilaiAngka = 0; // Default value
    if (json['nilai_angka'] != null) {
      if (json['nilai_angka'] is String) {
        parsedNilaiAngka = num.tryParse(json['nilai_angka'] as String) ?? 0;
      } else if (json['nilai_angka'] is num) {
        parsedNilaiAngka = json['nilai_angka'] as num;
      }
    }
    
    return SubmittedNilaiItem(
      idNilai: json['id_nilai'] as int?,
      idFrs: json['id_frs'] as int? ?? (json['frs'] as Map<String, dynamic>?)?['id_frs'] as int? ?? 0,
      nilaiAngka: parsedNilaiAngka, 
      nilaiHuruf: json['nilai_huruf'] as String? ?? 'E',
      statusPenilaian: json['status_penilaian'] as String? ?? 'belum_dinilai',
    );
  }
}