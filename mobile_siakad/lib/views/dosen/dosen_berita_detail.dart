import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_siakad/models/berita_model.dart';
import 'package:mobile_siakad/services/dosen/dosen_berita_service.dart';
import 'package:mobile_siakad/services/auth_service.dart';
import 'package:mobile_siakad/services/api_client.dart';
import 'package:http/http.dart' as http;

class DosenBeritaDetailPage extends StatefulWidget {
  final String beritaId;
  final String? initialTitle;

  const DosenBeritaDetailPage({
    super.key,
    required this.beritaId,
    this.initialTitle,
  });

  @override
  State<DosenBeritaDetailPage> createState() => _DosenBeritaDetailPageState();
}

class _DosenBeritaDetailPageState extends State<DosenBeritaDetailPage> {
  final Color primaryBlue = const Color(0xFF133B7A);
  final Color secondaryBlue = const Color(0xFF1E5BB0);

  Berita? _berita;
  bool _isLoading = true;
  String? _errorMessage;

  late final DosenBeritaService _beritaService;

  @override
  void initState() {
    super.initState();
    print('BeritaDetailPage initialized with ID: ${widget.beritaId}');
    final apiClient = ApiClient(http.Client());
    final authService = AuthService(apiClient);
    _beritaService = DosenBeritaService(authService, apiClient);
    _loadBeritaDetail();
  }

  Future<void> _loadBeritaDetail() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('Loading berita detail for ID: ${widget.beritaId}');
      final berita = await _beritaService.getBeritaBySlug(widget.beritaId);
      if (mounted) {
        setState(() {
          _berita = berita;
        });
      }
    } catch (e) {
      print('Error loading berita detail: $e');
      if (mounted) {
        setState(() {
          if (e.toString().contains('tidak ditemukan') || e.toString().contains('404')) {
            _errorMessage = 'Berita dengan ID ${widget.beritaId} tidak ditemukan atau telah dihapus.';
          } else {
            _errorMessage = 'Gagal memuat detail berita: ${e.toString()}';
          }
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

  String _formatDate(DateTime date) {
    return DateFormat('d MMMM yyyy, HH:mm', 'id_ID').format(date);
  }

  Widget _buildContent(String content) {
    // Split content by paragraphs and format URLs
    final paragraphs = content.split('\n');
    List<Widget> widgets = [];

    for (String paragraph in paragraphs) {
      if (paragraph.trim().isEmpty) continue;

      // Check if paragraph contains URL
      if (paragraph.contains('http')) {
        widgets.add(
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: SelectableText(
              paragraph.trim(),
              style: TextStyle(
                fontSize: 14,
                color: Colors.blue.shade700,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        );
      } else {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SelectableText(
              paragraph.trim(),
              style: const TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Colors.black87,
              ),
            ),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.initialTitle ?? 'Detail Berita',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [primaryBlue, secondaryBlue],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: primaryBlue),
                  const SizedBox(height: 16),
                  Text(
                    'Memuat berita...',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.article_outlined,
                          color: Colors.grey.shade400,
                          size: 80,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          "Berita Tidak Ditemukan",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              icon: const Icon(Icons.arrow_back, color: Colors.white),
                              label: const Text(
                                "Kembali",
                                style: TextStyle(color: Colors.white),
                              ),
                              onPressed: () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.refresh, color: Colors.white),
                              label: const Text(
                                "Coba Lagi",
                                style: TextStyle(color: Colors.white),
                              ),
                              onPressed: _loadBeritaDetail,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryBlue,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              : _berita == null
                  ? const Center(
                      child: Text('Berita tidak ditemukan'),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadBeritaDetail,
                      color: primaryBlue,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // News Header Card
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Title
                                  Text(
                                    _berita!.judul,
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: primaryBlue,
                                      height: 1.3,
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // Metadata
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.access_time,
                                        size: 16,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        _formatDate(_berita!.publishedAt),
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.visibility,
                                        size: 16,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Target: ${_berita!.targetRole}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _berita!.status == 'terbit'
                                              ? Colors.green.shade100
                                              : Colors.orange.shade100,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          _berita!.status.toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: _berita!.status == 'terbit'
                                                ? Colors.green.shade700
                                                : Colors.orange.shade700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            // News Content Card
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Isi Berita',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: primaryBlue,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  _buildContent(_berita!.isi),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
    );
  }
}