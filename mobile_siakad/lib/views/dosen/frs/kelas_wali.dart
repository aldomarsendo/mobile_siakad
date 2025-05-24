// views/dosen/frs/kelas_wali.dart
import 'package:flutter/material.dart';
import 'package:mobile_siakad/models/dosen_model.dart';
import 'package:mobile_siakad/models/mahasiswa_model.dart'; // Pastikan Kelas model ada di sini atau diimpor dari path yang benar
import 'package:mobile_siakad/services/api_client.dart';
import 'package:mobile_siakad/services/dosen/dosen_profile_service.dart';
import 'package:http/http.dart' as http;
import 'detail_kelas_wali.dart'; // <-- IMPORT HALAMAN DETAIL KELAS WALI

class KelasWaliPage extends StatefulWidget {
  const KelasWaliPage({super.key});

  @override
  State<KelasWaliPage> createState() => _KelasWaliPageState();
}

class _KelasWaliPageState extends State<KelasWaliPage> {
  Dosen? _dosenProfile;
  List<Kelas> _kelasWaliList = [];
  bool _isLoading = true;
  String? _errorMessage;

  late final DosenProfileService _profileService;
  final Color primaryBlue = const Color(0xFF133B7A);

  @override
  void initState() {
    super.initState();
    final apiClient = ApiClient(http.Client());
    _profileService = DosenProfileService(apiClient);
    _fetchDosenProfileAndKelasWali();
  }

  Future<void> _fetchDosenProfileAndKelasWali() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _kelasWaliList = [];
    });

    try {
      final profile = await _profileService.getProfile();
      if (mounted) {
        setState(() {
          _dosenProfile = profile;
          if (profile.isDosenWali && profile.kelasWali != null) {
            _kelasWaliList = profile.kelasWali!;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Gagal memuat data: ${e.toString()}';
        });
      }
      print('Error fetching dosen profile for KelasWaliPage: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelas Perwalian'),
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white, // Agar ikon dan teks AppBar putih
      ),
      body: RefreshIndicator(
        onRefresh: _fetchDosenProfileAndKelasWali,
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: primaryBlue),
            const SizedBox(height: 16),
            const Text('Memuat data kelas wali...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 50),
              const SizedBox(height: 10),
              Text(_errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _fetchDosenProfileAndKelasWali,
                child: const Text("Coba Lagi"),
              ),
            ],
          ),
        ),
      );
    }

    if (_dosenProfile == null || !_dosenProfile!.isDosenWali) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Anda bukan dosen wali atau data profil tidak termuat.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    if (_kelasWaliList.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Tidak ada kelas yang Anda wali saat ini.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: _kelasWaliList.length,
      itemBuilder: (context, index) {
        final kelas = _kelasWaliList[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            leading: Icon(Icons.class_outlined, color: primaryBlue, size: 30),
            title: Text(
              kelas.namaKelas,
              style: TextStyle(fontWeight: FontWeight.bold, color: primaryBlue),
            ),
            subtitle: Text('Status: ${kelas.status}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigasi ke DetailKelasWaliPage dengan mengirim objek Kelas
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailKelasWaliPage(kelas: kelas),
                ),
              );
            },
          ),
        );
      },
    );
  }
}