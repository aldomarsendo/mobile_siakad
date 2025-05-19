import 'package:flutter/material.dart';
import 'package:mobile_siakad/views/auth/login.dart';
import 'package:mobile_siakad/views/dosen/dosen_dashboard.dart';
import 'package:mobile_siakad/views/mahasiswa/mahasiswa_dashboard.dart';
import 'package:mobile_siakad/views/mahasiswa/mahasiswa_frs.dart';
import 'views/mahasiswa/mahasiswa_jadwal.dart';
import 'views/mahasiswa/mahasiswa_nilai.dart';
import 'views/dosen/dosen_jadwal.dart';
// import 'views/dosen/dosen_nilai.dart';
import 'views/dosen/dosen_dashboard.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jadwal Kuliah',
      debugShowCheckedModeBanner: false,
      home: MahasiswaJadwalPage(), // Jalankan halaman ini langsung
    );
  }
}
