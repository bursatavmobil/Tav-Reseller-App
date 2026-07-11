import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class KycImageSourcePicker extends StatefulWidget {
  final ValueChanged<ImageSource> onSourceSelected;

  const KycImageSourcePicker({super.key, required this.onSourceSelected});

  static void show(
    BuildContext context, {
    required ValueChanged<ImageSource> onSourceSelected,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor:
          Colors.black26, // Lapisan transparan gelap di latar belakang
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (context, animation, secondaryAnimation) =>
          const SizedBox.shrink(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        // Efek bounce halus dari bawah layar
        final backdropTween =
            Tween<Offset>(
              begin: const Offset(0, 1),
              end: const Offset(0, 0),
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
            );

        return SlideTransition(
          position: backdropTween,
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 24,
            ),
            alignment: Alignment
                .bottomCenter, // Posisi di bawah layaknya floating menu
            child: KycImageSourcePicker(onSourceSelected: onSourceSelected),
          ),
        );
      },
    );
  }

  @override
  State<KycImageSourcePicker> createState() => _KycImageSourcePickerState();
}

class _KycImageSourcePickerState extends State<KycImageSourcePicker> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50), // Rounded Full Container
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // Sesuai dengan lebar konten internal
        children: [
          // MENU 1: AMBIL FOTO (KAMERA)
          _buildFloatingMenuButton(
            icon: Icons.camera_alt_rounded,
            label: "Ambil Foto",
            backgroundColor: const Color(0xFFE52525), // Merah Khas TAV
            foregroundColor: Colors.white,
            onTap: () {
              Navigator.pop(context);
              widget.onSourceSelected(ImageSource.camera);
            },
          ),
          const SizedBox(width: 12),
          // Divider Estetik Pemisah antar Menu berbentuk Bulat
          Container(height: 24, width: 1.5, color: const Color(0xFFEAEAEA)),
          const SizedBox(width: 12),
          // MENU 2: PILIH ALBUM (GALERI)
          _buildFloatingMenuButton(
            icon: Icons.photo_library_rounded,
            label: "Dari Album",
            backgroundColor: const Color(0xFFF9F9F9),
            foregroundColor: const Color(0xFF222222),
            onTap: () {
              Navigator.pop(context);
              widget.onSourceSelected(ImageSource.gallery);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingMenuButton({
    required IconData icon,
    required String label,
    required Color backgroundColor,
    required Color foregroundColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(
            30,
          ), // Efek tombol kapsul internal
          border: backgroundColor == const Color(0xFFF9F9F9)
              ? Border.all(color: const Color(0xFFEAEAEA), width: 1)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: foregroundColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: foregroundColor,
                fontFamily: 'Montserrat',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
