import 'package:flutter/material.dart';

class JadwalKuliahPage extends StatelessWidget {
  final Color primaryBlue = Color(0xFF133B7A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primaryBlue,
                ),

              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  SizedBox(width: 16),
                  Text(
                    'Jadwal Kuliah',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Hari & Tanggal
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  Text(
                    'Senin, 27 Mei 2024',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                ],
              ),
            ),

            SizedBox(height: 16),

            // Card Mata Kuliah
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _classCard(
                    time: '07:00 - 09:10',
                    subject: 'Testing & Implementasi',
                    room: 'C 203',
                  ),
                  SizedBox(height: 16),
                  _classCard(
                    time: '10:00 - 12:30',
                    subject: 'Workshop Design Pengalaman Pengguna',
                    room: 'C 203',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _classCard({
    required String time,
    required String subject,
    required String room,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            time,
            style: TextStyle(
              color: primaryBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6),
          Text(
            subject,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: Colors.grey),
              SizedBox(width: 4),
              Text(
                room,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
