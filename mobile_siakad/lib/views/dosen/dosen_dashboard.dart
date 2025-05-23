import 'package:flutter/material.dart';
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
  final Color primaryBlue = Color(0xFF133B7A);
  User? _currentUser;
  Dosen? _dosenProfile;
  bool _isLoading = true;
  late AuthService _authService;
  late ApiClient _apiClient;
  late DosenProfileService _profileService;
  late DosenJadwalService _jadwalService;
  List<MataKuliah> _mataKuliah = [];

  @override
  void initState() {
    super.initState();
    _apiClient = ApiClient(http.Client());
    _authService = AuthService(_apiClient);
    _profileService = DosenProfileService(_apiClient);
    _jadwalService = DosenJadwalService(_authService, _apiClient);
    _loadCurrentUser();
    _loadMataKuliah();
  }

  Future<void> _loadCurrentUser() async {
    try {
      setState(() => _isLoading = true);
      final user = await _authService.getCurrentUser();
      setState(() {
        _currentUser = user;
      });

      // Load dosen profile
      final dosen = await _profileService.getProfile();
      setState(() {
        _dosenProfile = dosen;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading user data: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMataKuliah() async {
    try {
      print('=== MULAI MENGAMBIL DATA MATA KULIAH ===');
      final mataKuliah = await _jadwalService.getMataKuliah();
      setState(() {
        _mataKuliah = mataKuliah;
      });
      print('=== SELESAI MENGAMBIL DATA MATA KULIAH ===');
    } catch (e) {
      print('Error loading mata kuliah: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[200],
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: primaryBlue,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.grey[300],
                    child: Icon(Icons.person, size: 40, color: Colors.white),
                    radius: 30,
                  ),
                  SizedBox(height: 10),
                  Text(
                    _currentUser?.name ?? 'Loading...',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${_dosenProfile?.nidn} (Dosen)',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.person_outline),
              title: Text('Edit Profile'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DosenProfilPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () async {
                try {
                  await _authService.logout();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginPage(),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error logging out: $e')),
                  );
                }
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primaryBlue,
                borderRadius: BorderRadius.only(),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=3'),
                      ),
                      SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _currentUser?.name ?? 'Loading...',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${_dosenProfile?.nidn} (Dosen)',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                      Spacer(),
                      IconButton(
                        icon: Icon(Icons.menu, color: Colors.white),
                        onPressed: () {
                          _scaffoldKey.currentState?.openEndDrawer();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Berita Terbaru
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Berita Terbaru', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/images/pens.png',
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
            ),

            // Menu Akademik
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Akademik', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _menuButton(context, Icons.calendar_today, "Jadwal", primaryBlue, DosenJadwalPage()),
                        _menuButton(context, Icons.grade, "Nilai", primaryBlue, DosenNilaiPage()),
                        _menuButton(context, Icons.file_copy, "FRS", primaryBlue, DosenFrsPage()),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),

            // Jadwal Kuliah Hari Ini
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Text("Jadwal kuliah hari ini", style: TextStyle(fontWeight: FontWeight.bold)),
                  Spacer(),
                  Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
            ),
            SizedBox(height: 8),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 16),
                children: [
                  Text("27  Senin · 2 MATA KULIAH", style: TextStyle(fontSize: 12)),
                  SizedBox(height: 8),
                  _classCard("07:00", "09:10", "Testing & Implementasi", "C 203", primaryBlue),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuButton(BuildContext context, IconData icon, String label, Color color, Widget page) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => page),
            );
          },
          child: CircleAvatar(
            backgroundColor: color,
            child: Icon(icon, color: Colors.white),
          ),
        ),
        SizedBox(height: 4),
        Text(label),
      ],
    );
  }

  Widget _classCard(String start, String end, String subject, String room, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$start → $end", style: TextStyle(color: Colors.white)),
          SizedBox(height: 4),
          Text(subject, style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal)),
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.white, size: 16),
              SizedBox(width: 4),
              Text(room, style: TextStyle(color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }
}