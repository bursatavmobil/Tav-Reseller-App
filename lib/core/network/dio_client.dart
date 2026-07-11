import 'package:dio/dio.dart';

class DioClient {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://xbc.tavmobil.co.id/api',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  Dio get dio => _dio;

  //AUTH :
  static const String googleAuthEndpoint = '/v1/agen/auth/google';
  static const String googleCallbackEndpoint = '/v1/agen/auth/google-callback';
}