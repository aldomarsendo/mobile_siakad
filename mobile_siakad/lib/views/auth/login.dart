import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; 
import 'package:mobile_siakad/services/api_client.dart'; 
import 'package:mobile_siakad/services/auth_service.dart';
import 'package:mobile_siakad/views/mahasiswa/mahasiswa_dashboard.dart';
import 'package:mobile_siakad/views/dosen/dosen_dashboard.dart';
import 'package:mobile_siakad/models/user_model.dart'; 

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  final ApiClient _apiClient = ApiClient(http.Client());
  
  late final AuthService _authService;

  final Color primaryBlue = const Color(0xFF133B7A);

  @override
  void initState() {
    super.initState();
    _authService = AuthService(_apiClient);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      if (mounted) { 
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email dan password tidak boleh kosong')),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      final User user = await _authService.login(
        _emailController.text,
        _passwordController.text,
        AuthService.getDeviceName(), 
      );

      if (mounted) {
        if (user.role == 'mahasiswa') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MahasiswaDashboardPage()),
          );
        } else if (user.role == 'dosen') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DosenDashboardPage()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Peran pengguna tidak valid: ${user.role}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login gagal: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.school, size: 80, color: primaryBlue),
              SizedBox(height: 16),
              Text(
                'Login',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: primaryBlue,
                ),
              ),
              SizedBox(height: 32),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text('Login', style: TextStyle(fontSize: 16) ),
                ),
              ),
              SizedBox(height: 16),
              Text(
                '© 2025 Politeknik Elektronika Negeri Surabaya',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              )
            ],
          ),
        ),
      ),
    );
  }
}