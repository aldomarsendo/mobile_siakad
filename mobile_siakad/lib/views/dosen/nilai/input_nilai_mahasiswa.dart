// lib/views/dosen/nilai/input_nilai_mahasiswa.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Untuk TextInputFormatter
import 'package:mobile_siakad/models/matakuliah_model.dart'; // Model Kelas dan MataKuliah dari Anda
import 'package:mobile_siakad/models/nilai_model.dart'; // Model baru kita
import 'package:mobile_siakad/services/api_client.dart';
// import 'package:mobile_siakad/services/auth_service.dart'; // Dihilangkan jika DosenNilaiService tidak pakai
import 'package:mobile_siakad/services/dosen/dosen_nilai_service.dart';
import 'package:http/http.dart' as http;

// Helper class untuk UI state per mahasiswa
class MahasiswaNilaiEntry {
  final MahasiswaUntukNilai mahasiswaData; // Dari nilai_model.dart
  final TextEditingController nilaiAngkaController;
  String? nilaiHurufDisplay;
  bool isSaving;

  MahasiswaNilaiEntry({
    required this.mahasiswaData,
    String? initialNilaiAngka,
    this.nilaiHurufDisplay,
    this.isSaving = false,
  }) : nilaiAngkaController = TextEditingController(text: initialNilaiAngka ?? mahasiswaData.nilaiAngka?.toString() ?? '');

  MahasiswaNilaiEntry copyWith({
    MahasiswaUntukNilai? mahasiswaData,
    String? nilaiHurufDisplay,
    bool? isSaving,
    // Controller tidak di-copy, ia persisten per entry
  }) {
    return MahasiswaNilaiEntry(
      mahasiswaData: mahasiswaData ?? this.mahasiswaData,
      initialNilaiAngka: this.nilaiAngkaController.text, // Pertahankan teks saat ini jika tidak di-override
      nilaiHurufDisplay: nilaiHurufDisplay ?? this.nilaiHurufDisplay,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}


class InputNilaiMahasiswaPage extends StatefulWidget {
  final Kelas selectedKelas; // Dari model Anda
  final MataKuliah selectedMataKuliah; // Dari model Anda

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
  // late final AuthService _authService; // Dihilangkan jika DosenNilaiService tidak pakai
  late final DosenNilaiService _dosenNilaiService;

  NilaiJadwalKuliahDetail? _jadwalDetail; // Untuk menyimpan detail MK dari API
  List<MahasiswaNilaiEntry> _mahasiswaListForGrading = [];
  bool _isLoading = true;
  String? _errorMessage;

  final Color primaryBlue = const Color(0xFF133B7A);
  final Color successColor = Colors.green.shade700;
  final Color errorColor = Colors.red.shade700;

  @override
  void initState() {
    super.initState();
    _apiClient = ApiClient(http.Client());
    // _authService = AuthService(_apiClient); // Dihilangkan jika DosenNilaiService tidak pakai
    _dosenNilaiService = DosenNilaiService(_apiClient); // Hanya perlu ApiClient
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
      _mahasiswaListForGrading = []; // Kosongkan sebelum fetch baru
    });

    try {
      // Menggunakan idMk dari widget.selectedMataKuliah sebagai id_mk_jadwal
      final response = await _dosenNilaiService.getMahasiswaByMatakuliah(widget.selectedMataKuliah.idMk);
      
      if (mounted) {
        List<MahasiswaNilaiEntry> entries = response.mahasiswaList.map((mhsNilai) {
          return MahasiswaNilaiEntry(
            mahasiswaData: mhsNilai,
            // nilaiAngkaController sudah diinisialisasi di dalam constructor MahasiswaNilaiEntry
            nilaiHurufDisplay: mhsNilai.nilaiHuruf,
          );
        }).toList();
        
        // Urutkan berdasarkan NRP
        entries.sort((a,b) => a.mahasiswaData.nrp.compareTo(b.mahasiswaData.nrp));

        setState(() {
          _jadwalDetail = response.matakuliahDetail;
          _mahasiswaListForGrading = entries;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Gagal memuat daftar mahasiswa: ${e.toString().replaceFirst("Exception: ", "")}";
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

    final num? nilaiAngka = num.tryParse(nilaiAngkaStr); // Gunakan num.tryParse
    if (nilaiAngka == null || nilaiAngka < 0 || nilaiAngka > 100) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nilai angka harus antara 0 dan 100.'), backgroundColor: Colors.orange),
        );
      }
      return;
    }

    int entryIndex = _mahasiswaListForGrading.indexWhere((e) => e.mahasiswaData.idFrs == mhsEntry.mahasiswaData.idFrs);
    if (entryIndex == -1) return;

    setState(() {
      _mahasiswaListForGrading[entryIndex] = mhsEntry.copyWith(isSaving: true);
    });

    try {
      // Menggunakan method inputNilai dari service
      final SubmittedNilaiItem submittedNilai = await _dosenNilaiService.inputNilai(
        idFrs: mhsEntry.mahasiswaData.idFrs,
        nilaiAngka: nilaiAngka,
      );

      if (mounted) {
        // Update MahasiswaUntukNilai di dalam MahasiswaNilaiEntry
        final updatedMahasiswaData = mhsEntry.mahasiswaData;
        updatedMahasiswaData.nilaiAngka = submittedNilai.nilaiAngka;
        updatedMahasiswaData.nilaiHuruf = submittedNilai.nilaiHuruf;
        updatedMahasiswaData.statusPenilaian = submittedNilai.statusPenilaian;
        
        _mahasiswaListForGrading[entryIndex] = mhsEntry.copyWith(
          mahasiswaData: updatedMahasiswaData,
          nilaiHurufDisplay: submittedNilai.nilaiHuruf,
          isSaving: false,
        );
        // Pastikan controller juga diupdate jika nilai dari server berbeda (misal pembulatan)
        _mahasiswaListForGrading[entryIndex].nilaiAngkaController.text = submittedNilai.nilaiAngka.toString();

        setState(() {}); 

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Nilai untuk ${mhsEntry.mahasiswaData.namaMahasiswa} berhasil disimpan: ${submittedNilai.nilaiAngka} (${submittedNilai.nilaiHuruf})'),
            backgroundColor: successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _mahasiswaListForGrading[entryIndex] = mhsEntry.copyWith(isSaving: false);
        setState(() {});

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan nilai untuk ${mhsEntry.mahasiswaData.namaMahasiswa}: ${e.toString().replaceFirst("Exception: ", "")}'), backgroundColor: errorColor),
        );
      }
      print("Error submitting nilai for FRS ID ${mhsEntry.mahasiswaData.idFrs}: $e");
    }
  }

  Widget _buildHeaderInfo() {
    // Gunakan _jadwalDetail jika ada, fallback ke widget.selectedMataKuliah
    final String namaMk = _jadwalDetail?.masterMatakuliah?.namaMk ?? widget.selectedMataKuliah.namaMk;
    final String kodeMk = _jadwalDetail?.masterMatakuliah?.kodeMk ?? widget.selectedMataKuliah.kodeMk;
    final int sks = _jadwalDetail?.masterMatakuliah?.sks ?? widget.selectedMataKuliah.sks;
    final String semester = _jadwalDetail?.semester ?? widget.selectedMataKuliah.semester;
    final String namaKelas = _jadwalDetail?.namaKelas ?? widget.selectedKelas.namaKelas;


    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            namaMk,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryBlue),
          ),
          const SizedBox(height: 4),
          Text(
            "Kelas: $namaKelas | Kode MK: $kodeMk | $sks SKS",
            style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
          ),
          Text(
            "Semester: $semester",
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
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _isLoading ? null : _fetchMahasiswaData,
            tooltip: 'Refresh Data',
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchMahasiswaData,
        color: primaryBlue,
        child: Column(
          children: [
            _buildHeaderInfo(),
            const Divider(height: 1, thickness: 1),
            if (_isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_errorMessage != null)
              Expanded(child: _buildErrorWidget())
            else if (_mahasiswaListForGrading.isEmpty)
              Expanded(child: _buildEmptyListWidget())
            else
              Expanded(
                child: SingleChildScrollView( // Untuk konten tabel yang mungkin lebar
                  child: SingleChildScrollView( // Untuk scroll vertikal jika tabel panjang
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
                            DataCell(Text(mhsEntry.mahasiswaData.nrp)),
                            DataCell(SizedBox(width: 180, child: Text(mhsEntry.mahasiswaData.namaMahasiswa, overflow: TextOverflow.ellipsis))),
                            DataCell(
                              SizedBox(
                                width: 80,
                                child: TextField(
                                  controller: mhsEntry.nilaiAngkaController,
                                  keyboardType: TextInputType.numberWithOptions(decimal: false),
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(3)],
                                  textAlign: TextAlign.center,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                                    hintText: "0-100",
                                    isDense: true,
                                  ),
                                  enabled: !mhsEntry.isSaving,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ),
                            DataCell(
                              Center(
                                child: Text(
                                  mhsEntry.nilaiHurufDisplay ?? mhsEntry.mahasiswaData.nilaiHuruf ?? '-', 
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                )
                              )
                            ),
                            DataCell(
                              mhsEntry.isSaving
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
            Text(_errorMessage ?? "Terjadi kesalahan tidak diketahui.", textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
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