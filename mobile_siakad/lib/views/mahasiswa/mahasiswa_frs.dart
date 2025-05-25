import 'package:flutter/material.dart';

class MahasiswaFrsPage extends StatefulWidget {
  const MahasiswaFrsPage({Key? key}) : super(key: key);

  @override
  State<MahasiswaFrsPage> createState() => _MahasiswaFrsPageState();
}

class _MahasiswaFrsPageState extends State<MahasiswaFrsPage>
    with SingleTickerProviderStateMixin {
  // Contoh data mata kuliah yang bisa diambil (FRS)
  final List<Map<String, String>> matakuliahDiambil = [
    {'kode': '210702-12', 'nama': 'Testing dan Implementasi', 'sks': '3'},
    {'kode': '210702-13', 'nama': 'Rekayasa Web Prak.', 'sks': '2'},
    {'kode': '210702-14', 'nama': 'Sistem Operasi', 'sks': '3'},
  ];

  // Contoh data mata kuliah yang tersedia untuk dipilih
  final List<Map<String, String>> matakuliahTersedia = [
    {'kode': 'KP001', 'nama': 'Konsep Pemrograman', 'sks': '3'},
    {'kode': 'PM002', 'nama': 'Pemrograman Mobile', 'sks': '4'},
    {'kode': 'UIX003', 'nama': 'Desain UI/UX', 'sks': '3'},
    {'kode': 'SO004', 'nama': 'Sistem Operasi', 'sks': '3'}, // Contoh duplikat untuk pilihan
    {'kode': 'WEB005', 'nama': 'Pengembangan Web Dasar', 'sks': '3'},
  ];


  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Palet Warna Utama
  final Color primaryBlue = const Color(0xFF133B7A);
  final Color secondaryBlue = const Color(0xFF1E5BB0);

  // Warna Tambahan dari tema
  final Color textOnLightBg = Colors.black87;
  final Color subtleTextOnLightBg = Colors.grey.shade700;
  late final Color iconColorOnLightBg;
  late final Color dividerColor;
  late final Color cardShadowColor;

  String _selectedSemester = 'Genap'; // Contoh: Genap 2024/2025
  // Menggunakan nama mata kuliah sebagai value untuk DropdownButton
  // Pastikan _selectedMatakuliahTersedia adalah salah satu nama dari matakuliahTersedia
  late String _selectedMatakuliahTersedia;


  @override
  void initState() {
    super.initState();

    // Inisialisasi warna tambahan
    iconColorOnLightBg = primaryBlue.withOpacity(0.75);
    dividerColor = primaryBlue.withOpacity(0.2);
    cardShadowColor = primaryBlue.withOpacity(0.08);

    // Set nilai awal untuk _selectedMatakuliahTersedia
    if (matakuliahTersedia.isNotEmpty) {
      _selectedMatakuliahTersedia = matakuliahTersedia.first['nama']!;
    } else {
      // Handle jika matakuliahTersedia kosong, mungkin dengan nilai default atau error handling
      _selectedMatakuliahTersedia = "Tidak ada mata kuliah";
    }

    // Konfigurasi Animasi
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

  Future<void> _refreshFRS() async {
    // Implementasi logika refresh data jika diperlukan
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() {});
    }
  }

  int _calculateTotalSKS() {
    if (matakuliahDiambil.isEmpty) return 0;
    return matakuliahDiambil.fold(0, (sum, mk) => sum + (int.tryParse(mk['sks'] ?? '0') ?? 0));
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
          'FRS Online',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: RefreshIndicator( // Ditambahkan untuk konsistensi
            onRefresh: _refreshFRS,
            color: primaryBlue,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(), // Atau AlwaysScrollableScrollPhysics
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCard(),
                  const SizedBox(height: 24),
                  _buildSemesterSelector(),
                  const SizedBox(height: 24),
                  _buildStudentDetailsCard(),
                  const SizedBox(height: 24),
                  _buildAddCourseSection(),
                  const SizedBox(height: 24),
                  _buildCourseTable(),
                  const SizedBox(height: 16), // Extra space at bottom
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
            'FRS Online', // Atau bisa diganti 'Formulir Rencana Studi'
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          const Text( // Contoh Tahun Ajaran
            '2024/2025',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28, // Ukuran bisa disesuaikan
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Semester $_selectedSemester',
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
        _buildSectionHeader('Pilih Semester', Icons.calendar_today_outlined),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
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
              style: TextStyle(color: textOnLightBg, fontSize: 16, fontWeight: FontWeight.w500),
              items: ['Ganjil', 'Genap'] // Contoh semester
                  .map((e) => DropdownMenuItem(
                      value: e,
                      child: Text(e, style: TextStyle(color: textOnLightBg))))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedSemester = value;
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStudentDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [ // Bayangan konsisten
          BoxShadow(
            color: cardShadowColor,
            blurRadius: 10, // Disesuaikan
            offset: const Offset(0, 4),  // Disesuaikan
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10), // Padding ikon disesuaikan
                decoration: BoxDecoration(
                  color: primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10), // Radius disesuaikan
                ),
                child: Icon(Icons.person_outline_rounded, color: primaryBlue, size: 24), // Ikon dan size disesuaikan
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text( // Data Mahasiswa (Contoh)
                  'Ahmad Fathan Subagja', // Ganti dengan nama mahasiswa
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: textOnLightBg), // Warna disesuaikan
                  overflow: TextOverflow.ellipsis,
                ),
              )
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRowFRS( // Menggunakan versi FRS
            icon: Icons.credit_card_outlined, // Contoh ikon lain
            label: 'NRP:',
            value: '2103010001', // Ganti dengan NIM mahasiswa
          ),
          const SizedBox(height: 12),
          _buildInfoRowFRS(
            icon: Icons.layers_outlined, // Contoh ikon lain
            label: 'Batas / Sisa SKS:',
            value: '24 / ${_calculateTotalSKS() > 0 ? 24 - _calculateTotalSKS() : 24} SKS', // Contoh perhitungan
          ),
          const SizedBox(height: 12),
          _buildInfoRowFRS(
            icon: Icons.star_border_rounded, // Contoh ikon lain
            label: 'IPK Kumulatif:',
            value: '3.75', // Ganti dengan IPK mahasiswa
          ),
        ],
      ),
    );
  }

  // Versi _buildInfoRow yang disesuaikan untuk FRS agar lebih rapi
  Widget _buildInfoRowFRS({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: iconColorOnLightBg, size: 20), // Menggunakan iconColorOnLightBg
        const SizedBox(width: 12),
        Expanded(
          flex: 2, // Memberi ruang lebih untuk label
          child: Text(
            label,
            style: TextStyle(color: subtleTextOnLightBg, fontSize: 14), // Warna disesuaikan
          ),
        ),
        Expanded(
          flex: 3, // Memberi ruang lebih untuk value
          child: Text(
            value,
            textAlign: TextAlign.end, // Value rata kanan
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: textOnLightBg), // Warna & weight disesuaikan
          ),
        ),
      ],
    );
  }

  Widget _buildAddCourseSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Tambah Mata Kuliah', Icons.add_circle_outline_rounded),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [ // Bayangan konsisten
              BoxShadow(
                color: cardShadowColor,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Container( // Dropdown container styling
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                   boxShadow: [
                      BoxShadow(
                        color: cardShadowColor.withOpacity(0.5), // Shadow lebih halus untuk dropdown
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                   ],
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedMatakuliahTersedia,
                    icon: Icon(Icons.keyboard_arrow_down, color: primaryBlue),
                    style: TextStyle(color: textOnLightBg, fontSize: 16, fontWeight: FontWeight.w500),
                    items: matakuliahTersedia
                        .map((mk) => DropdownMenuItem(
                            value: mk['nama']!,
                            child: Text(
                              "${mk['nama']!} (${mk['sks']} SKS)",
                              style: TextStyle(color: textOnLightBg)
                            )))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedMatakuliahTersedia = value;
                        });
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon( // Menggunakan ElevatedButton.icon
                  icon: const Icon(Icons.add, size: 20 , color: Colors.white), // Ikon disesuaikan
                  onPressed: () {
                    // Logika tambah mata kuliah
                    // Cari mata kuliah yang dipilih dari matakuliahTersedia
                    final selected = matakuliahTersedia.firstWhere((mk) => mk['nama'] == _selectedMatakuliahTersedia, orElse: () => {});
                    if (selected.isNotEmpty) {
                        // Cek apakah mata kuliah sudah ada di matakuliahDiambil
                        bool alreadyExists = matakuliahDiambil.any((mk) => mk['kode'] == selected['kode']);
                        if (alreadyExists) {
                             ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Mata kuliah ${selected['nama']} sudah diambil.'), backgroundColor: Colors.orange),
                              );
                        } else {
                            setState(() {
                                matakuliahDiambil.add(Map<String,String>.from(selected)); // Pastikan SKS juga ditambahkan
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Mata kuliah ${selected['nama']} berhasil ditambahkan.'), backgroundColor: Colors.green),
                            );
                        }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14), // Padding disesuaikan
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  label: const Text(
                    'Tambah Mata Kuliah',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15), // Font size disesuaikan
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCourseTable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Daftar Mata Kuliah Diambil', Icons.list_alt_outlined),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [ // Bayangan konsisten
              BoxShadow(
                color: cardShadowColor,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect( // Untuk memastikan border radius pada child
            borderRadius: BorderRadius.circular(16),
            child: Column(
              children: [
                // Table Header
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16), // Padding disesuaikan
                  color: primaryBlue.withOpacity(0.9), // Warna header lebih soft
                  child: Row(
                    children: [
                      const Expanded(
                        flex: 1,
                        child: Text('No', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                      const Expanded(
                        flex: 3, // Flex untuk kode MK
                        child: Text('Kode MK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                      const Expanded(
                        flex: 5, // Flex untuk nama MK
                        child: Text('Mata Kuliah', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                       const Expanded(
                        flex: 1, // Flex untuk SKS
                        child: Text('SKS', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                      Container(width: 40, alignment: Alignment.centerRight, child: const Text('Aksi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))), // Lebar untuk ikon hapus
                    ],
                  ),
                ),
                // Table Rows
                if (matakuliahDiambil.isEmpty)
                    Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
                        child: Center(
                            child: Text("Belum ada mata kuliah yang diambil.", style: TextStyle(color: subtleTextOnLightBg, fontSize: 15))
                        ),
                    )
                else
                ...List.generate(matakuliahDiambil.length, (index) {
                  final mk = matakuliahDiambil[index];
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), // Padding row disesuaikan
                    decoration: BoxDecoration(
                      border: index < matakuliahDiambil.length - 1
                          ? Border(bottom: BorderSide(color: dividerColor, width: 1)) // Border antar row
                          : null,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Text('${index + 1}', style: TextStyle(color: textOnLightBg, fontSize: 14)),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(mk['kode']!, style: TextStyle(color: textOnLightBg, fontSize: 14)),
                        ),
                        Expanded(
                          flex: 5,
                          child: Text(mk['nama']!, style: TextStyle(color: textOnLightBg, fontWeight: FontWeight.w500, fontSize: 14)),
                        ),
                         Expanded(
                          flex: 1,
                          child: Text(mk['sks'] ?? '0', textAlign: TextAlign.center, style: TextStyle(color: textOnLightBg, fontSize: 14)),
                        ),
                        SizedBox(
                          width: 40, // Lebar konsisten untuk tombol aksi
                          child: IconButton(
                            icon: Icon(Icons.delete_outline_rounded, color: Colors.red.shade500, size: 22), // Warna dan size ikon hapus
                            onPressed: () {
                              setState(() {
                                matakuliahDiambil.removeAt(index);
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Mata kuliah ${mk['nama']} dihapus'), backgroundColor: Colors.red.shade700),
                              );
                            },
                            padding: EdgeInsets.zero, // Menghilangkan padding default IconButton
                            constraints: const BoxConstraints(), // Menghilangkan constraints default
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                // Table Footer
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  color: Colors.grey.shade100, // Warna footer
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Total SKS Diambil:',
                        style: TextStyle(fontWeight: FontWeight.w500, color: textOnLightBg, fontSize: 14),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${_calculateTotalSKS()} SKS',
                        style: TextStyle(fontWeight: FontWeight.bold, color: primaryBlue, fontSize: 15), // Warna total SKS
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}