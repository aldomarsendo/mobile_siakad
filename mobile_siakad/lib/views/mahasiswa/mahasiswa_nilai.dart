import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_siakad/models/mahasiswa_nilai.dart';
import 'package:mobile_siakad/services/api_client.dart';
import 'package:mobile_siakad/services/mahasiswa/mahasiswa_nilai_service.dart'; 

class MahasiswaNilaiPage extends StatefulWidget {
  const MahasiswaNilaiPage({Key? key}) : super(key: key);

  @override
  State<MahasiswaNilaiPage> createState() => _MahasiswaNilaiPageState();
}

class _MahasiswaNilaiPageState extends State<MahasiswaNilaiPage>
    with SingleTickerProviderStateMixin {
  late final ApiClient _apiClient;
  late final MahasiswaNilaiService _nilaiService;

  GetMahasiswaNilaiResponse? _nilaiDataResponse;
  List<MahasiswaNilaiItem> _filteredNilaiItems = []; 
  
  bool _isLoading = true;
  String? _errorMessage;

  // String _selectedSemester = 'Genap 2024/2025'; // Akan diisi dari data API atau default jika API tidak menyediakan
  String? _selectedSemesterView; // Format "Genap 2024/2025"
  List<String> _semesterOptions = []; // Akan diisi dari data API

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final Color primaryBlue = const Color(0xFF133B7A);
  final Color secondaryBlue = const Color(0xFF1E5BB0);
  final Color textOnLightBg = Colors.black87;
  final Color subtleTextOnLightBg = Colors.grey.shade700;
  late final Color cardShadowColor;

  @override
  void initState() {
    super.initState();
    _apiClient = ApiClient(http.Client());
    _nilaiService = MahasiswaNilaiService(_apiClient);

    cardShadowColor = primaryBlue.withOpacity(0.08);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _fetchNilaiData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchNilaiData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _nilaiService.getNilaiMahasiswa();
      if (mounted) {
        setState(() {
          _nilaiDataResponse = data;
          _populateSemesterOptions();
          _filterNilaiBySelectedSemester(); // Filter awal
          _isLoading = false;
        });
        _animationController.forward(from:0.0);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceFirst("Exception: ", "");
        });
      }
    }
  }

  void _populateSemesterOptions() {
    if (_nilaiDataResponse == null || _nilaiDataResponse!.semuaNilai.isEmpty) {
      _semesterOptions = ['Tidak ada data semester'];
      _selectedSemesterView = _semesterOptions.first;
      return;
    }

    // Membuat daftar semester unik dari data nilai
    final Set<String> uniqueSemesters = {};
    for (var item in _nilaiDataResponse!.semuaNilai) {
      if (item.semesterMkDiambil != null && item.tahunAjaranFrs != null) {
        // Asumsi semesterMkDiambil adalah "Ganjil"/"Genap" atau angka
        // dan tahunAjaranFrs adalah "TAHUN/TAHUN"
        String semesterKey = "${item.semesterMkDiambil} ${item.tahunAjaranFrs}";
        uniqueSemesters.add(semesterKey);
      }
    }
    
    _semesterOptions = uniqueSemesters.toList();
    // Sortir semester (opsional, mungkin perlu logika sortir yang lebih kompleks)
    _semesterOptions.sort((a, b) {
        // Sorting sederhana berdasarkan tahun ajaran dulu, lalu semester (Ganjil sebelum Genap)
        final partsA = a.split(' ');
        final partsB = b.split(' ');
        final taA = partsA.length > 1 ? partsA.sublist(1).join(' ') : '';
        final taB = partsB.length > 1 ? partsB.sublist(1).join(' ') : '';
        final semA = partsA.isNotEmpty ? partsA[0] : '';
        final semB = partsB.isNotEmpty ? partsB[0] : '';

        int taCompare = taB.compareTo(taA); // Tahun terbaru dulu
        if (taCompare != 0) return taCompare;
        // Ganjil (1) sebelum Genap (0) jika diurutkan descending, atau sebaliknya
        return (semB.toLowerCase() == 'ganjil' ? 1 : 0).compareTo(semA.toLowerCase() == 'ganjil' ? 1 : 0);
    });


    if (_semesterOptions.isNotEmpty) {
      // Pilih semester terbaru sebagai default jika belum ada yang terpilih
      _selectedSemesterView = _selectedSemesterView ?? _semesterOptions.first;
    } else {
      _semesterOptions = ['Tidak ada data semester'];
      _selectedSemesterView = _semesterOptions.first;
    }
  }

  void _filterNilaiBySelectedSemester() {
    if (_nilaiDataResponse == null || _selectedSemesterView == null || _selectedSemesterView == 'Tidak ada data semester') {
      _filteredNilaiItems = [];
      return;
    }

    final parts = _selectedSemesterView!.split(' ');
    if (parts.length < 2) {
      _filteredNilaiItems = [];
      return;
    }
    final targetSemester = parts[0]; // "Ganjil" atau "Genap"
    final targetTahunAjaran = parts.sublist(1).join(' '); // "TAHUN/TAHUN"

    _filteredNilaiItems = _nilaiDataResponse!.semuaNilai.where((item) {
      return item.semesterMkDiambil?.toLowerCase() == targetSemester.toLowerCase() &&
             item.tahunAjaranFrs == targetTahunAjaran;
    }).toList();
  }


  Map<String, dynamic> _calculateGPAForSelectedSemester() {
    double totalPoints = 0;
    int totalSKS = 0;
    final Map<String, double> bobotNilai = {
      'A': 4.0, 'A-': 3.75, 'B+': 3.25, 'B': 3.0, 'B-': 2.75, 
      'C+': 2.25, 'C': 2.0, 'D': 1.0, 'E': 0.0
    };

    for (var item in _filteredNilaiItems) {
      if (item.nilaiHuruf != null && item.sks > 0 && bobotNilai.containsKey(item.nilaiHuruf!.toUpperCase())) {
        totalPoints += bobotNilai[item.nilaiHuruf!.toUpperCase()]! * item.sks;
        totalSKS += item.sks;
      }
    }
    return {
      'gpa': totalSKS > 0 ? totalPoints / totalSKS : 0.0,
      'totalSks': totalSKS,
    };
  }

  Color _getNilaiColor(String? nilai) {
    if (nilai == null) return Colors.grey.shade500;
    switch (nilai.toUpperCase()) {
      case 'A': return Colors.green.shade600;
      case 'A-': return Colors.green.shade500;
      case 'B+': return Colors.blue.shade700;
      case 'B': return Colors.blue.shade600;
      case 'B-': return Colors.blue.shade500;
      case 'C+': return Colors.orange.shade700;
      case 'C': return Colors.orange.shade600;
      case 'D': return Colors.deepOrange.shade600;
      case 'E': return Colors.red.shade600;
      default: return Colors.grey.shade500;
    }
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> gpaData = {'gpa': 0.0, 'totalSks': 0};
    if (!_isLoading && _nilaiDataResponse != null) {
        gpaData = _calculateGPAForSelectedSemester();
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: primaryBlue,
        elevation: 1.0,
        title: const Text(
          'Nilai Akademik',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: _isLoading ? null : _fetchNilaiData,
            tooltip: 'Refresh Data',
          )
        ],
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: RefreshIndicator(
            onRefresh: _fetchNilaiData,
            color: primaryBlue,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGPACard(gpaData['gpa'], gpaData['totalSks']),
                  const SizedBox(height: 24),
                  _buildSemesterSelector(),
                  const SizedBox(height: 24),
                  _buildSectionHeader('Daftar Nilai Mata Kuliah', Icons.list_alt_rounded),
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

  Widget _buildGPACard(double gpa, int totalSks) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryBlue, secondaryBlue.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'IP Semester (${_selectedSemesterView ?? 'Pilih Semester'})',
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
            'Total SKS Dinilai: $totalSks',
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
    );
  }

  Widget _buildSemesterSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Pilih Periode Nilai', Icons.calendar_today_outlined),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
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
              value: _selectedSemesterView,
              hint: Text("Pilih Semester"),
              icon: Icon(Icons.keyboard_arrow_down, color: primaryBlue),
              style: TextStyle(
                color: textOnLightBg,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              items: _semesterOptions
                  .map((e) => DropdownMenuItem(
                      value: e,
                      child: Text(e, style: TextStyle(color: textOnLightBg))))
                  .toList(),
              onChanged: _isLoading ? null : (value) { // Nonaktifkan saat loading
                if (value != null) {
                  setState(() {
                    _selectedSemesterView = value;
                    _filterNilaiBySelectedSemester(); // Filter data saat semester berubah
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
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded, color: Colors.red.shade700, size: 60),
              const SizedBox(height: 16),
              Text("Oops!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red.shade700)),
              const SizedBox(height: 8),
              Text(_errorMessage!, textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text("Coba Lagi"),
                onPressed: _fetchNilaiData,
                style: ElevatedButton.styleFrom(backgroundColor: primaryBlue, foregroundColor: Colors.white),
              )
            ],
          ),
        )
      );
    }
    if (_filteredNilaiItems.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off_rounded, size: 70, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                "Belum Ada Nilai",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 8),
              Text(
                _selectedSemesterView == 'Tidak ada data semester' 
                ? "Data nilai tidak tersedia."
                : "Nilai untuk semester ${_selectedSemesterView ?? ''} belum tersedia.",
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
      itemCount: _filteredNilaiItems.length,
      itemBuilder: (context, index) {
        final item = _filteredNilaiItems[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: cardShadowColor,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.namaMk,
                      style: TextStyle(
                        fontSize: 15, // Sedikit lebih kecil
                        fontWeight: FontWeight.bold,
                        color: textOnLightBg,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Kode: ${item.kodeMk} • ${item.sks} SKS',
                      style: TextStyle(
                        fontSize: 13, // Sedikit lebih kecil
                        color: subtleTextOnLightBg,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              if (item.statusPenilaian?.toLowerCase() == 'sudah_dinilai' && item.nilaiHuruf != null)
                Container(
                  width: 44, 
                  height: 44,
                  decoration: BoxDecoration(
                    color: _getNilaiColor(item.nilaiHuruf),
                    shape: BoxShape.circle,
                    boxShadow: [
                         BoxShadow(
                          color: _getNilaiColor(item.nilaiHuruf).withOpacity(0.3),
                          blurRadius: 5,
                          offset: const Offset(0,2),
                        )
                      ]
                  ),
                  child: Center(
                    child: Text(
                      item.nilaiHuruf!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17, 
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
              else
                Container( // Placeholder jika belum dinilai
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '-',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}