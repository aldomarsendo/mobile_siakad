import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_siakad/models/mahasiswa_profile_model.dart';

import 'package:mobile_siakad/services/mahasiswa/mahasiswa_profile_service.dart';
import 'package:mobile_siakad/services/api_client.dart';

class MahasiswaProfilPage extends StatefulWidget {
  const MahasiswaProfilPage({super.key});

  @override
  State<MahasiswaProfilPage> createState() => _MahasiswaProfilPageState();
}

class _MahasiswaProfilPageState extends State<MahasiswaProfilPage>
    with SingleTickerProviderStateMixin {
  // Palet Warna Utama
  final Color primaryBlue = const Color(0xFF133B7A);
  final Color secondaryBlue = const Color(0xFF1E5BB0); 

  // Warna Tambahan dari tema
  final Color textOnLightBg = Colors.black87;
  final Color subtleTextOnLightBg = Colors.grey.shade700;
  late final Color iconColorOnLightBg;
  late final Color dividerColor;
  late final Color cardShadowColor;

  // State Variables
  MahasiswaProfile? _mahasiswaProfile; 
  bool _isLoading = true;
  String? _errorMessage;
  bool _isUpdatingPassword = false;

  // Services
  late final MahasiswaProfileService _profileService;

  // Controllers for form fields
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _nrpController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController = TextEditingController();
  final _formKeyPassword = GlobalKey<FormState>(); // Kunci untuk validasi form password
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  // Animation Controller
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Inisialisasi warna tambahan
    iconColorOnLightBg = primaryBlue.withOpacity(0.75);
    dividerColor = primaryBlue.withOpacity(0.2);
    cardShadowColor = primaryBlue.withOpacity(0.08);

    // Inisialisasi service
    final apiClient = ApiClient(http.Client());
    _profileService = MahasiswaProfileService(apiClient);

    // Inisialisasi AnimationController
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
    // Langsung muat data profil saat halaman dibuka
    _loadMahasiswaProfile();
  }

  @override
  void dispose() {
    _namaController.dispose();
    _nrpController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadMahasiswaProfile() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });    

    try {
      final MahasiswaProfile profile = await _profileService.getProfile();
      if (mounted) {
        setState(() {
          _mahasiswaProfile = profile;
          _namaController.text = profile.nama;
          _nrpController.text = profile.nrp;
          _emailController.text = profile.email ?? '';
          _isLoading = false;
      });
      _animationController.forward(from: 0.0); 
    }
    } catch (e) {
      print("Error fetching mahasiswa profile: $e");
      if (mounted) {
        setState(() {
          _errorMessage = "Gagal memuat data profil: ${e.toString()}";
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updatePassword() async {
    if (!_formKeyPassword.currentState!.validate()) {
      return;
    }

    setState(() {
      _isUpdatingPassword = true;
    });

    try {
      final message = await _profileService.updatePassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
        newPasswordConfirmation: _confirmNewPasswordController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.green,
          ),
        );
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmNewPasswordController.clear();
        FocusScope.of(context).unfocus();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memperbarui password: ${e.toString().replaceFirst("Exception: ", "")}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingPassword = false;
        });
      }
    }
  }

  void _resetForm() {
    if (_mahasiswaProfile != null) {
      setState(() {
        _namaController.text = _mahasiswaProfile!.nama;
        _nrpController.text = _mahasiswaProfile!.nrp;
        _emailController.text = _mahasiswaProfile!.email ?? '';
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmNewPasswordController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Form telah di-reset'),
          duration: const Duration(seconds: 2),
          backgroundColor: primaryBlue.withOpacity(0.8),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Pengaturan Profil',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 18)),
        backgroundColor: primaryBlue,
        elevation: 1.0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _isLoading || _isUpdatingPassword ? null : _loadMahasiswaProfile,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: primaryBlue),
                  const SizedBox(height: 20),
                  Text('Memuat data profil...',
                      style: TextStyle(fontSize: 16, color: subtleTextOnLightBg)),
                ],
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline_rounded,
                            size: 70, color: Colors.red.shade400),
                        const SizedBox(height: 20),
                         Text(
                          "Gagal Memuat Data",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red.shade700),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _errorMessage!,
                          style: TextStyle(fontSize: 16, color: subtleTextOnLightBg),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 25),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                          label: const Text("Coba Lagi", style: TextStyle(color: Colors.white, fontSize: 16)),
                          onPressed: _loadMahasiswaProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryBlue,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        )
                      ],
                    ),
                  ),
                )
              : FadeTransition(
                  opacity: _fadeAnimation,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Kartu Header Profil
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [primaryBlue, secondaryBlue],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: primaryBlue.withOpacity(0.25),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundImage: const NetworkImage(
                                    'https://st3.depositphotos.com/6672868/13701/v/450/depositphotos_137014128-stock-illustration-user-profile-icon.jpg'),
                                backgroundColor: Colors.white.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _mahasiswaProfile?.nama ?? 'Nama tidak tersedia',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'NRP: ${_mahasiswaProfile?.nrp ?? 'N/A'}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _mahasiswaProfile?.email ?? 'Email tidak tersedia',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Kartu Form Edit
                        Card(
                          elevation: 0,
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                           
                          child: Container(
                             decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12.0),
                                boxShadow: [
                                   BoxShadow(
                                    color: cardShadowColor,
                                    blurRadius: 10,
                                    offset: const Offset(0,4)
                                   )
                                ]
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Form(
                                key: _formKeyPassword,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Ubah Password', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryBlue)),
                                    const SizedBox(height: 20),
                                    TextFormField(
                                      controller: _currentPasswordController,
                                      obscureText: _obscureCurrentPassword,
                                      decoration: InputDecoration(
                                        labelText: 'Password Saat Ini',
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                        prefixIcon: Icon(Icons.lock_outline_rounded),
                                        suffixIcon: IconButton(
                                          icon: Icon(_obscureCurrentPassword ? Icons.visibility_off : Icons.visibility),
                                          onPressed: () => setState(() => _obscureCurrentPassword = !_obscureCurrentPassword),
                                        )
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) return 'Password saat ini tidak boleh kosong.';
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    TextFormField(
                                      controller: _newPasswordController,
                                      obscureText: _obscureNewPassword,
                                      decoration: InputDecoration(
                                        labelText: 'Password Baru',
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                        prefixIcon: Icon(Icons.lock_person_outlined),
                                        suffixIcon: IconButton(
                                          icon: Icon(_obscureNewPassword ? Icons.visibility_off : Icons.visibility),
                                          onPressed: () => setState(() => _obscureNewPassword = !_obscureNewPassword),
                                        )
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) return 'Password baru tidak boleh kosong.';
                                        if (value.length < 8) return 'Password minimal 8 karakter.';
                                        // Tambahkan validasi lain jika perlu (mixedCase, numbers, symbols dari Laravel)
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    TextFormField(
                                      controller: _confirmNewPasswordController,
                                      obscureText: _obscureConfirmPassword,
                                      decoration: InputDecoration(
                                        labelText: 'Konfirmasi Password Baru',
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                        prefixIcon: Icon(Icons.lock_person_outlined),
                                        suffixIcon: IconButton(
                                          icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                                          onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                                        )
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) return 'Konfirmasi password tidak boleh kosong.';
                                        if (value != _newPasswordController.text) return 'Konfirmasi password tidak cocok.';
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 24),
                                    ElevatedButton.icon(
                                      icon: _isUpdatingPassword ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Icon(Icons.save_alt_outlined, color: Colors.white),
                                      label: Text(_isUpdatingPassword ? 'Menyimpan...' : 'Simpan Password', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                                      onPressed: _isUpdatingPassword ? null : _updatePassword,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: primaryBlue,
                                        minimumSize: const Size(double.infinity, 50),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        padding: const EdgeInsets.symmetric(vertical: 14)
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Refresh button only (removed save button since nothing can be changed)
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.refresh_rounded),
                                onPressed: _isUpdatingPassword ? null : _resetForm,
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  side: BorderSide(color: primaryBlue.withOpacity(0.7)),
                                  foregroundColor: primaryBlue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                ),
                                label: const Text('Refresh Data', style: TextStyle(fontWeight: FontWeight.w600)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
    );
  }
}