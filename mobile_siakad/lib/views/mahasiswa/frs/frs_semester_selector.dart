import 'package:flutter/material.dart';
import './widgets/section_header.dart'; // Import section_header.dart

class FrsSemesterSelector extends StatelessWidget {
  final String selectedSemester;
  final ValueChanged<String?> onChanged;
  final Color primaryColor;
  final Color textColor;
  final Color cardShadowColor;

  const FrsSemesterSelector({
    Key? key,
    required this.selectedSemester,
    required this.onChanged,
    required this.primaryColor,
    required this.textColor,
    required this.cardShadowColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Pilih Semester (Filter)',
          icon: Icons.calendar_today_outlined,
          iconColor: primaryColor,
          textColor: primaryColor,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                color: cardShadowColor,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: selectedSemester,
              icon: Icon(Icons.keyboard_arrow_down, color: primaryColor),
              style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w500),
              items: ['Ganjil', 'Genap']
                  .map((e) => DropdownMenuItem(
                      value: e,
                      child: Text(e, style: TextStyle(color: textColor))))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
