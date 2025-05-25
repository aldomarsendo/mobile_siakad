// lib/views/dosen/nilai/input_nilai_mahasiswa.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Untuk TextInputFormatter
import 'package:mobile_siakad/models/mahasiswa_model.dart' hide Kelas; 
import 'package:mobile_siakad/models/matakuliah_model.dart'; 
import 'package:mobile_siakad/models/nilai_model.dart'; 
import 'package:mobile_siakad/services/api_client.dart';
import 'package:mobile_siakad/services/auth_service.dart';
import 'package:mobile_siakad/services/dosen/dosen_nilai_service.dart'; 
import 'package:http/http.dart' as http;

class InputNilaiMahasiswaPage extends StatefulWidget {
  final Kelas selectedKelas;
  final MataKuliah selectedMataKuliah;

  const InputNilaiMahasiswaPage({
    Key? key,
    required this.selectedKelas,
    required this.selectedMataKuliah,
  }) : super(key: key);

  @override
  State<InputNilaiMahasiswaPage> createState() => _InputNilaiMahasiswaPageState();
}

class _InputNilaiMahasiswaPageState extends State<InputNilaiMahasiswaPage> {
  late final ApiClient _apiClient;
  late final AuthService _authService;
  late final DosenNilaiService _dosenNilaiService;

  List<MahasiswaNilaiEntry> _mahasiswaListForGrading = [];
  bool _isLoading = true;
  String? _errorMessage;
  // _isUpdatingStatus dan _currentlyProcessingFrsId tidak lagi diperlukan secara global
  // karena status 'isSaving' sekarang ada di dalam setiap MahasiswaNilaiEntry

  final Color primaryBlue = const Color(0xFF133B7A);
  final Color successColor = Colors.green.shade700;
  final Color errorColor = Colors.red.shade700;

  @override
  void initState() {
    super.initState();
    _apiClient = ApiClient(http.Client());
    _authService = AuthService(_apiClient);
    _dosenNilaiService = DosenNilaiService(_apiClient, _authService);
    _fetchMahasiswaData();
  }

  @override
  void dispose() {
    for (var entry in _mahasiswaListForGrading) {
      entry.nilaiAngkaController.dispose();
    }
    super.dispose();
  }

  Future<void> _fetchMahasiswaData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      _mahasiswaListForGrading = await _dosenNilaiService.getMahasiswaForNilaiByKelas(
        widget.selectedMataKuliah.idMk,
        widget.selectedKelas.idKelas,
      );
      _mahasiswaListForGrading.sort((a,b) => a.nrp.compareTo(b.nrp));
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Gagal memuat daftar mahasiswa: ${e.toString()}";
        });
      }
      print("Error fetching mahasiswa for grading: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleSimpanNilai(MahasiswaNilaiEntry mhsEntry) async {
    if (!mounted || mhsEntry.isSaving) return;

    final String nilaiAngkaStr = mhsEntry.nilaiAngkaController.text.trim();
    if (nilaiAngkaStr.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nilai angka tidak boleh kosong.'), backgroundColor: Colors.orange),
        );
      }
      return;
    }

    final int? nilaiAngka = int.tryParse(nilaiAngkaStr);
    if (nilaiAngka == null || nilaiAngka < 0 || nilaiAngka > 100) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nilai angka harus antara 0 dan 100.'), backgroundColor: Colors.orange),
        );
      }
      return;
    }

    // PERBAIKAN: Update state untuk mhsEntry spesifik menggunakan copyWith
    int entryIndex = _mahasiswaListForGrading.indexWhere((e) => e.idFrs == mhsEntry.idFrs);
    if (entryIndex == -1) return; // Mahasiswa tidak ditemukan, seharusnya tidak terjadi

    setState(() {
      _mahasiswaListForGrading[entryIndex] = mhsEntry.copyWith(isSaving: true);
    });

    try {
      final Nilai updatedNilai = await _dosenNilaiService.submitNilaiMahasiswa(
        mhsEntry.idFrs,
        nilaiAngka,
      );

      if (mounted) {
        // PERBAIKAN: Update mhsEntry di list dengan data baru dari server menggunakan copyWith
        _mahasiswaListForGrading[entryIndex] = _mahasiswaListForGrading[entryIndex].copyWith(
          nilaiAngkaAwal: () => updatedNilai.nilaiAngka, // Gunakan ValueGetter untuk nullable
          nilaiHurufAwal: () => updatedNilai.nilaiHuruf,
          statusPenilaianAwal: updatedNilai.statusPenilaian,
          nilaiHurufDisplay: updatedNilai.nilaiHuruf, // Update tampilan nilai huruf
          isSaving: false,
        );
        // Controller perlu diupdate secara manual jika nilainya berubah setelah save
        _mahasiswaListForGrading[entryIndex].nilaiAngkaController.text = updatedNilai.nilaiAngka.toString();

        setState(() {}); // Trigger rebuild untuk seluruh list (atau hanya baris yang diubah jika menggunakan state management lebih canggih)

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Nilai untuk ${mhsEntry.nama} berhasil disimpan: ${updatedNilai.nilaiAngka} (${updatedNilai.nilaiHuruf})'),
            backgroundColor: successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        // Jika gagal, kembalikan status isSaving ke false untuk mhsEntry yang sama
        _mahasiswaListForGrading[entryIndex] = _mahasiswaListForGrading[entryIndex].copyWith(isSaving: false);
        setState(() {});

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan nilai untuk ${mhsEntry.nama}: $e'), backgroundColor: errorColor),
        );
      }
      print("Error submitting nilai for FRS ID ${mhsEntry.idFrs}: $e");
    } 
    // 'finally' block tidak lagi dibutuhkan untuk setState isSaving secara global
  }

  Widget _buildHeaderInfo() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.selectedMataKuliah.namaMk,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryBlue),
          ),
          const SizedBox(height: 4),
          Text(
            "Kelas: ${widget.selectedKelas.namaKelas} | Kode MK: ${widget.selectedMataKuliah.kodeMk} | ${widget.selectedMataKuliah.sks} SKS",
            style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
          ),
          Text(
            "Semester: ${widget.selectedMataKuliah.semester}",
            style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }

  DataColumn _dataColumn(String label, {double? width}) {
    return DataColumn(
      label: Container(
        width: width, 
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Input Nilai Mahasiswa'),
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchMahasiswaData,
        color: primaryBlue,
        child: Column(
          children: [
            _buildHeaderInfo(),
            const Divider(height: 1),
            if (_isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_errorMessage != null)
              Expanded(child: _buildErrorWidget())
            else if (_mahasiswaListForGrading.isEmpty)
              Expanded(child: _buildEmptyListWidget())
            else
              Expanded(
                child: SingleChildScrollView( 
                  child: SingleChildScrollView( 
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DataTable(
                        columnSpacing: 15,
                        horizontalMargin: 10,
                        headingRowColor: MaterialStateProperty.resolveWith((states) => primaryBlue.withOpacity(0.9)),
                        border: TableBorder.all(color: Colors.grey.shade300, width: 1, borderRadius: BorderRadius.circular(8)),
                        columns: [
                          _dataColumn("NRP", width: 100),
                          _dataColumn("Nama Mahasiswa", width: 180),
                          _dataColumn("Nilai Angka (0-100)", width: 100),
                          _dataColumn("Nilai Huruf", width: 80),
                          _dataColumn("Aksi", width: 100),
                        ],
                        rows: _mahasiswaListForGrading.map((mhsEntry) {
                          return DataRow(cells: [
                            DataCell(Text(mhsEntry.nrp)),
                            DataCell(SizedBox(width: 180, child: Text(mhsEntry.nama, overflow: TextOverflow.ellipsis))),
                            DataCell(
                              SizedBox(
                                width: 80,
                                child: TextField(
                                  controller: mhsEntry.nilaiAngkaController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(3)],
                                  textAlign: TextAlign.center,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                                    hintText: "0-100",
                                  ),
                                  enabled: !mhsEntry.isSaving, // Gunakan mhsEntry.isSaving
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ),
                            DataCell(
                              Center(
                                child: Text(
                                  mhsEntry.nilaiHurufDisplay ?? '-', 
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                )
                              )
                            ),
                            DataCell(
                              mhsEntry.isSaving // Gunakan mhsEntry.isSaving
                                  ? const Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5)))
                                  : IconButton(
                                      icon: Icon(Icons.save_alt_outlined, color: primaryBlue),
                                      tooltip: 'Simpan Nilai',
                                      onPressed: () => _handleSimpanNilai(mhsEntry),
                                    ),
                            ),
                          ]);
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
          ],
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
            Icon(Icons.error_outline_rounded, color: errorColor, size: 60),
            const SizedBox(height: 15),
            Text("Gagal Memuat Data", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: errorColor), textAlign: TextAlign.center,),
            const SizedBox(height: 8),
            Text(_errorMessage!, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text("Coba Lagi", style: TextStyle(color: Colors.white)),
              onPressed: _fetchMahasiswaData,
              style: ElevatedButton.styleFrom(backgroundColor: primaryBlue, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), textStyle: const TextStyle(fontSize: 15)),
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
            Icon(Icons.people_outline_rounded, size: 70, color: Colors.grey.shade400),
            const SizedBox(height: 15),
            Text('Tidak Ada Mahasiswa', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
            const SizedBox(height: 8),
            Text(
              'Tidak ditemukan mahasiswa yang mengambil mata kuliah ini di kelas ${widget.selectedKelas.namaKelas}, atau FRS belum disetujui.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.grey.shade500),
            ),
          ],
        ),
      ));
  }
}
