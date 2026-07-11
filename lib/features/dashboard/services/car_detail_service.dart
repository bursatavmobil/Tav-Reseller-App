import 'package:dio/dio.dart';
import 'package:reseller_app_tav/features/dashboard/services/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CarDetailService {
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

  Future<Map<String, dynamic>> fetchDetailCar(int carId) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString(ApiConfig.tokenKey);

    try {
      final response = await _dio.get(
        'agen/visit-schedule/car/$carId',
        options: Options(
          headers: {if (token != null) 'Authorization': 'Bearer $token'},
        ),
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['text'] ?? 'Gagal memuat detail mobil');
    }
  }
}
