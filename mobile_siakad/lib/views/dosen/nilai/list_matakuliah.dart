import 'package:flutter/material.dart';
import 'package:mobile_siakad/models/matakuliah_model.dart';
import 'package:mobile_siakad/services/api_client.dart';
import 'package:mobile_siakad/services/auth_service.dart';
import 'package:mobile_siakad/services/dosen/dosen_jadwal_service.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_siakad/views/dosen/nilai/list_kelas_matakuliah.dart';

class ListMatakuliahPage extends StatefulWidget {
  const ListMatakuliahPage({Key? key}) : super(key: key);

  @override
  State<ListMatakuliahPage> createState() => _ListMatakuliahPageState();
}

class _ListMatakuliahPageState extends State<ListMatakuliahPage> with SingleTickerProviderStateMixin {
  late final ApiClient _apiClient;
  late final AuthService _authService;
  late final DosenJadwalService _dosenJadwalService;

  List<MataKuliah> _listMataKuliahDiampu = [];
  bool _isLoading = true;
  String? _errorMessage;

  final Color primaryBlue = const Color(0xFF133B7A);
  final Color textOnLightBg = Colors.black87;
  final Color subtleTextOnLightBg = Colors.grey.shade700;
  late final Color iconColorOnLightBg;
  late final Color cardShadowColor;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    iconColorOnLightBg = primaryBlue.withOpacity(0.75);
    cardShadowColor = primaryBlue.withOpacity(0.08);

    _apiClient = ApiClient(http.Client());
    _authService = AuthService(_apiClient);
    _dosenJadwalService = DosenJadwalService(_authService, _apiClient);
    _fetchMataKuliahDiampu();

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
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchMataKuliahDiampu() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final token = await _authService.getToken();
      if (token == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sesi Anda berakhir. Silakan login kembali.')),
          );
          Navigator.pushReplacementNamed(context, '/login');
        }
        return;
      }

      final fetchedMataKuliah = await _dosenJadwalService.getMataKuliah();
      
      fetchedMataKuliah.sort((a, b) {
        int semesterCompare = a.semester.compareTo(b.semester);
        if (semesterCompare != 0) {
          return semesterCompare;
        }
        return a.namaMk.toLowerCase().compareTo(b.namaMk.toLowerCase());
      });
      
      if (mounted) {
        setState(() {
          _listMataKuliahDiampu = fetchedMataKuliah;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Gagal memuat mata kuliah: ${e.toString()}";
        });
      }
      print("Error fetching mata kuliah diampu: $e");
    }
  }

  Widget _buildMataKuliahCard(MataKuliah mk) {
    return Card(
      elevation: 2.0, // Sedikit penyesuaian elevasi jika perlu
      shadowColor: cardShadowColor,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0), // Radius konsisten
      ),
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(12.0),
        onTap: () {
          print('Navigasi ke detail mata kuliah: ${mk.namaMk} (ID: ${mk.idMk})');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ListKelasMatakuliahPage(selectedCourse: mk),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0), // Padding disesuaikan
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center, // Vertically center items in Row
            children: [
              // Leading Icon
              Icon(Icons.school_outlined, color: primaryBlue, size: 36), // Ikon representatif
              const SizedBox(width: 16),
              // Main Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mk.namaMk,
                      style: TextStyle(
                        fontSize: 16, // Ukuran font disesuaikan
                        fontWeight: FontWeight.bold,
                        color: textOnLightBg,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8), // Spasi antar teks
                    _buildInfoRow(Icons.qr_code_scanner_outlined, "${mk.kodeMk} - ${mk.sks} SKS"),
                    _buildInfoRow(Icons.layers_outlined, "Semester ${mk.semester}"),
                    _buildInfoRow(Icons.group_work_outlined, "Kelas: ${mk.kelas.namaKelas}"), // Ikon kelas yang lebih umum
                  ],
                ),
              ),
              const SizedBox(width: 8), // Spasi sebelum ikon chevron
              // Trailing Navigation Icon
              Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400, size: 28),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0), // Sedikit mengurangi padding atas
      child: Row(
        children: [
          Icon(icon, size: 14, color: iconColorOnLightBg), // Ukuran ikon sedikit lebih kecil
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13, color: subtleTextOnLightBg), // Font teks info
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Mata Kuliah Diampu', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 18)),
        backgroundColor: primaryBlue,
        elevation: 1.0,
        leading: const BackButton(color: Colors.white),
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: RefreshIndicator(
          onRefresh: _fetchMataKuliahDiampu,
          color: primaryBlue,
          child: _isLoading
              ? Center(child: CircularProgressIndicator(color: primaryBlue))
              : _errorMessage != null
                  ? _buildErrorWidget()
                  : _listMataKuliahDiampu.isEmpty
                      ? _buildEmptyListWidget()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0), // Vertical padding disesuaikan
                          itemCount: _listMataKuliahDiampu.length,
                          itemBuilder: (context, index) {
                            final mataKuliah = _listMataKuliahDiampu[index];
                            return _buildMataKuliahCard(mataKuliah);
                          },
                        ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    // ... (kode _buildErrorWidget tetap sama)
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, color: Colors.red.shade400, size: 80),
            const SizedBox(height: 20),
            Text(
              "Gagal Memuat Data",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red.shade700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 25),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text("Coba Lagi", style: TextStyle(color: Colors.white, fontSize: 16)),
              onPressed: _fetchMataKuliahDiampu,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyListWidget() {
    // ... (kode _buildEmptyListWidget tetap sama)
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school_outlined, size: 90, color: Colors.grey.shade400),
            const SizedBox(height: 24),
            Text(
              'Tidak Ada Mata Kuliah',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
            ),
            const SizedBox(height: 10),
            Text(
              'Anda tidak mengampu mata kuliah apapun saat ini.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      ));
  }
}