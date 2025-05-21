import 'package:flutter/material.dart';

class MahasiswaProfilPage extends StatelessWidget {
  final Color primaryBlue = Color(0xFF133B7A);

  MahasiswaProfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pengaturan Profil', style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=3'),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: primaryBlue,
                      child: Icon(Icons.edit, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Pradita Arif Setiawan',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              '3123500052',
              style: TextStyle(color: Colors.grey[700]),
            ),
            SizedBox(height: 24),
            _profilField(label: 'Email', value: 'pradita@student.pens.ac.id'),
            SizedBox(height: 16),
            _profilField(label: 'No. HP', value: '0812-3456-7890'),
            SizedBox(height: 16),
            _profilField(label: 'Alamat', value: 'Jl. Raya ITS, Surabaya'),
            SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Tambahkan aksi simpan di sini
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Perubahan profil disimpan!')),
                  );
                },
                icon: Icon(Icons.save),
                label: Text('Simpan Perubahan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profilField({required String label, required String value}) {
    return TextFormField(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}