import 'package:flutter/material.dart';
import 'package:mobile_siakad/services/dosen/dosen_profile_service.dart';
import 'package:mobile_siakad/models/dosen_model.dart';
import 'package:mobile_siakad/services/api_client.dart';
import 'package:http/http.dart' as http;

class DosenProfilPage extends StatefulWidget {
  const DosenProfilPage({super.key});

  @override
  State<DosenProfilPage> createState() => _DosenProfilPageState();
}

class _DosenProfilPageState extends State<DosenProfilPage>
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
  Dosen? _dosenProfile;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isUpdating = false;

  // Services
  late final DosenProfileService _dosenService;

  // Controllers untuk form fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nidnController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _showPassword = false;
  bool _showConfirmPassword = false;

  // Animation Controller
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    iconColorOnLightBg = primaryBlue.withOpacity(0.75);
    dividerColor = primaryBlue.withOpacity(0.2);
    cardShadowColor = primaryBlue.withOpacity(0.08);

    final apiClient = ApiClient(http.Client());
    _dosenService = DosenProfileService(apiClient);

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

    _loadDosenProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nidnController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadDosenProfile() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final profile = await _dosenService.getProfile();
      if (mounted) {
        setState(() {
          _dosenProfile = profile;
          _nameController.text = profile.name;
          _nidnController.text = profile.nidn;
          _emailController.text = profile.email;
          _passwordController.clear();
          _confirmPasswordController.clear();
          _isLoading = false;
        });
        _animationController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Gagal memuat profil: ${e.toString()}";
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateProfile() async {
    if (_dosenProfile == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: const Text('Data profil belum dimuat'),
              backgroundColor: Colors.orange.shade700),
        );
      }
      return;
    }

    final newPassword = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (newPassword.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  const Text('Masukkan password baru jika ingin mengubah.'),
              backgroundColor: primaryBlue.withOpacity(0.8)),
        );
      }
      return;
    }

    if (newPassword.length < 8) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: const Text('Password minimal 8 karakter'),
              backgroundColor: Colors.orange.shade700),
        );
      }
      return;
    }
    if (newPassword != confirmPassword) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: const Text('Konfirmasi password tidak cocok'),
              backgroundColor: Colors.orange.shade700),
        );
      }
      return;
    }

    setState(() {
      _isUpdating = true;
    });

    try {
      await _dosenService.updateProfile(
        // Nama, NIDN, Email tidak diubah dari sini, hanya password
        password: newPassword,
        passwordConfirmation: confirmPassword,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password berhasil diperbarui.'),
            backgroundColor: Colors.green,
          ),
        );
      }
      await _loadDosenProfile();

      if (mounted && _dosenProfile != null) {
        Navigator.pop(context, _dosenProfile);
      } else if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memperbarui password: ${e.toString()}'),
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
    if (_dosenProfile != null) {
      setState(() {
        _passwordController.clear();
        _confirmPasswordController.clear();
        _showPassword = false;
        _showConfirmPassword = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Form password telah di-reset'),
            duration: const Duration(seconds: 2),
            backgroundColor: primaryBlue.withOpacity(0.8),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    InputDecoration themedFormFieldDecoration(String label, IconData prefixIcon,
        {Widget? suffixIcon,
        String? helperText,
        Color? helperColor, // Warna spesifik untuk helper text jika diperlukan
        bool readOnly = false}) {
      return InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: subtleTextOnLightBg),
        helperText: helperText,
        helperStyle: TextStyle(
            color: helperColor ?? subtleTextOnLightBg.withOpacity(0.8), fontSize: 12), // Sedikit lebih soft
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: dividerColor)), // Border standar
        enabledBorder: OutlineInputBorder( // Border saat tidak aktif
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: dividerColor.withOpacity(0.7))),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: primaryBlue, width: 1.5),
            borderRadius: BorderRadius.circular(10.0)),
        prefixIcon: Icon(prefixIcon, color: iconColorOnLightBg),
        suffixIcon: suffixIcon != null
            ? Theme( // Memastikan warna ikon suffix konsisten
                data: Theme.of(context).copyWith(
                    iconTheme: IconThemeData(color: iconColorOnLightBg.withOpacity(0.7))),
                child: suffixIcon,
              )
            : null,
        filled: readOnly,
        fillColor: readOnly ? Colors.grey.shade100 : null,
        contentPadding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 12.0), // Padding konsisten
      );
    }

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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            Navigator.pop(context, _dosenProfile);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _isLoading || _isUpdating ? null : _loadDosenProfile,
            tooltip: 'Refresh Data',
          ),
          if (!_isLoading && _dosenProfile != null)
            IconButton(
              icon: const Icon(Icons.settings_backup_restore_rounded),
              onPressed: _isUpdating ? null : _resetForm,
              tooltip: 'Reset Form Password',
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
                          "Gagal Memuat Profil",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade700),
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
                          label: const Text("Coba Lagi",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16)),
                          onPressed: _loadDosenProfile,
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
                                backgroundImage: NetworkImage(
                                    'https://st3.depositphotos.com/6672868/13701/v/450/depositphotos_137014128-stock-illustration-user-profile-icon.jpg'),
                                backgroundColor: Colors.white.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _dosenProfile?.name ?? 'Nama Tidak Tersedia',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'NIDN: ${_dosenProfile?.nidn ?? 'N/A'}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _dosenProfile?.email ?? 'Email Tidak Tersedia',
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

                        // Kartu Form
                        Container(
                          padding: const EdgeInsets.all(20.0),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.0),
                              boxShadow: [
                                BoxShadow(
                                    color: cardShadowColor,
                                    blurRadius: 10,
                                    offset: const Offset(0, 4))
                              ]),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Informasi Profil (Data Tetap)',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: primaryBlue,
                                ),
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: _nameController,
                                readOnly: true,
                                decoration: themedFormFieldDecoration(
                                  'Nama Lengkap',
                                  Icons.person_outline_rounded,
                                  helperText: 'Data nama tidak dapat diubah.',
                                  helperColor: Colors.orange.shade700,
                                  readOnly: true,
                                  suffixIcon: Icon(Icons.lock_outline_rounded, size: 20, color: iconColorOnLightBg.withOpacity(0.5))
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _nidnController,
                                readOnly: true,
                                decoration: themedFormFieldDecoration(
                                  'NIDN',
                                  Icons.badge_outlined,
                                  helperText: 'NIDN adalah data tetap.',
                                  helperColor: Colors.orange.shade700,
                                  readOnly: true,
                                   suffixIcon: Icon(Icons.lock_outline_rounded, size: 20, color: iconColorOnLightBg.withOpacity(0.5))
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _emailController,
                                readOnly: true,
                                decoration: themedFormFieldDecoration(
                                  'Email',
                                  Icons.email_outlined,
                                  helperText: 'Data email tidak dapat diubah.',
                                  helperColor: Colors.orange.shade700,
                                  readOnly: true,
                                   suffixIcon: Icon(Icons.lock_outline_rounded, size: 20, color: iconColorOnLightBg.withOpacity(0.5))
                                ),
                                keyboardType: TextInputType.emailAddress,
                              ),
                              const SizedBox(height: 24),
                              Divider(color: dividerColor.withOpacity(0.6), thickness: 1), // Divider lebih terlihat
                              const SizedBox(height: 16),
                              Text(
                                'Ubah Password',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: primaryBlue,
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: !_showPassword,
                                decoration: themedFormFieldDecoration(
                                  'Password Baru',
                                  Icons.lock_outline_rounded,
                                  helperText:
                                      'Kosongkan jika tidak ingin mengubah password. Min 8 karakter.',
                                  suffixIcon: IconButton(
                                    icon: Icon(_showPassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined),
                                    onPressed: () {
                                      setState(() {
                                        _showPassword = !_showPassword;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _confirmPasswordController,
                                obscureText: !_showConfirmPassword,
                                decoration: themedFormFieldDecoration(
                                  'Konfirmasi Password Baru',
                                  Icons.lock_person_outlined, // Ikon berbeda
                                  helperText: 'Ulangi password baru jika diisi.',
                                  suffixIcon: IconButton(
                                    icon: Icon(_showConfirmPassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined),
                                    onPressed: () {
                                      setState(() {
                                        _showConfirmPassword =
                                            !_showConfirmPassword;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Tombol Aksi
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.settings_backup_restore_rounded,
                                    size: 20),
                                onPressed: _isUpdating ? null : _resetForm,
                                style: OutlinedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  side: BorderSide(
                                      color: primaryBlue.withOpacity(0.7)),
                                  foregroundColor: primaryBlue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                ),
                                label: const Text('Reset Password',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: ElevatedButton.icon(
                                icon: _isUpdating
                                    ? Container(
                                        width: 18,
                                        height: 18,
                                        margin: const EdgeInsets.only(right: 8),
                                        child: const CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.white)))
                                    : const Icon(Icons.save_alt_rounded, size: 20),
                                onPressed: _isUpdating ? null : _updateProfile,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryBlue,
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  elevation: 2,
                                ),
                                label: Text(
                                    _isUpdating
                                        ? 'Menyimpan...'
                                        : 'Simpan Password',
                                    style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16), // Tambahan padding bawah
                      ],
                    ),
                  ),
                ),
    );
  }
}