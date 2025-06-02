import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_siakad/views/dosen/dosen_jadwal.dart';
import 'package:mobile_siakad/views/dosen/dosen_profil.dart';
import 'package:mobile_siakad/services/auth_service.dart';
import 'package:mobile_siakad/models/user_model.dart';
import 'package:mobile_siakad/services/dosen/dosen_profile_service.dart';
import 'package:mobile_siakad/models/dosen_model.dart';
import 'package:mobile_siakad/views/auth/login.dart';
import 'package:mobile_siakad/services/api_client.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_siakad/services/dosen/dosen_jadwal_service.dart';
import 'package:mobile_siakad/models/matakuliah_model.dart';
import 'package:mobile_siakad/views/dosen/frs/kelas_wali.dart';
import 'package:mobile_siakad/views/dosen/nilai/list_matakuliah.dart';
import 'package:mobile_siakad/services/dosen/dosen_berita_service.dart';
import 'package:mobile_siakad/models/berita_model.dart';
import 'package:mobile_siakad/views/dosen/dosen_berita_detail.dart';

class DosenDashboardPage extends StatefulWidget {
  const DosenDashboardPage({super.key});

  @override
  State<DosenDashboardPage> createState() => _DosenDashboardPageState();
}

class _DosenDashboardPageState extends State<DosenDashboardPage> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Color primaryBlue = const Color(0xFF133B7A);
  final Color secondaryBlue = const Color(0xFF1E5BB0);
  final PageController _pageController = PageController();

  // Warna-warna ini tidak lagi didefinisikan di sini,
  // karena kita kembali ke skema warna asli dari "Design 4 - Filled Tonal Card"
  // yang menggunakan variasi dari primaryBlue.

  User? _currentUser;
  Dosen? _dosenProfile;
  List<MataKuliah> _jadwalHariIni = [];
  List<Berita> _beritaList = [];
  int _currentBeritaIndex = 0;
  bool _isLoading = true;
  String? _errorMessage;

  late final AuthService _authService;
  late final DosenProfileService _profileService;
  late final DosenJadwalService _jadwalService;
  late final DosenBeritaService _beritaService;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    final apiClient = ApiClient(http.Client());
    _authService = AuthService(apiClient);
    _profileService = DosenProfileService(apiClient);
    _jadwalService = DosenJadwalService(_authService, apiClient);
    _beritaService = DosenBeritaService(_authService, apiClient);
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
    _pageController.dispose();
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
      final dosenProfileFuture = _profileService.getProfile();
      final semuaMataKuliahFuture = _jadwalService.getMataKuliah();
      final beritaFuture = _beritaService.getBerita();

      final results = await Future.wait([
        userFuture,
        dosenProfileFuture,
        semuaMataKuliahFuture,
        beritaFuture,
      ]);

      final User? user = results[0] as User?;
      final Dosen? dosen = results[1] as Dosen?;
      final List<MataKuliah> semuaMataKuliah = results[2] as List<MataKuliah>;
      final BeritaResponse beritaResponse = results[3] as BeritaResponse;
      
      final now = DateTime.now();
      final String hariIniString = DateFormat('EEEE', 'id_ID').format(now);

      final List<MataKuliah> filteredJadwal = semuaMataKuliah
          .where((mk) => mk.hari.toLowerCase() == hariIniString.toLowerCase())
          .toList();
      filteredJadwal.sort((a, b) => a.jamMulai.compareTo(b.jamMulai));

      if (mounted) {
        setState(() {
          _currentUser = user;
          _dosenProfile = dosen;
          _jadwalHariIni = filteredJadwal;
          _beritaList = beritaResponse.data;
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
                backgroundImage: NetworkImage('https://st3.depositphotos.com/6672868/13701/v/450/depositphotos_137014128-stock-illustration-user-profile-icon.jpg'),
                backgroundColor: Colors.white.withOpacity(0.5),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentUser?.name ?? (_isLoading ? 'Memuat...' : 'Nama Dosen'),
                      style: const TextStyle(
                        color: Colors.white, 
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      _dosenProfile?.nidn != null 
                          ? '${_dosenProfile!.nidn} (Dosen)' 
                          : (_isLoading ? '...' : 'NIDN Dosen'),
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
            child: _isLoading && (_currentUser == null || _dosenProfile == null)
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
                        _currentUser?.name ?? 'Nama Dosen',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16
                        ),
                      ),
                      Text(
                        _dosenProfile?.nidn != null 
                            ? '${_dosenProfile!.nidn} (Dosen)' 
                            : 'NIDN Dosen',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14
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
                MaterialPageRoute(builder: (context) => const DosenProfilPage()),
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
          _buildSectionHeader('Berita & Pengumuman', Icons.article_outlined),
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
          _buildSectionHeader('Berita & Pengumuman', Icons.article_outlined),
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

  final int itemCount = _beritaList.length > 5 ? 5 : _beritaList.length;

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0), 
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: _buildSectionHeader('Berita & Pengumuman', Icons.article_outlined),
        ),
        const SizedBox(height: 12),
        Stack( // Menggunakan Stack untuk menempatkan indikator di atas PageView
          children: [
            Container(
              height: 200, // Tinggi section berita yang sudah disesuaikan sebelumnya
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentBeritaIndex = index;
                  });
                },
                itemCount: itemCount, 
                itemBuilder: (context, index) {
                  final berita = _beritaList[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0), 
                    child: _buildBeritaCard(berita),
                  );
                },
              ),
            ),
            if (itemCount > 1)
              Positioned(
                bottom: 12.0, // Jarak indikator dari bawah
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    itemCount, 
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentBeritaIndex == index ? 12 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentBeritaIndex == index
                            ? primaryBlue 
                            : primaryBlue.withOpacity(0.4), 
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    ),
  );
}

// Mengembalikan _buildBeritaCard ke versi "Design 4 - Filled Tonal Card"
// dengan maxLines: 2 untuk isi berita
Widget _buildBeritaCard(Berita berita) {
  final String formattedDate = DateFormat('d MMM yy', 'id_ID').format(berita.publishedAt.toLocal()); 
  
  return GestureDetector(
    onTap: () {
      print('Baca Selengkapnya: ID ${berita.slug}');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DosenBeritaDetailPage(
            beritaId: berita.slug,
            initialTitle: berita.judul,
          ),
        ),
      );
    },
    child: Container(
      decoration: BoxDecoration(
        color: primaryBlue.withOpacity(0.08), // Warna background tonal asli
        borderRadius: BorderRadius.circular(16.0), 
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(0.05), // Shadow asli
            blurRadius: 10,
            offset: const Offset(0, 4), // Bisa juga (0,5) seperti di awal
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: primaryBlue.withOpacity(0.15), // Warna chip asli
                    borderRadius: BorderRadius.circular(20), 
                  ),
                  child: Text(
                    berita.targetRole?.toUpperCase() ?? 'UMUM',
                    style: TextStyle(
                      color: primaryBlue, // Warna teks chip asli
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  formattedDate,
                  style: TextStyle(
                    color: primaryBlue.withOpacity(0.9), // Warna tanggal asli
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              berita.judul ?? 'Tanpa Judul',
              style: TextStyle(
                color: Color(0xFF0A2A57), // Warna judul asli (atau primaryBlue)
                fontSize: 15.5, 
                fontWeight: FontWeight.bold, 
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6), 
            Expanded(
              child: Text(
                berita.isi ?? '',
                style: TextStyle(
                  color: Colors.black.withOpacity(0.75), // Warna isi asli
                  fontSize: 13, 
                  height: 1.4,
                ),
                maxLines: 2, // Dipertahankan 2 baris untuk mencegah overflow
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 8), // Spasi sebelum tombol "Selengkapnya"
            Align(
              alignment: Alignment.bottomRight,
              child: TextButton.icon(
                icon: Icon(Icons.arrow_forward_ios, size: 11, color: primaryBlue),
                label: Text(
                  'Selengkapnya',
                  style: TextStyle(
                    color: primaryBlue, // Warna tombol asli
                    fontSize: 12, 
                    fontWeight: FontWeight.w600, 
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal:10, vertical: 5),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                ),
                onPressed: () {
                  print('Baca Selengkapnya (from button): ID ${berita.slug}');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DosenBeritaDetailPage(
                        beritaId: berita.slug,
                        initialTitle: berita.judul,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    )
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
                _menuButton(context, Icons.calendar_today, "Jadwal", const DosenJadwalPage()),
                _menuButton(context, Icons.grade, "Nilai", const ListMatakuliahPage()),
                _menuButton(context, Icons.file_copy, "FRS Wali", const KelasWaliPage()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodaySchedule() {
    final now = DateTime.now();
    final String tanggalHariIniText = DateFormat('d MMMM yyyy', 'id_ID').format(now.toLocal());
    final String namaHariIniText = DateFormat('EEEE', 'id_ID').format(now.toLocal());

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DosenJadwalPage()),
              );
            },
            child: Row(
              children: [
                _buildSectionHeader('Jadwal Mengajar Hari Ini', Icons.access_time_filled_outlined),
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
            )
          ),
          const SizedBox(height: 12),
          if (_jadwalHariIni.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Text(
                  'Tidak ada jadwal mengajar hari ini.',
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
                  mk.jamMulai.substring(0,5), 
                  mk.jamSelesai.substring(0,5), 
                  mk.namaMk, 
                  mk.ruang.namaRuang,
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
                room.isNotEmpty ? room : 'N/A', 
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          if (dosenPengampu != null && dosenPengampu.isNotEmpty && dosenPengampu.toLowerCase() != 'n/a')
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