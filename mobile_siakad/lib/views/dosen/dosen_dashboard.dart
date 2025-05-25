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

class DosenDashboardPage extends StatefulWidget {
  const DosenDashboardPage({super.key});

  @override
  State<DosenDashboardPage> createState() => _DosenDashboardPageState();
}

class _DosenDashboardPageState extends State<DosenDashboardPage> with SingleTickerProviderStateMixin { // Added SingleTickerProviderStateMixin
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Color primaryBlue = const Color(0xFF133B7A);
  final Color secondaryBlue = const Color(0xFF1E5BB0); // Added secondaryBlue

  User? _currentUser;
  Dosen? _dosenProfile;
  List<MataKuliah> _jadwalHariIni = [];
  bool _isLoading = true;
  String? _errorMessage;

  late final AuthService _authService;
  late final DosenProfileService _profileService;
  late final DosenJadwalService _jadwalService;
  
  late AnimationController _animationController; // Added for FadeTransition
  late Animation<double> _fadeAnimation; // Added for FadeTransition

  @override
  void initState() {
    super.initState();
    final apiClient = ApiClient(http.Client());
    _authService = AuthService(apiClient);
    _profileService = DosenProfileService(apiClient);
    _jadwalService = DosenJadwalService(_authService, apiClient);
    _loadInitialData();

    _animationController = AnimationController( // Initialize AnimationController
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate( // Initialize FadeAnimation
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.forward(); // Start animation
  }

  @override
  void dispose() {
    _animationController.dispose(); // Dispose AnimationController
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
  
  // Copied from MahasiswaDashboardPage and adapted
  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.all(16), // Margin for the header itself
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryBlue, secondaryBlue],
        ),
        borderRadius: BorderRadius.circular(16), // Rounded corners for the header
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
              CircleAvatar( // Placeholder, ideally use user's actual avatar URL if available
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
          // SizedBox(height: 16), // Optional: if more content needed in header
        ],
      ),
    );
  }

  // Adapted from MahasiswaDashboardPage
  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration( // Gradient for DrawerHeader
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
                          color: Colors.white70, // Adjusted for better contrast
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

  // Section header helper, adapted from MahasiswaDashboardPage
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
    // Structure adapted from MahasiswaDashboardPage
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0), // Consistent horizontal padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Berita Terbaru', Icons.newspaper_outlined), // Using new helper
          const SizedBox(height: 12),
          Container( // Card-like container
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
            child: ClipRRect( // To clip the image corners
              borderRadius: const BorderRadius.all(Radius.circular(16)),
              child: Image.asset(
                'assets/images/pens.png', // Ensure this asset exists
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
    // Structure adapted from MahasiswaDashboardPage
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Akademik', Icons.school_outlined), // Using new helper
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
                // Using the new _menuButton styling
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
    String tanggalHariIniText = DateFormat('d MMMM yyyy', 'id_ID').format(DateTime.now());
    String namaHariIniText = DateFormat('EEEE', 'id_ID').format(DateTime.now());

    return Padding(
      padding: const EdgeInsets.all(16.0), // Consistent padding for the whole section
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector( // To make the header tappable for full schedule
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DosenJadwalPage()),
              );
            },
            child: Row(
              children: [
                _buildSectionHeader('Jadwal Mengajar Hari Ini', Icons.access_time_filled_outlined), // Using new helper
                const Spacer(),
                Icon(Icons.arrow_forward_ios, size: 16, color: primaryBlue),
              ],
            ),
          ),
          const SizedBox(height: 8), // Reduced space
           Text(
            '$namaHariIniText, $tanggalHariIniText · ${_jadwalHariIni.length} MATA KULIAH', 
            style: TextStyle(
              fontSize: 12, // Slightly smaller
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700, // Darker grey
            )
          ),
          const SizedBox(height: 12),
          if (_jadwalHariIni.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Text(
                  'Tidak ada jadwal mengajar hari ini.',
                  style: TextStyle(fontSize: 15, color: Colors.grey[600]), // Adjusted size
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
                // Using new _classCard styling
                return _classCard(
                    mk.jamMulai.substring(0,5), 
                    mk.jamSelesai.substring(0,5), 
                    mk.namaMk, 
                    mk.ruang.namaRuang);
              },
            ),
        ],
      ),
    );
  }

  // Adapted from MahasiswaDashboardPage's _menuButton
  Widget _menuButton(BuildContext context, IconData icon, String label, Widget page) {
    return Expanded( // Ensures buttons take equal space
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: primaryBlue.withOpacity(0.3), // Shadow color from target
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
              shape: BoxShape.circle,
            ),
            child: Material( // For InkWell ripple effect on a circle
              color: Colors.transparent,
              shape: const CircleBorder(),
              child: InkWell(
                borderRadius: BorderRadius.circular(28), // Half of CircleAvatar radius * 2
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => page),
                  );
                },
                child: CircleAvatar(
                  backgroundColor: primaryBlue, // Target background color
                  radius: 28, // Target radius
                  child: Icon(icon, color: Colors.white, size: 24), // Target icon style
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
              fontSize: 13, // Slightly smaller to fit if labels are long
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  // Class card adapted from MahasiswaDashboardPage
  Widget _classCard(String start, String end, String subject, String room) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12), // Spacing between cards
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient( // Gradient background
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
              color: Colors.white70, // Adjusted for readability
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
              const Icon(Icons.location_on, color: Colors.white70, size: 16), // Adjusted color
              const SizedBox(width: 4),
              Text(
                room, 
                style: const TextStyle(
                  color: Colors.white70, // Adjusted color
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
      backgroundColor: Colors.grey[100], // Matched background
      endDrawer: _buildDrawer(), // Drawer from the right
      body: SafeArea(
        child: FadeTransition( // Added FadeTransition
          opacity: _fadeAnimation,
          child: Column(
            children: [
              _buildHeader(), // New custom header, no AppBar
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => _loadInitialData(isRefresh: true),
                  color: primaryBlue,
                  child: _isLoading && _jadwalHariIni.isEmpty && _currentUser == null // More specific loading condition
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
                          : SingleChildScrollView( // Changed from ListView to SingleChildScrollView for a Column child
                              physics: const BouncingScrollPhysics(), // For a nice scroll effect
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 0), // Removed top padding here, header provides margin
                                  _buildNewsSection(),
                                  const SizedBox(height: 24),
                                  _buildAcademicMenu(),
                                  const SizedBox(height: 24),
                                  _buildTodaySchedule(),
                                  const SizedBox(height: 20), // Padding at the bottom of scroll view
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