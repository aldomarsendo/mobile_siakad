import 'package:flutter/material.dart';

class DosenJadwalPage extends StatelessWidget {
  final Color primaryBlue = Color(0xFF133B7A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: Colors.black87),
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Jadwal Kuliah',
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
                  'Jadwal Kuliah saya',
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
        color: Color(0xFF133B7A),
        borderRadius: BorderRadius.circular(15),
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
              color: Colors.white,
              fontWeight: FontWeight.normal,
            ),
          ),
          SizedBox(height: 6),
          Text(
            subject,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: Colors.white),
              SizedBox(width: 4),
              Text(
                room,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
