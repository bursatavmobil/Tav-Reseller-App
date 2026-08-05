import 'package:flutter/material.dart';
import 'package:reseller_app_tav/core/theme/app_assets.dart';

class AnimatedStatusDialog extends StatefulWidget {
  final bool isSuccess;
  final String title;
  final String message;

  const AnimatedStatusDialog({
    super.key,
    required this.isSuccess,
    required this.title,
    required this.message,
  });

  static void show(
    BuildContext context, {
    required bool isSuccess,
    required String title,
    required String message,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (context, anim1, anim2) => const SizedBox.shrink(),
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: CurvedAnimation(parent: anim1, curve: Curves.bounceOut).value,
          child: FadeTransition(
            opacity: anim1,
            child: AnimatedStatusDialog(
              isSuccess: isSuccess,
              title: title,
              message: message,
            ),
          ),
        );
      },
    );
  }

  @override
  State<AnimatedStatusDialog> createState() => _AnimatedStatusDialogState();
}

class _AnimatedStatusDialogState extends State<AnimatedStatusDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _iconController;

  @override
  void initState() {
    super.initState();
    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _iconController.dispose();
    super.dispose();
  }

  String _capitalizeWords(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final Color mainBrandColor = widget.isSuccess
        ? const Color(0xFFD4AF37)
        : const Color(0xFFE52525);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: mainBrandColor.withOpacity(0.4), width: 1.5),
      ),
      backgroundColor: const Color(0xFF1A1A1A),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: CurvedAnimation(
                parent: _iconController,
                curve: Curves.elasticOut,
              ),
              child: Container(
                height: 100,
                width: 100,
                padding: const EdgeInsets.all(12),
                child: Image.asset(
                  widget.isSuccess
                      ? AppAssets.imageEmailSend
                      : AppAssets.imageQuestion,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      widget.isSuccess
                          ? Icons.mark_email_read_rounded
                          : Icons.error_outline_rounded,
                      color: mainBrandColor,
                      size: 64,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _capitalizeWords(widget.title),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w900,
                fontSize: 16,
                color: mainBrandColor,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.isSuccess
                      ? const Color(0xFFE52525)
                      : const Color(0xFF262626),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  side: widget.isSuccess
                      ? BorderSide.none
                      : const BorderSide(color: Color(0xFF333333)),
                ),
                onPressed: () => Navigator.pop(context),
                child: Text(
                  widget.isSuccess ? "Oke, Mengerti" : "Tutup",
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}