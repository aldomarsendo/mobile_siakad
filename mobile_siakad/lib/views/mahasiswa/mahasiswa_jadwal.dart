import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Keep this if ApiClient needs it directly or for other purposes
import 'package:mobile_siakad/models/mahasiswa_jadwal_model.dart';
import 'package:mobile_siakad/services/api_client.dart';
import 'package:mobile_siakad/services/mahasiswa/mahasiswa_jadwal_service.dart'; // Correct import

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
  late MahasiswaJadwalService _jadwalService; // Correctly typed

  Map<String, List<MahasiswaJadwalItem>> _jadwalKuliahData = {};
  bool _isLoading = true;
  String? _errorMessage;
  String _apiMessage = '';
  String _currentSemesterDisplay = "Memuat...";

  final Color primaryBlue = const Color(0xFF133B7A);
  final Color secondaryBlue = const Color(0xFF1E5BB0);

  final Color textOnLightBg = Colors.black87;
  final Color subtleTextOnLightBg = Colors.grey.shade700;
  late final Color iconColorOnLightBg;
  late final Color dividerColor;
  late final Color cardShadowColor;

  final List<String> _daysOrder = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];

  @override
  void initState() {
    super.initState();

    _apiClient = ApiClient(http.Client());
    _jadwalService = MahasiswaJadwalService(_apiClient); // Correct instantiation
    iconColorOnLightBg = primaryBlue.withOpacity(0.75); // Using withOpacity for clarity
    dividerColor = primaryBlue.withOpacity(0.2);
    cardShadowColor = primaryBlue.withOpacity(0.08);

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
      // Menggunakan MahasiswaJadwalItem langsung dari service
      final List<MahasiswaJadwalItem> jadwalList = await _jadwalService.getJadwalLengkap();
      
      if (mounted) {
        setState(() {
          // Group jadwal berdasarkan hari
          Map<String, List<MahasiswaJadwalItem>> groupedByDay = {};
          
          if (jadwalList.isNotEmpty) {
            for (var jadwal in jadwalList) {
              String hari = jadwal.hari; // Assuming 'hari' is never null due to model defaults
              // Ensure 'hari' is a valid key (e.g., not 'N/A' if that's undesirable as a key)
              if (hari != 'N/A') { // Example: only group valid days
                 groupedByDay.putIfAbsent(hari, () => []).add(jadwal);
              }
            }
            
            // Sort jadwal dalam setiap hari berdasarkan jam mulai
            groupedByDay.forEach((hari, listJadwal) {
              listJadwal.sort((a, b) => a.jamMulai.compareTo(b.jamMulai));
            });
          }
          
          _jadwalKuliahData = groupedByDay;
          
          _apiMessage = jadwalList.isNotEmpty 
              ? "Jadwal berhasil dimuat" 
              : "Tidak ada jadwal tersedia";
          
          if (jadwalList.isNotEmpty) {
            _currentSemesterDisplay = jadwalList.first.semester; // Assuming semester is never null
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

  // Helper extension for Color to replace withValues if it was custom
  // Using withOpacity as a standard alternative. If withValues had different logic,
  // this would need to be adjusted.
  // For example, if withValues was: color.withAlpha(value.toInt())
  // Color _withValues(Color color, {double? alpha}) {
  //   if (alpha != null) {
  //     return color.withOpacity(alpha / 255.0); // Assuming alpha was 0-255
  //   }
  //   return color;
  // }


  @override
  Widget build(BuildContext context) {
    // Re-assigning colors here if they depended on withValues that might have changed meaning
    // Or ensure iconColorOnLightBg etc. are initialized correctly in initState
    // For simplicity, assuming withOpacity is the intended replacement for withValues(alpha: X)
    final currentIconColorOnLightBg = primaryBlue.withOpacity(0.75); 
    final currentDividerColor = primaryBlue.withOpacity(0.2);
    final currentCardShadowColor = primaryBlue.withOpacity(0.08);


    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: const BackButton(color: Colors.white),
        backgroundColor: primaryBlue,
        elevation: 1.0,
        title: const Text(
          'Jadwal Kuliah',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w600, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
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
                            : _buildScheduleList(currentIconColorOnLightBg, currentDividerColor, currentCardShadowColor), // Pass down colors
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
            Icon(Icons.error_outline_rounded, color: Colors.red.shade700, size: 70),
            const SizedBox(height: 16),
            Text(
              "Oops! Terjadi Kesalahan",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red.shade700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              _errorMessage ?? "Gagal memuat data. Silakan coba lagi nanti.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text("Coba Lagi", style: TextStyle(color: Colors.white, fontSize: 16)),
              onPressed: _fetchJadwalKuliah,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: const TextStyle(fontSize: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
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
          colors: [primaryBlue, secondaryBlue.withOpacity(0.85)], // Used withOpacity
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(0.3), // Used withOpacity
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Total Mata Kuliah',
            style: TextStyle(
              color: Colors.white.withOpacity(0.95), // Used withOpacity
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
              color: Colors.white.withOpacity(0.9), // Used withOpacity
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
        Icon(icon, color: primaryBlue, size: 24),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
            color: primaryBlue,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text, Color currentIconColorOnLightBg, {Color? textColor}) {
    return Padding(
      padding: const EdgeInsets.only(top: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: currentIconColorOnLightBg.withOpacity(0.9)), // Used withOpacity
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

  Widget _buildScheduleList(Color currentIconColorOnLightBg, Color currentDividerColor, Color currentCardShadowColor) {
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
        if (indexA == -1 && indexB == -1) return a.compareTo(b); // Both not in order, sort alphabetically
        if (indexA == -1) return 1; // a is not in order, b is; b comes first
        if (indexB == -1) return -1; // b is not in order, a is; a comes first
        return indexA.compareTo(indexB); // Both in order, sort by order
      });

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8.0),
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      itemCount: activeDays.length,
      itemBuilder: (context, index) {
        String day = activeDays[index];
        List<MahasiswaJadwalItem> daySchedules = _jadwalKuliahData[day]!;

        // Schedules are already sorted by time in _fetchJadwalKuliah
        // daySchedules.sort((a, b) {
        //   String timeA = a.jamMulai;
        //   String timeB = b.jamMulai;
        //   return timeA.compareTo(timeB);
        // });

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: (index == 0 ? 8.0 : 20.0), bottom: 6.0),
              child: Text(
                day,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: textOnLightBg.withOpacity(0.9), // Used withOpacity
                ),
              ),
            ),
            Divider(color: currentDividerColor.withOpacity(0.7), height: 12, thickness: 1), // Used withOpacity
            const SizedBox(height: 12),
            ...daySchedules.map((jadwalItem) {
              return _buildScheduleSlot(jadwalItem, currentIconColorOnLightBg, currentDividerColor, currentCardShadowColor); // Pass colors
            }),
            if (index < activeDays.length - 1) const SizedBox(height: 12),
          ],
        );
      },
    );
  }

  Widget _buildScheduleSlot(MahasiswaJadwalItem jadwal, Color currentIconColorOnLightBg, Color currentDividerColor, Color currentCardShadowColor) {
    String jamMulai = jadwal.jamMulai;
    String jamSelesai = jadwal.jamSelesai;
    String namaMk = jadwal.namaMk;
    String kodeMk = jadwal.kodeMk;
    String dosenPengampu = jadwal.dosenPengampu;
    String ruang = jadwal.ruang;
    String kelasMatakuliah = jadwal.kelasMatakuliah;
    String prodiMk = jadwal.prodiMk;
    String sksDisplay = jadwal.sks.toString();

    return Card(
      margin: const EdgeInsets.only(bottom: 18.0),
      elevation: 2.5,
      shadowColor: currentCardShadowColor.withOpacity(0.7), // Used withOpacity
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14.0),
      ),
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(14.0),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Jadwal: $namaMk ($kodeMk)"),
              backgroundColor: secondaryBlue,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 80,
                padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      jamMulai,
                      style: TextStyle(
                        fontSize: 17.5,
                        fontWeight: FontWeight.bold,
                        color: primaryBlue,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Container(
                      height: 12,
                      width: 1.5,
                      color: currentDividerColor.withOpacity(0.8), // Used withOpacity
                      margin: const EdgeInsets.symmetric(vertical: 3),
                    ),
                    Text(
                      jamSelesai,
                      style: TextStyle(
                        fontSize: 15.5,
                        color: subtleTextOnLightBg.withOpacity(0.9), // Used withOpacity
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              // VerticalDivider is tricky for intrinsic height. A Container might be more reliable.
              // For it to show, the Row needs a defined height or the VerticalDivider needs one.
              // Let's use a Container for the visual divider if VerticalDivider is problematic.
              SizedBox(
                height: 100, // Example height, adjust as needed or make parent Row intrinsically sized
                child: VerticalDivider(
                    width: 1.5, // Total width taken by the divider area
                    thickness: 1.5, // Thickness of the line itself
                    color: currentDividerColor.withOpacity(0.6), // Used withOpacity
                    indent: 8, // Space at the top
                    endIndent: 8 // Space at the bottom
                    ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      namaMk,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: textOnLightBg,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      kodeMk,
                      style: TextStyle(
                        fontSize: 13,
                        color: primaryBlue.withOpacity(0.8), // Used withOpacity
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (dosenPengampu.isNotEmpty && dosenPengampu != 'N/A')
                      _buildInfoRow(Icons.person_pin_circle_outlined, dosenPengampu, currentIconColorOnLightBg),
                    if (ruang.isNotEmpty && ruang != 'N/A')
                      _buildInfoRow(Icons.meeting_room_outlined, ruang, currentIconColorOnLightBg),
                    if (kelasMatakuliah.isNotEmpty && kelasMatakuliah != 'N/A')
                      _buildInfoRow(Icons.group_outlined, kelasMatakuliah, currentIconColorOnLightBg),
                    if (prodiMk.isNotEmpty && prodiMk != 'N/A')
                      _buildInfoRow(Icons.school_outlined, prodiMk, currentIconColorOnLightBg),
                    if (sksDisplay != '0') // Assuming SKS can be 0 and shouldn't be displayed
                      _buildInfoRow(Icons.credit_card_outlined, '$sksDisplay SKS', currentIconColorOnLightBg),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
