import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_siakad/views/mahasiswa/frs/mahasiswa_frs_page.dart';
import 'package:mobile_siakad/views/mahasiswa/mahasiswa_berita_detail.dart';
import 'package:mobile_siakad/views/mahasiswa/mahasiswa_jadwal.dart';
import 'package:mobile_siakad/views/mahasiswa/mahasiswa_nilai.dart';
import 'package:mobile_siakad/views/mahasiswa/mahasiswa_profil.dart';
import 'package:mobile_siakad/services/auth_service.dart';
import 'package:mobile_siakad/models/user_model.dart';
import 'package:mobile_siakad/services/mahasiswa/mahasiswa_profile_service.dart';
import 'package:mobile_siakad/models/mahasiswa_profile_model.dart';
import 'package:mobile_siakad/views/auth/login.dart';
import 'package:mobile_siakad/services/api_client.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_siakad/services/mahasiswa/mahasiswa_dashboard_service.dart';
import 'package:mobile_siakad/models/mahasiswa_jadwal_model.dart';
import 'package:mobile_siakad/services/mahasiswa/mahasiswa_berita_service.dart';
import 'package:mobile_siakad/models/berita_model.dart';

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
  MahasiswaProfile? _mahasiswaProfile;
  List<MahasiswaJadwalItem> _jadwalHariIni = [];
  List<Berita> _beritaList = []; 
  bool _isLoading = true;
  String? _errorMessage;

  late final AuthService _authService;
  late final MahasiswaProfileService _profileService;
  late final MahasiswaDashboardService _dashboardService;
  late final MahasiswaBeritaService _beritaService;

  PageController? _pageController; 
  int _currentBeritaIndex = 0;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    final apiClient = ApiClient(http.Client());
    _authService = AuthService(apiClient);
    _profileService = MahasiswaProfileService(apiClient);
    _dashboardService = MahasiswaDashboardService(apiClient: apiClient);
    _beritaService = MahasiswaBeritaService(_authService, apiClient);

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
    _pageController?.dispose();
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
      final jadwalHariIniFuture = _dashboardService.getJadwalHariIni();
      final beritaFuture = _beritaService.getBerita();
      
      final results = await Future.wait([
        userFuture,
        mahasiswaProfileFuture,
        jadwalHariIniFuture,
        beritaFuture,
      ]);

      final User? user = results[0] as User?;
      final MahasiswaProfile? mahasiswaProfile = results[1] as MahasiswaProfile?; 
      final List<MahasiswaJadwalItem> jadwalHariIni = results[2] as List<MahasiswaJadwalItem>;
      final BeritaResponse beritaResponse = results[3] as BeritaResponse;

      if (mounted) {
        setState(() {
          _currentUser = user;
          _mahasiswaProfile = mahasiswaProfile;
          _jadwalHariIni = jadwalHariIni;
          _beritaList = beritaResponse.data;

          if (_beritaList.isNotEmpty) {
            _pageController = PageController(viewportFraction: 0.9); 
          } else {
            _pageController?.dispose(); 
            _pageController = null;
          }
           _currentBeritaIndex = 0; 
        });
      }
    } catch (e) {
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
                _loadInitialData(isRefresh: true);
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
    if (_isLoading && _beritaList.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
        child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             _buildSectionHeader('Berita & Pengumuman', Icons.newspaper_outlined),
             const SizedBox(height: 12),
            Center(child: CircularProgressIndicator(color: primaryBlue)),
          ],
        ),
      );
    }
    if (!_isLoading && _beritaList.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Berita & Pengumuman', Icons.newspaper_outlined),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Center(
                child: Text('Tidak ada berita terbaru', style: TextStyle(fontSize: 15, color: Colors.grey)),
              ),
            )
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0), // Padding vertikal untuk section
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _buildSectionHeader('Berita & Pengumuman', Icons.newspaper_outlined),
          ),
          const SizedBox(height: 12),
          Container(
            height: 200, // Sesuaikan tinggi PageView
            child: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentBeritaIndex = index;
                    });
                  },
                  // Ambil maksimal 5 berita atau semua jika kurang dari 5
                  itemCount: _beritaList.length > 5 ? 5 : _beritaList.length, 
                  itemBuilder: (context, index) {
                    final berita = _beritaList[index];
                    // Padding untuk setiap item di PageView agar tidak terlalu mepet
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0), // Jarak antar kartu berita
                      child: _buildBeritaCard(berita),
                    );
                  },
                ),
                if (_beritaList.length > 1 && (_beritaList.length > 5 ? 5 : _beritaList.length) > 1) // Tampilkan indikator jika item lebih dari 1
                  Positioned(
                    bottom: 10, // Posisi indikator
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _beritaList.length > 5 ? 5 : _beritaList.length, // Jumlah indikator sesuai item yang ditampilkan
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentBeritaIndex == index ? 12 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentBeritaIndex == index
                                ? Colors.white // Warna indikator aktif
                                : Colors.white.withOpacity(0.5), // Warna indikator tidak aktif
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBeritaCard(Berita berita) {
    final String formattedDate = DateFormat('d MMM yy', 'id_ID').format(berita.publishedAt);
  
    return GestureDetector(
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomLeft, // Ubah arah gradient untuk variasi
            end: Alignment.topRight,
            colors: [primaryBlue.withOpacity(0.95), secondaryBlue.withOpacity(0.85)],
          ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
        child: Padding(
        padding: const EdgeInsets.all(12.0), 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3), 
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    berita.targetRole?.toUpperCase() ?? 'UMUM',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9, // Font lebih kecil
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  formattedDate,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 11, 
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8), 

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min, 
                children: [
                  Text(
                    berita.judul ?? 'Tanpa Judul',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15, 
                      fontWeight: FontWeight.bold,
                      height: 1.25,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4), 
                  Flexible(
                    child: Text(
                      berita.isi ?? '',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12.5, 
                        height: 1.35,
                      ),
                      maxLines: 3, 
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: TextButton(
                onPressed: () {
                  print('Baca Selengkapnya: ID ${berita.id}');
                  Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MahasiswaBeritaDetailPage(
                            beritaSlug: berita.slug,
                            initialTitle: berita.judul,
                          ),
                        ),
                      );
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.15),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), 
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  minimumSize: const Size(0, 28), 
                ),
                child: const Text(
                  'Baca Selengkapnya',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11, 
                    fontWeight: FontWeight.w600,
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

  Widget _buildAcademicMenu() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Akademik', Icons.school_outlined),
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
                _buildSectionHeader('Jadwal Kuliah Hari Ini', Icons.access_time_filled_outlined),
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
          if (_isLoading && _jadwalHariIni.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Center(child: CircularProgressIndicator(color: primaryBlue)),
            )
          else if (!_isLoading && _jadwalHariIni.isEmpty)
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
                final jadwal = _jadwalHariIni[index];
                return _classCard(
                  jadwal.jamMulai.length > 5 ? jadwal.jamMulai.substring(0, 5) : jadwal.jamMulai,
                  jadwal.jamSelesai.length > 5 ? jadwal.jamSelesai.substring(0, 5) : jadwal.jamSelesai,
                  jadwal.namaMk,
                  jadwal.ruang,
                  kodeMk: jadwal.kodeMk,
                  dosenPengampu: jadwal.dosenPengampu,
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _menuButton(BuildContext context, IconData icon, String label, Widget page) {
    return Expanded(
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
                borderRadius: BorderRadius.circular(28),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => page),
                  );
                },
                child: CircleAvatar(
                  backgroundColor: primaryBlue,
                  radius: 28,
                  child: Icon(icon, color: Colors.white, size: 24),
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
              fontSize: 13,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  // Update method _classCard untuk menerima parameter tambahan dari MahasiswaJadwalItem
  Widget _classCard(String start, String end, String subject, String room, {String? kodeMk, String? dosenPengampu}) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "$start → $end",
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (kodeMk != null && kodeMk.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    kodeMk,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
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
              const Icon(Icons.location_on, color: Colors.white70, size: 16),
              const SizedBox(width: 4),
              Text(
                room,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          if (dosenPengampu != null && dosenPengampu.isNotEmpty && dosenPengampu != 'N/A')
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                children: [
                  const Icon(Icons.person, color: Colors.white70, size: 16),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      dosenPengampu,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
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
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => _loadInitialData(isRefresh: true),
                  color: primaryBlue,
                  child: _isLoading && _jadwalHariIni.isEmpty && _currentUser == null
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
                                  const SizedBox(height: 0),
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