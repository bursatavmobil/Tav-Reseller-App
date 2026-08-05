import 'package:flutter/material.dart';
import 'package:upgrader/upgrader.dart';

class ForceUpgradeDialog extends StatefulWidget {
  final Upgrader upgrader;
  final String version;
  final bool isForceUpdate;

  const ForceUpgradeDialog({
    super.key,
    required this.upgrader,
    required this.version,
    required this.isForceUpdate,
  });

  static void show(
    BuildContext context, {
    required Upgrader upgrader,
    required String version,
    required bool isForceUpdate,
    required VoidCallback onDismissOptional,
  }) {
    showDialog(
      context: context,
      barrierDismissible: !isForceUpdate,
      barrierColor: Colors.black.withOpacity(0.85),
      builder: (_) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 650),
        curve: Curves.bounceOut,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: ForceUpgradeDialog(
              upgrader: upgrader,
              version: version,
              isForceUpdate: isForceUpdate,
            ),
          );
        },
      ),
    ).then((_) {
      if (!isForceUpdate) {
        onDismissOptional();
      }
    });
  }

  @override
  State<ForceUpgradeDialog> createState() => _ForceUpgradeDialogState();
}

class _ForceUpgradeDialogState extends State<ForceUpgradeDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !widget.isForceUpdate,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF151517),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF2C2C2E), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE52525).withOpacity(0.15),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF1F1F23),
                      border: Border.all(
                        color: const Color(
                          0xFFE52525,
                        ).withOpacity(0.3 + (_pulseController.value * 0.4)),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xFFE52525,
                          ).withOpacity(0.1 * _pulseController.value),
                          blurRadius: 15,
                          spreadRadius: _pulseController.value * 4,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: Image.asset(
                        'assets/icons/new_version.webp',
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.system_update_rounded,
                            size: 40,
                            color: Color(0xFFE52525),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Pembaruan Sistem',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: widget.isForceUpdate
                      ? const Color(0xFF3A1212)
                      : const Color(0xFF1F1F23),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: widget.isForceUpdate
                        ? const Color(0xFFE52525).withOpacity(0.4)
                        : const Color(0xFF3A3A3C),
                  ),
                ),
                child: Text(
                  widget.isForceUpdate
                      ? 'Wajib Update • v${widget.version}'
                      : 'Versi Baru • v${widget.version}',
                  style: TextStyle(
                    color: widget.isForceUpdate
                        ? const Color(0xFFFF4545)
                        : const Color(0xFFD4AF37),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.isForceUpdate
                    ? 'Versi aplikasi Anda sudah terlalu usang. Silakan perbarui aplikasi ke versi terbaru untuk terus menggunakan layanan Reseller Partner.'
                    : 'Fitur baru dan peningkatan performa sistem telah tersedia di Play Store. Perbarui aplikasi Anda sekarang.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFA1A1AA),
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              Column(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE52525),
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () => widget.upgrader.sendUserToAppStore(),
                    child: const Text(
                      'Perbarui Sekarang',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (!widget.isForceUpdate) ...[
                    const SizedBox(height: 8),
                    TextButton(
                      style: TextButton.styleFrom(
                        minimumSize: const Size.fromHeight(44),
                        foregroundColor: const Color(0xFFA1A1AA),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Nanti Saja',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 5),
                  Text(
                    '*Sangat di rekomendasikan untuk update sekarang',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight(400),
                      fontSize: 12,
                      color: Colors.amber,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
