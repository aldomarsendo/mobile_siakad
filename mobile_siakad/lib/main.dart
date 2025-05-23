import 'package:flutter/material.dart';
import 'package:mobile_siakad/views/auth/login.dart';
import 'package:mobile_siakad/views/dosen/dosen_dashboard.dart';
import 'package:mobile_siakad/views/dosen/dosen_frs.dart';
import 'package:mobile_siakad/views/dosen/dosen_profil.dart';
import 'package:mobile_siakad/views/mahasiswa/mahasiswa_dashboard.dart';
import 'package:mobile_siakad/views/mahasiswa/mahasiswa_jadwal.dart';
import 'package:mobile_siakad/views/mahasiswa/mahasiswa_profil.dart';
import 'package:intl/date_symbol_data_local.dart'; // Tambahkan ini untuk inisialisasi locale

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Pastikan binding Flutter siap untuk operasi async
  await initializeDateFormatting('id_ID', null); // Inisialisasi locale 'id_ID'
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jadwal Kuliah',
      debugShowCheckedModeBanner: false,
      home: LoginPage(), // Jalankan halaman ini langsung
    );
  }
}