import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_siakad/models/matakuliah_model.dart';
import 'package:mobile_siakad/services/auth_service.dart';
import 'package:mobile_siakad/services/dosen/dosen_jadwal_service.dart';
import 'package:mobile_siakad/services/api_client.dart';

class DosenJadwalPage extends StatefulWidget {
  const DosenJadwalPage({Key? key}) : super(key: key);

  @override
  State<DosenJadwalPage> createState() => _DosenJadwalPageState();
}

class _DosenJadwalPageState extends State<DosenJadwalPage> with SingleTickerProviderStateMixin {
  late final ApiClient _apiClient;
  late final AuthService _authService;
  late final DosenJadwalService _jadwalService;

  List<MataKuliah> _allMataKuliah = [];
  Map<String, List<MataKuliah>> _groupedJadwalByDay = {};

  bool _isLoading = true;
  String? _errorMessage;

  // Palet Warna Akademik
  final Color primaryBlue = const Color(0xFF133B7A); 
  final Color secondaryBlue = const Color(0xFF1E5BB0); // Untuk gradien Kartu Ringkasan

  final Color textOnLightBg = Colors.black87; 
  final Color subtleTextOnLightBg = Colors.grey.shade700; 
  late final Color iconColorOnLightBg; 
  late final Color dividerColor; 
  late final Color cardShadowColor; 

  final List<String> _daysOrder = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    iconColorOnLightBg = primaryBlue.withOpacity(0.75);
    dividerColor = primaryBlue.withOpacity(0.2);
    cardShadowColor = primaryBlue.withOpacity(0.08);

    _apiClient = ApiClient(http.Client());
    _authService = AuthService(_apiClient);
    _jadwalService = DosenJadwalService(_authService, _apiClient);
    _loadAllMataKuliah();

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

  Future<void> _loadAllMataKuliah() async {
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

      final fetchedMataKuliah = await _jadwalService.getMataKuliah();

      if (mounted) {
        setState(() {
          _allMataKuliah = fetchedMataKuliah;
          _groupAndSortJadwal();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Gagal memuat jadwal: ${e.toString()}';
        });
      }
      print('Error loading all mata kuliah: $e');
    }
  }

  void _groupAndSortJadwal() {
    Map<String, List<MataKuliah>> grouped = {};
    for (var day in _daysOrder) {
      grouped[day] = _allMataKuliah.where((mk) => mk.hari.toLowerCase() == day.toLowerCase()).toList()
        ..sort((a, b) => a.jamMulai.compareTo(b.jamMulai));
    }
    _groupedJadwalByDay = grouped;
  }

  Widget _buildSummaryCardDosen() {
    // Kartu ringkasan tetap menggunakan gradien primaryBlue & secondaryBlue
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20.0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryBlue, secondaryBlue], 
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Total Mata Kuliah Diampu',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isLoading ? "-" : _allMataKuliah.length.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Data Keseluruhan',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionListHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, top: 8.0),
      child: Row(
        children: [
          Icon(icon, color: primaryBlue, size: 22),
          const SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleSlot(MataKuliah mk, int slotNumber) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 2.0, 
      shadowColor: cardShadowColor, 
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
        child: Row(
          children: [
            Container(
              width: 75,
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    mk.jamMulai.substring(0, 5),
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: primaryBlue,
                    ),
                  ),
                  Container(
                    height: 10,
                    width: 1.2, 
                    color: dividerColor, 
                    margin: const EdgeInsets.symmetric(vertical: 2),
                  ),
                  Text(
                    mk.jamSelesai.substring(0, 5),
                    style: TextStyle(
                      fontSize: 15,
                      color: subtleTextOnLightBg, 
                    ),
                  ),
                ],
              ),
            ),
            VerticalDivider(width: 1, thickness: 1, color: dividerColor.withOpacity(0.5), indent: 8, endIndent: 8),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          mk.namaMk,
                          style: TextStyle(
                            fontSize: 16.5,
                            fontWeight: FontWeight.bold,
                            color: textOnLightBg,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: primaryBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '$slotNumber',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: primaryBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildInfoRow(Icons.location_on_outlined, mk.ruang.namaRuang),
                  _buildInfoRow(Icons.class_outlined, mk.kelas.namaKelas),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 5.0),
      child: Row(
        children: [
          Icon(icon, size: 15, color: iconColorOnLightBg),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13.5, color: subtleTextOnLightBg),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayScheduleSection(String day, List<MataKuliah> jadwalForDay) {
    if (jadwalForDay.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 20.0, bottom: 4.0),
          child: Text(
            day,
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w600,
              color: textOnLightBg,
            ),
          ),
        ),
        Divider(color: dividerColor, height: 12, thickness: 0.8),
        const SizedBox(height: 10),
        ListView.builder(
          itemCount: jadwalForDay.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final mk = jadwalForDay[index];
            return _buildScheduleSlot(mk, index + 1);
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeDaysWithSchedule = _daysOrder
        .where((day) => _groupedJadwalByDay[day]?.isNotEmpty ?? false)
        .toList();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: const BackButton(color: Colors.white),
        backgroundColor: primaryBlue, // AppBar menggunakan warna solid primaryBlue
        elevation: 1.0, // Bisa ditambahkan sedikit elevasi jika diinginkan
        title: const Text(
          'Jadwal Mengajar',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: RefreshIndicator(
          onRefresh: _loadAllMataKuliah,
          color: primaryBlue,
          child: _isLoading && _allMataKuliah.isEmpty
              ? Center(child: CircularProgressIndicator(color: primaryBlue))
              : _errorMessage != null
                  ? _buildErrorWidget()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                              if (!_isLoading) _buildSummaryCardDosen(),
                              if (!_isLoading && _errorMessage == null && _allMataKuliah.isNotEmpty)
                                _buildSectionListHeader('Daftar Jadwal Mengajar', Icons.event_note_outlined),
                             ]
                          ),
                        ),
                        Expanded(
                          child: _allMataKuliah.isEmpty && !_isLoading
                              ? _buildEmptyScheduleWidget()
                              : ListView.builder(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                  itemCount: activeDaysWithSchedule.length,
                                  itemBuilder: (context, index) {
                                    final day = activeDaysWithSchedule[index];
                                    final mataKuliahListForDay = _groupedJadwalByDay[day]!;
                                    return _buildDayScheduleSection(day, mataKuliahListForDay);
                                  },
                                ),
                        ),
                      ],
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
              "Gagal Memuat Jadwal",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red.shade700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              _errorMessage ?? "Terjadi kesalahan yang tidak diketahui.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 25),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text("Coba Lagi", style: TextStyle(color: Colors.white, fontSize: 16)),
              onPressed: _loadAllMataKuliah,
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

  Widget _buildEmptyScheduleWidget() {
    // ... (kode _buildEmptyScheduleWidget tetap sama)
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_available_outlined, size: 90, color: Colors.grey.shade400),
            const SizedBox(height: 24),
            Text(
              'Tidak Ada Jadwal',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
            ),
            const SizedBox(height: 10),
            Text(
              'Saat ini tidak ada jadwal mengajar yang tersedia untuk Anda.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      ));
  }
}