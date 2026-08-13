import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:reseller_app_tav/features/dashboard/services/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CarLeasingService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(ApiConfig.tokenKey);
  }

  Future<List<dynamic>> fetchCarLeasing(int carId) async {
    final String? token = await _getToken();
    final String endpoint = 'user/mobil/$carId/leasing';

    debugPrint('Menembak GET CAR LEASING: ${_dio.options.baseUrl}$endpoint');

    try {
      final response = await _dio.get(
        endpoint,
        options: Options(
          headers: {
            if (token != null && token.isNotEmpty)
              'Authorization': 'Bearer $token',
          },
        ),
      );

      final decoded = response.data;
      if (decoded['status'] == true || response.statusCode == 200) {
        return decoded['data'] ?? [];
      } else {
        throw Exception(decoded['text'] ?? 'Gagal mengambil data leasing');
      }
    } on DioException catch (e) {
      debugPrint('========= ERROR DI FETCH CAR LEASING =========');
      if (e.response?.statusCode == 401) {
        throw Exception('Sesi Anda telah berakhir. Silakan masuk kembali.');
      }
      throw Exception(
        e.response?.data['text'] ?? 'Terjadi kesalahan jaringan.',
      );
    }
  }
}
