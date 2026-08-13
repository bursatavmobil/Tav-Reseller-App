import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:reseller_app_tav/features/dashboard/services/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileService {
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
    return prefs.getString('auth_token');
  }

  Future<Map<String, dynamic>> fetchProfile() async {
    final String? token = await _getToken();
    const String endpoint = 'agen/profile';

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
      if (response.data['status'] == true) {
        return response.data;
      } else {
        throw Exception(response.data['text'] ?? 'Gagal memuat profil');
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['text'] ?? 'Terjadi kesalahan jaringan.',
      );
    }
  }

  Future<List<dynamic>> fetchMasterBank({String search = ''}) async {
    final String? token = await _getToken();
    final String endpoint = search.isNotEmpty
        ? 'master-bank?search[search]=$search'
        : 'master-bank';

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

      if (response.data['status'] == true) {
        return response.data['data'] ?? [];
      } else {
        return [];
      }
    } on DioException catch (e) {
      debugPrint("Error fetch master bank: $e");
      return [];
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String noWhatsapp,
  }) async {
    final String? token = await _getToken();
    const String endpoint = 'agen/profile';

    try {
      final response = await _dio.put(
        endpoint,
        data: {'name': name, 'no_whatsapp': noWhatsapp},
        options: Options(
          headers: {
            if (token != null && token.isNotEmpty)
              'Authorization': 'Bearer $token',
          },
        ),
      );
      if (response.data['status'] == true) {
        return response.data;
      } else {
        throw Exception(response.data['text'] ?? 'Gagal memperbarui profil');
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['text'] ?? 'Gagal memperbarui profil ke server.',
      );
    }
  }

  Future<Map<String, dynamic>> submitKyc({
    int? kycId, // ID ditambahkan di sini
    required String noWhatsappDarurat,
    required String bank,
    required String namaDiRekening,
    required String noRekening,
    required String nomorKtp,
    required String jenisKelamin,
    required String tempatLahir,
    required String tanggalLahir,
    required int subDistrictId,
    required String rt,
    required String rw,
    required String alamat,
    File? fotoKtp, // Ubah menjadi nullable
    File? fotoKtpSelfie, // Ubah menjadi nullable
    File? fotoKK,
  }) async {
    final String? token = await _getToken();
    const String endpoint = 'agen/profile/kyc';

    try {
      final Map<String, dynamic> mapData = {
        if (kycId != null)
          'id': kycId, // Sertakan ID untuk kebutuhan update data
        'no_whatsapp_darurat': noWhatsappDarurat,
        'bank': bank,
        'nama_di_rekening': namaDiRekening,
        'no_rekening': noRekening,
        'nomor_ktp': nomorKtp,
        'jenis_kelamin': jenisKelamin,
        'tempat_lahir': tempatLahir,
        'tanggal_lahir': tanggalLahir,
        'sub_district_id': subDistrictId,
        'rt': rt,
        'rw': rw,
        'alamat': alamat,
      };

      if (fotoKtp != null) {
        mapData['foto_ktp'] = await MultipartFile.fromFile(
          fotoKtp.path,
          filename: fotoKtp.path.split('/').last,
        );
      }

      if (fotoKtpSelfie != null) {
        mapData['foto_formal'] = await MultipartFile.fromFile(
          fotoKtpSelfie.path,
          filename: fotoKtpSelfie.path.split('/').last,
        );
      }
      if (fotoKK != null) {
        mapData['foto_kk'] = await MultipartFile.fromFile(
          fotoKK.path,
          filename: fotoKK.path.split('/').last,
        );
      }

      final FormData formData = FormData.fromMap(mapData);

      final response = await _dio.post(
        endpoint,
        data: formData,
        options: Options(
          headers: {
            if (token != null && token.isNotEmpty)
              'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.data['status'] == true) {
        return response.data;
      } else {
        throw Exception(
          response.data['text'] ?? 'Gagal memverifikasi KYC data.',
        );
      }
    } on DioException catch (e) {
      debugPrint("DIO ERROR RESPONSE: ${e.response?.data}");
      throw Exception(
        e.response?.data['text'] ?? 'Terjadi kesalahan saat mengunggah KYC.',
      );
    }
  }
}
