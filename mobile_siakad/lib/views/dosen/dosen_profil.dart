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

class _DosenProfilPageState extends State<DosenProfilPage> {
  final Color primaryBlue = const Color(0xFF133B7A);

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
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _showPassword = false;
  bool _showConfirmPassword = false;

  @override
  void initState() {
    super.initState();
    final apiClient = ApiClient(http.Client());
    _dosenService = DosenProfileService(apiClient);
    _loadDosenProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nidnController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadDosenProfile() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('🔄 Loading dosen profile on DosenProfilPage...');
      final profile = await _dosenService.getProfile();
      print('✅ Profile loaded successfully on DosenProfilPage: ${profile.name}');
      if (mounted) {
        setState(() {
          _dosenProfile = profile;
          _nameController.text = profile.name;
          _nidnController.text = profile.nidn;
          _emailController.text = profile.email;
          _passwordController.clear();
          _confirmPasswordController.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Gagal memuat profil: ${e.toString()}";
        });
      }
      print('Error loading dosen profile on DosenProfilPage: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateProfile() async {
    if (_dosenProfile == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data profil belum dimuat')),
        );
      }
      return;
    }

    // Nama tidak lagi diambil untuk diupdate dari sini
    // final newName = _nameController.text.trim(); 
    final newPassword = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // Jika password tidak diisi, tidak ada yang perlu diupdate dari halaman ini
    if (newPassword.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Masukkan password baru jika ingin mengubah.')),
        );
      }
      return;
    }

    // Validasi Password
    if (newPassword.length < 8) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password minimal 8 karakter')),
        );
      }
      return;
    }
    if (newPassword != confirmPassword) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Konfirmasi password tidak cocok')),
        );
      }
      return;
    }

    setState(() {
      _isUpdating = true;
    });

    try {
      // Panggil service HANYA dengan password dan konfirmasinya
      // Asumsi DosenProfileService.updateProfile mendukung parameter name opsional
      // atau Anda memiliki method khusus untuk update password.
      // Jika DosenProfileService.updateProfile tetap memerlukan 'name', kirim nama yang ada:
      // name: _dosenProfile!.name, 
      await _dosenService.updateProfile(
        // name: null, // Atau jangan sertakan parameter name sama sekali jika service mendukungnya
        // Atau jika service Anda diubah agar name opsional:
        // name: _dosenProfile?.name, // Kirim nama yang ada jika service membutuhkannya
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

      // Muat ulang profil untuk memastikan data (terutama 'updated_at') fresh
      // dan untuk mengosongkan field password.
      await _loadDosenProfile(); 

      // Setelah profil dimuat ulang (dan _dosenProfile di-setState),
      // kembalikan _dosenProfile yang sudah fresh ke halaman sebelumnya.
      if (mounted && _dosenProfile != null) {
        Navigator.pop(context, _dosenProfile);
      } else if (mounted) {
        Navigator.pop(context); // Fallback jika _dosenProfile null
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
      print("Error updating password: $e");
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
      // Nama, NIDN, Email tidak di-reset karena read-only dan sudah terisi dari _loadDosenProfile
      // _nameController.text = _dosenProfile?.name ?? '';
      // _emailController.text = _dosenProfile?.email ?? '';
      // _nidnController.text = _dosenProfile?.nidn ?? '';
      setState(() {
        _passwordController.clear();
        _confirmPasswordController.clear();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Form password telah di-reset'), duration: Duration(seconds: 2)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    InputDecoration formFieldDecoration(String label, IconData prefixIcon, {Widget? suffixIcon, String? helperText, Color? helperColor, bool readOnly = false}) {
      return InputDecoration(
        labelText: label,
        helperText: helperText,
        helperStyle: TextStyle(color: helperColor ?? Colors.grey[600], fontSize: 12),
        border: const OutlineInputBorder(),
        prefixIcon: Icon(prefixIcon),
        suffixIcon: suffixIcon,
        filled: readOnly,
        fillColor: readOnly ? Colors.grey[200] : null,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan Profil', style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Pastikan _dosenProfile yang mungkin sudah di-refresh oleh _loadDosenProfile
            // dikembalikan jika ada perubahan (meskipun di sini hanya password)
            // atau jika pengguna hanya ingin kembali tanpa menyimpan.
            // Jika _updateProfile sudah memanggil Navigator.pop dengan data, ini mungkin tidak perlu.
            // Namun, jika pengguna menekan tombol back standar, ini akan dijalankan.
            Navigator.pop(context, _dosenProfile); 
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading || _isUpdating ? null : _loadDosenProfile,
            tooltip: 'Refresh Data',
          ),
          if (!_isLoading && _dosenProfile != null)
            IconButton(
              icon: const Icon(Icons.restore),
              onPressed: _isUpdating ? null : _resetForm, // Hanya reset field password
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
                  const SizedBox(height: 16),
                  const Text('Memuat data profil...'),
                ],
              ),
            )
          : _errorMessage != null
              ? Center(
                  // ... (Error UI, sama seperti sebelumnya) ...
                   child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadDosenProfile,
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Card(
                        // ... (Profile Header Card, sama seperti sebelumnya, menampilkan _dosenProfile?.name) ...
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [primaryBlue, primaryBlue.withOpacity(0.7)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              const CircleAvatar(
                                radius: 50,
                                backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=3'),
                                backgroundColor: Colors.white,
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
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Informasi Profil (Data Tetap)', // Judul diubah
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: _nameController,
                                readOnly: true, // Nama read-only
                                decoration: formFieldDecoration(
                                  'Nama Lengkap',
                                  Icons.person,
                                  helperText: 'Data nama tidak dapat diubah dari halaman ini.',
                                  helperColor: Colors.grey[600],
                                  readOnly: true,
                                  suffixIcon: const Icon(Icons.lock, color: Colors.grey, size: 20)
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _nidnController,
                                readOnly: true,
                                decoration: formFieldDecoration(
                                  'NIDN',
                                  Icons.badge,
                                  helperText: 'NIDN adalah data tetap.',
                                  helperColor: Colors.orange[600],
                                  readOnly: true,
                                   suffixIcon: const Icon(Icons.lock, color: Colors.grey, size: 20)
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _emailController,
                                readOnly: true, // Email read-only
                                decoration: formFieldDecoration(
                                  'Email',
                                  Icons.email,
                                  helperText: 'Data email tidak dapat diubah dari halaman ini.',
                                  helperColor: Colors.grey[600],
                                  readOnly: true,
                                   suffixIcon: const Icon(Icons.lock, color: Colors.grey, size: 20)
                                ),
                                keyboardType: TextInputType.emailAddress,
                              ),
                              const SizedBox(height: 24),
                              const Text(
                                'Ubah Password',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: !_showPassword,
                                decoration: formFieldDecoration(
                                  'Password Baru',
                                  Icons.lock_outline,
                                  helperText: 'Kosongkan jika tidak ingin mengubah password.',
                                  suffixIcon: IconButton(
                                    icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility),
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
                                decoration: formFieldDecoration(
                                  'Konfirmasi Password Baru',
                                  Icons.lock,
                                  helperText: 'Ulangi password baru jika diisi.',
                                  suffixIcon: IconButton(
                                    icon: Icon(_showConfirmPassword ? Icons.visibility_off : Icons.visibility),
                                    onPressed: () {
                                      setState(() {
                                        _showConfirmPassword = !_showConfirmPassword;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _isUpdating ? null : _resetForm, // Hanya reset password fields
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                side: BorderSide(color: primaryBlue),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: Text('Reset Password', style: TextStyle(color: primaryBlue)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: _isUpdating ? null : _updateProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryBlue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: _isUpdating
                                  ? const Row(
                                      // ... (Loading indicator, sama seperti sebelumnya) ...
                                       mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Text('Menyimpan...'),
                                      ],
                                    )
                                  : const Text(
                                      'Simpan Password', // Teks tombol diubah
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
    );
  }
}