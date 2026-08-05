import 'dart:ui'; // Efek BackdropFilter

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:reseller_app_tav/core/theme/app_assets.dart';
import 'package:reseller_app_tav/core/widget/alert_manager.dart';
import 'package:reseller_app_tav/features/auth/providers/auth_provider.dart';
import 'package:reseller_app_tav/features/auth/screens/widget/register_form_widget.dart';
import 'package:reseller_app_tav/features/dashboard/screens/main_layout.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // ===========================================================================
  // [TAG - LOGIN MANUAL] STATE & CONTROLLER DISEMBUNYIKAN
  // ===========================================================================

  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  bool _obscurePassword = true;
  bool _isManualLoading = false;

  bool _isLoginView = true;
  bool _isGoogleLoading = false;

  @override
  void initState() {
    super.initState();
    // ===========================================================================
    // [TAG - LOGIN MANUAL] INISIALISASI CONTROLLER DISEMBUNYIKAN
    // ===========================================================================

    _emailController = TextEditingController();
    _passwordController = TextEditingController();

    _checkExistingSession();
  }

  void _checkExistingSession() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.userName != null && mounted) {
        _navigateToMainLayout();
      }
    });
  }

  // ===========================================================================
  // [TAG - LOGIN MANUAL] PROSES OTENTIKASI EMAIL PASSWORD DISEMBUNYIKAN
  // ===========================================================================
  Future<void> _handleLogin() async {
    if (!_validateInputs()) return;

    setState(() {
      _isManualLoading = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.loginUser(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (success && mounted) {
        AlertManager.show(context, 'Login Berhasil!', true);
        _navigateToMainLayout();
      } else {
        if (mounted) {
          AlertManager.show(
            context,
            'Gagal masuk. Silakan periksa kredensial Anda.',
            false,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Terjadi kesalahan sistem saat login.';
        if (e is Exception) {
          errorMessage = e.toString().replaceAll('Exception: ', '');
        } else if (e.toString().contains('401')) {
          errorMessage = 'Gagal, periksa kembali email dan password anda';
        }
        AlertManager.show(context, errorMessage, false);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isManualLoading = false;
        });
      }
    }
  }

  bool _validateInputs() {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      AlertManager.show(context, 'Email dan password harus diisi', false);
      return false;
    }
    return true;
  }

  Future<void> _handleGoogleLogin() async {
    setState(() {
      _isGoogleLoading = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final isSuccess = await authProvider.signInWithGoogle();

      if (isSuccess && mounted) {
        AlertManager.show(context, 'Login Berhasil!', true);
        _navigateToMainLayout();
      } else {
        if (mounted) {
          AlertManager.show(context, 'Gagal Masuk, Login Diabatalkan', false);
        }
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Terjadi kesalahan saat masuk dengan Google.';
        if (e is Exception) {
          errorMessage = e.toString().replaceAll('Exception: ', '');
        }
        AlertManager.show(context, errorMessage, false);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGoogleLoading = false;
        });
      }
    }
  }

  void _navigateToMainLayout() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const MainLayout(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.linear),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeaderSection(),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                        child: _isLoginView
                            ? _buildLoginFormSection(
                                key: const ValueKey('login'),
                              )
                            : RegisterFormWidget(
                                key: const ValueKey('register'),
                                onSuccess: () {
                                  AlertManager.show(
                                    context,
                                    'Registrasi berhasil! Silakan login',
                                    true,
                                  );
                                  setState(() => _isLoginView = true);
                                },
                                onSwitchToLogin: () {
                                  setState(() => _isLoginView = true);
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Expanded(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF260808), Colors.black],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            // UKURAN LOGO DIPERBESAR MENJADI 220
            SvgPicture.asset(AppAssets.logoTav, width: 220),
            const SizedBox(height: 16),
            const Text(
              'TAV RESELLER PARTNER',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                fontFamily: 'Montserrat',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginFormSection({Key? key}) {
    // CONTAINER CARD BOTTOM POLYMORPHISM / GLASSMORPHISM (HANYA ROUNDED & BORDER ATAS-KANAN-KIRI)
    return ClipRRect(
      key: key,
      // 🟢 Clip agar efek blur hanya berada pada bagian kartu yang melengkung di atas
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          decoration: ShapeDecoration(
            color: const Color(0xFF121212).withOpacity(0.85),
            // 🟢 ShapeDecoration memungkinkan garis tepi (side) uniform mengikuti bentuk melengkung atas saja
            shape: RoundedRectangleBorder(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
              side: BorderSide(
                color: const Color(0xFFD4AF37).withOpacity(0.35),
                width: 1.0,
              ),
            ),
            shadows: [
              BoxShadow(
                color: const Color(0xFFD4AF37).withOpacity(0.12),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeaderText(),
              const SizedBox(height: 28),

              // ===========================================================================
              // [TAG - LOGIN MANUAL] ELEMENT UI FORM MANUAL DISEMBUNYIKAN
              // ===========================================================================
              // _buildEmailField(),
              // const SizedBox(height: 16),
              // _buildPasswordField(),
              // const SizedBox(height: 24),
              // _buildLoginButton(),
              // const SizedBox(height: 16),
              // _buildDivider(),
              // const SizedBox(height: 16),
              _buildGoogleLoginButton(),
              const SizedBox(height: 16),
              // _buildRegisterLink(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderText() {
    return Column(
      children: const [
        Text(
          'Selamat Datang Kembali',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat',
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8),
        Text(
          'Masuk untuk mengelola inventaris mobil dan melacak komisi penjualan Anda.',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 13,
            height: 1.5,
            fontFamily: 'Montserrat',
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ===========================================================================
  // [TAG - LOGIN MANUAL] WIDGET BUILDER EMAIL & PASSWORD DISEMBUNYIKAN
  // ===========================================================================

  // Widget _buildEmailField() {
  //   return TextFormField(
  //     controller: _emailController,
  //     style: const TextStyle(color: Colors.white),
  //     keyboardType: TextInputType.emailAddress,
  //     decoration: _buildInputDecoration(
  //       labelText: 'Email',
  //       hintText: 'Masukkan email Anda',
  //       icon: Icons.email,
  //     ),
  //   );
  // }

  // Widget _buildPasswordField() {
  //   return TextFormField(
  //     controller: _passwordController,
  //     style: const TextStyle(color: Colors.white),
  //     obscureText: _obscurePassword,
  //     decoration: _buildInputDecoration(
  //       labelText: 'Password',
  //       hintText: 'Masukkan password Anda',
  //       icon: Icons.lock,
  //       suffixIcon: IconButton(
  //         icon: Icon(
  //           _obscurePassword ? Icons.visibility_off : Icons.visibility,
  //           color: Colors.grey,
  //         ),
  //         onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
  //       ),
  //     ),
  //   );
  // }

  // InputDecoration _buildInputDecoration({
  //   required String labelText,
  //   required String hintText,
  //   required IconData icon,
  //   Widget? suffixIcon,
  // }) {
  //   return InputDecoration(
  //     labelText: labelText,
  //     hintText: hintText,
  //     labelStyle: const TextStyle(color: Colors.grey),
  //     hintStyle: const TextStyle(color: Colors.grey),
  //     prefixIcon: Icon(icon, color: Colors.grey),
  //     suffixIcon: suffixIcon,
  //     filled: true,
  //     fillColor: Colors.grey[900],
  //     border: _buildBorder(Colors.grey[700]!),
  //     enabledBorder: _buildBorder(Colors.grey[700]!),
  //     focusedBorder: _buildBorder(const Color(0xFFE52525)),
  //   );
  // }

  // OutlineInputBorder _buildBorder(Color color) {
  //   return OutlineInputBorder(
  //     borderRadius: BorderRadius.circular(10),
  //     borderSide: BorderSide(color: color),
  //   );
  // }

  // Widget _buildLoginButton() {
  //   final anyLoading = false || _isGoogleLoading;
  //   return SizedBox(
  //     height: 52,
  //     child: ElevatedButton(
  //       style: ElevatedButton.styleFrom(
  //         backgroundColor: const Color(0xFFE52525),
  //         foregroundColor: Colors.white,
  //         elevation: 0,
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(10),
  //         ),
  //       ),
  //       onPressed: anyLoading ? null : _handleLogin,
  //       child: false
  //           ? const SizedBox(
  //               height: 20,
  //               width: 20,
  //               child: CircularProgressIndicator(
  //                 strokeWidth: 2.5,
  //                 valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
  //               ),
  //             )
  //           : const Text(
  //               'Masuk',
  //               style: TextStyle(
  //                 fontFamily: 'Montserrat',
  //                 fontWeight: FontWeight.bold,
  //                 fontSize: 16,
  //               ),
  //             ),
  //     ),
  //   );
  // }

  // Widget _buildDivider() {
  //   return Row(
  //     children: [
  //       Expanded(child: Divider(color: Colors.grey[700], thickness: 1)),
  //       Padding(
  //         padding: const EdgeInsets.symmetric(horizontal: 12),
  //         child: Text(
  //           'atau',
  //           style: TextStyle(color: Colors.grey[600], fontSize: 12),
  //         ),
  //       ),
  //       Expanded(child: Divider(color: Colors.grey[700], thickness: 1)),
  //     ],
  //   );
  // }

  Widget _buildGoogleLoginButton() {
    final anyLoading = _isGoogleLoading;
    return SizedBox(
      height: 52,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          side: BorderSide(color: Colors.grey.shade300),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        onPressed: anyLoading ? null : _handleGoogleLogin,
        icon: _isGoogleLoading
            ? const SizedBox()
            : SizedBox(
                width: 20,
                height: 20,
                child: SvgPicture.asset(
                  AppAssets.googleIcon,
                  fit: BoxFit.contain,
                ),
              ),
        label: _isGoogleLoading
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                ),
              )
            : const Text(
                'Masuk dengan Google',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
      ),
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Belum punya akun? ',
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
        GestureDetector(
          onTap: () => setState(() => _isLoginView = false),
          child: const Text(
            'Daftar di sini',
            style: TextStyle(
              color: Color(0xFFE52525),
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}
