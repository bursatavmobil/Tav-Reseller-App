import 'dart:io';

import 'package:flutter/material.dart';
import 'package:reseller_app_tav/features/dashboard/services/profile_service.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileService _profileService = ProfileService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  bool _isKycSaving = false;
  bool get isKycSaving => _isKycSaving;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Map<String, dynamic>? _profileData;
  Map<String, dynamic>? get profileData => _profileData;

  Future<void> loadProfileData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _profileService.fetchProfile();
      if (response['status'] == true && response['data'] != null) {
        _profileData = response['data'];
      } else {
        _errorMessage = 'Gagal memuat data profil.';
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveProfileUpdate({
    required String name,
    required String noWhatsapp,
  }) async {
    _isSaving = true;
    notifyListeners();

    try {
      final response = await _profileService.updateProfile(
        name: name,
        noWhatsapp: noWhatsapp,
      );
      if (response['status'] == true) {
        if (_profileData != null) {
          _profileData!['name'] = name;
          _profileData!['no_wa'] = noWhatsapp;
          _profileData!['phone'] = noWhatsapp;
        }
        _isSaving = false;
        notifyListeners();
        return true;
      }
      _isSaving = false;
      notifyListeners();
      return false;
    } catch (e) {
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> uploadKycData({
    required int? kycId,
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
    required File? fotoKtp,
    required File? fotoKtpSelfie,
    required File? fotoKK,
  }) async {
    _isKycSaving = true;
    _errorMessage = null; // Reset error message
    notifyListeners();

    try {
      final response = await _profileService.submitKyc(
        noWhatsappDarurat: noWhatsappDarurat,
        bank: bank,
        namaDiRekening: namaDiRekening,
        noRekening: noRekening,
        nomorKtp: nomorKtp,
        jenisKelamin: jenisKelamin,
        tempatLahir: tempatLahir,
        tanggalLahir: tanggalLahir,
        subDistrictId: subDistrictId,
        rt: rt,
        rw: rw,
        alamat: alamat,
        fotoKtp: fotoKtp,
        fotoKtpSelfie: fotoKtpSelfie,
        fotoKK: fotoKK,
      );

      _isKycSaving = false;

      if (response['status'] == true) {
        notifyListeners();
        return true;
      } else {
        _errorMessage =
            response['text'] ??
            response['message'] ??
            'Gagal memverifikasi data KYC ke server.';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isKycSaving = false;
      rethrow;
    }
  }
}
