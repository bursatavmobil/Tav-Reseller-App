import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reseller_app_tav/core/widget/alert_manager.dart'; // Import AlertManager Anda
import 'package:reseller_app_tav/features/auth/providers/auth_provider.dart';

class RegisterFormWidget extends StatefulWidget {
  final VoidCallback? onSuccess;
  final VoidCallback? onSwitchToLogin;

  const RegisterFormWidget({
    super.key,
    this.onSuccess,
    this.onSwitchToLogin,
  });

  @override
  State<RegisterFormWidget> createState() => _RegisterFormWidgetState();
}

class _RegisterFormWidgetState extends State<RegisterFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _repeatPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureRepeatPassword = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: const BoxDecoration(
        color: Color(0xFF121212),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Daftar Akun Baru",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Montserrat',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                "Buat akun untuk mulai mengelola penjualan Anda",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                  height: 1.5,
                  fontFamily: 'Montserrat',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),

              // ... [KODE TEXTFIELD NAMA, EMAIL, PASSWORD SAMA SEPERTI SEBELUMNYA] ...
              // Agar tidak terlalu panjang, bagian input field saya singkat
              // Pastikan Anda tetap memasukkan field _nameController, _emailController, dsb di sini.
              _buildNameField(),
              const SizedBox(height: 16),
              _buildEmailField(),
              const SizedBox(height: 16),
              _buildPasswordField(),
              const SizedBox(height: 16),
              _buildRepeatPasswordField(),
              const SizedBox(height: 28),

              // Register Button
              Consumer<AuthProvider>(
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
                      onPressed: authProvider.isLoading ? null : _handleRegister,
                      child: authProvider.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text(
                              'Daftar',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Sudah punya akun link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Sudah punya akun? ',
                    style: TextStyle(color: Colors.grey),
                  ),
                  GestureDetector(
                    // Gunakan fungsi switch yang dilempar dari LoginScreen
                    onTap: widget.onSwitchToLogin, 
                    child: const Text(
                      'Masuk di sini',
                      style: TextStyle(
                        color: Color(0xFFE52525),
                        fontWeight: FontWeight.bold,
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
  }

  // --- WIDGET TEXTFIELD ---
  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      style: const TextStyle(color: Colors.white),
      decoration: _buildInputDeco('Nama Lengkap', 'Masukkan nama lengkap', Icons.person),
      validator: (val) => val?.isEmpty == true ? 'Nama harus diisi' : null,
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      style: const TextStyle(color: Colors.white),
      keyboardType: TextInputType.emailAddress,
      decoration: _buildInputDeco('Email', 'Masukkan email', Icons.email),
      validator: (val) {
        if (val?.isEmpty == true) return 'Email harus diisi';
        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(val!)) return 'Email tidak valid';
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      style: const TextStyle(color: Colors.white),
      obscureText: _obscurePassword,
      decoration: _buildInputDeco('Password', 'Masukkan password', Icons.lock).copyWith(
        suffixIcon: IconButton(
          icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
      ),
      validator: (val) {
        if (val?.isEmpty == true) return 'Password harus diisi';
        if (val!.length < 6) return 'Minimal 6 karakter';
        return null;
      },
    );
  }

  Widget _buildRepeatPasswordField() {
    return TextFormField(
      controller: _repeatPasswordController,
      style: const TextStyle(color: Colors.white),
      obscureText: _obscureRepeatPassword,
      decoration: _buildInputDeco('Konfirmasi Password', 'Ulangi password', Icons.lock).copyWith(
        suffixIcon: IconButton(
          icon: Icon(_obscureRepeatPassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
          onPressed: () => setState(() => _obscureRepeatPassword = !_obscureRepeatPassword),
        ),
      ),
      validator: (val) {
        if (val?.isEmpty == true) return 'Konfirmasi password harus diisi';
        if (val != _passwordController.text) return 'Password tidak cocok';
        return null;
      },
    );
  }

  InputDecoration _buildInputDeco(String label, String hint, IconData icon) {
    return InputDecoration(
      labelText: label, hintText: hint,
      labelStyle: const TextStyle(color: Colors.grey),
      hintStyle: const TextStyle(color: Colors.grey),
      prefixIcon: Icon(icon, color: Colors.grey),
      filled: true, fillColor: Colors.grey[900],
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey[700]!)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey[700]!)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE52525))),
    );
  }

  // --- LOGIC UTAMA REGISTER YANG DIPERBAIKI ---
  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    
    // BUNGKUS DENGAN TRY-CATCH
    try {
      final success = await authProvider.registerUser(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        repeatPassword: _repeatPasswordController.text,
      );

      if (mounted) {
        if (success) {
          // Panggil fungsi sukses (akan dikelola oleh LoginScreen)
          widget.onSuccess?.call();
        } else {
          // Jika tidak masuk catch, tapi return false
          AlertManager.show(context, 'Registrasi gagal, periksa data Anda.', false);
        }
      }
    } catch (e) {
      if (mounted) {
        // TAMPILKAN ERROR (Teks "Exception: gagal..." akan dibersihkan oleh AlertManager Anda)
        AlertManager.showError(context, e);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _repeatPasswordController.dispose();
    super.dispose();
  }
}