import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_siakad/views/dosen/dosen_jadwal.dart';
import 'package:mobile_siakad/views/dosen/dosen_nilai.dart';
import 'package:mobile_siakad/views/dosen/dosen_frs.dart';
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

class DosenDashboardPage extends StatefulWidget {
  const DosenDashboardPage({super.key});

  @override
  State<DosenDashboardPage> createState() => _DosenDashboardPageState();
}

class _DosenDashboardPageState extends State<DosenDashboardPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Color primaryBlue = const Color(0xFF133B7A);

  User? _currentUser;
  Dosen? _dosenProfile;
  List<MataKuliah> _jadwalHariIni = [];
  bool _isLoading = true; // Satu flag loading untuk semua data awal
  String? _errorMessage;

  late final AuthService _authService;
  late final DosenProfileService _profileService;
  late final DosenJadwalService _jadwalService;

  @override
  void initState() {
    super.initState();
    final apiClient = ApiClient(http.Client());
    _authService = AuthService(apiClient);
    _profileService = DosenProfileService(apiClient);
    _jadwalService = DosenJadwalService(_authService, apiClient);
    _loadInitialData();
  }

  Future<void> _loadInitialData({bool isRefresh = false}) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      if (!isRefresh) _errorMessage = null;
    });

    try {
      // Ambil data user dan profil dosen secara bersamaan
      final userFuture = _authService.getCurrentUser();
      final dosenProfileFuture = _profileService.getProfile();
      // Ambil semua mata kuliah untuk difilter nanti
      final semuaMataKuliahFuture = _jadwalService.getMataKuliah();

      // Tunggu semua future selesai
      final results = await Future.wait([
        userFuture,
        dosenProfileFuture,
        semuaMataKuliahFuture,
      ]);

      final User? user = results[0] as User?;
      final Dosen? dosen = results[1] as Dosen?;
      final List<MataKuliah> semuaMataKuliah = results[2] as List<MataKuliah>;
      
      final String hariIniString = DateFormat('EEEE', 'id_ID').format(DateTime.now());
      final List<MataKuliah> filteredJadwal = semuaMataKuliah
          .where((mk) => mk.hari.toLowerCase() == hariIniString.toLowerCase())
          .toList();
      filteredJadwal.sort((a, b) => a.jamMulai.compareTo(b.jamMulai));

      if (mounted) {
        setState(() {
          _currentUser = user;
          _dosenProfile = dosen;
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

  @override
  Widget build(BuildContext context) {
    String tanggalHariIniText = DateFormat('d MMMM yy', 'id_ID').format(DateTime.now());
    String namaHariIniText = DateFormat('EEEE', 'id_ID').format(DateTime.now());

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[200],
      appBar: AppBar( // Menggunakan AppBar standar
        backgroundColor: primaryBlue,
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white.withValues(alpha: 0.8),
              radius: 18,
              child: Icon(Icons.person, size: 18, color: primaryBlue),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentUser?.name ?? (_isLoading ? 'Memuat...' : 'Nama Dosen'),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  _dosenProfile?.nidn != null 
                    ? '${_dosenProfile!.nidn} (Dosen)' 
                    : (_isLoading ? '...' : 'NIDN Dosen'),
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              _scaffoldKey.currentState?.openEndDrawer();
            },
          ),
        ],
      ),
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: primaryBlue,
              ),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.white))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.white.withValues(alpha: 0.8),
                          radius: 30,
                          child: Icon(Icons.person, size: 30, color: primaryBlue),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _currentUser?.name ?? 'Nama Dosen',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          _dosenProfile?.nidn != null 
                            ? '${_dosenProfile!.nidn} (Dosen)' 
                            : 'NIDN Dosen',
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
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
                ).then((_) => _loadInitialData(isRefresh: true));
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: _handleLogout,
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadInitialData(isRefresh: true),
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: primaryBlue))
            : _errorMessage != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, color: Colors.red, size: 50),
                          SizedBox(height: 10),
                          Text(_errorMessage!, textAlign: TextAlign.center, style: TextStyle(color: Colors.red)),
                          SizedBox(height: 10),
                          ElevatedButton(onPressed: () => _loadInitialData(), child: Text("Coba Lagi"))
                        ],
                      ),
                    ))
                : ListView( // Menggunakan ListView agar seluruh konten bisa di-scroll
                    children: [
                      // Berita Terbaru
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Berita Terbaru', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                'assets/images/pens.png',
                                height: 150,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Menu Akademik
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Akademik', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withValues(alpha: 0.2),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _menuButton(context, Icons.calendar_today_outlined, "Jadwal", primaryBlue, DosenJadwalPage()),
                                  _menuButton(context, Icons.grade_outlined, "Nilai", primaryBlue, DosenNilaiPage()),
                                  _menuButton(context, Icons.file_copy_outlined, "FRS", primaryBlue, DosenFrsPage()),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Jadwal Kuliah Hari Ini
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Jadwal Kuliah Hari Ini", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            Text('$namaHariIniText, $tanggalHariIniText - ${_jadwalHariIni.length} Mata Kuliah', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_jadwalHariIni.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                          child: Center(
                            child: Text(
                              'Tidak ada jadwal kuliah hari ini.',
                              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                            ),
                          ),
                        )
                      else
                        ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          shrinkWrap: true, // Penting karena di dalam ListView lain
                          physics: const NeverScrollableScrollPhysics(), // Penting
                          itemCount: _jadwalHariIni.length,
                          itemBuilder: (context, index) {
                            final mk = _jadwalHariIni[index];
                            return _classCard(
                                mk.jamMulai.substring(0,5), 
                                mk.jamSelesai.substring(0,5), 
                                mk.namaMk, 
                                mk.ruang.namaRuang, 
                                primaryBlue);
                          },
                        ),
                      const SizedBox(height: 20), // Padding bawah
                    ],
                  ),
      ),
    );
  }

  Widget _menuButton(BuildContext context, IconData icon, String label, Color color, Widget page) {
    return Expanded(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.15),
                radius: 28,
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(fontSize: 13), textAlign: TextAlign.center,),
            ],
          ),
        ),
      ),
    );
  }

  Widget _classCard(String start, String end, String subject, String room, Color color) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: color, width: 5)),
          borderRadius: BorderRadius.circular(12)
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("$start - $end", style: TextStyle(color: Colors.grey[700], fontSize: 13, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text(subject, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, color: Colors.grey[600], size: 14),
                      const SizedBox(width: 4),
                      Text(room, style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}