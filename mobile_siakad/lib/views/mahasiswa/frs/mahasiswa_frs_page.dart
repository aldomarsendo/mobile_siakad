import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Model yang Digunakan
import 'package:mobile_siakad/models/frs_model.dart';
import 'package:mobile_siakad/models/mahasiswa_frs_data_model.dart';

// Service yang Digunakan
import 'package:mobile_siakad/services/api_client.dart';
import 'package:mobile_siakad/services/mahasiswa/mahasiswa_frs_service.dart';

// Komponen UI Kustom Anda (pastikan path ini benar)
import 'package:mobile_siakad/views/mahasiswa/frs/frs_summary_card.dart';
import 'package:mobile_siakad/views/mahasiswa/frs/frs_student_details_card.dart';
import 'package:mobile_siakad/views/mahasiswa/frs/frs_add_course_section.dart';
import 'package:mobile_siakad/views/mahasiswa/frs/frs_course_table.dart';
// import 'widgets/frs_semester_selector.dart'; // Jika akan digunakan

class MahasiswaFrsPage extends StatefulWidget {
  const MahasiswaFrsPage({Key? key}) : super(key: key);

  @override
  State<MahasiswaFrsPage> createState() => _MahasiswaFrsPageState();
}

class _MahasiswaFrsPageState extends State<MahasiswaFrsPage>
    with SingleTickerProviderStateMixin {
  late final ApiClient _apiClient;
  late final MahasiswaFrsService _frsService;

  List<FrsItem> _matakuliahDiambil = [];
  List<AvailableMatakuliahItem> _matakuliahTersedia = [];

  bool _isLoadingMyFrs = true;
  bool _isLoadingAvailableMk = true;
  bool _isSubmitting = false; // Untuk loading saat add/delete
  String? _errorMessage;

  // Data mahasiswa & TA - Placeholder, idealnya dari API Profile & API Info TA Aktif
  String _namaMahasiswa = "Nama Mahasiswa";
  String _nrpMahasiswa = "NRP Mahasiswa";
  String _ipkMahasiswa = "N/A";
  int _batasSks = 24;
  String _tahunAjaranAktif = "Memuat...";
  String _semesterAktifDisplay = "Memuat...";

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final Color primaryBlue = const Color(0xFF133B7A);
  final Color secondaryBlue = const Color(0xFF1E5BB0);
  final Color textOnLightBg = Colors.black87;
  final Color subtleTextOnLightBg = Colors.grey.shade700;
  late final Color iconColorOnLightBg;
  late final Color dividerColor;
  late final Color cardShadowColor;

  int? _selectedMatakuliahTersediaId;

  @override
  void initState() {
    super.initState();

    _apiClient = ApiClient(http.Client());
    _frsService = MahasiswaFrsService(_apiClient);

    iconColorOnLightBg = primaryBlue.withOpacity(0.75);
    dividerColor = primaryBlue.withOpacity(0.2);
    cardShadowColor = primaryBlue.withOpacity(0.08);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _loadInitialData();
    // TODO: Panggil service untuk mengambil data profil mahasiswa dan update state _namaMahasiswa, _nrpMahasiswa, dll.
    // _fetchMahasiswaProfile(); 
  }

  Future<void> _loadInitialData() async {
    if (!mounted) return;
    setState(() {
      _isLoadingMyFrs = true;
      _isLoadingAvailableMk = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        _frsService.getMyFrs(),
        _frsService.getAvailableMatakuliah(),
      ]);

      final myFrsResponse = results[0] as GetMyFrsResponse;
      final availableMkResponse = results[1] as GetAvailableMatakuliahResponse;

      if (mounted) {
        setState(() {
          _matakuliahDiambil = myFrsResponse.frs;
          _matakuliahTersedia = availableMkResponse.matakuliah;

          if (_matakuliahDiambil.isNotEmpty) {
            _tahunAjaranAktif = _matakuliahDiambil.first.tahunAjaranFrs ?? "N/A";
            _semesterAktifDisplay = _matakuliahDiambil.first.jadwalKuliah?.semesterPelaksanaan ?? "N/A";
          } else if (availableMkResponse.matakuliah.isNotEmpty) {
            // Jika API getAvailableMatakuliah mengembalikan info TA/Semester global, gunakan itu.
            // Jika tidak, ini akan menjadi placeholder.
            // Anda mungkin perlu endpoint API khusus untuk info TA/Semester aktif.
            _tahunAjaranAktif = "TA Aktif"; // Placeholder
            _semesterAktifDisplay = availableMkResponse.matakuliah.first.semesterPelaksanaan ?? "N/A"; 
          } else {
            _tahunAjaranAktif = "N/A";
            _semesterAktifDisplay = "N/A";
          }
          
          if (_matakuliahTersedia.isNotEmpty) {
            _selectedMatakuliahTersediaId = _matakuliahTersedia.first.idMkJadwal;
          } else {
            _selectedMatakuliahTersediaId = null;
          }

          _isLoadingMyFrs = false;
          _isLoadingAvailableMk = false;
          
        });
        _animationController.forward(from: 0.0);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Gagal memuat data FRS: ${e.toString().replaceFirst("Exception: ", "")}";
          _isLoadingMyFrs = false;
          _isLoadingAvailableMk = false;
        });
      }
      print("Error loading initial FRS data: $e");
    }
  }

  Future<void> _refreshFRS() async {
    await _loadInitialData();
  }

  int _calculateTotalSKS() {
    if (_matakuliahDiambil.isEmpty) return 0;
    return _matakuliahDiambil.fold(0, (sum, item) {
      final sksInt = item.jadwalKuliah?.masterMatakuliah?.sks ?? 
                     item.jadwalKuliah?.masterMatakuliah?.sks ?? 
                     0;
      return sum + sksInt;
    });
  }
  
  void _showErrorSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade700, duration: const Duration(seconds: 3)),
    );
  }

  void _showSuccessSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green.shade700, duration: const Duration(seconds: 2)),
    );
  }

  Future<void> _handleAddCourse() async {
    if (_selectedMatakuliahTersediaId == null) {
      _showErrorSnackbar('Silakan pilih mata kuliah terlebih dahulu.');
      return;
    }
    if (_isSubmitting) return; // Mencegah multiple submissions

    // Cek apakah mata kuliah sudah ada di FRS yang diambil mahasiswa
    bool alreadyExists = _matakuliahDiambil.any((item) =>
        (item.jadwalKuliah?.idJadwal == _selectedMatakuliahTersediaId) ||
        (item.jadwalKuliah?.masterMatakuliah?.idMasterMk == _selectedMatakuliahTersediaId) // Untuk FRS item dari createFRS response
    );

    if (alreadyExists) {
      String mkNameToDisplay = "Mata kuliah yang dipilih"; // Default
      try {
        // Mencoba mendapatkan nama MK dari daftar yang tersedia untuk pesan error
        final selectedMkFromAvailableList = _matakuliahTersedia.firstWhere(
          (mk) => mk.idMkJadwal == _selectedMatakuliahTersediaId,
        );
        mkNameToDisplay = selectedMkFromAvailableList.namaMk;
      } catch (e) {
        // Jika tidak ketemu di _matakuliahTersedia (seharusnya tidak terjadi jika ID valid)
        // kita bisa coba cari dari _matakuliahDiambil karena sudah dipastikan ada.
        try {
          final existingFrsItem = _matakuliahDiambil.firstWhere((item) =>
              (item.jadwalKuliah?.idJadwal == _selectedMatakuliahTersediaId));
          mkNameToDisplay = existingFrsItem.jadwalKuliah?.masterMatakuliah?.namaMk ?? 
                            "Mata kuliah yang dipilih";
        } catch (e2) {
          print("Error finding existing MK name for snackbar: $e2");
        }
        print("Warning: Selected MK ID '$_selectedMatakuliahTersediaId' not found in available list for error message, though it exists in FRS.");
      }
      _showErrorSnackbar('$mkNameToDisplay sudah ada dalam FRS Anda.');
      return;
    }

    // Dapatkan detail mata kuliah yang akan ditambahkan
    AvailableMatakuliahItem? mkToAdd;
    try {
      mkToAdd = _matakuliahTersedia.firstWhere((mk) => mk.idMkJadwal == _selectedMatakuliahTersediaId);
    } catch (e) {
      print("Error finding MK to add in _matakuliahTersedia: $e");
      mkToAdd = null;
    }
    
    if (mkToAdd == null) { 
      _showErrorSnackbar('Mata kuliah yang dipilih tidak valid atau tidak ditemukan.');
      return;
    }

    final int sksToAddInt = mkToAdd.sks;

    // Validasi batas SKS
    if ((_calculateTotalSKS() + sksToAddInt) > _batasSks) {
      _showErrorSnackbar('Tidak dapat menambah mata kuliah. Total SKS ($_batasSks SKS) akan terlampaui.');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      // Panggil service untuk membuat FRS
      final createFrsResponse = await _frsService.createFrs(_selectedMatakuliahTersediaId!);
      _showSuccessSnackbar(createFrsResponse.message);
      await _refreshFRS(); // Refresh data FRS yang diambil dan mata kuliah tersedia
    } catch (e) {
      // Pesan error dari service sudah di-handle untuk menampilkan pesan API jika ada
      _showErrorSnackbar('Gagal menambah mata kuliah: ${e.toString().replaceFirst("Exception: ", "")}');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _handleDeleteCourse(int idFrs, String namaMk) async {
    if (_isSubmitting) return;
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Apakah Anda yakin ingin menghapus mata kuliah "$namaMk" dari FRS?'),
        actions: <Widget>[
          TextButton(child: const Text('Batal'), onPressed: () => Navigator.of(context).pop(false)),
          TextButton(style: TextButton.styleFrom(foregroundColor: Colors.red), child: const Text('Hapus'), onPressed: () => Navigator.of(context).pop(true)),
        ],
      ),
    );

    if (confirmDelete == true) {
      setState(() => _isSubmitting = true);
      try {
        final message = await _frsService.deleteFrs(idFrs);
        _showSuccessSnackbar(message);
        await _refreshFRS(); 
      } catch (e) {
        _showErrorSnackbar('Gagal menghapus mata kuliah: ${e.toString().replaceFirst("Exception: ", "")}');
      } finally {
        if (mounted) setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Di dalam class _MahasiswaFrsPageState

@override
Widget build(BuildContext context) {
  bool showPageLoading = (_isLoadingMyFrs || _isLoadingAvailableMk) && 
                         _matakuliahDiambil.isEmpty && 
                         _matakuliahTersedia.isEmpty && 
                         _errorMessage == null;

  return Scaffold(
    backgroundColor: Colors.grey[100],
    appBar: AppBar(
      leading: const BackButton(color: Colors.white),
      backgroundColor: primaryBlue, // Menggunakan variabel warna Anda
      elevation: 1.0,
      title: const Text('FRS Online', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 18)),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(Icons.refresh, color: Colors.white),
          // Nonaktifkan tombol refresh saat sedang loading atau submitting
          onPressed: (showPageLoading || _isSubmitting) ? null : _refreshFRS,
          tooltip: 'Refresh Data',
        )
      ],
    ),
    body: SafeArea(
      child: FadeTransition(
        opacity: _fadeAnimation, // Menggunakan animasi fade Anda
        child: RefreshIndicator(
          onRefresh: _refreshFRS,
          color: primaryBlue, // Menggunakan variabel warna Anda
          child: 
              // 1. Tampilkan Error jika ada (dan bukan loading awal)
              _errorMessage != null && !showPageLoading 
                ? _buildErrorWidget() 
              // 2. Tampilkan Loading Utama jika sedang loading awal
                : showPageLoading 
                    ? Center(child: CircularProgressIndicator(color: primaryBlue))
              // 3. Tampilkan Konten Utama jika tidak loading dan tidak ada error
                    : SingleChildScrollView(
                        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FrsSummaryCard(
                              tahunAjaran: _tahunAjaranAktif,
                              semesterDisplay: _semesterAktifDisplay,
                              primaryColor: primaryBlue,
                              secondaryColor: secondaryBlue,
                            ),
                            const SizedBox(height: 24),
                            FrsStudentDetailsCard(
                              namaMahasiswa: _namaMahasiswa,
                              nrpMahasiswa: _nrpMahasiswa,
                              ipkMahasiswa: _ipkMahasiswa,
                              batasSks: _batasSks,
                              totalSksDiambil: _calculateTotalSKS(),
                              primaryColor: primaryBlue,
                              textOnLightBgColor: textOnLightBg,
                              subtleTextOnLightBgColor: subtleTextOnLightBg,
                              iconColorOnLightBgColor: iconColorOnLightBg,
                              cardShadowColor: cardShadowColor,
                            ),
                            const SizedBox(height: 24),
                            FrsAddCourseSection(
                              matakuliahTersedia: _matakuliahTersedia,
                              selectedMatakuliahId: _selectedMatakuliahTersediaId,
                              onMatakuliahChanged: (value) {
                                if (value != null) {
                                  setState(() => _selectedMatakuliahTersediaId = value);
                                }
                              },
                              onAddCoursePressed: _isSubmitting ? null : _handleAddCourse,
                              isLoadingAvailableMk: _isLoadingAvailableMk, // Untuk loading di dalam section ini
                              isSubmitting: _isSubmitting, // Untuk status tombol tambah
                              primaryColor: primaryBlue,
                              textOnLightBgColor: textOnLightBg,
                              subtleTextOnLightBgColor: subtleTextOnLightBg,
                              cardShadowColor: cardShadowColor,
                            ),
                            const SizedBox(height: 24),
                            FrsCourseTable(
                              matakuliahDiambil: _matakuliahDiambil,
                              onDeleteCourse: _isSubmitting ? null : _handleDeleteCourse,
                              isLoadingMyFrs: _isLoadingMyFrs, // Untuk loading di dalam tabel ini
                              isSubmitting: _isSubmitting, // Bisa digunakan untuk disable tombol hapus per baris
                              totalSksDiambil: _calculateTotalSKS(),
                              primaryColor: primaryBlue,
                              textOnLightBgColor: textOnLightBg,
                              subtleTextOnLightBgColor: subtleTextOnLightBg,
                              dividerColor: dividerColor,
                              cardShadowColor: cardShadowColor,
                            ),
                            const SizedBox(height: 16),
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
            Icon(Icons.error_outline_rounded, color: Colors.red.shade700, size: 60),
            const SizedBox(height: 15),
            Text(
              "Oops! Terjadi Kesalahan",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red.shade700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? "Gagal memuat data. Silakan coba lagi.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text("Coba Lagi", style: TextStyle(color: Colors.white)),
              onPressed: _loadInitialData, // Memanggil _loadInitialData untuk refresh
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                textStyle: const TextStyle(fontSize: 15)
              ),
            )
          ],
        ),
      ),
    );
  }
}