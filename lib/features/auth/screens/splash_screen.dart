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
    with SingleTickerProviderStateMixin {
  late AnimationController _floatingController;
  late Animation<double> _floatingAnimation;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();

    _floatingController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _floatingAnimation = Tween<double>(begin: 0.0, end: 12.0).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );

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

  @override
  void dispose() {
    _floatingController.dispose();
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
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 3),

                // Logo Utama
                AnimatedBuilder(
                  animation: _floatingAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _floatingAnimation.value),
                      child: child,
                    );
                  },
                  child: SvgPicture.asset(AppAssets.logoReseller, width: 170),
                ),

                const Spacer(flex: 3),

                // Footer Identitas Perusahaan Elegan
                Padding(
                  padding: const EdgeInsets.only(bottom: 32.0),
                  child: Column(
                    children: [
                      const Text(
                        'PT TAV MOBIL INDONESIA',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 20,
                            height: 1,
                            color: const Color(0xFFD4AF37).withOpacity(0.6),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              'TERBESAR DAN TERPERCAYA',
                              style: TextStyle(
                                color: Color(0xFFD4AF37),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.8,
                              ),
                            ),
                          ),
                          Container(
                            width: 20,
                            height: 1,
                            color: const Color(0xFFD4AF37).withOpacity(0.6),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
