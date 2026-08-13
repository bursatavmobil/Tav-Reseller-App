import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:reseller_app_tav/core/theme/app_assets.dart';
import 'package:reseller_app_tav/features/auth/providers/auth_provider.dart';
import 'package:reseller_app_tav/features/auth/screens/login_screen.dart';
import 'package:reseller_app_tav/features/auth/screens/widget/force_upgrade_widget.dart';
import 'package:reseller_app_tav/features/dashboard/screens/main_layout.dart';
import 'package:upgrader/upgrader.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _floatingController;
  late AnimationController _loadingController;
  late Animation<double> _floatingAnimation;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();

    _floatingController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _floatingAnimation = Tween<double>(begin: 0.0, end: 15.0).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );

    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _navigateToNextRoute();
  }

  Future<void> _navigateToNextRoute() async {
    await Future.delayed(const Duration(milliseconds: 2000));
    if (!mounted) return;

    
    final upgrader = Upgrader(
      debugDisplayAlways: false,
      debugLogging: true,
      minAppVersion: '1.0.8',
    );

    await upgrader.initialize();

    if (upgrader.shouldDisplayUpgrade()) {
      debugPrint(
        '[SPLASH SCREEN] Terdeteksi versi baru di Store! Menampilkan Dialog Update.',
      );
      if (!mounted) return;

      ForceUpgradeDialog.show(
        context,
        upgrader: upgrader,
        version: upgrader.currentAppStoreVersion ?? '1.0.8',
        isForceUpdate: upgrader.belowMinAppVersion(),
        onDismissOptional: () {
          _executeSessionNavigation();
        },
      );
      return;
    }

    _executeSessionNavigation();
  }

  Future<void> _executeSessionNavigation() async {
    if (_isNavigating) return;
    _isNavigating = true;

    final authProvider = context.read<AuthProvider>();
    final bool hasValidSession = await authProvider.checkExistingSession();

    if (hasValidSession) {
      debugPrint('[SPLASH SCREEN] Sesi Valid! Mengarah ke MainLayout.');
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainLayout()),
          (route) => false,
        );
      }
    } else {
      debugPrint(
        '[SPLASH SCREEN] Sesi Kosong/Expired! Mengarah ke LoginScreen.',
      );
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  void _showCustomUpgradeDialog(
    BuildContext context, {
    required Upgrader upgrader,
    required String version,
    required bool isForceUpdate,
  }) {
    showDialog(
      context: context,
      barrierDismissible: !isForceUpdate,
      builder: (context) {
        return PopScope(
          canPop: !isForceUpdate,
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.system_update_rounded,
                    size: 50,
                    color: Color(0xFFE52525),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Pembaruan Aplikasi!',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Versi $version telah tersedia di Play Store. Silakan lakukan pembaruan untuk menikmati fitur terbaru.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      if (!isForceUpdate) ...[
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.black),
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              _proceedToNextRouteAfterDismiss();
                            },
                            child: const Text(
                              'Nanti',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            upgrader.sendUserToAppStore();
                          },
                          child: const Text(
                            'Update',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _proceedToNextRouteAfterDismiss() async {
    final authProvider = context.read<AuthProvider>();
    final bool hasValidSession = await authProvider.checkExistingSession();
    if (!mounted) return;

    if (hasValidSession) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainLayout()),
        (route) => false,
      );
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  void dispose() {
    _floatingController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.2,
                  colors: [Color(0xFF1F0505), Colors.black],
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                AnimatedBuilder(
                  animation: _floatingAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _floatingAnimation.value),
                      child: child,
                    );
                  },
                  child: SvgPicture.asset(AppAssets.logoReseller, width: 160),
                ),

                const Spacer(flex: 1),

                AnimatedBuilder(
                  animation: _loadingController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _loadingController.value * 2 * math.pi,
                      child: child,
                    );
                  },
                  child: CustomPaint(
                    size: const Size(42, 42),
                    painter: CustomLoadingPainter(),
                  ),
                ),

                const Spacer(flex: 1),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CustomLoadingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const double strokeWidth = 3.5;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final bgPaint = Paint()
      ..color = const Color(0xFF222222)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, bgPaint);

    final activePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = const SweepGradient(
        colors: [Color(0xFFE52525), Color(0xFFD4AF37), Color(0xFFE52525)],
        stops: [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0,
      math.pi * 1.5,
      false,
      activePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
