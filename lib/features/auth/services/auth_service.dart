import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:reseller_app_tav/features/dashboard/services/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthApiService {
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

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    debugPrint('[AUTH SERVICE] Token berhasil disimpan di SharedPreferences.');
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString(_tokenKey);
    debugPrint('[AUTH SERVICE] Mengambil token dari SharedPreferences: $token');
    return token;
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    debugPrint('[AUTH SERVICE] Token berhasil dihapus dari SharedPreferences.');
  }

  Future<Map<String, dynamic>> verifyToken(String tokenValue) async {
    const String endpoint = 'agen/auth/verify-token';
    debugPrint(
      '[AUTH SERVICE] Menembak POST -> ${_dio.options.baseUrl}$endpoint',
    );
    debugPrint('[AUTH SERVICE] Body Token: $tokenValue');

    try {
      final response = await _dio.post(
        endpoint,
        data: {'token': tokenValue},
        options: Options(headers: {'Authorization': 'Bearer $tokenValue'}),
      );

      debugPrint('[AUTH SERVICE] Response Status Code: ${response.statusCode}');
      debugPrint('[AUTH SERVICE] Response Data: ${response.data}');

      return _handleResponse(response);
    } on DioException catch (e) {
      debugPrint('==================================================');
      debugPrint('[AUTH SERVICE ERROR] Terjadi Kendala di verifyToken');
      debugPrint('Dio Error Message: ${e.message}');
      debugPrint('Dio Error Data: ${e.response?.data}');
      debugPrint('==================================================');

      if (e.response?.statusCode == 401) {
        await clearToken();
        throw Exception('Sesi Anda telah berakhir. Silakan masuk kembali.');
      }

      throw Exception(
        e.response?.data['text'] ??
            'Terjadi kesalahan verifikasi token backend.',
      );
    }
  }

  Future<Map<String, dynamic>> registerUser({
    required String name,
    required String email,
    required String password,
    required String repeatPassword,
  }) async {
    const String endpoint = 'agen/auth/register';

    debugPrint(
      '[AUTH SERVICE] Menembak POST -> ${_dio.options.baseUrl}$endpoint',
    );

    if (password != repeatPassword) {
      throw Exception('Password dan konfirmasi password tidak cocok.');
    }

    try {
      final response = await _dio.post(
        endpoint,
        data: {
          'name': name,
          'email': email,
          'password': password,
          'repeat_pasword': repeatPassword,
        },
      );

      debugPrint('[AUTH SERVICE] Response Status Code: ${response.statusCode}');
      debugPrint('[AUTH SERVICE] Response Data: ${response.data}');

      final result = _handleResponse(response);

      // Jika ada token, simpan token
      if (result['data'] != null && result['data']['token'] != null) {
        await saveToken(result['data']['token']);
      }

      return result;
    } on DioException catch (e) {
      debugPrint('==================================================');
      debugPrint('[AUTH SERVICE ERROR] Terjadi Kendala di registerUser');
      debugPrint('Dio Error Message: ${e.message}');
      debugPrint('Dio Error Data: ${e.response?.data}');
      debugPrint('==================================================');

      throw Exception(
        e.response?.data['message'] ??
            e.response?.data['text'] ??
            'Terjadi kesalahan pada server. Silakan coba lagi.',
      );
    }
  }

  Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    const String endpoint = 'agen/auth/login';

    debugPrint(
      '[AUTH SERVICE] Menembak POST -> ${_dio.options.baseUrl}$endpoint',
    );

    if (email.isEmpty || password.isEmpty) {
      throw Exception('Email dan password harus diisi.');
    }

    try {
      final response = await _dio.post(
        endpoint,
        data: {'email': email, 'password': password},
      );

      debugPrint('[AUTH SERVICE] Response Status Code: ${response.statusCode}');
      debugPrint('[AUTH SERVICE] Response Data: ${response.data}');

      final result = _handleResponse(response);

      // Simpan token dari response
      if (result['data'] != null && result['data']['token'] != null) {
        await saveToken(result['data']['token']);
        debugPrint('[AUTH SERVICE] Token login berhasil disimpan.');
      }

      return result;
    } on DioException catch (e) {
      debugPrint('==================================================');
      debugPrint('[AUTH SERVICE ERROR] Terjadi Kendala di loginUser');
      debugPrint('Dio Error Message: ${e.message}');
      debugPrint('Dio Error Data: ${e.response?.data}');
      debugPrint('==================================================');

      if (e.response?.statusCode == ("401")) {
        throw Exception('Email atau password salah.');
      }

      throw Exception(
        e.response?.data['message'] ??
            e.response?.data['text'] ??
            'Terjadi kesalahan pada server. Silakan coba lagi.',
      );
    }
  }

  // Future<Map<String, dynamic>> fetchRiwayatPenarikan({
  //   int page = 1,
  //   int perPage = 10,
  //   List<String> statuses = const ['sukses', 'diajukan'],
  // }) async {
  //   const String endpoint = 'agen/riwayat-penarikan';
  //   final String? token = await getToken();

  //   try {
  //     final response = await _dio.post(
  //       endpoint,
  //       data: {'page': page, 'per_page': perPage, 'status': statuses},
  //       options: Options(
  //         headers: {
  //           if (token != null && token.isNotEmpty)
  //             'Authorization': 'Bearer $token',
  //         },

  //         validateStatus: (status) => status == 200 || status == 404,
  //       ),
  //     );

  //     if (response.statusCode == 404) {
  //       debugPrint(
  //         '[AUTH SERVICE] Menjinakkan 404 penarikan menjadi data sukses kosong.',
  //       );
  //       return {
  //         "status": true,
  //         "code": "200",
  //         "text": "success",
  //         "method": "index",
  //         "data": {
  //           "total_data": 0,
  //           "per_page": perPage,
  //           "current_page": page,
  //           "last_page": 1,
  //           "next_page_url": "",
  //           "result": [],
  //         },
  //         "meta": null,
  //       };
  //     }

  //     return _handleResponse(response);
  //   } on DioException catch (e) {
  //     debugPrint(
  //       '[AUTH SERVICE ERROR] Gagal mengambil riwayat penarikan: ${e.message}',
  //     );
  //     final customErrorMessage =
  //         e.response?.data['text'] ??
  //         'Gagal memuat riwayat penarikan dari server.';
  //     throw Exception(customErrorMessage);
  //   }
  // }

  Map<String, dynamic> _handleResponse(Response response) {
    final decoded = response.data;
    debugPrint('[AUTH SERVICE] Handling response data: $decoded');

    if (decoded['status'] == true ||
        response.statusCode == 200 ||
        response.statusCode == 201) {
      return decoded is Map<String, dynamic> ? decoded : {'data': decoded};
    } else {
      throw Exception(decoded['text'] ?? 'Terjadi kesalahan server');
    }
  }
}
