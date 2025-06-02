import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
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
  final Color secondaryBlue = const Color(0xFF1E5BB0); 

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
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
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
            'Semester Genap 2024/2025',
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, top: 8.0),
      child: Row(
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
      ),
    );
  }

  // UPDATED: Schedule slot that matches dashboard card style
  Widget _buildScheduleSlot(MataKuliah mk, int slotNumber) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
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
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Detail untuk ${mk.namaMk}')),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${mk.jamMulai.substring(0, 5)} → ${mk.jamSelesai.substring(0, 5)}",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        mk.kodeMk ?? '#$slotNumber',
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
                  mk.namaMk,
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
                      mk.ruang.namaRuang,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.people, color: Colors.white70, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      mk.kelas.namaKelas,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDayScheduleSection(String day, List<MataKuliah> jadwalForDay) {
    if (jadwalForDay.isEmpty) {
      return const SizedBox.shrink();
    }

    String formattedDate = '';
    try {
      // Find a date in this year that falls on the given day of week
      final now = DateTime.now();
      final firstDayOfYear = DateTime(now.year, 1, 1);
      final daysOfWeek = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
      final dayIndex = daysOfWeek.indexOf(day);
      
      if (dayIndex != -1) {
        // Find the next occurrence of this day from first day of year
        int daysUntil = (dayIndex + 1 - firstDayOfYear.weekday) % 7;
        if (daysUntil == 0) daysUntil = 7;
        final date = firstDayOfYear.add(Duration(days: daysUntil));
        formattedDate = DateFormat('d MMMM', 'id_ID').format(date);
      }
    } catch (e) {
      // Fallback if date formatting fails
      formattedDate = '';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 20.0, bottom: 4.0),
          child: Row(
            children: [
              Text(
                day,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: primaryBlue,
                ),
              ),
              if (formattedDate.isNotEmpty) ...[
                Text(
                  ' · ',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  formattedDate,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
              ],
              const Spacer(),
              Text(
                "${jadwalForDay.length} MATA KULIAH",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
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
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [primaryBlue, secondaryBlue],
            ),
          ),
        ),
        elevation: 0,
        title: const Text(
          'Jadwal Mengajar',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: RefreshIndicator(
            onRefresh: _loadAllMataKuliah,
            color: primaryBlue,
            child: _isLoading && _allMataKuliah.isEmpty
                ? Center(child: CircularProgressIndicator(color: primaryBlue))
                : _errorMessage != null
                    ? _buildErrorWidget()
                    : SingleChildScrollView(
                        physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!_isLoading) _buildSummaryCardDosen(),
                            
                            if (!_isLoading && _errorMessage == null && _allMataKuliah.isNotEmpty)
                              _buildSectionHeader('Jadwal Mengajar Per Hari', Icons.event_note_outlined),
                            
                            if (_allMataKuliah.isEmpty && !_isLoading)
                              _buildEmptyScheduleWidget()
                            else
                              ...activeDaysWithSchedule.map((day) {
                                final mataKuliahListForDay = _groupedJadwalByDay[day]!;
                                return _buildDayScheduleSection(day, mataKuliahListForDay);
                              }).toList(),
                              
                            const SizedBox(height: 20),
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
      )
    );
  }
}