import 'package:flutter/material.dart';
import 'package:mobile_siakad/models/frs_model.dart';
import './widgets/section_header.dart';

class FrsCourseTable extends StatelessWidget {
  final List<FrsItem> matakuliahDiambil;
  final Future<void> Function(int idFrs, String namaMk)? onDeleteCourse;
  final bool isLoadingMyFrs;
  final bool isSubmitting; 
  final int totalSksDiambil;

  final Color primaryColor;
  final Color textOnLightBgColor;
  final Color subtleTextOnLightBgColor;
  final Color dividerColor;
  final Color cardShadowColor;

  const FrsCourseTable({
    Key? key,
    required this.matakuliahDiambil,
    required this.onDeleteCourse,
    required this.isLoadingMyFrs,
    required this.isSubmitting,
    required this.totalSksDiambil,
    required this.primaryColor,
    required this.textOnLightBgColor,
    required this.subtleTextOnLightBgColor,
    required this.dividerColor,
    required this.cardShadowColor,
  }) : super(key: key);

  Color _getStatusColor(String status) {
    String currentStatus = status.toLowerCase();
    if (currentStatus == 'disetujui') {
      return Colors.green.shade700;
    } else if (currentStatus == 'ditolak') {
      return Colors.red.shade700;
    } else if (currentStatus == 'pending') {
      return Colors.orange.shade700;
    }
    return Colors.grey.shade700; // Default
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Daftar Mata Kuliah Diambil',
          icon: Icons.list_alt_outlined,
          iconColor: primaryColor,
          textColor: primaryColor,
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: cardShadowColor,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect( 
            borderRadius: BorderRadius.circular(16),
            child: Column(
              children: [
                // Table Header
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  color: primaryColor.withOpacity(0.9), 
                  child: Row(
                    children: [
                      const Expanded(
                        flex: 1, 
                        child: Text('No', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)), // Ukuran font disesuaikan
                      ),
                      const Expanded(
                        flex: 3, 
                        child: Text('Kode MK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                      const Expanded(
                        flex: 4, // Flex disesuaikan
                        child: Text('Mata Kuliah', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                      const Expanded(
                        flex: 1, 
                        child: Text('SKS', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                      const Expanded(
                        flex: 2, // Sesuaikan flex untuk status
                        child: Text('Status', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                      Container( 
                        width: 35, // Lebar sedikit disesuaikan
                        alignment: Alignment.center, 
                        child: const Text('Aksi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))
                      ),
                    ],
                  ),
                ),
                // Table Rows
                if (isLoadingMyFrs && matakuliahDiambil.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Center(child: CircularProgressIndicator(color: primaryColor)),
                  )
                else if (!isLoadingMyFrs && matakuliahDiambil.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
                    child: Center(
                        child: Text("Belum ada mata kuliah yang diambil.", style: TextStyle(color: subtleTextOnLightBgColor, fontSize: 15))),
                  )
                else
                  ...List.generate(matakuliahDiambil.length, (index) {
                    final item = matakuliahDiambil[index];

                    print("FrsCourseTable - Rendering item FRS ID: ${item.idFrs}");
  print("  > Status: ${item.status}");
  print("  > jadwalKuliah (objek): ${item.jadwalKuliah}");
  print("  > jadwalKuliah?.masterMatakuliah (objek): ${item.jadwalKuliah?.masterMatakuliah}");
  print("  > jadwalKuliah?.masterMatakuliah?.kodeMk: ${item.jadwalKuliah?.masterMatakuliah?.kodeMk}");
  print("  > jadwalKuliah?.masterMatakuliah?.namaMk: ${item.jadwalKuliah?.masterMatakuliah?.namaMk}");
  print("  > jadwalKuliah?.masterMatakuliah?.sks: ${item.jadwalKuliah?.masterMatakuliah?.sks}");
                    final mk = item.jadwalKuliah; 
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        border: index < matakuliahDiambil.length - 1
                            ? Border(bottom: BorderSide(color: dividerColor, width: 1))
                            : null,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Text('${index + 1}', style: TextStyle(color: textOnLightBgColor, fontSize: 13)), // Ukuran font disesuaikan
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(item.jadwalKuliah?.masterMatakuliah?.kodeMk ?? "", style: TextStyle(color: textOnLightBgColor, fontSize: 13)),
                          ),
                          Expanded(
                            flex: 4,
                            child: Text(item.jadwalKuliah?.masterMatakuliah?.namaMk ?? "", style: TextStyle(color: textOnLightBgColor, fontWeight: FontWeight.w500, fontSize: 13)),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(item.jadwalKuliah?.masterMatakuliah?.sks.toString() ?? "", textAlign: TextAlign.center, style: TextStyle(color: textOnLightBgColor, fontSize: 13)),
                          ),
                          Expanded(
                            flex: 2, // Sesuaikan flex
                            child: Center( // Agar teks status di tengah
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(item.status).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  item.status.toUpperCase(),
                                  style: TextStyle(
                                    color: _getStatusColor(item.status),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10, // Font lebih kecil untuk status
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 35, 
                            child: IconButton(
                              icon: Icon(Icons.delete_outline_rounded, 
                                    color: item.status.toLowerCase() == 'pending' ? Colors.red.shade500 : Colors.grey, 
                                    size: 20), // Ukuran ikon disesuaikan
                              tooltip: item.status.toLowerCase() == 'pending' ? 'Hapus Mata Kuliah' : 'Tidak dapat dihapus (Status: ${item.status})',
                              onPressed: isSubmitting || item.status.toLowerCase() != 'pending'
                                ? null  
                                : () {
                                  if (onDeleteCourse != null) {
                                    onDeleteCourse!(item.idFrs, mk?.masterMatakuliah?.namaMk ?? "Mata Kuliah Tidak Diketahui");
                                  }
                                }, 
                              padding: EdgeInsets.zero, 
                              constraints: const BoxConstraints(), 
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                // Table Footer
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  color: Colors.grey.shade100, 
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Total SKS Diambil:',
                        style: TextStyle(fontWeight: FontWeight.w500, color: textOnLightBgColor, fontSize: 14),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$totalSksDiambil SKS',
                        style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor, fontSize: 15),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
