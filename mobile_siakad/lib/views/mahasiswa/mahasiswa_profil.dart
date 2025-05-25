import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:mobile_siakad/services/mahasiswa/mahasiswa_profile_service.dart';
import 'package:mobile_siakad/models/mahasiswa_model.dart';
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
  Mahasiswa? _mahasiswaProfile;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isUpdating = false;

  // Services
  late final MahasiswaProfileService _profileService;

  // Controllers for form fields
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _nrpController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

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
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadMahasiswaProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final profile = await _profileService.getProfile();
      if (mounted) {
        setState(() {
          _mahasiswaProfile = profile;
          _namaController.text = profile.nama;
          _nrpController.text = profile.nrp;
          _emailController.text = profile.email ?? '';
          _isLoading = false;
        });
        _animationController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Gagal memuat data profil: ${e.toString()}";
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateProfile() async {
    // Since name and email are now non-editable, we no longer need validation for them
    setState(() {
      _isUpdating = true;
    });

    try {
      // Call API with empty updates since we're not changing anything
      await _profileService.updateProfile(
        // We're not updating name or email anymore
        nama: _mahasiswaProfile?.nama ?? _namaController.text.trim(),
        email: _mahasiswaProfile?.email ?? _emailController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil berhasil diperbarui'),
            backgroundColor: Colors.green,
          ),
        );
      }
      await _loadMahasiswaProfile();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memperbarui profil: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
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
            onPressed: _isLoading || _isUpdating ? null : _loadMahasiswaProfile,
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
                                _emailController.text,
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Informasi Profil',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: primaryBlue,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  
                                  // Nama field (now read-only)
                                  TextFormField(
                                    controller: _namaController,
                                    readOnly: true, // Set to read-only
                                    decoration: InputDecoration(
                                      labelText: 'Nama Lengkap (Tidak dapat diubah)',
                                      labelStyle: TextStyle(color: subtleTextOnLightBg),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                      prefixIcon: Icon(Icons.person_outline_rounded, color: iconColorOnLightBg),
                                      filled: true, // Add filled background like NRP field
                                      fillColor: Colors.grey.shade100,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  // NRP field (already read-only)
                                  TextFormField(
                                    controller: _nrpController,
                                    readOnly: true,
                                    decoration: InputDecoration(
                                      labelText: 'NRP (Tidak dapat diubah)',
                                      labelStyle: TextStyle(color: subtleTextOnLightBg),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                      prefixIcon: Icon(Icons.badge_outlined, color: iconColorOnLightBg),
                                      filled: true,
                                      fillColor: Colors.grey.shade100,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  // Email field (now read-only)
                                  TextFormField(
                                    controller: _emailController,
                                    readOnly: true, // Set to read-only
                                    decoration: InputDecoration(
                                      labelText: 'Email (Tidak dapat diubah)',
                                      labelStyle: TextStyle(color: subtleTextOnLightBg),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                      prefixIcon: Icon(Icons.email_outlined, color: iconColorOnLightBg),
                                      filled: true, // Add filled background like NRP field
                                      fillColor: Colors.grey.shade100,
                                    ),
                                    keyboardType: TextInputType.emailAddress,
                                  ),
                                  
                                  // Info message about updating profile
                                  const SizedBox(height: 24),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.blue.shade200),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.info_outline, color: primaryBlue, size: 24),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            'Untuk mengubah nama atau email, silakan hubungi bagian akademik.',
                                            style: TextStyle(
                                              color: primaryBlue,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
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
                                onPressed: _isUpdating ? null : _resetForm,
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