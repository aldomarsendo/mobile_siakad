import 'package:flutter/material.dart';
import 'package:mobile_siakad/views/mahasiswa/mahasiswa_jadwal.dart';
import 'package:mobile_siakad/views/mahasiswa/mahasiswa_nilai.dart';
import 'package:mobile_siakad/views/mahasiswa/mahasiswa_frs.dart';
import 'package:mobile_siakad/views/mahasiswa/mahasiswa_profil.dart';
import 'package:mobile_siakad/services/auth_service.dart';
import 'package:mobile_siakad/models/user_model.dart';
import 'package:mobile_siakad/services/mahasiswa_service.dart';
import 'package:mobile_siakad/models/mahasiswa_model.dart';
import 'package:mobile_siakad/views/auth/login.dart';

class MahasiswaDashboardPage extends StatefulWidget {
  const MahasiswaDashboardPage({super.key});

  @override
  State<MahasiswaDashboardPage> createState() => _MahasiswaDashboardPageState();
}

class _MahasiswaDashboardPageState extends State<MahasiswaDashboardPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Color primaryBlue = Color(0xFF133B7A);
  User? _currentUser;
  Mahasiswa? _mahasiswaProfile;
  final AuthService _authService = AuthService();
  final MahasiswaService _mahasiswaService = MahasiswaService();

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final user = await _authService.getCurrentUser();
      setState(() {
        _currentUser = user;
      });

      // Load mahasiswa profile
      final mahasiswa = await _mahasiswaService.getProfile();
      setState(() {
        _mahasiswaProfile = mahasiswa;
      });
    } catch (e) {
      print('Error loading user data: $e');
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
                    backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=3'),
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
                    '${_mahasiswaProfile?.nrp} (Mahasiswa)',
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
                    builder: (context) => MahasiswaProfilPage(),
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
                            '${_mahasiswaProfile?.nrp} (Mahasiswa)',
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
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Akademik', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
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
                        _menuButton(context, Icons.calendar_today, "Jadwal", primaryBlue, MahasiswaJadwalPage()),
                        _menuButton(context, Icons.grade, "Nilai", primaryBlue, MahasiswaNilaiPage()),
                        _menuButton(context, Icons.file_copy, "FRS", primaryBlue, MahasiswaFrsPage()),
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
                  SizedBox(height: 8),
                  _classCard("10:00", "12:30", "Workshop Design Pengalaman Pengguna", "C 203", primaryBlue),
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
          Text(subject, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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