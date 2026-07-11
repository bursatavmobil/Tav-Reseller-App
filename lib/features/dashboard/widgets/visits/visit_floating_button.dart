import 'package:flutter/material.dart';

class VisitFloatingButton extends StatefulWidget {
  final VoidCallback onPressed;

  const VisitFloatingButton({super.key, required this.onPressed});

  @override
  State<VisitFloatingButton> createState() => _VisitFloatingButtonState();
}

class _VisitFloatingButtonState extends State<VisitFloatingButton> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16.0, right: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: widget.onPressed,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                height: 54,
                padding: EdgeInsets.symmetric(
                  horizontal: _isExpanded ? 16 : 14,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A), // Premium Matte Black
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: const Color(
                      0xFFD4AF37,
                    ).withOpacity(0.6), // Soft Gold Border
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      color: Color(0xFFD4AF37), // Gold Icon
                      size: 20,
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: Row(
                        children: [
                          if (_isExpanded) ...[
                            const SizedBox(width: 10),
                            const Text(
                              "Jadwalkan Kunjungan Anda",
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Tombol Chevron pemicu Hide/Show
            GestureDetector(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFEAEAEA)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  _isExpanded
                      ? Icons.chevron_right_rounded
                      : Icons.chevron_left_rounded,
                  color: const Color(0xFFE52525), // Accent Red
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
