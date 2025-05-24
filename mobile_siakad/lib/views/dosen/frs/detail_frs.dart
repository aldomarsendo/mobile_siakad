// lib/views/dosen/frs/detail_frs.dart
import 'package:flutter/material.dart';
import 'package:mobile_siakad/models/mahasiswa_model.dart';
import 'package:mobile_siakad/models/frs_model.dart';
import 'package:mobile_siakad/services/api_client.dart';
import 'package:mobile_siakad/services/dosen/dosen_frs_service.dart';
import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart'; // Tidak digunakan saat ini

class DetailFrsPage extends StatefulWidget {
  final Mahasiswa mahasiswa;

  const DetailFrsPage({super.key, required this.mahasiswa});

  @override
  State<DetailFrsPage> createState() => _DetailFrsPageState();
}

class _DetailFrsPageState extends State<DetailFrsPage> {
  // Menyimpan semua FRS mahasiswa ini yang diambil dari backend
  List<FrsItem> _allFrsForThisStudentFromBackend = []; 
  
  // List turunan untuk ditampilkan di UI
  List<FrsItem> _pendingFrsForThisStudent = [];
  List<FrsItem> _approvedFrsForThisStudent = [];
  List<FrsItem> _rejectedFrsForThisStudent = [];

  bool _isLoading = true;
  String? _errorMessage;
  bool _isUpdatingStatus = false;
  int? _currentlyProcessingFrsId; // Untuk loading per baris

  late final DosenFrsService _dosenFrsService;
  final Color primaryBlue = const Color(0xFF133B7A);
  final Color pendingColor = Colors.orange.shade700;
  final Color approvedColor = Colors.green.shade700;
  final Color rejectedColor = Colors.red.shade700;

  @override
  void initState() {
    super.initState();
    final apiClient = ApiClient(http.Client());
    _dosenFrsService = DosenFrsService(apiClient);
    _fetchInitialFrsData();
  }

  Future<void> _fetchInitialFrsData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // PENTING: Panggil metode baru untuk mendapatkan SEMUA FRS mahasiswa ini
      // Ini mengasumsikan DosenFrsService.getAllFrsForMahasiswa sudah diimplementasikan
      // dan backend memiliki endpoint seperti GET /dosen/frs/mahasiswa/{id_mahasiswa}
      _allFrsForThisStudentFromBackend = await _dosenFrsService.getAllFrsForMahasiswa(widget.mahasiswa.idMahasiswa);
      
      _categorizeFrsForThisStudent();

    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Gagal memuat data FRS: ${e.toString()}";
        });
      }
      print("Error fetching FRS data for student ${widget.mahasiswa.idMahasiswa}: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _categorizeFrsForThisStudent() {
    if (!mounted) return;

    _pendingFrsForThisStudent = _allFrsForThisStudentFromBackend
        .where((frs) => frs.status.toLowerCase() == 'pending')
        .toList();
    _approvedFrsForThisStudent = _allFrsForThisStudentFromBackend
        .where((frs) => frs.status.toLowerCase() == 'disetujui')
        .toList();
    _rejectedFrsForThisStudent = _allFrsForThisStudentFromBackend
        .where((frs) => frs.status.toLowerCase() == 'ditolak')
        .toList();
    
    _pendingFrsForThisStudent.sort((a, b) => a.matakuliah.namaMk.compareTo(b.matakuliah.namaMk));
    _approvedFrsForThisStudent.sort((a, b) => a.matakuliah.namaMk.compareTo(b.matakuliah.namaMk));
    _rejectedFrsForThisStudent.sort((a, b) => a.matakuliah.namaMk.compareTo(b.matakuliah.namaMk));

    setState(() {});
  }

  Future<void> _handleUpdateFrsStatus(FrsItem frsItemToUpdate, String newStatus) async {
    if (!mounted || _isUpdatingStatus) return;
    
    bool confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Konfirmasi Aksi FRS', style: TextStyle(color: primaryBlue)),
          content: Text('Anda yakin ingin ${newStatus == 'disetujui' ? 'menyetujui' : 'menolak'} FRS untuk mata kuliah "${frsItemToUpdate.matakuliah.namaMk}"?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text(newStatus == 'disetujui' ? 'Setujui' : 'Tolak', style: TextStyle(color: newStatus == 'disetujui' ? approvedColor : rejectedColor)),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    ) ?? false;

    if (!confirm || !mounted) return;

    setState(() {
      _isUpdatingStatus = true;
      _currentlyProcessingFrsId = frsItemToUpdate.idFrs;
    });

    try {
      final FrsItem updatedFrsFromServer = await _dosenFrsService.updateFrsStatus(frsItemToUpdate.idFrs, newStatus);
      
      if (mounted) {
        int index = _allFrsForThisStudentFromBackend.indexWhere((item) => item.idFrs == updatedFrsFromServer.idFrs);
        if (index != -1) {
          _allFrsForThisStudentFromBackend[index] = updatedFrsFromServer;
        } else {
          _allFrsForThisStudentFromBackend.removeWhere((item) => item.idFrs == updatedFrsFromServer.idFrs);
          _allFrsForThisStudentFromBackend.add(updatedFrsFromServer);
        }
        _categorizeFrsForThisStudent();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('FRS untuk "${updatedFrsFromServer.matakuliah.namaMk}" berhasil di-$newStatus.'),
            backgroundColor: newStatus == 'disetujui' ? approvedColor : rejectedColor,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui status FRS: $e'), backgroundColor: Colors.red),
        );
      }
      print("Error updating FRS status: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingStatus = false;
          _currentlyProcessingFrsId = null;
        });
      }
    }
  }
  
  Widget _buildInfoMahasiswa() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Detail Mahasiswa", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryBlue)),
              const SizedBox(height: 12),
              _infoRow("NRP", widget.mahasiswa.nrp),
              _infoRow("Nama", widget.mahasiswa.nama),
              _infoRow("Program Studi", widget.mahasiswa.prodi),
              _infoRow("Kelas", widget.mahasiswa.kelas),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 110, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15))),
          const Text(":  ", style: TextStyle(fontSize: 15)),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 15))),
        ],
      ),
    );
  }

  Widget _buildFrsTable(String title, List<FrsItem> frsList, Color headerColor, {bool showActions = false}) {
    List<DataColumn> columns = [
      const DataColumn(label: Text('No.', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
      const DataColumn(label: Text('Kode MK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
      const DataColumn(label: Text('Mata Kuliah', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
      const DataColumn(label: Text('SKS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), numeric: true),
      const DataColumn(label: Text('Dosen', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
    ];
    if (showActions || title != "Pending") {
        columns.add(DataColumn(label: Text(showActions ? 'Aksi' : 'Status', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 20.0, bottom: 8.0, left: 16.0, right: 16.0),
          child: Text(title, style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: headerColor)),
        ),
        if (frsList.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
            child: Center(child: Text("Tidak ada FRS dengan status $title untuk mahasiswa ini.", style: const TextStyle(fontSize: 15, fontStyle: FontStyle.italic, color: Colors.grey))),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width - 16),
                child: DataTable(
                  columnSpacing: 12,
                  horizontalMargin: 8,
                  headingRowHeight: 48,
                  dataRowMinHeight: 52,
                  dataRowMaxHeight: 72,
                  headingRowColor: MaterialStateColor.resolveWith((states) => headerColor),
                  border: TableBorder.all(color: Colors.grey.shade300, width: 1, borderRadius: BorderRadius.circular(8)),
                  columns: columns,
                  rows: frsList.asMap().entries.map((entry) {
                    int index = entry.key;
                    FrsItem frs = entry.value;
                    bool isCurrentlyProcessing = _isUpdatingStatus && _currentlyProcessingFrsId == frs.idFrs;
                    return DataRow(
                      color: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
                        if (index.isEven) return Colors.grey.shade100;
                        return null;
                      }),
                      cells: [
                        DataCell(Center(child: Text((index + 1).toString()))),
                        DataCell(Text(frs.matakuliah.kodeMk)),
                        DataCell(SizedBox(width: 180, child: Text(frs.matakuliah.namaMk, overflow: TextOverflow.ellipsis, maxLines: 2))),
                        DataCell(Center(child: Text(frs.matakuliah.sks.toString()))),
                        DataCell(SizedBox(width: 150, child: Text(frs.matakuliah.dosen?.user.name ?? 'N/A', overflow: TextOverflow.ellipsis, maxLines: 2))),
                        if (showActions)
                          DataCell(
                            isCurrentlyProcessing
                            ? const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2,)))
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Tooltip(
                                    message: 'Setujui FRS',
                                    child: IconButton(
                                      icon: Icon(Icons.check_circle_outline, color: approvedColor),
                                      onPressed: () => _handleUpdateFrsStatus(frs, 'disetujui'),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Tooltip(
                                    message: 'Tolak FRS',
                                    child: IconButton(
                                      icon: Icon(Icons.highlight_off, color: rejectedColor),
                                      onPressed: () => _handleUpdateFrsStatus(frs, 'ditolak'),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ),
                                ],
                              ),
                          )
                        else if (title != "Pending")
                           DataCell(
                            Center(
                              child: Text(
                                frs.status.toUpperCase(), 
                                style: TextStyle(
                                  color: frs.status.toLowerCase() == 'disetujui' ? approvedColor : rejectedColor, 
                                  fontWeight: FontWeight.bold
                                )
                              ),
                            )
                          ),
                      ]);
                  }).toList(),
                ),
              ),
            ),
          ),
      ],
    );
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail FRS: ${widget.mahasiswa.nama}', overflow: TextOverflow.ellipsis),
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchInitialFrsData,
        color: primaryBlue,
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: primaryBlue))
            : _errorMessage != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, color: Colors.red.shade700, size: 60),
                            const SizedBox(height: 15),
                            Text("Oops!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red.shade700)),
                            const SizedBox(height: 8),
                            Text(_errorMessage!, textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey.shade700)),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.refresh),
                              label: const Text("Coba Lagi Memuat"),
                              onPressed: _fetchInitialFrsData,
                              style: ElevatedButton.styleFrom(backgroundColor: primaryBlue, foregroundColor: Colors.white),
                            )
                          ]),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.only(bottom: 20),
                    children: [
                      _buildInfoMahasiswa(),
                      // Hapus catatan jika backend sudah mendukung pengambilan semua status FRS
                      // const Padding(
                      //   padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      //   child: Text(
                      //     "Catatan: Tabel 'Disetujui' dan 'Ditolak' hanya akan menampilkan FRS yang statusnya diubah pada sesi ini. Untuk riwayat lengkap, diperlukan pembaruan dari sisi server.",
                      //     style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: Colors.blueGrey),
                      //     textAlign: TextAlign.center,
                      //   ),
                      // ),
                      _buildFrsTable('Pending', _pendingFrsForThisStudent, pendingColor, showActions: true),
                      _buildFrsTable('Disetujui', _approvedFrsForThisStudent, approvedColor),
                      _buildFrsTable('Ditolak', _rejectedFrsForThisStudent, rejectedColor),
                    ],
                  ),
      ),
    );
  }
}