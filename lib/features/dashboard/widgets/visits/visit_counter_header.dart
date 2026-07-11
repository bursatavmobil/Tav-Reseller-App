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
            accentColor: const Color(0xFF666666), 
            icon: Icons.hourglass_empty_rounded,
          ),
          const SizedBox(width: 12),
          _buildCardCounter(
            title: "Selesai",
            count: selesai,
            accentColor: Colors.black,
            icon: Icons.check_circle_outline_rounded,
          ),
          const SizedBox(width: 12),
          _buildCardCounter(
            title: "Batal",
            count: batal,
            accentColor: const Color(0xFFE52525), 
            icon: Icons.cancel_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildCardCounter({
    required String title,
    required int count,
    required Color accentColor,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xEAEAEA), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: Color(0xFF8E8E93),
                  ),
                ),
                Icon(icon, size: 14, color: accentColor),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              textBaseline: TextBaseline.alphabetic,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              children: [
                Text(
                  count.toString(),
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: accentColor,
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