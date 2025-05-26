import 'package:flutter/material.dart';
import 'package:mobile_siakad/models/mahasiswa_frs_data_model.dart';
import './widgets/section_header.dart';

class FrsAddCourseSection extends StatelessWidget {
  final List<AvailableMatakuliahItem> matakuliahTersedia;
  final int? selectedMatakuliahId;
  final ValueChanged<int?> onMatakuliahChanged;
  final Future<void> Function()? onAddCoursePressed;
  final bool isLoadingAvailableMk;
  final bool isSubmitting;
  final Color primaryColor;
  final Color textOnLightBgColor;
  final Color subtleTextOnLightBgColor;
  final Color cardShadowColor;

  const FrsAddCourseSection({
    Key? key,
    required this.matakuliahTersedia,
    required this.selectedMatakuliahId,
    required this.onMatakuliahChanged,
    required this.onAddCoursePressed,
    required this.isLoadingAvailableMk,
    required this.isSubmitting,
    required this.primaryColor,
    required this.textOnLightBgColor,
    required this.subtleTextOnLightBgColor,
    required this.cardShadowColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Tambah Mata Kuliah',
          icon: Icons.add_circle_outline_rounded,
          iconColor: primaryColor,
          textColor: primaryColor,
        ),
        const SizedBox(height: 12),
        Container(
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: [
                    BoxShadow(
                      color: cardShadowColor.withOpacity(0.5),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    isExpanded: true,
                    value: selectedMatakuliahId,
                    hint: Text(isLoadingAvailableMk ? "Memuat..." : "Pilih Mata Kuliah", style: TextStyle(color: subtleTextOnLightBgColor)),
                    icon: Icon(Icons.keyboard_arrow_down, color: primaryColor),
                    style: TextStyle(color: textOnLightBgColor, fontSize: 16, fontWeight: FontWeight.w500),
                    items: matakuliahTersedia
                        .map((mk) => DropdownMenuItem<int>(
                            value: mk.idMkJadwal,
                            child: Text(
                              "${mk.namaMk} (${mk.sks} SKS)",
                              style: TextStyle(color: textOnLightBgColor),
                              overflow: TextOverflow.ellipsis,
                            )))
                        .toList(),
                    onChanged: isLoadingAvailableMk || isSubmitting ? null : onMatakuliahChanged,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: isSubmitting
                      ? Container(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.add, size: 20, color: Colors.white),
                  onPressed: isSubmitting || isLoadingAvailableMk || matakuliahTersedia.isEmpty ? null : onAddCoursePressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  label: Text(
                    isSubmitting ? 'Memproses...' : 'Tambah Mata Kuliah',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
