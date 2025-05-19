import 'package:flutter/material.dart';

class FrsPage extends StatelessWidget {
  final List<Map<String, String>> matakuliah = [
    {'kode': '210702-12', 'nama': 'Testing dan Implementasi'},
    {'kode': '210702-13', 'nama': 'Rekayasa Web Prak.'},
    {'kode': '210702-14', 'nama': 'Sistem Operasi'},
    {'kode': '210702-15', 'nama': 'Mobile Computing'},
  ];

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // FRS Header
            Row(
              children: [
                Icon(Icons.assignment_outlined, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'FRS Online Per Semester',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Tahun Ajaran & Semester
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
            SizedBox(height: 20),

            // Detail Dosen & IPK
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.person_outline, color: Colors.indigo),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Ghazali Nur Rahman, S.ST., M.T',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.stacked_bar_chart_outlined, color: Colors.indigo),
                      SizedBox(width: 8),
                      Text('Batas / Sisa: '),
                      Text('24 / 4 SKS', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.star_outline, color: Colors.indigo),
                      SizedBox(width: 8),
                      Text('IPK: '),
                      Text('4.00', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Dropdown Matakuliah
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Matakuliah',
                border: OutlineInputBorder(),
              ),
              value: 'Konsep Pemrograman',
              items: ['Konsep Pemrograman', 'Pemrograman Mobile', 'UI/UX']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (_) {},
            ),
            SizedBox(height: 10),

            // Tombol Tambah
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow.shade700,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text("Tambah Matkul"),
            ),
            SizedBox(height: 20),

            // Tabel Mata Kuliah
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.purple.shade100, style: BorderStyle.solid),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    color: Color(0xFF1F3C88),
                    child: Row(
                      children: const [
                        Expanded(flex: 1, child: Text('No', style: TextStyle(color: Colors.white))),
                        Expanded(flex: 2, child: Text('Kode MK', style: TextStyle(color: Colors.white))),
                        Expanded(flex: 5, child: Text('Mata Kuliah - Hari - Jam', style: TextStyle(color: Colors.white))),
                      ],
                    ),
                  ),
                  ...List.generate(matakuliah.length, (index) {
                    final mk = matakuliah[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                      child: Row(
                        children: [
                          Expanded(flex: 1, child: Text('${index + 1}')),
                          Expanded(flex: 2, child: Text(mk['kode']!)),
                          Expanded(flex: 5, child: Text(mk['nama']!)),
                        ],
                      ),
                    );
                  }),
                  Divider(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    color: Colors.grey.shade200,
                    width: double.infinity,
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Total SKS: 9 SKS',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
