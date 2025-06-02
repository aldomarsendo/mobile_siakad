import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_siakad/models/mahasiswa_jadwal_model.dart';
import 'package:mobile_siakad/services/api_client.dart';
import 'package:mobile_siakad/services/mahasiswa/mahasiswa_jadwal_service.dart';

class MahasiswaJadwalPage extends StatefulWidget {
  const MahasiswaJadwalPage({super.key});

  @override
  State<MahasiswaJadwalPage> createState() => _MahasiswaJadwalPageState();
}

class _MahasiswaJadwalPageState extends State<MahasiswaJadwalPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  late ApiClient _apiClient;
  late MahasiswaJadwalService _jadwalService;

  Map<String, List<MahasiswaJadwalItem>> _jadwalKuliahData = {};
  bool _isLoading = true;
  String? _errorMessage;
  String _apiMessage = '';
  String _currentSemesterDisplay = "Memuat...";

  final Color primaryBlue = const Color(0xFF133B7A);
  final Color secondaryBlue = const Color(0xFF1E5BB0);

  final Color textOnLightBg = Colors.black87;
  final Color subtleTextOnLightBg = Colors.grey.shade700;

  final List<String> _daysOrder = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];

  @override
  void initState() {
    super.initState();

    _apiClient = ApiClient(http.Client());
    _jadwalService = MahasiswaJadwalService(_apiClient);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _fetchJadwalKuliah();
  }

  Future<void> _fetchJadwalKuliah() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _apiMessage = '';
    });

    try {
      final List<MahasiswaJadwalItem> jadwalList = await _jadwalService.getJadwalLengkap();
      
      if (mounted) {
        setState(() {
          Map<String, List<MahasiswaJadwalItem>> groupedByDay = {};
          
          if (jadwalList.isNotEmpty) {
            for (var jadwal in jadwalList) {
              String hari = jadwal.hari;
              if (hari != 'N/A') {
                 groupedByDay.putIfAbsent(hari, () => []).add(jadwal);
              }
            }
            
            groupedByDay.forEach((hari, listJadwal) {
              listJadwal.sort((a, b) => a.jamMulai.compareTo(b.jamMulai));
            });
          }
          
          _jadwalKuliahData = groupedByDay;
          
          _apiMessage = jadwalList.isNotEmpty 
              ? "Jadwal berhasil dimuat" 
              : "Tidak ada jadwal tersedia";
          
          if (jadwalList.isNotEmpty) {
            _currentSemesterDisplay = jadwalList.first.semester;
          } else {
            _currentSemesterDisplay = "N/A";
          }

          _isLoading = false;
        });
        _animationController.forward(from: 0.0);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Gagal memuat jadwal: ${e.toString().replaceFirst("Exception: ", "")}";
          _isLoading = false;
        });
        _animationController.forward(from: 0.0);
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _refreshJadwal() async {
    if (!_isLoading) {
      _animationController.reset();
    }
    await _fetchJadwalKuliah();
  }

  int _calculateTotalMataKuliah() {
    if (_jadwalKuliahData.isEmpty) return 0;
    int total = 0;
    for (var listMk in _jadwalKuliahData.values) {
      total += listMk.length;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: const BackButton(color: Colors.white),
        backgroundColor: primaryBlue,
        elevation: 0,
        title: const Text(
          'Jadwal Kuliah',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w600, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _isLoading ? null : _refreshJadwal,
            tooltip: 'Refresh Jadwal',
          )
        ],
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: RefreshIndicator(
            onRefresh: _refreshJadwal,
            color: primaryBlue,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCard(),
                  const SizedBox(height: 24),
                  _buildSectionHeader('Daftar Jadwal Kuliah', Icons.event_note_outlined),
                  const SizedBox(height: 12),
                  Expanded(
                    child: _isLoading
                        ? Center(child: CircularProgressIndicator(color: primaryBlue))
                        : _errorMessage != null
                            ? _buildErrorWidget()
                            : _buildScheduleList(),
                  ),
                ],
              ),
            ),
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
            Icon(Icons.error_outline,
                color: Colors.red.shade400, size: 60),
            const SizedBox(height: 16),
            Text(
              "Ups, terjadi kesalahan!",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red.shade700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? "Gagal memuat data. Silakan coba lagi nanti.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text("Coba Lagi", style: TextStyle(color: Colors.white)),
              onPressed: _fetchJadwalKuliah,
              style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      width: double.infinity,
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
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Total Mata Kuliah',
            style: TextStyle(
              color: Colors.white.withOpacity(0.95),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isLoading ? "..." : _calculateTotalMataKuliah().toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 38,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _isLoading ? "Memuat semester..." : 'Semester: $_currentSemesterDisplay',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
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

  Widget _buildInfoRow(IconData icon, String text, {Color? textColor}) {
    return Padding(
      padding: const EdgeInsets.only(top: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: primaryBlue.withOpacity(0.75)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text.isNotEmpty ? text : '-',
              style: TextStyle(fontSize: 14, color: textColor ?? subtleTextOnLightBg),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleList() {
    if (_jadwalKuliahData.isEmpty && !_isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.calendar_today_outlined, size: 90, color: Colors.grey.shade400),
              const SizedBox(height: 20),
              Text(
                "Tidak Ada Jadwal",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 10),
              Text(
                _apiMessage.isNotEmpty ? _apiMessage : "Jadwal kuliah untuk saat ini belum tersedia.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
            ],
          ),
        )
      );
    }

    List<String> activeDays = _jadwalKuliahData.keys.toList()
      ..sort((a, b) {
        int indexA = _daysOrder.indexOf(a);
        int indexB = _daysOrder.indexOf(b);
        if (indexA == -1 && indexB == -1) return a.compareTo(b);
        if (indexA == -1) return 1;
        if (indexB == -1) return -1;
        return indexA.compareTo(indexB);
      });

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8.0),
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      itemCount: activeDays.length,
      itemBuilder: (context, index) {
        String day = activeDays[index];
        List<MahasiswaJadwalItem> daySchedules = _jadwalKuliahData[day]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: (index == 0 ? 8.0 : 20.0), bottom: 6.0),
              child: Text(
                day,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: primaryBlue,
                ),
              ),
            ),
            Divider(color: primaryBlue.withOpacity(0.2), height: 12, thickness: 1),
            const SizedBox(height: 12),
            ...daySchedules.map((jadwalItem) {
              return _buildScheduleSlot(jadwalItem);
            }),
            if (index < activeDays.length - 1) const SizedBox(height: 12),
          ],
        );
      },
    );
  }

  Widget _buildScheduleSlot(MahasiswaJadwalItem jadwal) {
    String jamMulai = jadwal.jamMulai;
    String jamSelesai = jadwal.jamSelesai;
    String namaMk = jadwal.namaMk;
    String kodeMk = jadwal.kodeMk;
    String dosenPengampu = jadwal.dosenPengampu;
    String ruang = jadwal.ruang;
    String kelasMatakuliah = jadwal.kelasMatakuliah;
    String prodiMk = jadwal.prodiMk;
    String sksDisplay = jadwal.sks.toString();

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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "$jamMulai → $jamSelesai",
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (kodeMk.isNotEmpty)
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
              namaMk,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            if (ruang.isNotEmpty && ruang != 'N/A')
              Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.white70, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      ruang,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            if (dosenPengampu.isNotEmpty && dosenPengampu != 'N/A')
              Padding(
                padding: const EdgeInsets.only(top: 6.0),
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
            if (kelasMatakuliah.isNotEmpty && kelasMatakuliah != 'N/A')
              Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Row(
                  children: [
                    const Icon(Icons.group, color: Colors.white70, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      kelasMatakuliah,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
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