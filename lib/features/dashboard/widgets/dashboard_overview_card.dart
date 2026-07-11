import 'package:flutter/material.dart';

class DashboardOverviewCards extends StatelessWidget {
  final int saldoKeuntungan;
  final int pemasukanBulanIni;
  final int unitTerjual;
  final double persentasePemasukan; 
  final double persentaseUnit; 
  final VoidCallback onTarikSaldoPressed;
  final VoidCallback onLihatDetailPressed;

  const DashboardOverviewCards({
    super.key,
    required this.saldoKeuntungan,
    required this.pemasukanBulanIni,
    required this.unitTerjual,
    required this.persentasePemasukan,
    required this.persentaseUnit,
    required this.onTarikSaldoPressed,
    required this.onLihatDetailPressed,
  });

  String _formatRupiah(int value) {
    String str = value.toString();
    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return str.replaceAllMapped(reg, (Match match) => '${match[1]}.');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildBaseCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'Saldo Keuntungan',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: onLihatDetailPressed,
                    child: const Text(
                      'Lihat Detail',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        'Rp. ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black.withOpacity(0.85),
                        ),
                      ),
                      Text(
                        _formatRupiah(saldoKeuntungan),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: onTarikSaldoPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE52525),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Tarik Saldo',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        _buildBaseCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Text(
                    'Pemasukan Bulan ini',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        'Rp. ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black.withOpacity(0.85),
                        ),
                      ),
                      Text(
                        _formatRupiah(pemasukanBulanIni),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  _buildBadgeTrend(persentasePemasukan),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        _buildBaseCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Unit Terjual',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    unitTerjual.toString(),
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  _buildBadgeTrend(persentaseUnit),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBaseCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEAEAEA), width: 1.5),
      ),
      child: child,
    );
  }

  Widget _buildBadgeTrend(double value) {
    final bool isNegative = value < 0;
    final Color badgeBg = isNegative
        ? const Color(0xFFFFEAEA)
        : const Color(0xFFE8F9EE);
    final Color textColor = isNegative
        ? const Color(0xFFE52525)
        : const Color(0xFF27AE60);
    final IconData icon = isNegative ? Icons.trending_down : Icons.trending_up;

    final String displayValue = '${value.abs().toStringAsFixed(1)}%';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: badgeBg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: textColor),
              const SizedBox(width: 4),
              Text(
                displayValue,
                style: TextStyle(
                  color: textColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'vs Last Month',
          style: TextStyle(color: Colors.grey[500], fontSize: 11),
        ),
      ],
    );
  }
}
