import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:reseller_app_tav/features/dashboard/providers/dashboard_provider.dart';

class CustomMonthPickerDialog extends StatelessWidget {
  const CustomMonthPickerDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const CustomMonthPickerDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<DashboardProvider>();
    final int tahunSekarang = DateTime.now().year;
    final int bulanSekarang = DateTime.now().month;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Pilih Periode $tahunSekarang",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Montserrat',
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18, color: Colors.grey),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 12,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.8,
              ),
              itemBuilder: (context, index) {
                int bulanKe = index + 1;
                bool isFutureMonth = bulanKe > bulanSekarang;
                DateTime targetMonth = DateTime(tahunSekarang, bulanKe, 1);
                bool isSelected = provider.selectedMonth.month == bulanKe;

                String namaSingkatBulan = DateFormat(
                  'MMM',
                  'id_ID',
                ).format(targetMonth);

                return InkWell(
                  onTap: isFutureMonth
                      ? null
                      : () {
                          provider.changeSelectedMonth(targetMonth);
                          Navigator.pop(context);
                        },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFE52525)
                          : (isFutureMonth
                                ? const Color(0xFFFAFAFA)
                                : const Color(0xFFF5F5F5)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      namaSingkatBulan,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isSelected
                            ? Colors.white
                            : (isFutureMonth
                                  ? Colors.grey[300]
                                  : const Color(0xFF4A4A4A)),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
