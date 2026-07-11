import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:reseller_app_tav/features/dashboard/services/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SaldoService {
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

  static const String _tokenKey = 'auth_token';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<Map<String, dynamic>> fetchRiwayatKomisi({
    int page = 1,
    int perPage = 10,
  }) async {
    final String? token = await _getToken();
    final String endpoint =
        'agen/saldo/riwayat-komisi?page=$page&perpage=$perPage';

    debugPrint('Menembak GET RIWAYAT KOMISI: ${_dio.options.baseUrl}$endpoint');

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
        debugPrint(
          '[SALDO SERVICE] Riwayat Komisi 404. Mengembalikan JSON tiruan sukses kosong.',
        );
        return {
          "status": true,
          "code": "200",
          "text": "success",
          "method": "index",
          "data": {
            "total_data": 0,
            "per_page": perPage,
            "current_page": page,
            "last_page": 1,
            "next_page_url": "",
            "result": [],
          },
          "meta": null,
        };
      }

      return _handleResponse(response);
    } on DioException catch (e) {
      debugPrint('========= ERROR DI FETCH RIWAYAT KOMISI =========');
      if (e.response?.statusCode == 401) {
        throw Exception('Sesi Anda telah berakhir. Silakan masuk kembali.');
      }
      throw Exception(
        e.response?.data['text'] ?? 'Terjadi kesalahan jaringan.',
      );
    }
  }

  Future<Map<String, dynamic>> fetchRiwayatPenarikan({
    int page = 1,
    int perPage = 10,
    List<String> statuses = const ['sukses', 'diajukan'],
  }) async {
    final String? token = await _getToken();
    final List<String> querySegments = ['page=$page', 'perpage=$perPage'];

    for (var status in statuses) {
      querySegments.add(
        'filter_multiple_value[status][]=${Uri.encodeComponent(status)}',
      );
    }

    final String queryString = querySegments.join('&');
    final String endpoint = 'agen/saldo/penarikan?$queryString';

    debugPrint(
      'Menembak GET RIWAYAT PENARIKAN: ${_dio.options.baseUrl}$endpoint',
    );

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
        debugPrint(
          '[SALDO SERVICE] Riwayat Penarikan 404. Mengembalikan JSON tiruan sukses kosong.',
        );
        return {
          "status": true,
          "code": "200",
          "text": "success",
          "method": "index",
          "data": {
            "total_data": 0,
            "per_page": perPage,
            "current_page": page,
            "last_page": 1,
            "next_page_url": "",
            "result": [],
          },
          "meta": null,
        };
      }

      return _handleResponse(response);
    } on DioException catch (e) {
      debugPrint('========= ERROR DI FETCH PENARIKAN SALDO =========');
      if (e.response?.statusCode == 401) {
        throw Exception('Sesi Anda telah berakhir. Silakan masuk kembali.');
      }
      throw Exception(
        e.response?.data['text'] ?? 'Terjadi kesalahan jaringan.',
      );
    }
  }

  Future<Map<String, dynamic>> createPenarikan(int nominal) async {
    final String? token = await _getToken();
    const String endpoint = 'agen/saldo/penarikan';

    try {
      final response = await _dio.post(
        endpoint,
        data: {'nominal': nominal},
        options: Options(
          headers: {
            if (token != null && token.isNotEmpty)
              'Authorization': 'Bearer $token',
          },
        ),
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      debugPrint('========= ERROR DI CREATE PENARIKAN =========');
      throw Exception(
        e.response?.data['text'] ?? 'Gagal memproses penarikan saldo.',
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
