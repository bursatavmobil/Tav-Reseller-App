import 'package:flutter/material.dart';

class VisitCounterHeader extends StatelessWidget {
  final Map<String, dynamic> counters;

  const VisitCounterHeader({super.key, required this.counters});

  @override
  Widget build(BuildContext context) {
    final int aktif = counters['aktif'] ?? 0;
    final int selesai = counters['selesai'] ?? 0;
    final int batal = counters['batal'] ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Row(
        children: [
          _buildCardCounter(
            title: "Aktif",
            count: aktif,
            textColor: Colors.white,
            bgColor: const Color(0xFF1A1A1A),
            borderColor: const Color(0xFFD4AF37),
            dotColor: const Color(0xFFD4AF37),
            icon: Icons.bolt_rounded,
          ),
          const SizedBox(width: 12),
          _buildCardCounter(
            title: "Selesai",
            count: selesai,
            textColor: const Color(0xFF1A1A1A),
            bgColor: Colors.white,
            borderColor: const Color(0xFFD4AF37),
            dotColor: const Color(0xFFD4AF37),
            icon: Icons.verified_rounded,
          ),
          const SizedBox(width: 12),
          _buildCardCounter(
            title: "Batal",
            count: batal,
            textColor: const Color(0xFF1A1A1A),
            bgColor: Colors.white,
            borderColor: const Color(0xFFEFEFEF),
            dotColor: const Color(0xFFE52525),
            icon: Icons.dangerous_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildCardCounter({
    required String title,
    required int count,
    required Color textColor,
    required Color bgColor,
    required Color borderColor,
    required Color dotColor,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title.toUpperCase(),
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                    color: textColor.withOpacity(
                      textColor == Colors.white ? 0.6 : 0.4,
                    ),
                  ),
                ),
                Icon(icon, size: 16, color: dotColor),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              textBaseline: TextBaseline.alphabetic,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              children: [
                Text(
                  count.toString(),
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: textColor,
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
