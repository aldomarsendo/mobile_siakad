import 'package:flutter/material.dart';

class MahasiswaJadwalPage extends StatefulWidget {
  const MahasiswaJadwalPage({Key? key}) : super(key: key);

  @override
  State<MahasiswaJadwalPage> createState() => _MahasiswaJadwalPageState();
}

class _MahasiswaJadwalPageState extends State<MahasiswaJadwalPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Palet Warna Utama (Konsisten dengan DosenJadwalPage)
  final Color primaryBlue = const Color(0xFF133B7A);
  final Color secondaryBlue = const Color(0xFF1E5BB0);

  // Warna Tambahan dari DosenJadwalPage
  final Color textOnLightBg = Colors.black87;
  final Color subtleTextOnLightBg = Colors.grey.shade700;
  late final Color iconColorOnLightBg;
  late final Color dividerColor;
  late final Color cardShadowColor;

  String _selectedSemester = 'Genap'; // State untuk semester terpilih

  // Data Jadwal Kuliah (Contoh Statis)
  final List<Map<String, dynamic>> jadwalKuliah = [
    {
      'time': '07:00 - 09:10',
      'subject': 'Testing & Implementasi',
      'room': 'C 203',
      'day': 'Senin'
    },
    {
      'time': '10:00 - 12:30',
      'subject': 'Workshop Design Pengalaman Pengguna',
      'room': 'C 203',
      'day': 'Senin'
    },
    {
      'time': '13:00 - 15:30',
      'subject': 'Workshop Pemrogramman Perangkat Bergerak',
      'room': 'D 301',
      'day': 'Selasa'
    },
    {
      'time': '07:30 - 09:50',
      'subject': 'Workshop Administrasi Jaringan',
      'room': 'Lab Jarkom',
      'day': 'Rabu'
    },
    // Tambahkan jadwal lain jika ada
    {
      'time': '09:00 - 11:30',
      'subject': 'Basis Data Lanjut',
      'room': 'D 205',
      'day': 'Rabu'
    },
  ];

  // Daftar urutan hari yang diinginkan
  final List<String> _daysOrder = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];


  @override
  void initState() {
    super.initState();

    // Inisialisasi warna tambahan
    iconColorOnLightBg = primaryBlue.withOpacity(0.75);
    dividerColor = primaryBlue.withOpacity(0.2);
    cardShadowColor = primaryBlue.withOpacity(0.08);

    // Konfigurasi Animasi (Konsisten dengan DosenJadwalPage)
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
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _refreshJadwal() async {
    // Implementasi logika refresh data jika diperlukan (misalnya dari API)
    // Untuk data statis, kita bisa menambahkan sedikit delay untuk simulasi
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() {
        // Proses ulang data jika ada perubahan atau hanya untuk memicu rebuild
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: const BackButton(color: Colors.white),
        backgroundColor: primaryBlue, // Latar belakang solid
        elevation: 1.0, // Elevasi AppBar
        title: const Text(
          'Jadwal Kuliah',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w600, fontSize: 18),
        ),
        centerTitle: true,
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
                  _buildSemesterSelector(),
                  const SizedBox(height: 24),
                  _buildSectionHeader('Daftar Jadwal Kuliah', Icons.event_note_outlined), // Icon disesuaikan
                  const SizedBox(height: 8), // Mengurangi jarak setelah header daftar jadwal
                  Expanded(
                    child: _buildScheduleList(),
                  ),
                ],
              ),
            ),
          ),
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
          BoxShadow( // Bayangan konsisten dengan DosenJadwalPage
            color: primaryBlue.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Total Mata Kuliah',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9), // Opacity disesuaikan
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            // Filter jadwalKuliah berdasarkan semester jika diperlukan di masa mendatang
            // Saat ini menampilkan semua jadwal
            jadwalKuliah.length.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Semester $_selectedSemester 2024/2025', // Contoh tahun ajaran
            style: TextStyle(
              color: Colors.white.withOpacity(0.9), // Opacity disesuaikan
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
        Icon(icon, color: primaryBlue, size: 22), // Ukuran ikon disesuaikan
        const SizedBox(width: 10), // Jarak disesuaikan
        Text(
          title,
          style: TextStyle(
            fontSize: 18, // Ukuran font disesuaikan
            fontWeight: FontWeight.bold,
            color: primaryBlue,
          ),
        ),
      ],
    );
  }

  Widget _buildSemesterSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Pilih Semester', Icons.calendar_today_outlined), // Icon disesuaikan
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), // Padding vertikal ditambahkan
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                color: cardShadowColor, // Menggunakan cardShadowColor dari DosenJadwalPage
                blurRadius: 5,         // Disesuaikan agar lebih subtle
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: _selectedSemester,
              icon: Icon(Icons.keyboard_arrow_down, color: primaryBlue),
              style: TextStyle(
                color: primaryBlue, // Warna teks dropdown disesuaikan
                fontSize: 16,
                fontWeight: FontWeight.w500, // Konsistensi font weight
              ),
              items: ['Ganjil', 'Genap'] // Bisa diperluas dengan semester lain
                  .map((e) => DropdownMenuItem(
                      value: e,
                      child: Text(e, style: TextStyle(color: textOnLightBg)))) // Warna teks item
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedSemester = value;
                    // Implementasi filter jadwal berdasarkan semester jika diperlukan
                  });
                }
              },
            ),
          ),
        ),
      ],
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

  Widget _buildScheduleList() {
    Map<String, List<Map<String, dynamic>>> groupedSchedule = {};
    for (var jadwal in jadwalKuliah) {
      String day = jadwal['day'];
      if (!groupedSchedule.containsKey(day)) {
        groupedSchedule[day] = [];
      }
      groupedSchedule[day]!.add(jadwal);
    }

    // Mengurutkan jadwal dalam setiap hari berdasarkan jam mulai (bagian pertama dari string 'time')
    groupedSchedule.forEach((day, schedules) {
      schedules.sort((a, b) {
        String timeA = a['time'].split(' - ')[0];
        String timeB = b['time'].split(' - ')[0];
        return timeA.compareTo(timeB);
      });
    });


    // Mengurutkan hari berdasarkan _daysOrder
    List<String> activeDays = groupedSchedule.keys.toList()
      ..sort((a, b) {
        int indexA = _daysOrder.indexOf(a);
        int indexB = _daysOrder.indexOf(b);
        // Handle jika hari tidak ada di _daysOrder (seharusnya tidak terjadi jika data valid)
        if (indexA == -1) return 1;
        if (indexB == -1) return -1;
        return indexA.compareTo(indexB);
      });

    if (activeDays.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.event_busy_outlined, size: 80, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                "Tidak Ada Jadwal",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 8),
              Text(
                "Jadwal kuliah untuk semester ini belum tersedia.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
            ],
          ),
        )
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8.0), // Padding atas untuk list
      physics: const BouncingScrollPhysics(), // Atau AlwaysScrollableScrollPhysics() jika ingin bisa refresh saat item sedikit
      itemCount: activeDays.length,
      itemBuilder: (context, index) {
        String day = activeDays[index];
        List<Map<String, dynamic>> daySchedules = groupedSchedule[day]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 4.0), // Padding atas ditambah
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
            ...daySchedules.map((jadwal) {
              List<String> times = jadwal['time'].split(' - ');
              String jamMulai = times.isNotEmpty ? times[0] : "--:--";
              String jamSelesai = times.length > 1 ? times[1] : "--:--";
              // int slotNumber = daySchedules.indexOf(jadwal) + 1; // Nomor urut per hari

              return _buildScheduleSlot(
                jamMulai: jamMulai,
                jamSelesai: jamSelesai,
                subject: jadwal['subject'],
                room: jadwal['room'],
                // slotNumber: slotNumber, // Jika ingin menampilkan nomor urut
              );
            }).toList(),
             if (index < activeDays.length -1 ) const SizedBox(height: 8), // Jarak antar hari kecuali hari terakhir

          ],
        );
      },
    );
  }

  Widget _buildScheduleSlot({
    required String jamMulai,
    required String jamSelesai,
    required String subject,
    required String room,
    // int? slotNumber, // Opsional
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 2.0,
      shadowColor: cardShadowColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(12.0),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Detail mata kuliah: $subject")),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
          child: Row(
            children: [
              Container(
                width: 75,
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      jamMulai,
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
                      jamSelesai,
                      style: TextStyle(
                        fontSize: 15,
                        color: subtleTextOnLightBg,
                      ),
                    ),
                  ],
                ),
              ),
              VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: dividerColor.withOpacity(0.5),
                  indent: 8,
                  endIndent: 8),
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
                            subject,
                            style: TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.bold,
                              color: textOnLightBg,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // if (slotNumber != null) ...[ // Contoh jika ingin ada nomor slot
                        //   const SizedBox(width: 8),
                        //   Container(
                        //     padding: const EdgeInsets.symmetric(
                        //         horizontal: 7, vertical: 3),
                        //     decoration: BoxDecoration(
                        //       color: primaryBlue.withOpacity(0.1),
                        //       borderRadius: BorderRadius.circular(6),
                        //     ),
                        //     child: Text(
                        //       '$slotNumber',
                        //       style: TextStyle(
                        //         fontSize: 12,
                        //         fontWeight: FontWeight.bold,
                        //         color: primaryBlue,
                        //       ),
                        //     ),
                        //   ),
                        // ]
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildInfoRow(Icons.location_on_outlined, room),
                    // _buildInfoRow(Icons.person_outline_rounded, "Nama Dosen"), // Contoh jika ada data dosen
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