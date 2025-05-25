import 'package:flutter/material.dart';
import 'package:mobile_siakad/models/matakuliah_model.dart';
import 'package:mobile_siakad/services/api_client.dart';
import 'package:mobile_siakad/services/auth_service.dart'; // Diperlukan oleh DosenJadwalService
import 'package:mobile_siakad/services/dosen/dosen_jadwal_service.dart'; // Menggunakan service yang ada
import 'package:http/http.dart' as http;
import 'package:mobile_siakad/views/dosen/nilai/list_kelas_matakuliah.dart';
// import 'detail_matakuliah.dart'; // Halaman selanjutnya, akan dibuat nanti

class ListMatakuliahPage extends StatefulWidget {
  const ListMatakuliahPage({Key? key}) : super(key: key);

  @override
  State<ListMatakuliahPage> createState() => _ListMatakuliahPageState();
}

class _ListMatakuliahPageState extends State<ListMatakuliahPage> {
  late final ApiClient _apiClient;
  late final AuthService _authService;
  late final DosenJadwalService _dosenJadwalService;

  List<MataKuliah> _listMataKuliahDiampu = [];
  bool _isLoading = true;
  String? _errorMessage;

  final Color primaryBlue = const Color(0xFF133B7A);

  @override
  void initState() {
    super.initState();
    _apiClient = ApiClient(http.Client());
    _authService = AuthService(_apiClient);
    _dosenJadwalService = DosenJadwalService(_authService, _apiClient);
    _fetchMataKuliahDiampu();
  }

  Future<void> _fetchMataKuliahDiampu() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Memastikan token ada sebelum memanggil service
      final token = await _authService.getToken();
      if (token == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sesi Anda berakhir. Silakan login kembali.')),
          );
          // Arahkan ke halaman login
          Navigator.pushReplacementNamed(context, '/login'); 
        }
        return;
      }

      // Mengambil semua mata kuliah yang diampu (tanpa filter semester)
      final fetchedMataKuliah = await _dosenJadwalService.getMataKuliah();
      
      // Urutkan berdasarkan semester, lalu nama mata kuliah
      fetchedMataKuliah.sort((a, b) {
        int semesterCompare = a.semester.compareTo(b.semester);
        if (semesterCompare != 0) {
          return semesterCompare;
        }
        return a.namaMk.toLowerCase().compareTo(b.namaMk.toLowerCase());
      });
      
      if (mounted) {
        setState(() {
          _listMataKuliahDiampu = fetchedMataKuliah;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Gagal memuat mata kuliah: ${e.toString()}";
        });
      }
      print("Error fetching mata kuliah diampu: $e");
    }
  }

  Widget _buildMataKuliahCard(MataKuliah mk) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.0),
        onTap: () {
          // Navigasi ke halaman detail_matakuliah.dart
          // Anda akan membuat halaman ini selanjutnya.
          print('Navigasi ke detail mata kuliah: ${mk.namaMk} (ID: ${mk.idMk})');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ListKelasMatakuliahPage(selectedCourse: mk),
            ),
          );
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Pilih: ${mk.namaMk}')),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                mk.namaMk,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: primaryBlue,
                ),
              ),
              const SizedBox(height: 8),
              _buildInfoRow(Icons.qr_code_scanner_outlined, "${mk.kodeMk} - ${mk.sks} SKS"),
              _buildInfoRow(Icons.calendar_today_outlined, mk.semester),
              _buildInfoRow(Icons.class_outlined, "Kelas: ${mk.kelas.namaKelas}"),
              // Anda bisa menambahkan info lain jika perlu, misal hari dan jam jika relevan di sini
              // _buildInfoRow(Icons.access_time_filled_outlined, "${mk.hari}, ${mk.jamMulai.substring(0,5)} - ${mk.jamSelesai.substring(0,5)}"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 5.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mata Kuliah Diampu', style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: IconThemeData(color: primaryBlue), // Warna ikon back
        surfaceTintColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchMataKuliahDiampu,
        color: primaryBlue,
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: primaryBlue))
            : _errorMessage != null
                ? _buildErrorWidget()
                : _listMataKuliahDiampu.isEmpty
                    ? _buildEmptyListWidget()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: _listMataKuliahDiampu.length,
                        itemBuilder: (context, index) {
                          final mataKuliah = _listMataKuliahDiampu[index];
                          return _buildMataKuliahCard(mataKuliah);
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
            Icon(Icons.error_outline_rounded, color: Colors.red.shade400, size: 70),
            const SizedBox(height: 20),
            Text(
              "Gagal Memuat Data",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red.shade700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 25),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text("Coba Lagi", style: TextStyle(color: Colors.white)),
              onPressed: _fetchMataKuliahDiampu,
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

  Widget _buildEmptyListWidget() {
     return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school_outlined, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 20),
            Text(
              'Tidak Ada Mata Kuliah',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 8),
            Text(
              'Anda tidak mengampu mata kuliah apapun saat ini.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
            ),
          ],
        ),
      ));
  }
}
