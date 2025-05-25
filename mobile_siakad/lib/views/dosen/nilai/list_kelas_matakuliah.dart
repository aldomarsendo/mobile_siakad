import 'package:flutter/material.dart';
import 'package:mobile_siakad/models/matakuliah_model.dart'; // Mengimpor MataKuliah dan Kelas yang terkait dengannya
import 'package:mobile_siakad/models/mahasiswa_model.dart' hide Kelas; // Menyembunyikan Kelas dari mahasiswa_model untuk menghindari konfli                // Jika Anda memerlukan model Mahasiswa di sini, Anda bisa tetap mengimpornya.
import 'package:mobile_siakad/services/api_client.dart';
import 'package:mobile_siakad/services/auth_service.dart';
import 'package:mobile_siakad/services/dosen/dosen_jadwal_service.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_siakad/views/dosen/nilai/input_nilai_mahasiswa.dart';
// import 'list_mahasiswa_nilai.dart'; // Halaman selanjutnya, akan dibuat nanti

class ListKelasMatakuliahPage extends StatefulWidget {
  final MataKuliah selectedCourse; 

  const ListKelasMatakuliahPage({Key? key, required this.selectedCourse}) : super(key: key);

  @override
  State<ListKelasMatakuliahPage> createState() => _ListKelasMatakuliahPageState();
}

class _ListKelasMatakuliahPageState extends State<ListKelasMatakuliahPage> {
  late final ApiClient _apiClient;
  late final AuthService _authService;
  late final DosenJadwalService _dosenJadwalService;

  // Tipe _uniqueKelasList sekarang akan mengikuti tipe Kelas yang diekspor oleh matakuliah_model.dart
  List<Kelas> _uniqueKelasList = []; 
  bool _isLoading = true;
  String? _errorMessage;

  final Color primaryBlue = const Color(0xFF133B7A);

  @override
  void initState() {
    super.initState();
    _apiClient = ApiClient(http.Client());
    _authService = AuthService(_apiClient);
    _dosenJadwalService = DosenJadwalService(_authService, _apiClient);
    _fetchAndFilterKelasForMatakuliah();
  }

  Future<void> _fetchAndFilterKelasForMatakuliah() async {
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

      final List<MataKuliah> allScheduledCourses = await _dosenJadwalService.getMataKuliah();

      final List<MataKuliah> schedulesForThisCourse = allScheduledCourses.where((schedule) =>
        schedule.kodeMk == widget.selectedCourse.kodeMk &&
        schedule.namaMk == widget.selectedCourse.namaMk
      ).toList();

      Map<int, Kelas> uniqueKelasMap = {};
      for (var schedule in schedulesForThisCourse) {
        // PERBAIKAN: Tambahkan null check untuk schedule.kelas
        if (schedule.kelas != null) { 
          // Jika schedule.kelas adalah non-nullable (final Kelas kelas;), tanda seru (!) tidak diperlukan.
          // Jika schedule.kelas adalah nullable (final Kelas? kelas;), maka '!' atau '?' diperlukan.
          // Asumsi 'Kelas' dari matakuliah_model memiliki idKelas.
          // Jika 'idKelas' juga nullable di model Kelas, perlu penanganan lebih lanjut.
          if (!uniqueKelasMap.containsKey(schedule.kelas.idKelas)) {
            uniqueKelasMap[schedule.kelas.idKelas] = schedule.kelas;
          }
        }
      }
      
      List<Kelas> displayableClasses = uniqueKelasMap.values.toList();
      // PERBAIKAN: Pastikan a.namaKelas dan b.namaKelas tidak null sebelum memanggil toLowerCase() jika namaKelas bisa null.
      // Model Kelas yang Anda berikan sebelumnya memiliki namaKelas non-nullable (String).
      displayableClasses.sort((a,b) => (a.namaKelas ?? "").toLowerCase().compareTo((b.namaKelas ?? "").toLowerCase()));
      
      if (mounted) {
        setState(() {
          _uniqueKelasList = displayableClasses;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Gagal memuat daftar kelas: ${e.toString()}";
        });
      }
      print("Error fetching/filtering kelas for matakuliah: $e");
    }
  }

  // Parameter 'kelas' sekarang bertipe Kelas (dari matakuliah_model.dart)
  Widget _buildKelasCard(Kelas kelas) { 
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: Icon(Icons.class_rounded, color: primaryBlue, size: 30),
        title: Text(
          // PERBAIKAN: Tambahkan null check atau default value jika namaKelas bisa null.
          // Berdasarkan model Kelas yang Anda berikan sebelumnya, namaKelas adalah non-nullable.
          kelas.namaKelas, 
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
        subtitle: Text(
             // PERBAIKAN: Tambahkan null check atau default value jika status bisa null.
            'Status: ${kelas.status}', // Asumsi status non-nullable di model Kelas Anda
             style: TextStyle(fontSize: 13, color: Colors.grey.shade600)
        ),
        trailing: Icon(Icons.chevron_right, color: Colors.grey.shade600),
        onTap: () {
          print('Pilih kelas: ${kelas.namaKelas} (ID: ${kelas.idKelas}) untuk Mata Kuliah: ${widget.selectedCourse.namaMk}');
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Pilih kelas: ${kelas.namaKelas}')),
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InputNilaiMahasiswaPage(
                selectedKelas: kelas, // Tipe Kelas harus konsisten
                selectedMataKuliah: widget.selectedCourse,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Pilih Kelas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(
              widget.selectedCourse.namaMk, 
              style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.9)),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchAndFilterKelasForMatakuliah,
        color: primaryBlue,
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: primaryBlue))
            : _errorMessage != null
                ? _buildErrorWidget()
                : _uniqueKelasList.isEmpty
                    ? _buildEmptyListWidget()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: _uniqueKelasList.length,
                        itemBuilder: (context, index) {
                          final kelas = _uniqueKelasList[index];
                          return _buildKelasCard(kelas);
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
            Icon(Icons.error_outline_rounded, color: Colors.red.shade400, size: 60),
            const SizedBox(height: 15),
            Text(
              "Gagal Memuat Data Kelas",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red.shade700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text("Coba Lagi", style: TextStyle(color: Colors.white)),
              onPressed: _fetchAndFilterKelasForMatakuliah,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                textStyle: const TextStyle(fontSize: 15)
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyListWidget() {
     return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.class_outlined, size: 70, color: Colors.grey.shade400),
            const SizedBox(height: 15),
            Text(
              'Tidak Ada Kelas',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 8),
            Text(
              'Tidak ditemukan kelas yang diajar untuk mata kuliah "${widget.selectedCourse.namaMk}".',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.grey.shade500),
            ),
          ],
        ),
      ));
  }
}
