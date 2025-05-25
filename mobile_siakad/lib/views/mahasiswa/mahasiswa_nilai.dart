import 'package:flutter/material.dart';

class MahasiswaNilaiPage extends StatefulWidget {
  const MahasiswaNilaiPage({Key? key}) : super(key: key);

  @override
  State<MahasiswaNilaiPage> createState() => _MahasiswaNilaiPageState();
}

class _MahasiswaNilaiPageState extends State<MahasiswaNilaiPage>
    with SingleTickerProviderStateMixin {
  // Data Mata Kuliah (Contoh Statis)
  final List<Map<String, dynamic>> mataKuliah = [
    {'kode': '3030', 'nama': 'Kecerdasan Buatan', 'nilai': 'A', 'sks': 3},
    {'kode': '3031', 'nama': 'Workshop Desain Pengalaman Pengguna', 'nilai': 'A', 'sks': 4},
    {'kode': '3032', 'nama': 'Workshop Pemrogramman Perangkat Bergerak', 'nilai': 'A', 'sks': 4},
    {'kode': '3033', 'nama': 'Workshop Administrasi Jaringan', 'nilai': 'AB', 'sks': 3},
    {'kode': '3034', 'nama': 'Pengembangan Aplikasi Web Lanjut', 'nilai': 'B', 'sks': 3},
    {'kode': '3035', 'nama': 'Manajemen Proyek TI', 'nilai': 'C', 'sks': 2},

  ];

  String _selectedSemester = 'Genap 2024/2025'; // Semester default
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<String> semesters = [
    'Genap 2024/2025',
    'Ganjil 2024/2025',
    'Genap 2023/2024',
    'Ganjil 2023/2024',
  ];

  // Palet Warna Utama (Konsisten dengan halaman lain)
  final Color primaryBlue = const Color(0xFF133B7A);
  final Color secondaryBlue = const Color(0xFF1E5BB0);

  // Warna Tambahan dari tema
  final Color textOnLightBg = Colors.black87;
  final Color subtleTextOnLightBg = Colors.grey.shade700;
  late final Color iconColorOnLightBg;
  late final Color dividerColor; // Mungkin tidak terpakai di halaman ini tapi didefinisikan untuk konsistensi
  late final Color cardShadowColor;

  @override
  void initState() {
    super.initState();

    // Inisialisasi warna tambahan
    iconColorOnLightBg = primaryBlue.withOpacity(0.75);
    dividerColor = primaryBlue.withOpacity(0.2);
    cardShadowColor = primaryBlue.withOpacity(0.08);

    // Konfigurasi Animasi (Konsisten dengan halaman lain)
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500), // Disesuaikan
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut, // Disesuaikan
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Kalkulasi IPK
  double calculateGPA() {
    double totalPoints = 0;
    int totalSKS = 0;

    for (var mk in mataKuliah) {
      double point = 0;
      switch (mk['nilai']) {
        case 'A': point = 4.0; break;
        case 'AB': point = 3.5; break;
        case 'B': point = 3.0; break;
        case 'BC': point = 2.5; break;
        case 'C': point = 2.0; break;
        case 'D': point = 1.0; break;
        case 'E': point = 0.0; break;
      }
      totalPoints += point * (mk['sks'] as int);
      totalSKS += mk['sks'] as int;
    }

    return totalSKS > 0 ? totalPoints / totalSKS : 0;
  }

  // Warna berdasarkan Nilai Huruf (dipertahankan karena makna semantik)
  Color _getNilaiColor(String nilai) {
    switch (nilai) {
      case 'A': return Colors.green.shade600; // Sedikit penyesuaian shade
      case 'AB': return Colors.green.shade400;
      case 'B': return Colors.blue.shade600;  // Sedikit penyesuaian shade
      case 'BC': return Colors.blue.shade400;
      case 'C': return Colors.orange.shade600; // Sedikit penyesuaian shade
      case 'D': return Colors.deepOrange.shade600; // Sedikit penyesuaian shade
      case 'E': return Colors.red.shade600; // Sedikit penyesuaian shade
      default: return Colors.grey.shade500;
    }
  }

  Future<void> _refreshNilai() async {
    // Implementasi logika refresh data jika diperlukan (misalnya dari API)
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() {
        // Proses ulang data jika ada perubahan atau hanya untuk memicu rebuild
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    final double gpa = calculateGPA();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: primaryBlue, // Latar belakang solid
        elevation: 1.0, // Elevasi AppBar
        title: const Text(
          'Nilai Akademik',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: RefreshIndicator( // Ditambahkan untuk konsistensi
            onRefresh: _refreshNilai,
            color: primaryBlue,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGPACard(gpa),
                  const SizedBox(height: 24),
                  _buildSemesterSelector(),
                  const SizedBox(height: 24),
                  _buildSectionHeader('Daftar Nilai Mata Kuliah', Icons.school_outlined), // Icon disesuaikan
                  const SizedBox(height: 16),
                  Expanded(
                    child: _buildCoursesList(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGPACard(double gpa) {
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
        boxShadow: [ // Bayangan konsisten
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
            'IP Semester',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            gpa.toStringAsFixed(2),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Total SKS: ${mataKuliah.fold<int>(0, (sum, mk) => sum + (mk['sks'] as int))}',
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300), // Border subtle
            boxShadow: [ // Bayangan konsisten
              BoxShadow(
                color: cardShadowColor,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: _selectedSemester,
              icon: Icon(Icons.keyboard_arrow_down, color: primaryBlue),
              style: TextStyle( // Style teks dropdown utama
                color: textOnLightBg, // Disesuaikan
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              items: semesters
                  .map((e) => DropdownMenuItem(
                      value: e,
                      child: Text(e, style: TextStyle(color: textOnLightBg)))) // Style teks item
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedSemester = value;
                    // Implementasi filter nilai berdasarkan semester jika diperlukan
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCoursesList() {
    if (mataKuliah.isEmpty) { // Penanganan jika data mata kuliah kosong
        return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off_rounded, size: 80, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                "Belum Ada Nilai",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 8),
              Text(
                "Nilai untuk semester ini belum tersedia.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
            ],
          ),
        )
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: mataKuliah.length,
      itemBuilder: (context, index) {
        final mk = mataKuliah[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16.0), // Margin disesuaikan
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [ // Bayangan konsisten
              BoxShadow(
                color: cardShadowColor,
                blurRadius: 8, // Disesuaikan agar lebih subtle
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material( // Untuk InkWell effect
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            child: InkWell( // Efek ripple saat disentuh
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Detail mata kuliah: ${mk['nama']}")),
                );
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center, // Ditengah secara vertikal
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mk['nama'],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textOnLightBg, // Disesuaikan
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6), // Jarak ditambah sedikit
                        Text(
                          'Kode: ${mk['kode']} • ${mk['sks']} SKS',
                          style: TextStyle(
                            fontSize: 13.5, // Ukuran font disesuaikan
                            color: subtleTextOnLightBg, // Disesuaikan
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16), // Jarak antara info MK dan nilai
                  Container(
                    width: 48, // Lebar dan tinggi disesuaikan
                    height: 48,
                    decoration: BoxDecoration(
                      color: _getNilaiColor(mk['nilai']),
                      shape: BoxShape.circle,
                      boxShadow: [ // Bayangan halus untuk bubble nilai
                         BoxShadow(
                           color: _getNilaiColor(mk['nilai']).withOpacity(0.3),
                           blurRadius: 6,
                           offset: const Offset(0,2),
                         )
                      ]
                    ),
                    child: Center(
                      child: Text(
                        mk['nilai'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18, // Ukuran font bisa disesuaikan
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}