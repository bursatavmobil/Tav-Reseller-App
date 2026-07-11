import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String _keyLastActivity = 'last_activity_timestamp';
  static const int _sessionTimeoutDuration =
      60 * 60 * 1000; 
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

  static Future<bool> isSessionExpired() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final int? lastActivity = prefs.getInt(_keyLastActivity);

      if (lastActivity == null) {
        debugPrint(
          '[SESSION MANAGER] Aktivitas terakhir kosong, anggap sesi baru/perlu login.',
        );
        return true;
      }

      final int currentTime = DateTime.now().millisecondsSinceEpoch;
      final int timeDifference = currentTime - lastActivity;

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
