import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:reseller_app_tav/core/network/dummy_header_token.dart';
import 'package:reseller_app_tav/core/service/session_manager.dart';
import 'package:reseller_app_tav/core/widget/alert_manager.dart';
import 'package:reseller_app_tav/features/auth/services/auth_service.dart';
import 'package:reseller_app_tav/features/dashboard/models/profile_response_model.dart';
import 'package:reseller_app_tav/features/dashboard/widgets/profile/kyc_getkeeper_modal.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _userName;
  String? _userPhotoUrl;
  String? get userName => _userName;
  String? get userPhotoUrl => _userPhotoUrl;

  final AuthApiService _apiService = AuthApiService();

  StreamSubscription<GoogleSignInAuthenticationEvent>? _authEventsSub;

  static const String _webClientId = String.fromEnvironment(
    'CLIENT_ID',
    defaultValue: '',
  );

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  AuthProvider() {
    _initializeGoogleSignIn();
  }

  void _initializeGoogleSignIn() {
    unawaited(
      _googleSignIn
          .initialize(clientId: _webClientId, serverClientId: _webClientId)
          .then((_) {
            _authEventsSub = _googleSignIn.authenticationEvents.listen(
              _handleAuthenticationEvent,
              onError: (error) {
                debugPrint(
                  '[AUTH PROVIDER ERROR] Google Auth Stream Event: $error',
                );
                _setLoading(false);
              },
            );
            _googleSignIn.attemptLightweightAuthentication();
          }),
    );
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<bool> checkExistingSession() async {
    _setLoading(true);
    try {
      final bool isExpired = await SessionManager.isSessionExpired();
      if (isExpired) {
        debugPrint('[AUTH PROVIDER] Sesi lokal terdeteksi expired.');
        await logout();
        return false;
      }

      final String? token = await _apiService.getToken();
      if (token == null || token.isEmpty) {
        _setLoading(false);
        return false;
      }

      final response = await _apiService.verifyToken(token);
      if (response['status'] == true) {
        final userData = response['data'];
        _userName = userData?['name'] ?? 'Reseller Partner';
        _userPhotoUrl = userData?['gavatar'];

        await SessionManager.updateLastActivity();
        _setLoading(false);
        return true;
      }

      _setLoading(false);
      return false;
    } catch (e) {
      debugPrint('[AUTH PROVIDER ERROR] Gagal verifikasi sesi backend: $e');
      await _apiService.clearToken();
      await SessionManager.clearSession();
      _setLoading(false);
      return false;
    }
  }

  String _parseGoogleSignInError(dynamic error) {
    final String errorString = error.toString().toLowerCase();

    if (errorString.contains('canceled') || errorString.contains('12501')) {
      return 'Proses masuk dibatalkan.';
    } else if (errorString.contains('account reauth failed') ||
        errorString.contains('status code 16') ||
        errorString.contains('[16]')) {
      return 'Gagal memverifikasi akun Google. Mohon pastikan sertifikat SHA-1 Release sudah terdaftar di Firebase/Google Cloud.';
    } else if (errorString.contains('network_error') ||
        errorString.contains('7')) {
      return 'Koneksi internet bermasalah. Periksa jaringan Anda dan coba lagi.';
    } else if (errorString.contains('developer_error') ||
        errorString.contains('10')) {
      return 'Terjadi kesalahan konfigurasi sistem aplikasi (SHA-1/Client ID). Mohon hubungi bantuan.';
    }

    return 'Gagal masuk dengan Google. Silakan coba beberapa saat lagi.';
  }

  Future<void> _handleAuthenticationEvent(
    GoogleSignInAuthenticationEvent event,
  ) async {
    final GoogleSignInAccount? user = switch (event) {
      GoogleSignInAuthenticationEventSignIn() => event.user,
      GoogleSignInAuthenticationEventSignOut() => null,
    };

    if (user != null) {
      _setLoading(true);
      try {
        final GoogleSignInAuthentication auth = await user.authentication;
        final String? idToken = auth.idToken;

        if (idToken == null) {
          throw Exception('Google ID Token tidak ditemukan.');
        }

        final response = await _apiService.verifyToken(idToken);

        final String? appToken = response != null
            ? (response['token'] ?? response['data']?['token'])
            : null;

        if (appToken != null) {
          await _apiService.saveToken(appToken);
          await SessionManager.updateLastActivity();

          _userName =
              user.displayName ??
              response['data']?['name'] ??
              'Reseller Partner';
          _userPhotoUrl = user.photoUrl ?? response['data']?['gavatar'];

          triggerAlert('Selamat datang kembali, $_userName!', true);
          notifyListeners();
        } else {
          final serverMessage =
              response?['message'] ??
              'Gagal mengekstrak Application Token dari server.';
          throw Exception(serverMessage);
        }
      } catch (e) {
        debugPrint('[AUTH PROVIDER ERROR] Proses pertukaran token gagal: $e');
        await logout();

        final friendlyMessage = _parseGoogleSignInError(e);
        triggerAlert(friendlyMessage, false);
      } finally {
        _setLoading(false);
      }
    } else {
      _userName = null;
      _userPhotoUrl = null;
      notifyListeners();
    }
  }

  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    try {
      if (_googleSignIn.supportsAuthenticate()) {
        await _googleSignIn.authenticate();

        _setLoading(false);
        return true;
      } else {
        throw Exception(
          'Platform ini tidak mendukung metode otentikasi yang dikenal.',
        );
      }
    } catch (e) {
      debugPrint('[AUTH PROVIDER ERROR] Gagal memicu authenticate(): $e');
      _setLoading(false);

      final friendlyMessage = _parseGoogleSignInError(e);
      triggerAlert(friendlyMessage, false);

      return false;
    }
  }

  Future<bool> loginWithDummyToken() async {
    _setLoading(true);
    try {
      debugPrint('========= BYPASS AUTH: MENGGUNAKAN DUMMY TOKEN =========');
      final String token = HeaderAuthDummy.dummyToken;

      if (token.isEmpty || token.startsWith('TEMPEL_')) {
        throw Exception(
          'Token dummy belum diisi dengan benar di file header_auth_dummy.dart',
        );
      }

      await _apiService.saveToken(token);
      await SessionManager.updateLastActivity();

      _userName = "Reseller Terotentikasi (Dummy)";
      _userPhotoUrl =
          "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=150";

      _setLoading(false);
      return true;
    } catch (e) {
      debugPrint('[AUTH PROVIDER ERROR] Gagal Bypass Dummy: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> registerUser({
    required String name,
    required String email,
    required String password,
    required String repeatPassword,
  }) async {
    _setLoading(true);
    try {
      final response = await _apiService.registerUser(
        name: name,
        email: email,
        password: password,
        repeatPassword: repeatPassword,
      );

      if (response['status'] == true) {
        final userData = response['data'];
        _userName = userData?['name'] ?? 'Reseller Partner';
        _userPhotoUrl = userData?['gavatar'];

        await SessionManager.updateLastActivity();

        debugPrint(
          '[AUTH PROVIDER] Register berhasil untuk: ${userData?['email']}',
        );
        triggerAlert(
          'Registrasi berhasil! Selamat datang ${userData?['name']}',
          true,
        );

        _setLoading(false);
        return true;
      }

      _setLoading(false);
      return false;
    } catch (e) {
      debugPrint('[AUTH PROVIDER ERROR] Gagal register: $e');
      triggerAlert('Gagal Registrasi: ${e.toString()}', false);
      _setLoading(false);
      return false;
    }
  }

  Future<bool> loginUser({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    try {
      final response = await _apiService.loginUser(
        email: email,
        password: password,
      );

      if (response['status'] == true) {
        final userData = response['data'];
        _userName = userData?['name'] ?? 'Reseller Partner';
        _userPhotoUrl = userData?['gavatar'];

        await SessionManager.updateLastActivity();

        debugPrint(
          '[AUTH PROVIDER] Login berhasil untuk: ${userData?['email']}',
        );
        triggerAlert(
          'Login berhasil! Selamat datang ${userData?['name']}',
          true,
        );

        _setLoading(false);
        return true;
      }

      _setLoading(false);
      return false;
    } catch (e) {
      debugPrint('[AUTH PROVIDER ERROR] Gagal login: $e');
      triggerAlert('Gagal Login: ${e.toString()}', false);
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      await _apiService.clearToken();
      await SessionManager.clearSession();

      await _googleSignIn.disconnect();
    } catch (e) {
      debugPrint(
        '[AUTH PROVIDER ERROR] Gagal membersihkan sesi google client: $e',
      );
    } finally {
      _userName = null;
      _userPhotoUrl = null;
      _setLoading(false);
    }
  }

  void verifyKycStatus(
    BuildContext context, {
    required ProfileData profile,
    required VoidCallback onRefreshData,
  }) {
    Future.microtask(() {
      if (!context.mounted) return;

      KycGatekeeperModal.checkAndShow(
        context,
        profile,
        onKycSuccess: () {
          debugPrint(
            '[GLOBAL PROVIDER] Callback onKycSuccess terpicu! Menyegarkan data...',
          );
          SessionManager.updateLastActivity();
          onRefreshData();
        },
      );
    });
  }

  void triggerAlert(String message, bool isSuccess) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      AlertManager.show(context, message, isSuccess);
    }
  }

  @override
  void dispose() {
    _authEventsSub?.cancel();
    super.dispose();
  }
}
