import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String _keyLastActivity = 'last_activity_timestamp';

  // Sesi timeout tetap 1 jam (60 menit * 60 detik * 1000 milidetik)[cite: 11]
  static const int _sessionTimeoutDuration = 60 * 60 * 1000;

  static Future<void> updateLastActivity() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final int now = DateTime.now().millisecondsSinceEpoch;
      await prefs.setInt(_keyLastActivity, now);
      debugPrint('[SESSION MANAGER] Sesi diperbarui pada timestamp: $now');
    } catch (e) {
      debugPrint('[SESSION MANAGER ERROR] Gagal memperbarui aktivitas: $e');
    }
  }

  /// Memeriksa apakah sesi expired berdasarkan waktu ATAU ketiadaan token fisik
  /// Tambahkan parameter [hasToken] yang dikirim dari AuthApiService
  static Future<bool> isSessionExpired(bool hasToken) async {
    try {
      // 💡 PERBAIKAN PRODUCTION 1: Jika token di local storage kosong,
      // sesi HARUS dianggap expired tanpa perlu peduli dengan durasi waktu.
      if (!hasToken) {
        debugPrint(
          '[SESSION MANAGER] Token fisik tidak ditemukan. Sesi Expired.',
        );
        return true;
      }

      final prefs = await SharedPreferences.getInstance();
      final int? lastActivity = prefs.getInt(_keyLastActivity);

      if (lastActivity == null) {
        debugPrint('[SESSION MANAGER] Aktivitas terakhir kosong, perlu login.');
        return true;
      }

      final int currentTime = DateTime.now().millisecondsSinceEpoch;
      final int timeDifference = currentTime - lastActivity;

      // 💡 PERBAIKAN PRODUCTION 2: Antisipasi jika user mengubah jam HP secara manual ke masa lalu
      if (timeDifference < 0) {
        debugPrint(
          '[SESSION MANAGER] Deteksi ketidaksesuaian waktu lokal HP. Sesi direset.',
        );
        return true;
      }

      final bool expired = timeDifference > _sessionTimeoutDuration;
      debugPrint(
        '[SESSION MANAGER] Selisih waktu: ${timeDifference / 1000} detik. Apakah Expired? -> $expired',
      );
      return expired;
    } catch (e) {
      debugPrint(
        '[SESSION MANAGER ERROR] Gagal memeriksa status kedaluwarsa: $e',
      );
      return true;
    }
  }

  static Future<void> clearSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyLastActivity);
      debugPrint('[SESSION MANAGER] Data sesi berhasil dihapus.');
    } catch (e) {
      debugPrint('[SESSION MANAGER ERROR] Gagal menghapus sesi: $e');
    }
  }
}
