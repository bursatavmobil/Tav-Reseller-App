import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:reseller_app_tav/features/dashboard/services/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StockCarService {
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

  Future<Map<String, dynamic>> fetchStockCars({
    int page = 1,
    int perPage = 10,
    String? searchName,
    List<String>? statuses,
  }) async {
    final String? token = await _getToken();

    final Map<String, dynamic> queryParams = {'page': page, 'perpage': perPage};

    if (searchName != null && searchName.isNotEmpty) {
      queryParams['search[name]'] = searchName;
    }

    if (statuses != null && statuses.isNotEmpty) {
      final List<String> cleanStatuses = [];
      for (var status in statuses) {
        if (status.toUpperCase() != 'SEMUA') {
          cleanStatuses.add(status.toUpperCase());
        }
      }

      if (cleanStatuses.isNotEmpty) {
        for (int i = 0; i < cleanStatuses.length; i++) {
          queryParams['filter_multiple_value[status][$i]'] = cleanStatuses[i];
        }
      }
    }

    const String endpoint = 'agen/visit-schedule/car';
    debugPrint(
      'Menembak GET STOCK CARS: ${_dio.options.baseUrl}$endpoint dengan params: $queryParams',
    );

    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParams,
        options: Options(
          headers: {
            if (token != null && token.isNotEmpty)
              'Authorization': 'Bearer $token',
          },
        ),
      );

      return _handleResponse(response);
    } on DioException catch (e) {
      debugPrint('========= ERROR DI FETCH STOCK CARS =========');
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
    if (decoded['status'] == true || response.statusCode == 200) {
      return decoded is Map<String, dynamic> ? decoded : {'data': decoded};
    } else {
      throw Exception(decoded['text'] ?? 'Terjadi kesalahan server');
    }
  }
}
