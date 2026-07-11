import 'package:dio/dio.dart';
import 'package:reseller_app_tav/features/dashboard/models/negosiasi_chat_response_model.dart';
import 'package:reseller_app_tav/features/dashboard/models/negosiasi_counter_response_model.dart';
import 'package:reseller_app_tav/features/dashboard/models/negosiasi_response_model.dart';
import 'package:reseller_app_tav/features/dashboard/services/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NegotiationService {
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

  // Mendapatkan token untuk otentikasi API header
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<NegotiationResponseModel> getAllNegotiation({
    int page = 1,
    int perPage = 10,
    String? filterSingleStatus,
    List<String>? filterMultipleStatus,
    String? startDate,
    String? endDate,
    String? searchCarOrBidder,
  }) async {
    try {
      final token = await _getToken();

      final Map<String, dynamic> queryParams = {
        'page': page,
        'perpage': perPage,
      };

      if (filterSingleStatus != null && filterSingleStatus.isNotEmpty) {
        queryParams['filter_single_value[status]'] = filterSingleStatus;
      }

      if (filterMultipleStatus != null && filterMultipleStatus.isNotEmpty) {
        queryParams['filter_multiple_value[status][]'] = filterMultipleStatus;
      }

      if (startDate != null && startDate.isNotEmpty) {
        queryParams['filter_date_range[start_date]'] = startDate;
      }
      if (endDate != null && endDate.isNotEmpty) {
        queryParams['filter_date_range[end_date]'] = endDate;
      }

      if (searchCarOrBidder != null && searchCarOrBidder.isNotEmpty) {
        queryParams['search[car_or_bidder]'] = searchCarOrBidder;
      }

      final response = await _dio.get(
        'agen/negotiation',
        queryParameters: queryParams,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return NegotiationResponseModel.fromJson(response.data);
      } else {
        throw Exception(
          response.data['text'] ?? 'Gagal mengambil data negosiasi.',
        );
      }
    } on DioException catch (e) {
      final errorMsg =
          e.response?.data['text'] ?? 'Terjadi kesalahan jaringan.';
      throw Exception(errorMsg);
    }
  }

  Future<Map<String, dynamic>> upsertNegotiation({
    int? id,
    required int carId,
    required String bidder,
    required String bidderPhone,
    required int negotiatedPrice,
    required String paymentType,
  }) async {
    try {
      final token = await _getToken();

      final Map<String, dynamic> body = {
        if (id != null) 'id': id,
        'car_id': carId,
        'bidder': bidder,
        'bidder_phone': bidderPhone,
        'negotiated_price': negotiatedPrice,
        'payment_type': paymentType.toUpperCase(),
      };

      final response = await _dio.post(
        'agen/negotiation',
        data: body,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception(
          response.data['text'] ?? 'Gagal memproses room negosiasi.',
        );
      }
    } on DioException catch (e) {
      final errorMsg = e.response?.data['text'] ?? 'Gagal menyimpan negosiasi.';
      throw Exception(errorMsg);
    }
  }

  Future<NegotiationCounterResponseModel> getNegotiationCounter() async {
    try {
      final token = await _getToken();
      final response = await _dio.get(
        'agen/negotiation/counter',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return NegotiationCounterResponseModel.fromJson(response.data);
      } else {
        throw Exception(
          response.data['text'] ?? 'Gagal mengambil counter negosiasi.',
        );
      }
    } on DioException catch (e) {
      final errorMsg =
          e.response?.data['text'] ?? 'Terjadi kesalahan jaringan.';
      throw Exception(errorMsg);
    }
  }

  Future<NegotiationResult> getDetailNegotiation(int id) async {
    try {
      final token = await _getToken();
      final response = await _dio.get(
        'agen/negotiation/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decodedData = response.data;
        if (decodedData['status'] == true) {
          return NegotiationResult.fromJson(decodedData['data']);
        } else {
          throw Exception(
            decodedData['text'] ?? 'Gagal mengambil detail negosiasi.',
          );
        }
      } else {
        throw Exception(
          response.data['text'] ?? 'Gagal mengambil detail negosiasi.',
        );
      }
    } on DioException catch (e) {
      final errorMsg =
          e.response?.data['text'] ??
          'Terjadi kesalahan jaringan saat memuat detail.';
      throw Exception(errorMsg);
    }
  }

  /// 5. PERBAIKAN: GET RIWAYAT CHAT DALAM ROOM NEGOSIASI
  Future<List<NegotiationChatItem>> getNegotiationChats(
    int negotiationId,
  ) async {
    try {
      final token = await _getToken();
      final response = await _dio.get(
        'agen/negotiation/$negotiationId/chat',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final chatResponse = NegosiasiChatResponseModel.fromJson(response.data);
        return chatResponse.data;
      } else {
        throw Exception(response.data['text'] ?? 'Gagal memuat pesan chat.');
      }
    } on DioException catch (e) {
      final errorMsg =
          e.response?.data['text'] ?? 'Gagal terhubung ke server chat.';
      throw Exception(errorMsg);
    }
  }

  Future<Map<String, dynamic>> sendNegotiationChat({
    required int negotiationId,
    int? id,
    String? pesan,
    int? nominal,
  }) async {
    try {
      final token = await _getToken();

      final Map<String, dynamic> body = {
        if (id != null) 'id': id,
        if (pesan != null) 'pesan': pesan,
        if (nominal != null) 'nominal': nominal,
      };

      final response = await _dio.post(
        'agen/negotiation/$negotiationId/chat',
        data: body,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception(response.data['text'] ?? 'Gagal mengirim pesan.');
      }
    } on DioException catch (e) {
      final errorMsg = e.response?.data['text'] ?? 'Pesan gagal terkirim.';
      throw Exception(errorMsg);
    }
  }

  Future<bool> readNegotiationChat({
    required int negotiationId,
    required int chatId,
    String? pesan,
    int? nominal,
  }) async {
    try {
      final token = await _getToken();

      final Map<String, dynamic> body = {
        if (pesan != null) 'pesan': pesan,
        if (nominal != null) 'nominal': nominal,
      };

      final response = await _dio.put(
        'agen/negotiation/$negotiationId/chat/$chatId/read',
        data: body,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return response.statusCode == 200 && response.data['status'] == true;
    } on DioException catch (e) {
      final errorMsg =
          e.response?.data['text'] ?? 'Gagal memperbarui status baca pesan.';
      throw Exception(errorMsg);
    }
  }

  Future<bool> deleteNegotiationChat({
    required int negotiationId,
    required int chatId,
  }) async {
    try {
      final token = await _getToken();
      final response = await _dio.delete(
        'agen/negotiation/$negotiationId/chat/$chatId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return response.statusCode == 200 && response.data['status'] == true;
    } on DioException catch (e) {
      final errorMsg =
          e.response?.data['text'] ?? 'Gagal menghapus pesan chat.';
      throw Exception(errorMsg);
    }
  }
}
