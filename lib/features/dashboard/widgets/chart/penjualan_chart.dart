import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:reseller_app_tav/features/dashboard/providers/dashboard_provider.dart';
import 'package:reseller_app_tav/features/dashboard/widgets/chart/custom_month_picker.dart';

class PenjualanChartCard extends StatelessWidget {
  const PenjualanChartCard({super.key});

  String _formatBulanIndo(DateTime date) {
    return DateFormat('MMMM yyyy', 'id_ID').format(date);
  }

  String _formatJutaan(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}Jt';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}Rb';
    }
    return value.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DashboardProvider>();
    final dataGrafik = provider.penjualanHarianGrafikData;

    // Menghitung nilai puncak Y secara dinamis
    double maxNominal = 500000;
    for (var element in dataGrafik) {
      if (element.value > maxNominal) maxNominal = element.value;
    }
    maxNominal = (maxNominal / 100000).ceil() * 100000.0;

    // Kontrol aktifasi tombol paginate
    int totalDaysInMonth = DateTime(
      provider.selectedMonth.year,
      provider.selectedMonth.month + 1,
      0,
    ).day;
    int maxIndex = (totalDaysInMonth / 5).ceil() - 1;
    bool canNext = provider.currentDayWindowIndex < maxIndex;
    bool canPrev = provider.currentDayWindowIndex > 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER: DROPDOWN BULAN & PILIHAN JENDELA
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Grafik Penjualan",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    provider.currentDayRangeLabel,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () => CustomMonthPickerDialog.show(context),
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_month_outlined,
                        size: 16,
                        color: Color(0xFFE52525),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatBulanIndo(provider.selectedMonth),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.keyboard_arrow_down,
                        size: 16,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // LINE CHART WIDGET
          SizedBox(
            height: 220,
            child: dataGrafik.isEmpty
                ? const Center(
                    child: Text(
                      "Tidak ada riwayat transaksi",
                      style: TextStyle(fontFamily: 'Montserrat'),
                    ),
                  )
                : LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: Colors.grey.withOpacity(0.08),
                          strokeWidth: 1,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 45,
                            interval: maxNominal / 4 > 0 ? maxNominal / 4 : 1,
                            getTitlesWidget: (value, meta) => Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Text(
                                _formatJutaan(value),
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 10,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: Alignment.centerRight.toTextAlign(),
                              ),
                            ),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 24,
                            getTitlesWidget: (value, meta) {
                              int index = value.toInt();
                              if (index >= 0 && index < dataGrafik.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top:8.0),
                                  child: Text(
                                    dataGrafik[index].key.replaceAll(
                                      "Tgl ",
                                      "",
                                    ),
                                    style: const TextStyle(
                                      color: Color(0xFF666666),
                                      fontSize: 11,
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      minX: 0,
                      maxX: (dataGrafik.length - 1).toDouble(),
                      minY: 0,
                      maxY: maxNominal,
                      lineBarsData: [
                        LineChartBarData(
                          spots: dataGrafik.asMap().entries.map((e) {
                            return FlSpot(e.key.toDouble(), e.value.value);
                          }).toList(),
                          isCurved: true,
                          curveSmoothness: 0.25,
                          color: const Color(
                            0xFFE52525,
                          ), // Merah Identitas Brand TAV
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) =>
                                FlDotCirclePainter(
                                  radius: 4,
                                  color: Colors.white,
                                  strokeColor: const Color(0xFFE52525),
                                  strokeWidth: 2,
                                ),
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFFE52525).withOpacity(0.15),
                                const Color(0xFFE52525).withOpacity(0.0),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              stops: const [0.2, 1.0],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          const SizedBox(height: 16),

          // BARIS FOOTER: INDIKATOR LEGEND & PAGINATION CHEVRON DI POJOK KANAN BAWAH
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE52525),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Total Komisi Penjualan",
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF666666),
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ],
              ),
              // TOMBOL NAVIGASI PAGINASI (CHEVRON LEFT & RIGHT)
              Row(
                children: [
                  IconButton(
                    autofocus: true,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      Icons.chevron_left,
                      color: canPrev ? Colors.black : Colors.grey[300],
                      size: 24,
                    ),
                    onPressed: canPrev
                        ? () => provider.previousDayWindow()
                        : null,
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    autofocus: true,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      Icons.chevron_right,
                      color: canNext ? Colors.black : Colors.grey[300],
                      size: 24,
                    ),
                    onPressed: canNext ? () => provider.nextDayWindow() : null,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

extension on Alignment {
  TextAlign toTextAlign() =>
      this == Alignment.centerRight ? TextAlign.right : TextAlign.center;
}
