import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:reseller_app_tav/features/dashboard/services/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InfoKomisiService {
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

  Future<Map<String, dynamic>> fetchInfoKomisi() async {
    final String? token = await _getToken();
    final String endpoint = 'agen/visit-schedule/estimasi-komisi';

    debugPrint('Fetching Info Komisi : ${_dio.options.baseUrl}$endpoint');

    try {
      final response = await _dio.get(
        endpoint,
        options: Options(
          headers: {
            if (token != null && token.isNotEmpty)
              'Authorization': 'Bearer $token',
          },
          validateStatus: (status) => status == 200 || status == 404,
        ),
      );
      if (response.statusCode == 404) {
        debugPrint('[info komisi service] 404');

        return {
          "status": true,
          "code": "200",
          "text": "success",
          "method": "estimasiKomisi",
          "data": {"cash": 0, "kredit_batas_bawah": 0, "kredit_batas_atas": 0},
          "meta": null,
        };
      }
      return _handleResponse(response);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Sesi Anda telah berakhir. Silakan masuk kembali.');
      }
      throw Exception(
        e.response?.data['text'] ?? 'Terjadi kesalahan jaringan.',
      );
    }
  }

  Map<String, dynamic> _handleResponse(Response response) {
    final decoded = response.data;
    if (decoded['status'] == true ||
        response.statusCode == 200 ||
        response.statusCode == 201) {
      return decoded is Map<String, dynamic> ? decoded : {'data': decoded};
    } else {
      throw Exception(decoded['text'] ?? 'Terjadi kesalahan server');
    }
  }
}
