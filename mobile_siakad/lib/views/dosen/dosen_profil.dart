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
  late final DosenProfileService _dosenService; // Inisialisasi di initState

  // Controllers untuk form fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nidnController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Inisialisasi service di initState
    final apiClient = ApiClient(http.Client());
    _dosenService = DosenProfileService(apiClient);
    
    _loadDosenProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nidnController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadDosenProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('🔄 Loading dosen profile...');
      final profile = await _dosenService.getProfile();
      
      print('✅ Profile loaded successfully: ${profile.name}');
      if (mounted) {
        setState(() {
          _dosenProfile = profile;
          _nameController.text = profile.name;
          _nidnController.text = profile.nidn;
          _emailController.text = profile.email;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Gagal memuat profil: ${e.toString()}";
        });
      }
      print('Error loading dosen profile: $e');
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
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('Profile data not loaded')),
        );
      }
      return;
    }

    if (_nameController.text.trim().isEmpty) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nama tidak boleh kosong')),
        );
      }
      return;
    }

    if (_emailController.text.trim().isEmpty) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email tidak boleh kosong')),
        );
      }
      return;
    }

    if (!_isValidEmail(_emailController.text.trim())) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Format email tidak valid')),
        );
      }
      return;
    }

    setState(() {
      _isUpdating = true;
    });

    try {
      await _dosenService.updateProfile(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
      );
      
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile berhasil diperbarui'),
            backgroundColor: Colors.green,
          ),
        );
      }
      
      await _loadDosenProfile();
    } catch (e) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memperbarui profile: $e'),
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

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void _resetForm() {
    if (_dosenProfile != null) {
      setState(() {
        _nameController.text = _dosenProfile?.name ?? '';
        _emailController.text = _dosenProfile?.email ?? '';
        _nidnController.text = _dosenProfile?.nidn ?? '';
      });
       if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('Form telah di-reset'), duration: Duration(seconds: 2),),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan Profil', style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading || _isUpdating ? null : _loadDosenProfile,
            tooltip: 'Refresh Data',
          ),
          if (!_isLoading && _dosenProfile != null)
            IconButton(
              icon: const Icon(Icons.restore),
              onPressed: _isUpdating ? null : _resetForm,
              tooltip: 'Reset ke Data Asli',
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
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              // PERBAIKAN: Menggunakan withOpacity()
                              colors: [primaryBlue, primaryBlue.withValues(alpha: 0.7)],
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
                                backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=3'), // Ganti dengan URL gambar dosen jika ada
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
                                  // PERBAIKAN: Menggunakan withOpacity()
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _emailController.text.isNotEmpty ? _emailController.text : 'Email Tidak Tersedia',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Form edit profile
                      Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Edit Informasi Profil',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              
                              // Nama field
                              TextFormField(
                                controller: _nameController,
                                decoration: InputDecoration(
                                  labelText: 'Nama Lengkap',
                                  helperText: 'Nama saat ini: ${_dosenProfile?.name ?? 'Tidak tersedia'}',
                                  helperStyle: TextStyle(
                                    color: Colors.blue[600],
                                    fontSize: 12,
                                  ),
                                  border: const OutlineInputBorder(),
                                  prefixIcon: const Icon(Icons.person),
                                ),
                                onChanged: (value) {
                                  // Tidak perlu setState di sini jika hanya untuk validasi visual di suffix
                                },
                              ),
                              const SizedBox(height: 16),
                              
                              // NIDN field
                              TextFormField(
                                controller: _nidnController,
                                readOnly: true,
                                decoration: InputDecoration(
                                  labelText: 'NIDN (Tidak dapat diubah)',
                                  helperText: 'NIDN adalah data tetap',
                                  helperStyle: TextStyle(
                                    color: Colors.orange[600],
                                    fontSize: 12,
                                  ),
                                  border: const OutlineInputBorder(),
                                  prefixIcon: const Icon(Icons.badge),
                                  suffixIcon: const Icon(Icons.lock, color: Colors.grey, size: 20),
                                  filled: true,
                                  fillColor: Colors.grey[100],
                                ),
                              ),
                              const SizedBox(height: 16),
                              
                              // Email field
                              TextFormField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  helperText: 'Email saat ini: ${_dosenProfile?.email ?? 'Tidak tersedia'}',
                                   helperStyle: TextStyle(
                                    color: Colors.blue[600],
                                    fontSize: 12,
                                  ),
                                  border: const OutlineInputBorder(),
                                  prefixIcon: const Icon(Icons.email),
                                  suffixIcon: _emailController.text.isNotEmpty && _isValidEmail(_emailController.text)
                                      ? const Icon(Icons.check_circle, color: Colors.green, size: 20)
                                      : _emailController.text.isNotEmpty
                                          ? const Icon(Icons.error, color: Colors.red, size: 20)
                                          : null, // Tidak perlu ikon edit jika kosong
                                ),
                                keyboardType: TextInputType.emailAddress,
                                onChanged: (value) {
                                  setState(() {}); // Update suffixIcon saat mengetik
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _isUpdating ? null : _resetForm,
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                side: BorderSide(color: primaryBlue),
                              ),
                              child: Text('Reset', style: TextStyle(color: primaryBlue)),
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
                                      'Simpan Perubahan',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16), // Padding bawah
                    ],
                  ),
                ),
    );
  }
}