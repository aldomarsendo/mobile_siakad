import 'package:flutter/material.dart';
import 'package:mobile_siakad/models/mahasiswa_model.dart';
import 'package:mobile_siakad/models/frs_model.dart';
import 'package:mobile_siakad/services/api_client.dart';
import 'package:mobile_siakad/services/dosen/dosen_frs_service.dart';
import 'package:http/http.dart' as http;

class DetailFrsPage extends StatefulWidget {
  final Mahasiswa mahasiswa;

  const DetailFrsPage({super.key, required this.mahasiswa});

  @override
  State<DetailFrsPage> createState() => _DetailFrsPageState();
}

class _DetailFrsPageState extends State<DetailFrsPage> {
  List<FrsItem> _allFrsForThisStudentFromBackend = [];
  List<FrsItem> _pendingFrsForThisStudent = [];
  List<FrsItem> _approvedFrsForThisStudent = [];
  List<FrsItem> _rejectedFrsForThisStudent = [];

  bool _isLoading = true;
  String? _errorMessage;
  bool _isUpdatingStatus = false;
  int? _currentlyProcessingFrsId;

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
      _allFrsForThisStudentFromBackend = await _dosenFrsService.getAllFrsForMahasiswa(widget.mahasiswa.idMahasiswa);
      _categorizeFrsForThisStudent();
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Gagal memuat data FRS: ${e.toString().replaceFirst('Exception: ', '')}";
        });
      }
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
    
    _pendingFrsForThisStudent.sort((a, b) => a.jadwalKuliah?.masterMatakuliah?.namaMk.compareTo(b.jadwalKuliah?.masterMatakuliah?.namaMk ?? '') ?? 0);
    _approvedFrsForThisStudent.sort((a, b) => a.jadwalKuliah?.masterMatakuliah?.namaMk.compareTo(b.jadwalKuliah?.masterMatakuliah?.namaMk ?? '') ?? 0);
    _rejectedFrsForThisStudent.sort((a, b) => a.jadwalKuliah?.masterMatakuliah?.namaMk.compareTo(b.jadwalKuliah?.masterMatakuliah?.namaMk ?? '') ?? 0);

    setState(() {});
  }

  Future<void> _handleUpdateFrsStatus(FrsItem frsItemToUpdate, String newStatus) async {

    if (!mounted || _isUpdatingStatus) return;
    
    String actionText = '';
    String confirmMessage = '';

    if (newStatus == 'disetujui') {
      actionText = 'Setujui';
      confirmMessage = 'Anda yakin ingin menyetujui FRS untuk mata kuliah "${frsItemToUpdate.jadwalKuliah?.masterMatakuliah?.namaMk ?? 'ini'}"?';
    } else if (newStatus == 'ditolak') {
      actionText = 'Tolak';
      confirmMessage = 'Anda yakin ingin menolak FRS untuk mata kuliah "${frsItemToUpdate.jadwalKuliah?.masterMatakuliah?.namaMk ?? 'ini'}"?';
    } else if (newStatus == 'pending') {
      actionText = 'Kembalikan ke Pending';
      confirmMessage = 'Anda yakin ingin mengembalikan status FRS untuk mata kuliah "${frsItemToUpdate.jadwalKuliah?.masterMatakuliah?.namaMk ?? 'ini'}" menjadi Pending?';
    } else {
      return; 
    }

    bool confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Konfirmasi: $actionText FRS', style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold)),
          content: Text(confirmMessage),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text(actionText, style: TextStyle(color: newStatus == 'disetujui' ? approvedColor : (newStatus == 'ditolak' ? rejectedColor : pendingColor))),
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
            content: Text('Status FRS untuk "${updatedFrsFromServer.jadwalKuliah?.masterMatakuliah?.namaMk ?? 'MK'}" berhasil diubah menjadi ${newStatus.toUpperCase()}.'),
            backgroundColor: newStatus == 'disetujui' ? approvedColor : (newStatus == 'ditolak' ? rejectedColor : pendingColor),
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
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Detail Mahasiswa", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryBlue)),
              const Divider(height: 20),
              _infoRow("NRP", widget.mahasiswa.nrp),
              _infoRow("Nama", widget.mahasiswa.nama),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: Colors.black54))),
          const Text(":  ", style: TextStyle(fontSize: 14, color: Colors.black54)),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14, color: Colors.black87))),
        ],
      ),
    );
  }

Widget _buildFrsTable(String title, List<FrsItem> frsList, Color headerColor) {
  List<DataColumn> columns = [
    const DataColumn(label: Text('No.', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
    const DataColumn(label: Text('Kode MK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
    const DataColumn(label: Text('Mata Kuliah', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
    const DataColumn(label: Text('SKS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), numeric: true),
    const DataColumn(label: Text('Dosen', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
    const DataColumn(label: Text('Aksi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))), 
  ];

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
                  headingRowColor: WidgetStateColor.resolveWith((states) => headerColor),
                  border: TableBorder.all(color: Colors.grey.shade300, width: 1, borderRadius: BorderRadius.circular(8)),
                  columns: columns,
                  rows: frsList.asMap().entries.map((entry) {
                    int index = entry.key;
                    FrsItem frs = entry.value;
                    bool isCurrentlyProcessing = _isUpdatingStatus && _currentlyProcessingFrsId == frs.idFrs;

                    return DataRow(
                      color: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
                        if (index.isEven) return Colors.grey.shade50;
                        return null;
                      }),
                      cells: [
                        DataCell(Center(child: Text((index + 1).toString()))),
                        DataCell(Text(frs.jadwalKuliah?.masterMatakuliah?.kodeMk ?? 'N/A')),
                        DataCell(SizedBox(width: 180, child: Text(frs.jadwalKuliah?.masterMatakuliah?.namaMk ?? 'N/A', overflow: TextOverflow.ellipsis, maxLines: 2))),
                        DataCell(Center(child: Text(frs.jadwalKuliah?.masterMatakuliah?.sks.toString() ?? '0'))),
                        DataCell(SizedBox(width: 150, child: Text(frs.jadwalKuliah?.dosen?.user?.name ?? 'N/A', overflow: TextOverflow.ellipsis, maxLines: 2))),
                        DataCell(
                          isCurrentlyProcessing
                          ? const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2,)))
                          : PopupMenuButton<String>(
                              icon: Icon(Icons.edit_note, color: Colors.blueGrey.shade700, size: 26),
                              tooltip: "Ubah Status FRS",
                              onSelected: (String actionTargetStatus) {
                                print('PopupMenuButton onSelected: actionTargetStatus = "$actionTargetStatus"'); 
                                _handleUpdateFrsStatus(frs, actionTargetStatus);
                              },
                              itemBuilder: (BuildContext context) {
                                List<PopupMenuEntry<String>> items = [];
                                String currentStatus = frs.status.toLowerCase();
                                if (currentStatus != 'disetujui') {
                                  items.add(const PopupMenuItem<String>(value: 'disetujui', child: Text('Setujui')));
                                }
                                if (currentStatus != 'ditolak') {
                                  items.add(const PopupMenuItem<String>(value: 'ditolak', child: Text('Tolak')));
                                }
                                if (currentStatus != 'pending') {
                                  items.add(const PopupMenuItem<String>(value: 'pending', child: Text('Kembalikan ke Pending')));
                                }
                                if (items.isEmpty) {
                                  items.add(const PopupMenuItem<String>(enabled: false, child: Text('Tidak ada aksi')));
                                }
                                return items;
                              },
                            ),
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
         actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _isLoading ? null : _fetchInitialFrsData,
            tooltip: 'Refresh Data FRS',
          )
        ],
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
                      _buildFrsTable('Pending', _pendingFrsForThisStudent, pendingColor), 
                      _buildFrsTable('Disetujui', _approvedFrsForThisStudent, approvedColor), 
                      _buildFrsTable('Ditolak', _rejectedFrsForThisStudent, rejectedColor),     
                    ],
                  ),
      ),
    );
  }
}
