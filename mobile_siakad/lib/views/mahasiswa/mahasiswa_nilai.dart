import 'package:flutter/material.dart';

class MahasiswaNilaiPage extends StatefulWidget {
  const MahasiswaNilaiPage({Key? key}) : super(key: key);

  @override
  State<MahasiswaNilaiPage> createState() => _MahasiswaNilaiPageState();
}

class _MahasiswaNilaiPageState extends State<MahasiswaNilaiPage> with SingleTickerProviderStateMixin {
  final List<Map<String, dynamic>> mataKuliah = [
    {'kode': '3030', 'nama': 'Kecerdasan Buatan', 'nilai': 'A', 'sks': 3},
    {'kode': '3031', 'nama': 'Workshop Desain Pengalaman Pengguna', 'nilai': 'A', 'sks': 4},
    {'kode': '3032', 'nama': 'Workshop Pemrogramman Perangkat Bergerak', 'nilai': 'A', 'sks': 4},
    {'kode': '3033', 'nama': 'Workshop Administrasi Jaringan', 'nilai': 'A', 'sks': 3},
  ];
  
  String _selectedSemester = 'Genap 2024/2025';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  final List<String> semesters = [
    'Genap 2024/2025',
    'Ganjil 2024/2025',
    'Genap 2023/2024',
    'Ganjil 2023/2024',
  ];

  final Color primaryBlue = const Color(0xFF133B7A);
  final Color secondaryBlue = const Color(0xFF1E5BB0);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Calculate GPA
  double calculateGPA() {
    double totalPoints = 0;
    int totalSKS = 0;
    
    for (var mk in mataKuliah) {
      double point = 0;
      switch (mk['nilai']) {
        case 'A': point = 4.0; break;
        case 'AB': point = 3.5; break;
        case 'B': point = 3.0; break;
        case 'BC': point = 2.5; break;
        case 'C': point = 2.0; break;
        case 'D': point = 1.0; break;
        case 'E': point = 0.0; break;
      }
      totalPoints += point * (mk['sks'] as int);
      totalSKS += mk['sks'] as int;
    }
    
    return totalSKS > 0 ? totalPoints / totalSKS : 0;
  }

  Color _getNilaiColor(String nilai) {
    switch (nilai) {
      case 'A': return Colors.green.shade700;
      case 'AB': return Colors.green.shade400;
      case 'B': return Colors.blue.shade700;
      case 'BC': return Colors.blue.shade400;
      case 'C': return Colors.orange;
      case 'D': return Colors.deepOrange;
      case 'E': return Colors.red;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double gpa = calculateGPA();
    
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                primaryBlue,
                secondaryBlue,
              ],
            ),
          ),
        ),
        elevation: 0,
        title: const Text(
          'Nilai Akademik',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // GPA Summary Card
                _buildGPACard(gpa),
                
                const SizedBox(height: 24),
                
                // Semester Selection
                _buildSemesterSelector(),
  
                const SizedBox(height: 24),
                
                // List Nilai Title
                _buildSectionHeader('Daftar Nilai Mata Kuliah', Icons.school),
                
                const SizedBox(height: 16),
                
                // List Nilai
                Expanded(
                  child: _buildCoursesList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGPACard(double gpa) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryBlue,
            secondaryBlue,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'IP Semester',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            gpa.toStringAsFixed(2),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Total SKS: ${mataKuliah.fold<int>(0, (sum, mk) => sum + (mk['sks'] as int))}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSemesterSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Pilih Semester', Icons.calendar_today),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: _selectedSemester,
              icon: Icon(Icons.keyboard_arrow_down, color: primaryBlue),
              style: TextStyle(
                color: primaryBlue,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              items: semesters
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedSemester = value;
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: primaryBlue, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: primaryBlue,
          ),
        ),
      ],
    );
  }

  Widget _buildCoursesList() {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: mataKuliah.length,
      itemBuilder: (context, index) {
        final mk = mataKuliah[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                // Show detailed information in the future
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Detail mata kuliah: ${mk['nama']}")),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Side: Course Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mk['nama'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Kode: ${mk['kode']} • ${mk['sks']} SKS',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Right Side: Grade
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _getNilaiColor(mk['nilai']),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          mk['nilai'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}