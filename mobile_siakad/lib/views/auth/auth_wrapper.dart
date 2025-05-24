import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_siakad/models/user_model.dart';
import 'package:mobile_siakad/services/api_client.dart';
import 'package:mobile_siakad/services/auth_service.dart';
import 'package:mobile_siakad/views/auth/login.dart';
import 'package:mobile_siakad/views/dosen/dosen_dashboard.dart';
import 'package:mobile_siakad/views/mahasiswa/mahasiswa_dashboard.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final AuthService _authService = AuthService(ApiClient(http.Client()));

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 1));

    try {
      final User? user = await _authService.getCurrentUser();

      if (!mounted) return;

      if (user != null && user.token != null && user.token!.isNotEmpty) {
        print("Sesi ditemukan untuk user: ${user.name}, role: ${user.role}");
        if (user.role == 'dosen') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DosenDashboardPage()),
          );
        } else if (user.role == 'mahasiswa') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MahasiswaDashboardPage()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        }
      } else {
        print("Tidak ada sesi aktif, mengarahkan ke halaman login.");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    } catch (e) {
      print("Error saat memeriksa status login: $e. Mengarahkan ke halaman login.");
       if (!mounted) return;
       Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}