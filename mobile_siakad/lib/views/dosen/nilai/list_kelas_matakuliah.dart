import 'package:flutter/material.dart';
import 'package:mobile_siakad/models/matakuliah_model.dart'; // Mengimpor MataKuliah dan Kelas yang terkait dengannya
// import 'package:mobile_siakad/models/mahasiswa_model.dart' hide Kelas; // Jika tidak digunakan, bisa di-comment
import 'package:mobile_siakad/services/api_client.dart';
import 'package:mobile_siakad/services/auth_service.dart';
import 'package:mobile_siakad/services/dosen/dosen_jadwal_service.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_siakad/views/dosen/nilai/input_nilai_mahasiswa.dart';

class ListKelasMatakuliahPage extends StatefulWidget {
  final MataKuliah selectedCourse; 

  const ListKelasMatakuliahPage({Key? key, required this.selectedCourse}) : super(key: key);

  @override
  State<ListKelasMatakuliahPage> createState() => _ListKelasMatakuliahPageState();
}

class _ListKelasMatakuliahPageState extends State<ListKelasMatakuliahPage> with SingleTickerProviderStateMixin { // Added mixin
  late final ApiClient _apiClient;
  late final AuthService _authService;
  late final DosenJadwalService _dosenJadwalService;

  List<Kelas> _uniqueKelasList = []; 
  bool _isLoading = true;
  String? _errorMessage;

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

    _apiClient = ApiClient(http.Client());
    _authService = AuthService(_apiClient);
    _dosenJadwalService = DosenJadwalService(_authService, _apiClient);
    _fetchAndFilterKelasForMatakuliah();

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
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose(); // Dispose AnimationController
    super.dispose();
  }

  Future<void> _fetchAndFilterKelasForMatakuliah() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final token = await _authService.getToken();
      if (token == null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sesi Anda berakhir. Silakan login kembali.')),
        );
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      final List<MataKuliah> allScheduledCourses = await _dosenJadwalService.getMataKuliah();

      final List<MataKuliah> schedulesForThisCourse = allScheduledCourses.where((schedule) =>
        schedule.kodeMk == widget.selectedCourse.kodeMk &&
        schedule.namaMk == widget.selectedCourse.namaMk
      ).toList();

      Map<int, Kelas> uniqueKelasMap = {};
      for (var schedule in schedulesForThisCourse) {
        if (schedule.kelas != null) { 
          // Asumsi 'idKelas' non-nullable di model Kelas dari matakuliah_model
          if (!uniqueKelasMap.containsKey(schedule.kelas.idKelas)) {
            uniqueKelasMap[schedule.kelas.idKelas] = schedule.kelas;
          }
        }
      }
      
      List<Kelas> displayableClasses = uniqueKelasMap.values.toList();
      // Asumsi 'namaKelas' non-nullable di model Kelas dari matakuliah_model
      displayableClasses.sort((a,b) => (a.namaKelas).toLowerCase().compareTo((b.namaKelas).toLowerCase()));
      
      if (mounted) {
        setState(() {
          _uniqueKelasList = displayableClasses;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Gagal memuat daftar kelas: ${e.toString()}";
        });
      }
      print("Error fetching/filtering kelas for matakuliah: $e");
    }
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
          print('Pilih kelas: ${kelas.namaKelas} (ID: ${kelas.idKelas}) untuk Mata Kuliah: ${widget.selectedCourse.namaMk}');
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(content: Text('Pilih kelas: ${kelas.namaKelas}')),
          // ); // Dimatikan agar tidak mengganggu alur navigasi
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InputNilaiMahasiswaPage(
                selectedKelas: kelas, 
                selectedMataKuliah: widget.selectedCourse,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Leading Icon
              Icon(Icons.class_outlined, color: primaryBlue, size: 32), // Ikon kelas
              const SizedBox(width: 16),
              // Main Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      kelas.namaKelas, // Asumsi non-nullable
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
                      // Asumsi 'status' non-nullable dan ada di model Kelas Anda
                      'Status: ${kelas.status}', 
                       style: TextStyle(fontSize: 13, color: subtleTextOnLightBg),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Trailing Navigation Icon
              Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400, size: 28),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Themed scaffold background
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Pilih Kelas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
            Text(
              widget.selectedCourse.namaMk, 
              style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.85)),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        backgroundColor: primaryBlue, // Themed AppBar color
        iconTheme: const IconThemeData(color: Colors.white), // Warna ikon back button
        elevation: 1.0,
        toolbarHeight: 60, // Sedikit menambah tinggi AppBar untuk dua baris title
      ),
      body: FadeTransition( // Added FadeTransition
        opacity: _fadeAnimation,
        child: RefreshIndicator(
          onRefresh: _fetchAndFilterKelasForMatakuliah,
          color: primaryBlue,
          child: _isLoading
              ? Center(child: CircularProgressIndicator(color: primaryBlue))
              : _errorMessage != null
                  ? _buildErrorWidget()
                  : _uniqueKelasList.isEmpty
                      ? _buildEmptyListWidget()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                          itemCount: _uniqueKelasList.length,
                          itemBuilder: (context, index) {
                            final kelas = _uniqueKelasList[index];
                            return _buildKelasCard(kelas);
                          },
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
              "Gagal Memuat Data Kelas",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red.shade700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text("Coba Lagi", style: TextStyle(color: Colors.white)),
              onPressed: _fetchAndFilterKelasForMatakuliah,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                textStyle: const TextStyle(fontSize: 15)
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyListWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.class_outlined, size: 80, color: Colors.grey.shade400), // Ikon disesuaikan
            const SizedBox(height: 15),
            Text(
              'Tidak Ada Kelas Tersedia', // Judul disesuaikan
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Tidak ditemukan data kelas untuk mata kuliah "${widget.selectedCourse.namaMk}".', // Pesan disesuaikan
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.grey.shade500),
              ),
            ),
          ],
        ),
      ));
  }
}