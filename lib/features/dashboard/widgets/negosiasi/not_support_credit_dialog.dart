// lib/features/dashboard/widgets/negosiasi/credit_not_supported_dialog.dart
import 'package:flutter/material.dart';
import 'package:reseller_app_tav/core/theme/negosiasi_theme.dart';

class CreditNotSupportedDialog extends StatefulWidget {
  const CreditNotSupportedDialog({super.key});

  static void show(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withOpacity(0.65),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) => const CreditNotSupportedDialog(),
      transitionBuilder: (context, anim1, anim2, child) {
        final curvedValue = Curves.easeInOutBack.transform(anim1.value);
        return Transform.scale(
          scale: curvedValue,
          child: Opacity(opacity: anim1.value, child: child),
        );
      },
    );
  }

  @override
  State<CreditNotSupportedDialog> createState() =>
      _CreditNotSupportedDialogState();
}

class _CreditNotSupportedDialogState extends State<CreditNotSupportedDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          style: BorderStyle.solid,
          color: NegotiationTheme.colorBorder,
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ikon Header dengan Lingkaran Gradasi Efek Modern
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: NegotiationTheme.colorRed.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.credit_card_off_rounded,
                color: NegotiationTheme.colorRed,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),

            // Judul Utama
            const Text(
              "KREDIT TIDAK TERSEDIA",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Montserrat',
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 12),

            // Sub Deskripsi Masalah 422
            const Text(
              "Unit mobil yang Anda pilih saat ini belum mendukung metode pembayaran kredit. Silakan ubah tipe pembayaran menjadi CASH untuk melanjutkan proses negosiasi.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: NegotiationTheme.colorGrayText,
                fontFamily: 'Montserrat',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),

            // Tombol Aksi Konfirmasi Utama
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: NegotiationTheme.colorGold,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "MENGERTI",
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
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
