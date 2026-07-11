import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reseller_app_tav/features/auth/providers/auth_provider.dart';
import 'package:reseller_app_tav/features/auth/screens/login_screen.dart';

class SessionExpiredScreen extends StatelessWidget {
  final String errorMessage;

  const SessionExpiredScreen({super.key, required this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon Warning Atensi
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFEAEA),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.gpp_maybe_outlined,
                  color: Color(0xFFE52525),
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Sesi Akses Terbatas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF222222),
                  fontFamily: 'Montserrat',
                ),
              ),
              const SizedBox(height: 12),
              Text(
                errorMessage.isNotEmpty
                    ? errorMessage
                    : 'Untuk menjaga keamanan akun data Anda, sistem mendeteksi masa berlaku token pendaftaran Anda telah berakhir. Silakan lakukan otentikasi masuk kembali.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF666666),
                  fontFamily: 'Montserrat',
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE52525),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () async {
                    await context.read<AuthProvider>().logout();

                    if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                      );
                    }
                  },
                  child: const Text(
                    'Masuk Kembali',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
