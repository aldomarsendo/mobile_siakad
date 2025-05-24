import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_siakad/models/matakuliah_model.dart';
import 'package:mobile_siakad/services/auth_service.dart';
import 'package:mobile_siakad/services/dosen/dosen_jadwal_service.dart';
import 'package:mobile_siakad/services/api_client.dart';
import 'package:intl/intl.dart'; // Untuk format tanggal

class DosenJadwalPage extends StatefulWidget {
  const DosenJadwalPage({Key? key}) : super(key: key);

  @override
  State<DosenJadwalPage> createState() => _DosenJadwalPageState();
}

class _DosenJadwalPageState extends State<DosenJadwalPage> {
  final AuthService _authService;
  final DosenJadwalService _service;
  List<MataKuliah> _mataKuliah = [];
  bool _isLoading = true; // MODIFIKASI: Default ke true jika ingin load data di awal
  final List<String> _semesterOptions = List.generate(8, (index) => 'Semester ${index + 1}');

  // TAMBAHKAN: Deklarasi state variable untuk semester yang dipilih
  String? _selectedSemester;

  _DosenJadwalPageState()
      : _authService = AuthService(ApiClient(http.Client())),
        _service = DosenJadwalService(
            AuthService(ApiClient(http.Client())),
            ApiClient(http.Client()),
            );

  @override
  void initState() {
    super.initState();
    if (_selectedSemester == null) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    try {
      (_authService as dynamic)._apiClient?.client?.close();
    } catch (e) {
      print("Error closing authService client: $e");
    }
    try {
      (_service as dynamic)._apiClient?.client?.close();
    } catch (e) {
      print("Error closing service client: $e");
    }
    super.dispose();
  }

  Future<void> _loadMataKuliah() async {
    // MODIFIKASI: Tambahkan pengecekan jika _selectedSemester null
    if (_selectedSemester == null) {
      setState(() {
        _mataKuliah = []; // Kosongkan daftar jika tidak ada semester dipilih
        _isLoading = false;
      });
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Silakan pilih semester terlebih dahulu.')),
      // );
      return;
    }

    setState(() {
      _isLoading = true;
      _mataKuliah = []; // Kosongkan list sebelum memuat data baru
    });

    try {
      final token = await _authService.getToken();
      if (token == null) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Sesi Anda berakhir. Silakan login kembali.')),
          );
          Navigator.pushReplacementNamed(context, '/login');
        }
        return;
      }

      final mataKuliah = await _service.getMataKuliah(
        semester: _selectedSemester, // _selectedSemester sudah ada nilainya dari dropdown
      );
      if (mounted) {
        setState(() {
          _mataKuliah = mataKuliah;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _mataKuliah = []; // Kosongkan jika error
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat jadwal: ${e.toString()}')),
        );
      }
      print('Error loading mata kuliah: $e');
    }
  }

  // Fungsi untuk mendapatkan tanggal berdasarkan hari dalam minggu saat ini
  DateTime getDateForDay(String day, DateTime referenceDate) {
    final days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    final referenceDayIndex = referenceDate.weekday - 1; // Senin = 0, Minggu = 6
    final targetDayIndex = days.indexOf(day);

    if (targetDayIndex == -1) { // Jika hari tidak ditemukan
        return referenceDate; // Kembalikan tanggal referensi atau handle error
    }
    final diff = targetDayIndex - referenceDayIndex;
    return referenceDate.add(Duration(days: diff));
  }

  @override
  Widget build(BuildContext context) {
    final List<String> daysOrder = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat'];
    Map<String, List<MataKuliah>> groupedByDay = {};

    // Hanya proses pengelompokan jika _mataKuliah tidak kosong dan _selectedSemester sudah dipilih
    if (_mataKuliah.isNotEmpty && _selectedSemester != null) {
      for (var day in daysOrder) {
        groupedByDay[day] = _mataKuliah.where((mk) => mk.hari == day).toList()
          ..sort((a, b) => a.jamMulai.compareTo(b.jamMulai));
      }
    }

    final activeDays = daysOrder.where((day) => groupedByDay[day]?.isNotEmpty ?? false).toList();
    final referenceDate = DateTime(2025, 5, 23); // Jumat
    final formatter = DateFormat('d MMMM yyyy', 'id_ID'); // Format tanggal diubah ke 'd MMMM yyyy'

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: Colors.black87),
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Jadwal Kuliah',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.school_outlined, color: Color(0xFF133B7A)),
                SizedBox(width: 8),
                Text(
                  'Jadwal Kuliah saya',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF133B7A)),
                ),
              ],
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Semester',
                labelStyle: TextStyle(color: Color(0xFF133B7A)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Color(0xFF133B7A), width: 2),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 15.0),
              ),
              value: _selectedSemester,
              hint: const Text('Pilih Semester'),
              items: _semesterOptions
                  .map((semesterValue) => DropdownMenuItem(
                        value: semesterValue,
                        child: Text(semesterValue),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null && value != _selectedSemester) { // MODIFIKASI: Cek jika nilai benar-benar berubah
                  setState(() {
                    _selectedSemester = value;
                    // _isLoading = true; // isLoading akan di-set di _loadMataKuliah
                  });
                  _loadMataKuliah(); // Panggil fungsi untuk memuat data
                }
              },
              isExpanded: true,
              icon: Icon(Icons.arrow_drop_down, color: Color(0xFF133B7A)),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator(color: Color(0xFF133B7A)))
                  : _selectedSemester == null // MODIFIKASI: Tampilkan pesan jika belum pilih semester
                      ? Center(
                          child: Text(
                          'Silakan pilih semester untuk melihat jadwal.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                        ))
                      : activeDays.isEmpty && _mataKuliah.isEmpty // MODIFIKASI: Kondisi jika tidak ada jadwal setelah memilih
                          ? Center(
                              child: Text(
                              'Tidak ada jadwal kuliah untuk $_selectedSemester.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                            ))
                          : ListView.builder(
                              // padding: EdgeInsets.symmetric(horizontal: 20), // Padding ini mungkin membuat tampilan kurang pas
                              itemCount: activeDays.length,
                              itemBuilder: (context, index) {
                                final day = activeDays[index];
                                final mataKuliahList = groupedByDay[day]!;
                                final date = formatter.format(getDateForDay(day, referenceDate));

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 4.0, right: 4.0, top: 8.0, bottom: 8.0), // Sesuaikan padding
                                      child: Row(
                                        children: [
                                          Text(
                                            '$day, $date',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          Spacer(),
                                          Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                                        ],
                                      ),
                                    ),
                                    // SizedBox(height: 16), // Kurangi spasi jika terlalu banyak
                                    ...mataKuliahList.map((mk) {
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 16.0),
                                        child: _classCard(
                                          time: '${mk.jamMulai.substring(0, 5)} - ${mk.jamSelesai.substring(0, 5)}',
                                          subject: mk.namaMk,
                                          room: mk.ruang.namaRuang, // Pastikan model MataKuliah Anda memiliki objek ruang yang benar
                                        ),
                                      );
                                    }).toList(),
                                  ],
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _classCard({
    required String time,
    required String subject,
    required String room,
  }) {
    return Container(
      width: double.infinity, // Agar card memenuhi lebar
      decoration: BoxDecoration(
        color: Color(0xFF133B7A),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            time,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontWeight: FontWeight.normal,
              fontSize: 13,
            ),
          ),
          SizedBox(height: 6),
          Text(
            subject,
            style: TextStyle(
              fontSize: 17, // Sedikit lebih besar agar mudah dibaca
              fontWeight: FontWeight.w600, // Lebih tebal
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8), // Tambah spasi
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 16, color: Colors.white.withOpacity(0.8)),
              SizedBox(width: 6), // Tambah spasi
              Expanded( // Agar teks ruang tidak overflow jika panjang
                child: Text(
                  room,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
