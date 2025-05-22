import 'package:flutter/material.dart';
import 'package:mobile_siakad/services/dosen_service.dart';
import 'package:mobile_siakad/models/dosen_model.dart';

class DosenProfilPage extends StatefulWidget {
  const DosenProfilPage({super.key});

  @override
  State<DosenProfilPage> createState() => _DosenProfilPageState();
}

class _DosenProfilPageState extends State<DosenProfilPage> {
  final Color primaryBlue = Color(0xFF133B7A);
  Dosen? _dosenProfile;
  final DosenService _dosenService = DosenService();
  bool _isLoading = true;
  String? _errorMessage;
  bool _isUpdating = false;

  // Controllers untuk form fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nidnController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
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
      if (profile != null) {
        print('✅ Profile loaded successfully: ${profile.name}');
        setState(() {
          _dosenProfile = profile;
          // PENTING: Set nilai awal di controllers dengan data dari API
          _nameController.text = profile.name;
          _nidnController.text = profile.nidn;
          _emailController.text = profile.email;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Profile data is null - Check API response';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          duration: Duration(seconds: 5),
        ),
      );
    }
  }

  Future<void> _updateProfile() async {
    if (_dosenProfile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile data not loaded')),
      );
      return;
    }

    // Validasi input
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nama tidak boleh kosong')),
      );
      return;
    }

    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Email tidak boleh kosong')),
      );
      return;
    }

    // Validasi format email
    if (!_isValidEmail(_emailController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Format email tidak valid')),
      );
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
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile berhasil diperbarui'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Reload profile setelah update untuk mendapatkan data terbaru
      await _loadDosenProfile();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating profile: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ),
      );
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void _resetForm() {
    if (_dosenProfile != null) {
      _nameController.text = _dosenProfile!.name;
      _emailController.text = _dosenProfile!.email;
      _nidnController.text = _dosenProfile!.nidn;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pengaturan Profil', style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadDosenProfile,
            tooltip: 'Refresh Data',
          ),
          if (!_isLoading && _dosenProfile != null)
            IconButton(
              icon: Icon(Icons.restore),
              onPressed: _resetForm,
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
                  SizedBox(height: 16),
                  Text('Memuat data profil...'),
                ],
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red),
                      SizedBox(height: 16),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadDosenProfile,
                        child: Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Avatar section dengan info user
                      Card(
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
                          padding: EdgeInsets.all(24),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=3'),
                                backgroundColor: Colors.white,
                              ),
                              SizedBox(height: 16),
                              Text(
                                _dosenProfile?.name ?? 'N/A',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'NIDN: ${_dosenProfile?.nidn ?? 'N/A'}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                _dosenProfile?.email ?? 'N/A',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 20),
                      
                      // Form edit profile
                      Card(
                        elevation: 2,
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Edit Informasi Profil',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 16),
                              
                              // Nama field - BISA DIEDIT, sudah terisi nilai awal
                              TextFormField(
                                controller: _nameController,
                                decoration: InputDecoration(
                                  labelText: 'Nama Lengkap',
                                  helperText: 'Nama saat ini: ${_dosenProfile?.name ?? 'Tidak tersedia'}',
                                  helperStyle: TextStyle(
                                    color: Colors.blue[600],
                                    fontSize: 12,
                                  ),
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.person),
                                  suffixIcon: _nameController.text.isNotEmpty
                                      ? Icon(Icons.edit, color: primaryBlue, size: 20)
                                      : null,
                                ),
                                onChanged: (value) {
                                  setState(() {}); // Untuk update suffixIcon
                                },
                              ),
                              SizedBox(height: 16),
                              
                              // NIDN field - READONLY, hanya untuk info
                              TextFormField(
                                controller: _nidnController,
                                readOnly: true,
                                decoration: InputDecoration(
                                  labelText: 'NIDN (Tidak dapat diubah)',
                                  helperText: 'NIDN adalah data tetap yang tidak dapat diubah',
                                  helperStyle: TextStyle(
                                    color: Colors.orange[600],
                                    fontSize: 12,
                                  ),
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.badge),
                                  suffixIcon: Icon(Icons.lock, color: Colors.grey, size: 20),
                                  filled: true,
                                  fillColor: Colors.grey[100],
                                ),
                              ),
                              SizedBox(height: 16),
                              
                              // Email field - BISA DIEDIT, sudah terisi nilai awal
                              TextFormField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  helperText: 'Email saat ini: ${_dosenProfile?.email ?? 'Tidak tersedia'}',
                                  helperStyle: TextStyle(
                                    color: Colors.blue[600],
                                    fontSize: 12,
                                  ),
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.email),
                                  suffixIcon: _emailController.text.isNotEmpty && _isValidEmail(_emailController.text)
                                      ? Icon(Icons.check_circle, color: Colors.green, size: 20)
                                      : _emailController.text.isNotEmpty
                                          ? Icon(Icons.error, color: Colors.red, size: 20)
                                          : Icon(Icons.edit, color: primaryBlue, size: 20),
                                ),
                                keyboardType: TextInputType.emailAddress,
                                onChanged: (value) {
                                  setState(() {}); // Untuk update suffixIcon
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 24),
                      
                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _isUpdating ? null : _resetForm,
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                side: BorderSide(color: primaryBlue),
                              ),
                              child: Text(
                                'Reset',
                                style: TextStyle(color: primaryBlue),
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: _isUpdating ? null : _updateProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryBlue,
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: _isUpdating
                                  ? Row(
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
                                  : Text(
                                      'Simpan Perubahan',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: 16),
                      
                      // Info card
                      Card(
                        color: Colors.blue[50],
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.blue[700]),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Form sudah terisi dengan data profil Anda saat ini. Anda dapat mengubah Nama dan Email, kemudian klik "Simpan Perubahan".',
                                  style: TextStyle(
                                    color: Colors.blue[700],
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}