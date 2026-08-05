import 'package:flutter/material.dart';

class PaginationFooterBar extends StatelessWidget {
  final int currentPage;
  final bool hasMore;
  final VoidCallback? onPreviousPressed;
  final VoidCallback? onNextPressed;

  const PaginationFooterBar({
    super.key,
    required this.currentPage,
    required this.hasMore,
    required this.onPreviousPressed,
    required this.onNextPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEFEFEF), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Teks Indikator Halaman Kontras
          Text(
            "Halaman $currentPage",
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF8E8E93),
            ),
          ),

          // Tombol Navigasi
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: onPreviousPressed,
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 12,
                  color: Color(0xFF1A1A1A),
                ),
                label: const Text(
                  "Prev",
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: onPreviousPressed != null
                        ? const Color(0xFFEFEFEF)
                        : Colors.transparent,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: onNextPressed,
                icon: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 12,
                  color: Color(0xFF1A1A1A),
                ),
                label: const Text(
                  "Next",
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: onNextPressed != null
                        ? const Color(0xFFEFEFEF)
                        : Colors.transparent,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
