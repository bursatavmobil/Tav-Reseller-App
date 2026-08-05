import 'dart:io'; // Pastikan import dart:io ditambahkan untuk tipe File

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
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
    File? gambarFile,
  }) async {
    try {
      final token = await _getToken();
      dynamic payload;
      Map<String, dynamic> headers = {'Authorization': 'Bearer $token'};

      if (gambarFile != null) {
        headers['Content-Type'] = 'multipart/form-data';

        final String fileName = gambarFile.path.split('/').last;
        payload = FormData.fromMap({
          if (id != null) 'id': id,
          if (pesan != null) 'pesan': pesan,
          if (nominal != null) 'nominal': nominal,
          'gambar': await MultipartFile.fromFile(
            gambarFile.path,
            filename: fileName,
          ),
        });

        debugPrint('[Service] Mengirim data via Multipart (File: $fileName)');
      } else {
        headers['Content-Type'] = 'application/json';
        payload = {
          if (id != null) 'id': id,
          if (pesan != null) 'pesan': pesan,
          if (nominal != null) 'nominal': nominal,
        };

        debugPrint('📡 [Service] Mengirim data via JSON Standard');
      }

      final response = await _dio.post(
        'agen/negotiation/$negotiationId/chat',
        data: payload,
        options: Options(headers: headers),
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
  

  Future<Map<String, dynamic>?> uploadChatFile({
    required String path,
    required File file,
  }) async {
    try {
      final token = await _getToken();
      final String fileName = file.path.split('/').last;

      final FormData formData = FormData();

      formData.fields.add(MapEntry("path", path));

      formData.files.add(
        MapEntry(
          "files[]",
          await MultipartFile.fromFile(file.path, filename: fileName),
        ),
      );
      /* 
      SETUP SAAT DIBUTUHKAN MULTIPLE UPLOAD
      for (var file dalam listFiles) {
          formData.files.add(
          MapEntry("files[]", await MultipartFile.fromFile(file.path, filename: ...)),
        );
      } */

      debugPrint("[DIO UPLOAD] Menembak URL Upload Asset secara independen...");

      // final response = await Dio().post(
      //   "https://xbc.tavmobil.co.id/api/v1/file/upload",
      //   data: formData,
      //   options: Options(
      //     headers: {
      //       "Accept": "application/json",
      //       if (token != null) "Authorization": "Bearer $token",
      //     },
      //   ),
      // );

      final response = await _dio.post(
        'file/upload',
        data: formData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("[DIO UPLOAD SUCCESS]: ${response.data['text']}");
        return response.data;
      } else {
        throw Exception(response.data['text'] ?? 'Gagal mengunggah file.');
      }
    } on DioException catch (e) {
      final errorMsg =
          e.response?.data['text'] ??
          'Terjadi kesalahan HTTP saat mengunggah berkas.';
      debugPrint(
        "[DIO UPLOAD ERROR]: $errorMsg (Status Code: ${e.response?.statusCode})",
      );
      throw Exception(errorMsg);
    } catch (e) {
      debugPrint("[LOCAL UPLOAD ERROR]: $e");
      return null;
    }
  }

  // AMBIL SEMUA DATA TRANSAKSI AGEN
  Future<NegotiationResponseModel> getAllTransactions({
    int page = 1,
    int perPage = 10,
    String? searchCarOrBidder,
  }) async {
    try {
      final token = await _getToken();

      final Map<String, dynamic> queryParams = {
        'page': page,
        'perpage': perPage,
      };

      if (searchCarOrBidder != null && searchCarOrBidder.isNotEmpty) {
        queryParams['search[car_or_bidder]'] = searchCarOrBidder;
      }

      final response = await _dio.get(
        'agen/transaksi', // Endpoint sesuai instruksi
        queryParameters: queryParams,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return NegotiationResponseModel.fromJson(response.data);
      } else {
        throw Exception(
          response.data['text'] ?? 'Gagal mengambil data transaksi.',
        );
      }
    } on DioException catch (e) {
      final errorMsg =
          e.response?.data['text'] ?? 'Terjadi kesalahan jaringan transaksi.';
      throw Exception(errorMsg);
    }
  }

  //  AMBIL DETAIL KUSUS TRANSAKSI AGEN
  Future<NegotiationResult> getDetailTransaction(int id) async {
    try {
      final token = await _getToken();
      final response = await _dio.get(
        'agen/transaksi/$id', // Endpoint detail transaksi
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decodedData = response.data;
        if (decodedData['status'] == true) {
          return NegotiationResult.fromJson(decodedData['data']);
        } else {
          throw Exception(
            decodedData['text'] ?? 'Gagal mengambil detail transaksi.',
          );
        }
      } else {
        throw Exception(
          response.data['text'] ?? 'Gagal mengambil detail transaksi.',
        );
      }
    } on DioException catch (e) {
      final errorMsg =
          e.response?.data['text'] ??
          'Terjadi kesalahan jaringan detail transaksi.';
      throw Exception(errorMsg);
    }
  }

  Future<Response> getAllCustomers({
    int page = 1,
    int perPage = 10,
    String? searchName,
  }) async {
    try {
      final token = await _getToken();
      final Map<String, dynamic> queryParams = {
        'page': page,
        'perpage': perPage,
      };

      if (searchName != null && searchName.isNotEmpty) {
        queryParams['search[name]'] = searchName;
      }

      return await _dio.get(
        'agen/customer',
        queryParameters: queryParams,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } catch (e) {
      rethrow;
    }
  }

  // UPSERT CUSTOMER
  Future<Response> saveCustomer({
    String? id,
    required String fullName,
    required String phone,
    required String email,
    required String address,
    File? fotoKtp,
  }) async {
    try {
      final token = await _getToken();

      Map<String, dynamic> mapData = {
        if (id != null) 'id': id,
        'full_name': fullName,
        'phone': phone,
        'email': email,
        'address': address,
      };

      if (fotoKtp != null) {
        String fileName = fotoKtp.path.split('/').last;
        mapData['foto_ktp'] = await MultipartFile.fromFile(
          fotoKtp.path,
          filename: fileName,
        );
      }

      FormData formData = FormData.fromMap(mapData);

      return await _dio.post(
        'agen/customer',
        data: formData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> sendPaymentRequest({
    required int transactionId,
    required int customerId,
  }) async {
    try {
      final token = await _getToken();

      final Map<String, dynamic> body = {'user_id': customerId};

      final String fullUrl =
          "${_dio.options.baseUrl}agen/transaksi/$transactionId/send-payment";
      debugPrint("==================== API REQUEST INFO ====================");
      debugPrint("METHOD       : POST");
      debugPrint("ENDPOINT URL  : $fullUrl");
      debugPrint(
        "AUTH TOKEN   : ${token != null ? 'Bearer ${token.substring(0, 15)}...' : 'NULL'}",
      );
      debugPrint("REQUEST BODY  : $body");
      debugPrint(" ========================================================");
      // ==============================================================================

      final response = await _dio.post(
        'agen/transaksi/$transactionId/send-payment',
        data: body,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      // ====================  [DEBUG] BACKEND HTTP RESPONSE SUCCESS ====================
      debugPrint(
        " ==================== API RESPONSE SUCCESS ====================",
      );
      debugPrint(" STATUS CODE  : ${response.statusCode}");
      debugPrint(" RESPONSE DATA : ${response.data}");
      debugPrint(
        " ==============================================================",
      );
      // ==================================================================================

      return response;
    } on DioException catch (e) {
      // ====================  [DEBUG] BACKEND HTTP RESPONSE ERROR ====================
      debugPrint(
        " ==================== API RESPONSE ERROR ====================",
      );
      debugPrint(" ERROR TYPE   : ${e.type}");
      debugPrint(" STATUS CODE  : ${e.response?.statusCode}");
      debugPrint(" ERROR BODY   : ${e.response?.data}");
      debugPrint(
        " ============================================================",
      );
      // ================================================================================
      rethrow;
    } catch (e) {
      debugPrint(" [LOCAL EXCEPTION] Terjadi crash lokal pada service: $e");
      rethrow;
    }
  }
}
