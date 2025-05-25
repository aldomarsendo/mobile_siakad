import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Ditambahkan untuk format tanggal
import 'package:mobile_siakad/views/mahasiswa/mahasiswa_jadwal.dart';
import 'package:mobile_siakad/views/mahasiswa/mahasiswa_nilai.dart';
import 'package:mobile_siakad/views/mahasiswa/mahasiswa_frs.dart';
import 'package:mobile_siakad/views/mahasiswa/mahasiswa_profil.dart';
import 'package:mobile_siakad/services/auth_service.dart';
import 'package:mobile_siakad/models/user_model.dart';
import 'package:mobile_siakad/services/mahasiswa/mahasiswa_profile_service.dart';
import 'package:mobile_siakad/models/mahasiswa_model.dart';
import 'package:mobile_siakad/views/auth/login.dart';
import 'package:mobile_siakad/services/api_client.dart';
import 'package:http/http.dart' as http;
// Import model MataKuliah jika struktur datanya sama atau mirip dengan jadwal dosen
// Jika berbeda, Anda mungkin memerlukan model khusus untuk jadwal mahasiswa.
import 'package:mobile_siakad/models/matakuliah_model.dart';
// Jika ada service khusus untuk jadwal mahasiswa, import di sini
// import 'package:mobile_siakad/services/mahasiswa/mahasiswa_jadwal_service.dart';

class MahasiswaDashboardPage extends StatefulWidget {
  const MahasiswaDashboardPage({super.key});

  @override
  State<MahasiswaDashboardPage> createState() => _MahasiswaDashboardPageState();
}

class _MahasiswaDashboardPageState extends State<MahasiswaDashboardPage> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Color primaryBlue = const Color(0xFF133B7A);
  final Color secondaryBlue = const Color(0xFF1E5BB0);

  User? _currentUser;
  Mahasiswa? _mahasiswaProfile;
  List<MataKuliah> _jadwalHariIni = []; // Diasumsikan menggunakan MataKuliah model
  bool _isLoading = true;
  String? _errorMessage;

  late final AuthService _authService;
  late final MahasiswaProfileService _profileService;
  // late final MahasiswaJadwalService _jadwalService; // Jika ada service jadwal mahasiswa

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    final apiClient = ApiClient(http.Client());
    _authService = AuthService(apiClient);
    _profileService = MahasiswaProfileService(apiClient);
    // _jadwalService = MahasiswaJadwalService(_authService, apiClient); // Inisialisasi jika ada

    _loadInitialData();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData({bool isRefresh = false}) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      if (!isRefresh) _errorMessage = null;
    });

    try {
      final userFuture = _authService.getCurrentUser();
      final mahasiswaProfileFuture = _profileService.getProfile();
      // final semuaMataKuliahFuture = _jadwalService.getJadwalMahasiswa(); // Panggil service jadwal mahasiswa

      // Untuk saat ini, karena service jadwal mahasiswa tidak ada, kita set _jadwalHariIni jadi kosong
      // Ganti bagian ini jika service sudah ada
      final results = await Future.wait([
        userFuture,
        mahasiswaProfileFuture,
        // semuaMataKuliahFuture,
      ]);

      final User? user = results[0] as User?;
      final Mahasiswa? mahasiswa = results[1] as Mahasiswa?;
      // final List<MataKuliah> semuaMataKuliah = results[2] as List<MataKuliah>;

      // Simulasi, karena belum ada service jadwal mahasiswa
      final List<MataKuliah> semuaMataKuliah = []; 
      
      final String hariIniString = DateFormat('EEEE', 'id_ID').format(DateTime.now());
      final List<MataKuliah> filteredJadwal = semuaMataKuliah
          .where((mk) => mk.hari.toLowerCase() == hariIniString.toLowerCase())
          .toList();
      filteredJadwal.sort((a, b) => a.jamMulai.compareTo(b.jamMulai));

      if (mounted) {
        setState(() {
          _currentUser = user;
          _mahasiswaProfile = mahasiswa;
          _jadwalHariIni = filteredJadwal;
        });
      }
    } catch (e) {
      print('Error loading dashboard data: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Gagal memuat data: ${e.toString()}';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleLogout() async {
    try {
      await _authService.logout();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saat logout: $e')),
        );
      }
    }
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryBlue, secondaryBlue],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage: const NetworkImage('https://st3.depositphotos.com/6672868/13701/v/450/depositphotos_137014128-stock-illustration-user-profile-icon.jpg'),
                backgroundColor: Colors.white.withOpacity(0.5),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentUser?.name ?? (_isLoading ? 'Memuat...' : 'Nama Mahasiswa'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      _mahasiswaProfile?.nrp != null
                          ? '${_mahasiswaProfile!.nrp} (Mahasiswa)'
                          : (_isLoading ? '...' : 'NRP Mahasiswa'),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () {
                  _scaffoldKey.currentState?.openEndDrawer();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [primaryBlue, secondaryBlue],
              ),
            ),
            child: _isLoading && (_currentUser == null || _mahasiswaProfile == null)
                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage('https://st3.depositphotos.com/6672868/13701/v/450/depositphotos_137014128-stock-illustration-user-profile-icon.jpg'),
                        backgroundColor: Colors.white.withOpacity(0.5),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _currentUser?.name ?? 'Nama Mahasiswa',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        _mahasiswaProfile?.nrp != null
                            ? '${_mahasiswaProfile!.nrp} (Mahasiswa)'
                            : 'NRP Mahasiswa',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Edit Profil'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MahasiswaProfilPage()),
              ).then((_) {
                _loadInitialData(isRefresh: true); // Refresh data setelah edit profil
              });
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: _handleLogout,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: primaryBlue, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: primaryBlue,
          ),
        ),
      ],
    );
  }

  Widget _buildNewsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Berita Terbaru', Icons.newspaper_outlined), // Icon disamakan
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect( // Menggunakan ClipRRect dengan BorderRadius.all
              borderRadius: const BorderRadius.all(Radius.circular(16)),
              child: Image.asset(
                'assets/images/pens.png',
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcademicMenu() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Akademik', Icons.school_outlined), // Icon disamakan
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _menuButton(context, Icons.calendar_today, "Jadwal", const MahasiswaJadwalPage()),
                _menuButton(context, Icons.grade, "Nilai", const MahasiswaNilaiPage()),
                _menuButton(context, Icons.file_copy, "FRS", const MahasiswaFrsPage()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodaySchedule() {
    String tanggalHariIniText = DateFormat('d MMMM yyyy', 'id_ID').format(DateTime.now());
    String namaHariIniText = DateFormat('EEEE', 'id_ID').format(DateTime.now());

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MahasiswaJadwalPage()),
              );
            },
            child: Row(
              children: [
                _buildSectionHeader('Jadwal Kuliah Hari Ini', Icons.access_time_filled_outlined), // Icon disamakan
                const Spacer(),
                Icon(Icons.arrow_forward_ios, size: 16, color: primaryBlue),
              ],
            ),
          ),
          const SizedBox(height: 8),
           Text(
            '$namaHariIniText, $tanggalHariIniText · ${_jadwalHariIni.length} MATA KULIAH',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 12),
          if (_isLoading && _jadwalHariIni.isEmpty) // Tampilkan loading jika masih memuat dan jadwal kosong
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Center(child: CircularProgressIndicator(color: primaryBlue)),
            )
          else if (!_isLoading && _jadwalHariIni.isEmpty) // Tampilkan pesan jika tidak loading dan jadwal kosong
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Text(
                  'Tidak ada jadwal kuliah hari ini.',
                  style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _jadwalHariIni.length,
              itemBuilder: (context, index) {
                final mk = _jadwalHariIni[index];
                return _classCard(
                  mk.jamMulai.substring(0, 5),
                  mk.jamSelesai.substring(0, 5),
                  mk.namaMk,
                  mk.ruang.namaRuang, // Asumsi struktur RuangModel sama
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _menuButton(BuildContext context, IconData icon, String label, Widget page) {
    return Expanded( // Ditambahkan Expanded
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: primaryBlue.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
              shape: BoxShape.circle,
            ),
            child: Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              child: InkWell(
                borderRadius: BorderRadius.circular(28), // Disesuaikan
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => page),
                  );
                },
                child: CircleAvatar(
                  backgroundColor: primaryBlue,
                  radius: 28, // Disesuaikan
                  child: Icon(icon, color: Colors.white, size: 24), // Disesuaikan
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 13, // Disesuaikan
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _classCard(String start, String end, String subject, String room) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryBlue, secondaryBlue],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$start → $end",
            style: const TextStyle(
              color: Colors.white70, // Disesuaikan
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subject,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.white70, size: 16), // Disesuaikan
              const SizedBox(width: 4),
              Text(
                room,
                style: const TextStyle(
                  color: Colors.white70, // Disesuaikan
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[100],
      endDrawer: _buildDrawer(),
      body: SafeArea(
        child: FadeTransition( // Ditambahkan FadeTransition
          opacity: _fadeAnimation,
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => _loadInitialData(isRefresh: true),
                  color: primaryBlue,
                  child: _isLoading && _jadwalHariIni.isEmpty && _currentUser == null // Kondisi loading awal yang lebih spesifik
                      ? Center(child: CircularProgressIndicator(color: primaryBlue))
                      : _errorMessage != null
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.error_outline, color: Colors.red.shade400, size: 60),
                                    const SizedBox(height: 16),
                                    Text("Oops, terjadi kesalahan!", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red.shade700)),
                                    const SizedBox(height: 8),
                                    Text(_errorMessage!, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600])),
                                    const SizedBox(height: 20),
                                    ElevatedButton.icon(
                                      icon: const Icon(Icons.refresh, color: Colors.white),
                                      label: const Text("Coba Lagi", style: TextStyle(color: Colors.white)),
                                      onPressed: () => _loadInitialData(),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: primaryBlue,
                                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            )
                          : SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 0), // Margin sudah diatur oleh header
                                  _buildNewsSection(),
                                  const SizedBox(height: 24),
                                  _buildAcademicMenu(),
                                  const SizedBox(height: 24),
                                  _buildTodaySchedule(),
                                  const SizedBox(height: 20),
                                ],
                              ),
                            ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}