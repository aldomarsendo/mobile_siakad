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
  bool _isLoading = true;
  String? _selectedSemester = 'Genap';

  _DosenJadwalPageState()
      : _authService = AuthService(ApiClient(http.Client())),
        _service = DosenJadwalService(
            AuthService(ApiClient(http.Client())),
            ApiClient(http.Client()),
          );

  @override
  void initState() {
    super.initState();
    _loadMataKuliah();
  }

  @override
  void dispose() {
    (_authService as dynamic)._apiClient.client.close();
    (_service as dynamic)._apiClient.client.close();
    super.dispose();
  }

  Future<void> _loadMataKuliah() async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Silakan login terlebih dahulu')),
        );
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }
      final mataKuliah = await _service.getMataKuliah(
        semester: _selectedSemester,
      );
      setState(() {
        _mataKuliah = mataKuliah;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  // Fungsi untuk mendapatkan tanggal berdasarkan hari dalam minggu saat ini
  DateTime getDateForDay(String day, DateTime referenceDate) {
    final days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    final referenceDayIndex = referenceDate.weekday - 1; // Senin = 0, Minggu = 6
    final targetDayIndex = days.indexOf(day);
    final diff = targetDayIndex - referenceDayIndex;
    return referenceDate.add(Duration(days: diff));
  }

  @override
  Widget build(BuildContext context) {
    // Daftar hari untuk urutan Senin sampai Jumat
    final List<String> daysOrder = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat'];

    // Kelompokkan mata kuliah berdasarkan hari
    Map<String, List<MataKuliah>> groupedByDay = {};
    for (var day in daysOrder) {
      groupedByDay[day] = _mataKuliah.where((mk) => mk.hari == day).toList()
        ..sort((a, b) => a.jamMulai.compareTo(b.jamMulai)); // Urutkan berdasarkan jam_mulai
    }

    // Filter hanya hari yang memiliki mata kuliah
    final activeDays = daysOrder.where((day) => groupedByDay[day]!.isNotEmpty).toList();

    // Tanggal referensi adalah 23 Mei 2025 (Jumat)
    final referenceDate = DateTime(2025, 5, 23);
    final formatter = DateFormat('d MMMM yyyy', 'id_ID');

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
                Icon(Icons.school_outlined, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Jadwal Kuliah saya',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Semester',
                border: OutlineInputBorder(),
              ),
              value: _selectedSemester,
              items: ['Ganjil', 'Genap']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSemester = value;
                  _isLoading = true;
                });
                _loadMataKuliah();
              },
            ),
            SizedBox(height: 24),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : activeDays.isEmpty
                      ? Center(child: Text('Tidak ada jadwal kuliah'))
                      : ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          itemCount: activeDays.length,
                          itemBuilder: (context, index) {
                            final day = activeDays[index];
                            final mataKuliahList = groupedByDay[day]!;
                            final date = formatter.format(getDateForDay(day, referenceDate));

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                  child: Row(
                                    children: [
                                      Text(
                                        '$day, $date',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Spacer(),
                                      Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 16),
                                ...mataKuliahList.map((mk) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 16.0),
                                    child: _classCard(
                                      time: '${mk.jamMulai.substring(0, 5)} - ${mk.jamSelesai.substring(0, 5)}',
                                      subject: mk.namaMk,
                                      room: mk.ruang.namaRuang,
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
      decoration: BoxDecoration(
        color: Color(0xFF133B7A),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
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
              color: Colors.white,
              fontWeight: FontWeight.normal,
            ),
          ),
          SizedBox(height: 6),
          Text(
            subject,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: Colors.white),
              SizedBox(width: 4),
              Text(
                room,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}