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
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  bool _obscurePassword = true;
  
  // State untuk mengontrol tampilan form yang aktif
  bool _isLoginView = true; 

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _checkExistingSession();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _checkExistingSession() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.userName != null && mounted) {
        debugPrint(
          '[LOGIN SCREEN] User aktif terdeteksi, navigasi ke MainLayout',
        );
        _navigateToMainLayout();
      }
    });
  }

  Future<void> _handleLogin() async {
    if (!_validateInputs()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.loginUser(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (success && mounted) {
      _navigateToMainLayout();
    }
  }

  bool _validateInputs() {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      AlertManager.show(context, 'Email dan password harus diisi', false);
      return false;
    }
    return true;
  }

  void _navigateToMainLayout() {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const MainLayout()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Consumer<AuthProvider>(
              builder: (context, authProvider, _) {
                if (authProvider.userName != null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) _navigateToMainLayout();
                  });
                }

                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildHeaderSection(),
                          
                          // Gunakan AnimatedSwitcher untuk transisi halus
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder: (child, animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0.0, 0.05),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: child,
                                ),
                              );
                            },
                            child: _isLoginView
                                ? _buildLoginFormSection(key: const ValueKey('login'))
                                : RegisterFormWidget(
                                    key: const ValueKey('register'),
                                    onSuccess: () {
                                      AlertManager.show(
                                        context,
                                        'Registrasi berhasil! Silakan login',
                                        true,
                                      );
                                      // Kembali ke layar login setelah sukses daftar
                                      setState(() => _isLoginView = true);
                                    },
                                    onSwitchToLogin: () {
                                      // Fungsi saat user tap "Masuk di sini"
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
            Image.asset(
              AppAssets.logoTav,
              width: 160,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.directions_car_filled_rounded,
                color: Color(0xFFE52525),
                size: 100,
              ),
            ),
            const SizedBox(height: 12),
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

  // Tambahkan parameter Key untuk keperluan AnimatedSwitcher
  Widget _buildLoginFormSection({Key? key}) {
    return Container(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      decoration: const BoxDecoration(
        color: Color(0xFF121212),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeaderText(),
          const SizedBox(height: 28),
          _buildEmailField(),
          const SizedBox(height: 16),
          _buildPasswordField(),
          const SizedBox(height: 24),
          _buildLoginButton(),
          const SizedBox(height: 16),
          _buildDivider(),
          const SizedBox(height: 16),
          _buildGoogleLoginButton(),
          const SizedBox(height: 16),
          _buildRegisterLink(),
        ],
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

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      style: const TextStyle(color: Colors.white),
      keyboardType: TextInputType.emailAddress,
      decoration: _buildInputDecoration(
        labelText: 'Email',
        hintText: 'Masukkan email Anda',
        icon: Icons.email,
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      style: const TextStyle(color: Colors.white),
      obscureText: _obscurePassword,
      decoration: _buildInputDecoration(
        labelText: 'Password',
        hintText: 'Masukkan password Anda',
        icon: Icons.lock,
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String labelText,
    required String hintText,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      labelStyle: const TextStyle(color: Colors.grey),
      hintStyle: const TextStyle(color: Colors.grey),
      prefixIcon: Icon(icon, color: Colors.grey),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.grey[900],
      border: _buildBorder(Colors.grey[700]!),
      enabledBorder: _buildBorder(Colors.grey[700]!),
      focusedBorder: _buildBorder(const Color(0xFFE52525)),
    );
  }

  OutlineInputBorder _buildBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: color),
    );
  }

  Widget _buildLoginButton() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return SizedBox(
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE52525),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: authProvider.isLoading ? null : _handleLogin,
            child: authProvider.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Masuk',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey[700], thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'atau',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey[700], thickness: 1)),
      ],
    );
  }

  Widget _buildGoogleLoginButton() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
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
            onPressed: authProvider.isLoading ? null : _handleGoogleLogin,
            icon: SizedBox(
              width: 20,
              height: 20,
              child: SvgPicture.asset(
                AppAssets.googleIcon,
                fit: BoxFit.contain,
              ),
            ),
            label: authProvider.isLoading
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
      },
    );
  }

  Future<void> _handleGoogleLogin() async {
    try {
      final authProvider = context.read<AuthProvider>();
      await authProvider.signInWithGoogle();
      if (mounted) {
        AlertManager.show(context, 'Login Berhasil!', true);
      }
    } catch (e) {
      if (mounted) {
        AlertManager.showError(context, e);
      }
    }
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
          // Ubah state menjadi false untuk menampilkan form register
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