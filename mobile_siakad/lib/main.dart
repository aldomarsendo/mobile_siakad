import 'package:flutter/material.dart';
import 'package:mobile_siakad/views/mahasiswa/dashboard.dart';
import 'views/mahasiswa/jadwal_kuliah.dart'; // Sesuaikan nama file

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jadwal Kuliah',
      debugShowCheckedModeBanner: false,
      home: DashboardPage(), // Jalankan halaman ini langsung
    );
  }
}
