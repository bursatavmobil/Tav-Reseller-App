import 'package:dio/dio.dart';
import 'package:reseller_app_tav/features/dashboard/services/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VisitScheduleService {
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

  Future<Map<String, dynamic>> fetchVisitSchedules({
    int page = 1,
    int perPage = 10,
  }) async {
    final String? token = await _getToken();
    final String endpoint = 'agen/visit-schedule?perpage=$perPage&page=$page';

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
        return {
          "status": true,
          "data": {
            "total_data": 0,
            "per_page": perPage,
            "current_page": page,
            "last_page": 1,
            "result": [],
          },
        };
      }
      return response.data;
    } catch (e) {
      throw Exception('Gagal memuat jadwal kunjungan.');
    }
  }

  Future<Map<String, dynamic>> fetchCounterStatus() async {
    final String? token = await _getToken();
    const String endpoint = 'agen/visit-schedule/counter-status-visit';

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
        return {
          "status": true,
          "data": {"aktif": 0, "batal": 0, "selesai": 0},
        };
      }
      return response.data;
    } catch (e) {
      return {
        "status": true,
        "data": {"aktif": 0, "batal": 0, "selesai": 0},
      };
    }
  }

  Future<Map<String, dynamic>> upsertVisitSchedule({
    int? id,
    required int carId,
    required String tipe,
    required String namaKonsumen,
    required String tanggal,
    required String jam,
    required String catatan,
  }) async {
    final String? token = await _getToken();
    const String endpoint = 'agen/visit-schedule';

    final Map<String, dynamic> body = {
      if (id != null) "id": id,
      "car_id": carId,
      "tipe": tipe,
      "nama_konsumen": namaKonsumen,
      "tanggal": tanggal,
      "jam": jam,
      "catatan": catatan,
    };

    try {
      final response = await _dio.post(
        endpoint,
        data: body,
        options: Options(
          headers: {
            if (token != null && token.isNotEmpty)
              'Authorization': 'Bearer $token',
          },
        ),
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['text'] ?? 'Gagal menyimpan jadwal kunjungan.',
      );
    }
  }

  Future<bool> cancelSchedule(int id) async {
    final String? token = await _getToken();
    final String endpoint = 'agen/visit-schedule/$id/cancel';

    try {
      final response = await _dio.put(
        endpoint,
        options: Options(
          headers: {
            if (token != null && token.isNotEmpty)
              'Authorization': 'Bearer $token',
          },
        ),
      );
      return response.data['status'] == true;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['text'] ?? 'Gagal membatalkan kunjungan.',
      );
    }
  }
}
