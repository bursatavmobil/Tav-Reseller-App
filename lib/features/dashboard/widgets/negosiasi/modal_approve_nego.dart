import 'package:flutter/material.dart';
import 'package:reseller_app_tav/core/theme/app_assets.dart';

class SuccessDealDialog extends StatelessWidget {
  final VoidCallback onRedirect;
  final bool isApproved;

  const SuccessDealDialog({
    super.key,
    required this.onRedirect,
    this.isApproved = true,
  });

  static void show(
    BuildContext context, {
    required VoidCallback onRedirect,
    bool isApproved = true,
  }) {
    showDialog(
      context: context,
      barrierDismissible: !isApproved,
      builder: (BuildContext context) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 700),
          curve: Curves.bounceOut,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: SuccessDealDialog(
                onRedirect: onRedirect,
                isApproved: isApproved,
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        // Border Gold Premium (Aksen emas bersinar saat Deal, Merah Muted saat Reject)
        side: BorderSide(
          color: isApproved
              ? const Color(0xFFD4AF37)
              : const Color(0xFFE52525).withOpacity(0.6),
          width: 1.5,
        ),
      ),
      backgroundColor: const Color(0xFF1A1A1A),
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 140,
              width: 140,
              margin: const EdgeInsets.symmetric(vertical: 12),
              child: Image.asset(
                isApproved ? AppAssets.imageDeal : AppAssets.imageNotDeal,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    isApproved
                        ? Icons.handshake_rounded
                        : Icons.cancel_outlined,
                    size: 80,
                    color: isApproved
                        ? const Color(0xFFD4AF37)
                        : const Color(0xFFE52525),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isApproved ? "Deal Mobil !" : "Penawaran Ditolak",
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w900,
                fontSize: 18,
                color: isApproved
                    ? const Color(0xFFD4AF37)
                    : const Color(0xFFE52525),
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isApproved
                  ? "Nego mobil sudah deal silahkan kunjungi menu transaksi, yaa"
                  : "Mohon maaf, penawaran harga yang Anda ajukan telah ditolak oleh manajemen.",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            if (isApproved) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE52525),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    onRedirect();
                  },
                  child: const Text(
                    "Kunjungi Transaksi",
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF333333)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Lanjut Chat",
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      color: Color(0xFF8E8E93),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ] else
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF333333)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Tutup",
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      color: Color(0xFF8E8E93),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
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
