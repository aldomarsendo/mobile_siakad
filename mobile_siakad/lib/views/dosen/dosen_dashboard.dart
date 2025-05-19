import 'package:flutter/material.dart';

class DosenDashboardPage extends StatelessWidget {
  final Color primaryBlue = Color(0xFF133B7A);

  DosenDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primaryBlue,
                borderRadius: BorderRadius.only(
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=3'),
                      ),
                      SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pradita Arif Setiawan',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '3123500052 (Dosen)',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                      Spacer(),
                      Icon(Icons.settings, color: Colors.white),
                    ],
                  ),
                ],
              ),
            ),

            // Berita Terbaru
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Berita Terbaru', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/images/pens.png',
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
            ),

            // Menu Akademik
                      // ...existing code...
            // Menu Akademik
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Akademik', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _menuButton(Icons.calendar_today, "Jadwal", primaryBlue),
                        _menuButton(Icons.grade, "Nilai", primaryBlue),
                        _menuButton(Icons.file_copy, "FRS", primaryBlue),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // ...existing code...
            SizedBox(height: 16),

            // Jadwal Kuliah Hari Ini
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Text("Jadwal kuliah hari ini", style: TextStyle(fontWeight: FontWeight.bold)),
                  Spacer(),
                  Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
            ),
            SizedBox(height: 8),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 16),
                children: [
                  Text("27  Senin · 2 MATA KULIAH", style: TextStyle(fontSize: 12)),
                  SizedBox(height: 8),
                  _classCard("07:00", "09:10", "Testing & Implementasi", "C 203", primaryBlue),
                  SizedBox(height: 8),
                  _classCard("10:00", "12:30", "Workshop Design Pengalaman Pengguna", "C 203", primaryBlue),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuButton(IconData icon, String label, Color color) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: color,
          child: Icon(icon, color: Colors.white),
        ),
        SizedBox(height: 4),
        Text(label),
      ],
    );
  }

  Widget _classCard(String start, String end, String subject, String room, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$start → $end", style: TextStyle(color: Colors.white)),
          SizedBox(height: 4),
          Text(subject, style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal)),
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.white, size: 16),
              SizedBox(width: 4),
              Text(room, style: TextStyle(color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }
}
