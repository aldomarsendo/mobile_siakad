// views/dosen/frs/detail_kelas_wali.dart
import 'package:flutter/material.dart';
import 'package:mobile_siakad/models/mahasiswa_model.dart'; // Impor model Mahasiswa dan Kelas
import 'package:mobile_siakad/services/api_client.dart';
import 'package:mobile_siakad/services/dosen/dosen_wali_service.dart'; // Impor service baru
import 'package:http/http.dart' as http;
import 'package:mobile_siakad/views/dosen/frs/detail_frs.dart';
// import 'detail_frs.dart'; // Impor halaman detail FRS jika sudah ada

class DetailKelasWaliPage extends StatefulWidget {
  final Kelas kelas; // Terima objek Kelas dari halaman sebelumnya

  const DetailKelasWaliPage({super.key, required this.kelas});

  @override
  State<DetailKelasWaliPage> createState() => _DetailKelasWaliPageState();
}

class _DetailKelasWaliPageState extends State<DetailKelasWaliPage> {
  List<Mahasiswa> _mahasiswaList = [];
  bool _isLoading = true;
  String? _errorMessage;

  late final DosenWaliService _dosenWaliService;
  final Color primaryBlue = const Color(0xFF133B7A);

  @override
  void initState() {
    super.initState();
    final apiClient = ApiClient(http.Client());
    _dosenWaliService = DosenWaliService(apiClient);
    _fetchMahasiswaByKelas();
  }

  Future<void> _fetchMahasiswaByKelas() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _mahasiswaList = [];
    });

    try {
      // Panggil service untuk mendapatkan semua mahasiswa wali
      final List<Mahasiswa> semuaMahasiswaWali = await _dosenWaliService.getMahasiswaWali();
      
      if (mounted) {
        // Filter mahasiswa berdasarkan idKelas dari widget.kelas
        final List<Mahasiswa> filteredList = semuaMahasiswaWali
            .where((m) => m.idKelas == widget.kelas.idKelas)
            .toList();
        
        // Sortir berdasarkan NRP atau Nama jika perlu
        filteredList.sort((a, b) => (a.nrp).compareTo(b.nrp)); 
        // atau berdasarkan nama: filteredList.sort((a, b) => a.nama.compareTo(b.nama));


        setState(() {
          _mahasiswaList = filteredList;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Gagal memuat data mahasiswa: ${e.toString()}';
        });
      }
      print('Error fetching mahasiswa for kelas ${widget.kelas.namaKelas}: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  DataColumn _createDataColumn(String label, {bool numeric = false}) {
    return DataColumn(
      label: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        textAlign: TextAlign.center,
      ),
      numeric: numeric,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mahasiswa Kelas ${widget.kelas.namaKelas}'),
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchMahasiswaByKelas,
        child: _buildMahasiswaTable(),
      ),
    );
  }

  Widget _buildMahasiswaTable() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: primaryBlue),
            const SizedBox(height: 16),
            const Text('Memuat data mahasiswa...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 50),
              const SizedBox(height: 10),
              Text(_errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _fetchMahasiswaByKelas,
                child: const Text("Coba Lagi"),
              )
            ],
          ),
        ),
      );
    }

    if (_mahasiswaList.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Tidak ada mahasiswa di kelas ini atau data tidak ditemukan.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    return SingleChildScrollView( // Agar tabel bisa di-scroll jika terlalu lebar/panjang
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 20,
          headingRowColor: MaterialStateColor.resolveWith((states) => primaryBlue.withOpacity(0.8)),
          columns: [
            _createDataColumn('NRP'),
            _createDataColumn('Nama Mahasiswa'),
            _createDataColumn('Aksi'),
          ],
          rows: _mahasiswaList.map((mahasiswa) {
            return DataRow(cells: [
              DataCell(Text(mahasiswa.nrp)),
              DataCell(Text(mahasiswa.nama)),
              DataCell(
                ElevatedButton.icon(
                  icon: const Icon(Icons.edit_note, size: 18),
                  label: const Text('FRS'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    textStyle: const TextStyle(fontSize: 13)
                  ),
                   onPressed: () {
      // Navigasi ke halaman detail FRS mahasiswa
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetailFrsPage(mahasiswa: mahasiswa), // Kirim objek mahasiswa
        ),
      ).then((_) {
        // Opsional: Refresh data jika ada perubahan status FRS setelah kembali
        // _fetchMahasiswaByKelas(); 
        // Atau lebih baik refresh halaman FRS detail itu sendiri setelah aksi
      });
    },
                ),
              ),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}