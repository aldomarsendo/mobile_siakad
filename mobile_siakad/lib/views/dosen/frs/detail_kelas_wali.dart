import 'package:flutter/material.dart';
import 'package:mobile_siakad/models/mahasiswa_model.dart'; // Impor model Mahasiswa dan Kelas
import 'package:mobile_siakad/services/api_client.dart';
import 'package:mobile_siakad/services/dosen/dosen_wali_service.dart'; // Impor service baru
import 'package:http/http.dart' as http;
import 'package:mobile_siakad/views/dosen/frs/detail_frs.dart';

class DetailKelasWaliPage extends StatefulWidget {
  final Kelas kelas; 

  const DetailKelasWaliPage({super.key, required this.kelas});

  @override
  State<DetailKelasWaliPage> createState() => _DetailKelasWaliPageState();
}

class _DetailKelasWaliPageState extends State<DetailKelasWaliPage> with SingleTickerProviderStateMixin { // Added mixin
  List<Mahasiswa> _mahasiswaList = [];
  bool _isLoading = true;
  String? _errorMessage;

  late final DosenWaliService _dosenWaliService;
  
  // Palet Warna Akademik
  final Color primaryBlue = const Color(0xFF133B7A);
  final Color textOnLightBg = Colors.black87;
  final Color subtleTextOnLightBg = Colors.grey.shade700;
  // late final Color iconColorOnLightBg; // Mungkin tidak banyak digunakan di sini
  late final Color dividerColor; 
  late final Color cardShadowColor;

  late AnimationController _animationController; // Added for FadeTransition
  late Animation<double> _fadeAnimation; // Added for FadeTransition

  @override
  void initState() {
    super.initState();

    // Inisialisasi warna turunan
    // iconColorOnLightBg = primaryBlue.withOpacity(0.75);
    dividerColor = primaryBlue.withValues(alpha: 0.15); // Sedikit lebih soft untuk tabel
    cardShadowColor = primaryBlue.withValues(alpha: 0.07);


    final apiClient = ApiClient(http.Client());
    _dosenWaliService = DosenWaliService(apiClient);
    _fetchMahasiswaByKelas();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if(mounted) _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchMahasiswaByKelas() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _mahasiswaList = [];
    });

    try {
      final List<Mahasiswa> semuaMahasiswaWali = await _dosenWaliService.getMahasiswaWali();
      
      if (mounted) {
        final List<Mahasiswa> filteredList = semuaMahasiswaWali
            .where((m) => m.idKelas == widget.kelas.idKelas) // Asumsi idKelas non-nullable
            .toList();
        
        filteredList.sort((a, b) => a.nrp.compareTo(b.nrp)); // Handle NRP null jika mungkin

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
      label: Expanded( // Added Expanded to allow text to wrap or center correctly
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14.5),
          textAlign: TextAlign.center, // Center align header text
        ),
      ),
      numeric: numeric,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Themed scaffold background
      appBar: AppBar(
        title: Text(
          'Mahasiswa Kelas ${widget.kelas.namaKelas}',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 18),
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 1.0,
        centerTitle: true, // Center title for consistency
      ),
      body: FadeTransition( // Added FadeTransition
        opacity: _fadeAnimation,
        child: RefreshIndicator(
          onRefresh: _fetchMahasiswaByKelas,
          color: primaryBlue,
          child: _buildContentBody(), // Changed to call a new method for clarity
        ),
      ),
    );
  }

  Widget _buildContentBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: primaryBlue),
            const SizedBox(height: 16),
            Text('Memuat data mahasiswa...', style: TextStyle(color: subtleTextOnLightBg, fontSize: 15)),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorWidget();
    }

    if (_mahasiswaList.isEmpty) {
      return _buildEmptyListWidget();
    }

    return Padding( // Padding for the card containing the table
      padding: const EdgeInsets.all(12.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: cardShadowColor,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect( // To clip the DataTable if it has sharp corners
          borderRadius: BorderRadius.circular(12.0),
          child: SingleChildScrollView( 
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 24, // Adjusted spacing
                headingRowHeight: 48, // Standard height for header
                dataRowMinHeight: 48, // Min height for data rows
                dataRowMaxHeight: 56, // Max height, allows for some wrapping
                headingRowColor: WidgetStateColor.resolveWith((states) => primaryBlue), // Solid blue header
                columns: [
                  _createDataColumn('NRP'),
                  _createDataColumn('Nama Mahasiswa'),
                  _createDataColumn('Aksi'),
                ],
                rows: _mahasiswaList.map((mahasiswa) {
                  return DataRow(
                    color: WidgetStateColor.resolveWith((Set<WidgetState> states) {
                      if (states.contains(WidgetState.selected)) { // if row is selected
                        return primaryBlue.withValues(alpha: 0.08);
                      }
                      return primaryBlue.withValues(alpha: 0.08); // Use default value for other states and unselected rows.
                    }),
                    cells: [
                    DataCell(Text(mahasiswa.nrp, style: TextStyle(color: textOnLightBg, fontSize: 14))),
                    DataCell(SizedBox(width: 200, child: Text(mahasiswa.nama, style: TextStyle(color: textOnLightBg, fontSize: 14), overflow: TextOverflow.ellipsis, maxLines: 2,))), // Added width constraint and wrapping
                    DataCell(
                      Center( // Center the button in the cell
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.edit_note_outlined, size: 18), // Outlined icon
                          label: const Text('FRS'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryBlue.withValues(alpha: 0.9), // Slightly lighter blue for button
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                            textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                            elevation: 1.0,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailFrsPage(mahasiswa: mahasiswa),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ]);
                }).toList(),
                border: TableBorder( // Subtle horizontal lines for rows
                    horizontalInside: BorderSide(color: dividerColor, width: 0.8),
                    borderRadius: BorderRadius.circular(12.0) // This might not work as expected with internal borders
                ),
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
            Icon(Icons.error_outline_rounded, color: Colors.red.shade400, size: 70),
            const SizedBox(height: 15),
            Text(
              "Gagal Memuat Data",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red.shade700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? "Terjadi kesalahan yang tidak diketahui.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text("Coba Lagi", style: TextStyle(color: Colors.white, fontSize: 15)),
              onPressed: _fetchMahasiswaByKelas,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue.withValues(alpha: 0.9),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
            Icon(Icons.people_outline_rounded, size: 80, color: Colors.grey.shade400), // Icon for empty student list
            const SizedBox(height: 15),
            Text(
              'Tidak Ada Mahasiswa',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Tidak ditemukan data mahasiswa untuk kelas "${widget.kelas.namaKelas}".',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.grey.shade500),
              ),
            ),
          ],
        ),
      ));
  }
}