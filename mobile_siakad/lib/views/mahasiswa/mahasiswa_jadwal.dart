import 'package:flutter/material.dart';

class MahasiswaJadwalPage extends StatefulWidget {
  const MahasiswaJadwalPage({Key? key}) : super(key: key);

  @override
  State<MahasiswaJadwalPage> createState() => _MahasiswaJadwalPageState();
}

class _MahasiswaJadwalPageState extends State<MahasiswaJadwalPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final Color primaryBlue = const Color(0xFF133B7A);
  final Color secondaryBlue = const Color(0xFF1E5BB0);
  String _selectedSemester = 'Genap';
  
  final List<Map<String, dynamic>> jadwalKuliah = [
    {
      'time': '07:00 - 09:10',
      'subject': 'Testing & Implementasi',
      'room': 'C 203',
      'day': 'Senin'
    },
    {
      'time': '10:00 - 12:30',
      'subject': 'Workshop Design Pengalaman Pengguna',
      'room': 'C 203',
      'day': 'Senin'
    },
    {
      'time': '13:00 - 15:30',
      'subject': 'Workshop Pemrogramman Perangkat Bergerak',
      'room': 'D 301',
      'day': 'Selasa'
    },
    {
      'time': '07:30 - 09:50',
      'subject': 'Workshop Administrasi Jaringan',
      'room': 'Lab Jarkom',
      'day': 'Rabu'
    },
  ];

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: const BackButton(color: Colors.white),
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
          'Jadwal Kuliah',
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
                // Schedule Summary Card
                _buildSummaryCard(),
                
                const SizedBox(height: 24),
                
                // Semester Selection
                _buildSemesterSelector(),
  
                const SizedBox(height: 24),
                
                // List Jadwal Title
                _buildSectionHeader('Daftar Jadwal Kuliah', Icons.schedule),
                
                const SizedBox(height: 16),
                
                // List Jadwal
                Expanded(
                  child: _buildScheduleList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
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
            'Total Mata Kuliah',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            jadwalKuliah.length.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Semester ${_selectedSemester} 2024/2025',
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
              items: ['Ganjil', 'Genap']
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

  Widget _buildScheduleList() {
    // Group by day
    Map<String, List<Map<String, dynamic>>> groupedSchedule = {};
    for (var jadwal in jadwalKuliah) {
      String day = jadwal['day'];
      if (!groupedSchedule.containsKey(day)) {
        groupedSchedule[day] = [];
      }
      groupedSchedule[day]!.add(jadwal);
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: groupedSchedule.keys.length,
      itemBuilder: (context, index) {
        String day = groupedSchedule.keys.elementAt(index);
        List<Map<String, dynamic>> daySchedules = groupedSchedule[day]!;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                day,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: primaryBlue,
                ),
              ),
            ),
            ...daySchedules.map((jadwal) => _classCard(
              time: jadwal['time'],
              subject: jadwal['subject'],
              room: jadwal['room'],
            )).toList(),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _classCard({
    required String time,
    required String subject,
    required String room,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryBlue,
            secondaryBlue,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            // Future feature - tapping on a class could show more details
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Detail mata kuliah: $subject")),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  time,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subject,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      room,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}