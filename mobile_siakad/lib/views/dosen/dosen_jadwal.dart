import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_siakad/models/matakuliah_model.dart'; // Pastikan path dan model ini sesuai
import 'package:mobile_siakad/services/auth_service.dart';
import 'package:mobile_siakad/services/dosen/dosen_jadwal_service.dart';
import 'package:mobile_siakad/services/api_client.dart';

class DosenJadwalPage extends StatefulWidget {
  const DosenJadwalPage({Key? key}) : super(key: key);

  @override
  State<DosenJadwalPage> createState() => _DosenJadwalPageState();
}

class _DosenJadwalPageState extends State<DosenJadwalPage> {
  late final ApiClient _apiClient;
  late final AuthService _authService;
  late final DosenJadwalService _jadwalService;

  List<MataKuliah> _allMataKuliah = []; 
  Map<String, List<MataKuliah>> _groupedJadwalByDay = {};
  
  bool _isLoading = true;
  String? _errorMessage;

  final Color primaryBlue = const Color(0xFF133B7A);
  final List<String> _daysOrder = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];

  @override
  void initState() {
    super.initState();
    _apiClient = ApiClient(http.Client());
    _authService = AuthService(_apiClient); 
    _jadwalService = DosenJadwalService(_authService, _apiClient);
    _loadAllMataKuliah();
  }

  @override
  void dispose() {
    print("DosenJadwalPage dispose called.");
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

  Widget _buildScheduleSlot(MataKuliah mk, int slotNumber) {
    // String dosenDisplayInfo = "N/A"; // Tidak digunakan lagi
    // if (mk.idDosen != 0) { 
    //      dosenDisplayInfo = "Pengajar ID: ${mk.idDosen}";
    // }

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          gradient: LinearGradient(
            colors: [primaryBlue.withOpacity(0.8), primaryBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
           boxShadow: [
            BoxShadow(
              color: primaryBlue.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$slotNumber',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mk.namaMk,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 6),
                    // Menghilangkan baris yang menampilkan dosenDisplayInfo
                    // if (dosenDisplayInfo.isNotEmpty && dosenDisplayInfo != "N/A")
                    //   _buildInfoRow(Icons.person_outline, dosenDisplayInfo, color: Colors.white.withOpacity(0.9)),
                    _buildInfoRow(Icons.access_time_outlined, '${mk.jamMulai.substring(0, 5)} - ${mk.jamSelesai.substring(0, 5)}', color: Colors.white.withOpacity(0.9)),
                    _buildInfoRow(Icons.location_on_outlined, mk.ruang.namaRuang, color: Colors.white.withOpacity(0.9)),
                    _buildInfoRow(Icons.class_outlined, mk.kelas.namaKelas, color: Colors.white.withOpacity(0.9)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 15, color: color ?? Colors.white.withOpacity(0.8)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13.5, color: color ?? Colors.white.withOpacity(0.8)),
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
          padding: const EdgeInsets.only(top: 24.0, bottom: 12.0),
          child: Text(
            day,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: primaryBlue,
            ),
          ),
        ),
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: BackButton(color: primaryBlue),
        backgroundColor: Colors.white,
        elevation: 1,
        surfaceTintColor: Colors.white,
        title: Text(
          'Jadwal Mengajar',
          style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _loadAllMataKuliah,
        color: primaryBlue,
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: primaryBlue))
            : _errorMessage != null 
                ? _buildErrorWidget()
                : _allMataKuliah.isEmpty
                    ? _buildEmptyScheduleWidget()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                        itemCount: activeDaysWithSchedule.length,
                        itemBuilder: (context, index) {
                          final day = activeDaysWithSchedule[index];
                          final mataKuliahListForDay = _groupedJadwalByDay[day]!;
                          return _buildDayScheduleSection(day, mataKuliahListForDay);
                        },
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
            Icon(Icons.cloud_off, color: Colors.red.shade300, size: 70),
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
              style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 25),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text("Coba Lagi", style: TextStyle(color: Colors.white)),
              onPressed: _loadAllMataKuliah,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: const TextStyle(fontSize: 16)
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
            Icon(Icons.event_note_outlined, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 20),
            Text(
              'Tidak Ada Jadwal',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 8),
            Text(
              'Saat ini tidak ada jadwal mengajar yang tersedia untuk Anda.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
            ),
          ],
        ),
      ));
  }
}
