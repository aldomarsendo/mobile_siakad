import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_siakad/services/api_client.dart';
import 'package:mobile_siakad/services/dosen/dosen_frs_service.dart';
import 'package:mobile_siakad/models/frs_model.dart';

class DosenFrsPage extends StatefulWidget {
  const DosenFrsPage({Key? key}) : super(key: key);

  @override
  State<DosenFrsPage> createState() => _DosenFrsPageState();
}

class _DosenFrsPageState extends State<DosenFrsPage> {

  List<FrsItem> _pendingFrsList = [];
  bool _isLoading = true;
  String? _userMessage;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _fetchPendingFrs();
  }

  Future<void> _fetchPendingFrs() async {
    
    setState(() {
      _isLoading = true;
      _userMessage = null;
      _isError = false;
    });

    try {
      final ApiClient apiClient = ApiClient(http.Client());
      final DosenFrsService dosenFrsService = DosenFrsService(apiClient);
      final frsItems = await dosenFrsService.getPendingFrs(); 
      if (mounted) { // Pastikan widget masih ada di tree sebelum memanggil setState
        setState(() {
          _pendingFrsList = frsItems;
          _isLoading = false;
          if (_pendingFrsList.isEmpty) {

          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isError = true;
        });
        String errorMessage = e.toString();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat FRS pending: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: Colors.black87),
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'FRS',
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
                  'FRS Kuliah Mahasiswa',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Tahun Ajaran',
                      border: OutlineInputBorder(),
                    ),
                    value: '2024 / 2025',
                    items: ['2023 / 2024', '2024 / 2025']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (_) {},
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Semester',
                      border: OutlineInputBorder(),
                    ),
                    value: 'Genap',
                    items: ['Ganjil', 'Genap']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (_) {},
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: _pendingFrsList.length,
                itemBuilder: (context, index) {
                  final frs = _pendingFrsList[index];
                  final masterMk = frs.jadwalKuliah?.masterMatakuliah; // Bisa null
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Color(0xFF1F3C88),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Kode MK : ${masterMk?.kodeMk ?? 'N/A'}',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                masterMk?.namaMk ?? 'N/A',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          frs.status,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
