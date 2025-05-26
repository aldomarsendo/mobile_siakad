import 'package:flutter/material.dart';
import './widgets/student_info_row.dart'; // Import student_info_row.dart

class FrsStudentDetailsCard extends StatelessWidget {
  final String namaMahasiswa;
  final String nrpMahasiswa;
  final String ipkMahasiswa;
  final int batasSks;
  final int totalSksDiambil;
  final Color primaryColor;
  final Color textOnLightBgColor;
  final Color subtleTextOnLightBgColor;
  final Color iconColorOnLightBgColor;
  final Color cardShadowColor;

  const FrsStudentDetailsCard({
    Key? key,
    required this.namaMahasiswa,
    required this.nrpMahasiswa,
    required this.ipkMahasiswa,
    required this.batasSks,
    required this.totalSksDiambil,
    required this.primaryColor,
    required this.textOnLightBgColor,
    required this.subtleTextOnLightBgColor,
    required this.iconColorOnLightBgColor,
    required this.cardShadowColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.person_outline_rounded, color: primaryColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  namaMahasiswa,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: textOnLightBgColor),
                  overflow: TextOverflow.ellipsis,
                ),
              )
            ],
          ),
          const SizedBox(height: 16),
          StudentInfoRow(
            icon: Icons.credit_card_outlined,
            label: 'NRP:',
            value: nrpMahasiswa,
            iconColor: iconColorOnLightBgColor,
            labelColor: subtleTextOnLightBgColor,
            valueColor: textOnLightBgColor,
          ),
          const SizedBox(height: 12),
          StudentInfoRow(
            icon: Icons.layers_outlined,
            label: 'Batas / Sisa SKS:',
            value: '$batasSks / ${batasSks - totalSksDiambil} SKS',
            iconColor: iconColorOnLightBgColor,
            labelColor: subtleTextOnLightBgColor,
            valueColor: textOnLightBgColor,
          ),
          const SizedBox(height: 12),
          StudentInfoRow(
            icon: Icons.star_border_rounded,
            label: 'IPK Kumulatif:',
            value: ipkMahasiswa,
            iconColor: iconColorOnLightBgColor,
            labelColor: subtleTextOnLightBgColor,
            valueColor: textOnLightBgColor,
          ),
        ],
      ),
    );
  }
}
