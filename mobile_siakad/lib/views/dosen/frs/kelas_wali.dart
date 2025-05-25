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

class _KelasWaliPageState extends State<KelasWaliPage> with SingleTickerProviderStateMixin { // Added mixin
  Dosen? _dosenProfile;
  List<Kelas> _kelasWaliList = [];
  bool _isLoading = true;
  String? _errorMessage;

  late final DosenProfileService _profileService;
  
  // Palet Warna Akademik
  final Color primaryBlue = const Color(0xFF133B7A);
  final Color textOnLightBg = Colors.black87;
  final Color subtleTextOnLightBg = Colors.grey.shade700;
  late final Color iconColorOnLightBg; 
  late final Color cardShadowColor;

  late AnimationController _animationController; // Added for FadeTransition
  late Animation<double> _fadeAnimation; // Added for FadeTransition


  @override
  void initState() {
    super.initState();

    // Inisialisasi warna turunan
    iconColorOnLightBg = primaryBlue.withOpacity(0.75);
    cardShadowColor = primaryBlue.withOpacity(0.08);

    final apiClient = ApiClient(http.Client());
    _profileService = DosenProfileService(apiClient);
    _fetchDosenProfileAndKelasWali();

    // Initialize AnimationController
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
     WidgetsBinding.instance.addPostFrameCallback((_) {
      if(mounted) _animationController.forward();
    });
  }

   @override
  void dispose() {
    _animationController.dispose(); // Dispose AnimationController
    super.dispose();
  }


  Future<void> _fetchDosenProfileAndKelasWali() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _kelasWaliList = []; // Kosongkan list sebelum fetch baru
    });

    try {
      final profile = await _profileService.getProfile();
      if (mounted) {
        setState(() {
          _dosenProfile = profile;
          if (profile.isDosenWali && profile.kelasWali != null) {
            _kelasWaliList = profile.kelasWali!;
             // Urutkan kelas wali berdasarkan nama kelas
            _kelasWaliList.sort((a, b) => a.namaKelas.toLowerCase().compareTo(b.namaKelas.toLowerCase()));
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
      backgroundColor: Colors.grey[100], // Themed scaffold background
      appBar: AppBar(
        title: const Text(
            'Kelas Perwalian', 
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 18)
        ),
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 1.0,
        centerTitle: true,
      ),
      body: FadeTransition( // Added FadeTransition
        opacity: _fadeAnimation,
        child: RefreshIndicator(
          onRefresh: _fetchDosenProfileAndKelasWali,
          color: primaryBlue,
          child: _buildContent(),
        ),
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
            Text('Memuat data kelas wali...', style: TextStyle(color: subtleTextOnLightBg, fontSize: 15)),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorWidget(); // Menggunakan helper widget error
    }

    if (_dosenProfile == null || !_dosenProfile!.isDosenWali) {
      return _buildEmptyOrNotDosenWaliWidget(
        icon: Icons.info_outline_rounded,
        title: 'Informasi Perwalian',
        message: 'Anda bukan dosen wali atau data profil tidak berhasil dimuat.',
      );
    }

    if (_kelasWaliList.isEmpty) {
      return _buildEmptyOrNotDosenWaliWidget(
        icon: Icons.school_outlined, // Atau Icons.no_meeting_room_outlined
        title: 'Tidak Ada Kelas Wali',
        message: 'Saat ini tidak ada kelas yang Anda ampu sebagai dosen wali.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      itemCount: _kelasWaliList.length,
      itemBuilder: (context, index) {
        final kelas = _kelasWaliList[index];
        return _buildKelasCard(kelas);
      },
    );
  }

  Widget _buildKelasCard(Kelas kelas) {
    return Card(
      elevation: 1.5,
      shadowColor: cardShadowColor,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(10.0),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailKelasWaliPage(kelas: kelas),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.groups_2_outlined, color: primaryBlue, size: 34), // Ikon yang lebih cocok untuk "wali"
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      kelas.namaKelas,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textOnLightBg,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Status: ${kelas.status}',
                       style: TextStyle(fontSize: 13, color: subtleTextOnLightBg),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400, size: 28),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, color: Colors.red.shade400, size: 70),
            const SizedBox(height: 15),
            Text(
              "Gagal Memuat Data",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red.shade700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? "Terjadi kesalahan yang tidak diketahui.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text("Coba Lagi", style: TextStyle(color: Colors.white, fontSize: 15)),
              onPressed: _fetchDosenProfileAndKelasWali,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyOrNotDosenWaliWidget({required IconData icon, required String title, required String message}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 15),
            Text(
              title,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.grey.shade500),
              ),
            ),
          ],
        ),
      ));
  }
}