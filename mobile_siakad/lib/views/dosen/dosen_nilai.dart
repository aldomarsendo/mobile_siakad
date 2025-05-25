import 'package:flutter/material.dart';

class DosenNilaiPage extends StatefulWidget {
  const DosenNilaiPage({Key? key}) : super(key: key);

  @override
  State<DosenNilaiPage> createState() => _DosenNilaiPageState();
}

class _DosenNilaiPageState extends State<DosenNilaiPage>
    with SingleTickerProviderStateMixin {
  // Data contoh (sebaiknya diambil dari state management atau API)
  final List<Map<String, String>> _allMataKuliah = [
    {'kode': 'IF3030', 'nama': 'Kecerdasan Buatan', 'sks': '3', 'nilai': 'A'},
    {'kode': 'IF3031', 'nama': 'Workshop Desain Pengalaman Pengguna', 'sks': '2', 'nilai': 'A-'},
    {'kode': 'IF3032', 'nama': 'Workshop Pemrogramman Perangkat Bergerak', 'sks': '2', 'nilai': 'B+'},
    {'kode': 'IF3033', 'nama': 'Workshop Administrasi Jaringan', 'sks': '2', 'nilai': 'A'},
    {'kode': 'CS1010', 'nama': 'Dasar Pemrograman', 'sks': '3', 'nilai': 'B'},
    {'kode': 'MA2020', 'nama': 'Kalkulus Lanjut', 'sks': '3', 'nilai': 'C+'},
    {'kode': 'FS4040', 'nama': 'Fisika Dasar II', 'sks': '2', 'nilai': 'D'},
    // Tambahkan data lain untuk menguji filter jika perlu
  ];

  List<Map<String, String>> _filteredMataKuliah = [];

  // Palet Warna "Akademik Modern & Interaktif"
  static const Color primaryBlue = Color(0xFF133B7A); // Biru tua solid
  static const Color accentBlue = Color(0xFF3A7BD5); // Biru lebih cerah untuk aksen
  static const Color pageBackground = Color(0xFFF4F7FC); // Abu-abu sangat muda
  static const Color cardBackground = Colors.white;
  static const Color primaryText = Color(0xFF2C3E50); // Abu-abu tua/hitam lembut
  static const Color secondaryText = Color(0xFF6c757d); // Abu-abu lebih terang
  static const Color subtleGrey = Color(0xFFadb5bd);

  static const Color gradeAColor = Color(0xFF2ECC71); // Hijau
  static const Color gradeBColor = Color(0xFF3498DB); // Biru muda
  static const Color gradeCColor = Color(0xFFF39C12); // Oranye
  static const Color gradeDColor = Color(0xFFE74C3C); // Merah
  static const Color gradeEColor = Color(0xFFC0392B); // Merah tua
  static const Color gradeDefaultBg = Color(0xFFE0E0E0); // Abu-abu untuk nilai tidak dikenal / "-"

  final Color dividerColor = Colors.grey.shade300;
  final Color cardShadowColor = Colors.grey.withOpacity(0.12);

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  String? _selectedTahunAjaran = '2024 / 2025';
  String? _selectedSemester = 'Genap';

  // Daftar contoh untuk dropdown (bisa dinamis)
  final List<String> _tahunAjaranOptions = ['2023 / 2024', '2024 / 2025', '2025 / 2026'];
  final List<String> _semesterOptions = ['Ganjil', 'Genap', 'Pendek'];

  @override
  void initState() {
    super.initState();
    _filteredMataKuliah = List.from(_allMataKuliah); // Awalnya tampilkan semua

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600), // Sedikit lebih lambat untuk kesan halus
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutCubic, // Kurva animasi yang lebih smooth
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _animationController.forward();
        _applyFilters(); // Terapkan filter awal jika ada
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    // Logika filter sederhana berdasarkan tahun ajaran dan semester
    // Di aplikasi nyata, ini mungkin melibatkan query ke database atau API
    // Untuk contoh ini, kita hanya akan mengacak atau menampilkan sebagian
    // agar terlihat ada perubahan.
    setState(() {
      // Simulasi filter:
      // Jika Anda memiliki data yang benar-benar terkait dengan tahun dan semester,
      // implementasikan logika filter yang sesuai di sini.
      // Contoh:
      // _filteredMataKuliah = _allMataKuliah.where((mk) {
      //   bool tahunMatch = _selectedTahunAjaran == null || mk['tahun'] == _selectedTahunAjaran;
      //   bool semesterMatch = _selectedSemester == null || mk['semester'] == _selectedSemester;
      //   return tahunMatch && semesterMatch;
      // }).toList();

      // Untuk demo, kita acak saja sedikit atau ubah jumlahnya:
      if (_selectedTahunAjaran == '2023 / 2024') {
          _filteredMataKuliah = _allMataKuliah.take(2).toList();
      } else if (_selectedSemester == 'Ganjil') {
          _filteredMataKuliah = _allMataKuliah.skip(1).take(3).toList();
      }
       else {
        _filteredMataKuliah = List.from(_allMataKuliah)..shuffle();
      }

      // Reset dan jalankan animasi lagi untuk efek refresh
      _animationController.reset();
      _animationController.forward();
    });
  }


  Color _getGradeBackgroundColor(String? nilai) {
    if (nilai == null || nilai == '-') return gradeDefaultBg;
    if (nilai.startsWith('A')) return gradeAColor;
    if (nilai.startsWith('B')) return gradeBColor;
    if (nilai.startsWith('C')) return gradeCColor;
    if (nilai.startsWith('D')) return gradeDColor;
    if (nilai.startsWith('E')) return gradeEColor;
    return gradeDefaultBg;
  }

  Color _getGradeTextColor(String? nilai) {
    if (nilai == null || nilai == '-') return primaryText;
    // Untuk kontras yang baik dengan background grade tertentu
    if (nilai.startsWith('A') || nilai.startsWith('B') || nilai.startsWith('E') || nilai.startsWith('D')) {
      return Colors.white;
    }
    return primaryText;
  }

  Widget _buildNilaiCard(Map<String, String> mk) {
    final String nilaiDisplay = mk['nilai'] ?? '-';
    final Color bgColor = _getGradeBackgroundColor(nilaiDisplay);
    final Color textColor = _getGradeTextColor(nilaiDisplay);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0), // Sedikit horizontal margin
      elevation: 2.5,
      shadowColor: cardShadowColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      color: cardBackground,
      child: InkWell(
        onTap: () {
          // Aksi saat kartu ditekan, misal navigasi ke detail input nilai mahasiswa
          // atau menampilkan dialog detail.
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Detail untuk ${mk['nama']} (belum diimplementasikan)'),
              backgroundColor: accentBlue,
              duration: const Duration(seconds: 2),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Visualisasi Nilai di Kiri
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                alignment: Alignment.center,
                child: Text(
                  nilaiDisplay,
                  // Gunakan 'Poppins' atau font pilihan Anda jika sudah di-setup
                  style: TextStyle(
                    fontFamily: 'Poppins', // Contoh penggunaan custom font
                    color: textColor,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Informasi Mata Kuliah
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mk['nama'] ?? 'Nama Mata Kuliah Tidak Tersedia',
                      // Gunakan 'Poppins' atau font pilihan Anda
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: primaryText,
                        fontSize: 15.5, // Sedikit lebih besar
                        fontWeight: FontWeight.w600, // Semi-bold
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Kode: ${mk['kode'] ?? '-'}  •  ${mk['sks'] ?? '-'} SKS",
                      // Gunakan 'Poppins' atau font pilihan Anda
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: secondaryText,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
              // Ikon Aksi (Contoh: Edit atau Lihat)
              // IconButton(
              //   icon: Icon(Icons.edit_note_outlined, color: accentBlue, size: 26),
              //   onPressed: () {
              //     // Logika untuk edit nilai atau navigasi ke halaman input
              //   },
              //   tooltip: 'Input/Edit Nilai',
              // ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _dropdownDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: secondaryText.withOpacity(0.8), fontSize: 14, fontFamily: 'Poppins'),
      prefixIcon: Icon(icon, color: primaryBlue, size: 20),
      filled: true,
      fillColor: Colors.white, // Atau cardBackground.withOpacity(0.8)
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(color: dividerColor.withOpacity(0.5)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(color: dividerColor.withOpacity(0.7), width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(color: accentBlue, width: 1.5),
      ),
      // Menghilangkan label default agar hintText berfungsi sebagai placeholder
      // labelText: hint,
      // labelStyle: TextStyle(color: primaryBlue.withOpacity(0.8)),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Untuk efek font seperti 'Poppins', pastikan Anda telah menambahkannya ke pubspec.yaml
    // dan folder assets. Jika tidak, Flutter akan menggunakan font default sistem.
    // ThemeData(textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme))

    return Scaffold(
      backgroundColor: pageBackground,
      appBar: AppBar(
        leading: const BackButton(color: Colors.white),
        backgroundColor: primaryBlue,
        elevation: 2.0, // Sedikit shadow untuk kedalaman
        title: const Text(
          'Manajemen Nilai Mahasiswa',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600, // Bold
            fontSize: 18, // Sesuaikan ukuran font
            fontFamily: 'Poppins', // Contoh penggunaan custom font
          ),
        ),
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Bagian Filter
              Text(
                'Filter Data Nilai',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryBlue,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: _dropdownDecoration('Tahun Ajaran', Icons.calendar_today_outlined),
                      value: _selectedTahunAjaran,
                      icon: Icon(Icons.arrow_drop_down_rounded, color: accentBlue, size: 28),
                      items: _tahunAjaranOptions
                          .map((e) => DropdownMenuItem(
                              value: e,
                              child: Text(e, style: TextStyle(color: primaryText, fontSize: 14.5, fontFamily: 'Poppins'))))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedTahunAjaran = value;
                          _applyFilters();
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: _dropdownDecoration('Semester', Icons.school_outlined),
                      value: _selectedSemester,
                      icon: Icon(Icons.arrow_drop_down_rounded, color: accentBlue, size: 28),
                      items: _semesterOptions
                          .map((e) => DropdownMenuItem(
                              value: e,
                              child: Text(e, style: TextStyle(color: primaryText, fontSize: 14.5, fontFamily: 'Poppins'))))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedSemester = value;
                           _applyFilters();
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Judul Daftar Mata Kuliah
              Row(
                children: [
                  Icon(Icons.list_alt_rounded, color: primaryBlue, size: 24),
                  const SizedBox(width: 10),
                  Text(
                    'Daftar Mata Kuliah & Nilai',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryBlue,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Daftar Nilai
              Expanded(
                child: _filteredMataKuliah.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.sentiment_dissatisfied_outlined,
                              size: 70,
                              color: subtleGrey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Tidak ada data nilai\nuntuk filter yang dipilih.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: secondaryText,
                                fontSize: 16,
                                fontFamily: 'Poppins',
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(top: 4.0, bottom: 16.0),
                        itemCount: _filteredMataKuliah.length,
                        itemBuilder: (context, index) {
                          final mk = _filteredMataKuliah[index];
                          // Animasi item list (opsional, bisa ditambahkan dengan package seperti flutter_staggered_animations)
                          return _buildNilaiCard(mk);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}