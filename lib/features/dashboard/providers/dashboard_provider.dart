import 'package:flutter/material.dart';
import 'package:reseller_app_tav/features/dashboard/models/penarikan_response_model.dart';
import 'package:reseller_app_tav/features/dashboard/models/profile_response_model.dart';
import 'package:reseller_app_tav/features/dashboard/models/riwayat_komisi_model.dart';
import 'package:reseller_app_tav/features/dashboard/services/profile_service.dart';
import 'package:reseller_app_tav/features/dashboard/services/saldo_service.dart';

class DashboardProvider extends ChangeNotifier {
  final SaldoService _saldoService = SaldoService();
  final ProfileService _profileService = ProfileService();
  
  Map<String, dynamic>? _rawProfileJson;
  Map<String, dynamic>? get rawProfileJson => _rawProfileJson;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  PenarikanResponseModel? _penarikanData;
  RiwayatKomisiResponseModel? _komisiData;
  ProfileResponseModel? _profileData;

  ProfileData? get profile => _profileData?.data;

  int _saldoKeuntungan = 0;
  int _pemasukanBulanIni = 0;
  int _unitTerjual = 0;

  int get saldoKeuntungan => _saldoKeuntungan;
  int get pemasukanBulanIni => _pemasukanBulanIni;
  int get unitTerjual => _unitTerjual;

  DateTime _selectedMonth = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    1,
  );
  int _currentDayWindowIndex = 0;
  final int _daysPerWindow = 5;

  DateTime get selectedMonth => _selectedMonth;
  int get currentDayWindowIndex => _currentDayWindowIndex;

  // Tambahkan satu variabel baru di level atas class DashboardProvider
  String? _userAvatarUrl;
  String? get userAvatarUrl => _userAvatarUrl;

  Future<void> loadDashboardData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    debugPrint('[DASHBOARD PROVIDER] Memulai loadDashboardData()...');

    try {
      debugPrint('[DASHBOARD PROVI  DER] Mengambil data Profile...');
      final profileRaw = await _profileService.fetchProfile();
      _profileData = ProfileResponseModel.fromJson(profileRaw);

      if (profileRaw != null && profileRaw['data'] != null) {
        _rawProfileJson = profileRaw['data'] as Map<String, dynamic>;

        final Map<String, dynamic> dataJson = profileRaw['data'];
        _userAvatarUrl =
            dataJson['gavatar']?.toString() ??
            dataJson['avatar']?.toString() ??
            dataJson['photo_url']?.toString();
      }
      final String currentStatus = (profile?.status ?? 'submission')
          .toLowerCase()
          .trim();

      debugPrint(
        '[DASHBOARD PROVIDER] Sukses memuat Profile. Status Akun dari Backend: "$currentStatus"',
      );

      if (currentStatus == 'approved' || currentStatus == 'active') {
        debugPrint(
          '[DASHBOARD PROVIDER] Akun Valid ($currentStatus). Mengambil data finansial...',
        );

        _errorMessage = null;

        try {
          final penarikanRes = await _saldoService.fetchRiwayatPenarikan(
            page: 1,
            perPage: 100,
            statuses: ['sukses', 'diajukan'],
          );
          _penarikanData = PenarikanResponseModel.fromJson(penarikanRes);
        } catch (e) {
          debugPrint(
            '[DASHBOARD PROVIDER WARNING] Gagal parsing riwayat penarikan (Fallback Kosong): $e',
          );
          _penarikanData = const PenarikanResponseModel(
            status: true,
            code: "200",
            text: "Empty Fallback",
            data: PenarikanData(
              totalData: 0,
              perPage: 100,
              currentPage: 1,
              lastPage: 1,
              result: [],
            ),
          );
        }

        try {
          final komisiRes = await _saldoService.fetchRiwayatKomisi(
            page: 1,
            perPage: 100,
          );
          _komisiData = RiwayatKomisiResponseModel.fromJson(komisiRes);
        } catch (e) {
          debugPrint(
            '[DASHBOARD PROVIDER WARNING] Gagal parsing riwayat komisi (Fallback Kosong): $e',
          );
          _komisiData = const RiwayatKomisiResponseModel(
            status: true,
            code: "200",
            text: "Empty Fallback",
            data: KomisiData(
              totalData: 0,
              perPage: 100,
              currentPage: 1,
              lastPage: 1,
              result: [],
            ),
          );
        }

        _hitungOverviewData();
      } else {
        debugPrint(
          '[DASHBOARD PROVIDER] Akun berstatus "$currentStatus". Mengunci akses menu fungsional.',
        );
        _resetOverviewData();
        _errorMessage = "Akun belum melakkan verifikasi atau belum disetujui";
      }
    } catch (e) {
      debugPrint(
        ' [DASHBOARD PROVIDER ERROR] Gagal fatal pada loadDashboardData: $e',
      );
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _hitungOverviewData() {
    if (_komisiData == null || _penarikanData == null) return;

    int totalSemuaKomisi = 0;
    for (var item in _komisiData!.data.result) {
      totalSemuaKomisi += item.nominal;
    }

    int totalPenarikanBerjalan = 0;
    for (var item in _penarikanData!.data.result) {
      if (item.status == 'sukses' || item.status == 'diajukan') {
        totalPenarikanBerjalan += item.nominal;
      }
    }

    _saldoKeuntungan = totalSemuaKomisi - totalPenarikanBerjalan;

    int totalPemasukanBulanIni = 0;
    int totalUnitBulanIni = 0;
    final DateTime sekarang = DateTime.now();

    for (var item in _komisiData!.data.result) {
      try {
        final DateTime tanggalKomisi = DateTime.parse(item.createdAt);
        if (tanggalKomisi.year == sekarang.year &&
            tanggalKomisi.month == sekarang.month) {
          totalPemasukanBulanIni += item.nominal;
          if (item.order != null) totalUnitBulanIni++;
        }
      } catch (e) {
        debugPrint(e.toString());
      }
    }
    _pemasukanBulanIni = totalPemasukanBulanIni;
    _unitTerjual = totalUnitBulanIni;
  }

  void _resetOverviewData() {
    _saldoKeuntungan = 0;
    _pemasukanBulanIni = 0;
    _unitTerjual = 0;
    _penarikanData = null;
    _komisiData = null;
  }

  Future<bool> submitPenarikan(int nominal) async {
    if (nominal <= 0 || nominal > _saldoKeuntungan) return false;
    _isLoading = true;
    notifyListeners();

    try {
      await _saldoService.createPenarikan(nominal);
      await loadDashboardData();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void changeSelectedMonth(DateTime newMonth) {
    _selectedMonth = DateTime(newMonth.year, newMonth.month, 1);
    _currentDayWindowIndex = 0;
    notifyListeners();
  }

  void nextDayWindow() {
    int totalDaysInMonth = DateTime(
      _selectedMonth.year,
      _selectedMonth.month + 1,
      0,
    ).day;
    int maxIndex = (totalDaysInMonth / _daysPerWindow).ceil() - 1;
    if (_currentDayWindowIndex < maxIndex) {
      _currentDayWindowIndex++;
      notifyListeners();
    }
  }

  void previousDayWindow() {
    if (_currentDayWindowIndex > 0) {
      _currentDayWindowIndex--;
      notifyListeners();
    }
  }

  String get currentDayRangeLabel {
    int startDay = (_currentDayWindowIndex * _daysPerWindow) + 1;
    int totalDaysInMonth = DateTime(
      _selectedMonth.year,
      _selectedMonth.month + 1,
      0,
    ).day;
    int endDay = startDay + _daysPerWindow - 1;
    if (endDay > totalDaysInMonth) endDay = totalDaysInMonth;

    return "Hari $startDay - $endDay";
  }

  List<MapEntry<String, double>> get penjualanHarianGrafikData {
    if (_komisiData == null) return [];

    int totalDaysInMonth = DateTime(
      _selectedMonth.year,
      _selectedMonth.month + 1,
      0,
    ).day;
    int startDay = (_currentDayWindowIndex * _daysPerWindow) + 1;
    int endDay = startDay + _daysPerWindow - 1;
    if (endDay > totalDaysInMonth) endDay = totalDaysInMonth;

    final Map<String, double> akumulasiHarian = {};
    for (int i = startDay; i <= endDay; i++) {
      String labelHari = "Tgl ${i.toString().padLeft(2, '0')}";
      akumulasiHarian[labelHari] = 0.0;
    }

    for (var item in _komisiData!.data.result) {
      try {
        final DateTime tanggalKomisi = DateTime.parse(item.createdAt);

        if (tanggalKomisi.year == _selectedMonth.year &&
            tanggalKomisi.month == _selectedMonth.month) {
          int hari = tanggalKomisi.day;

          if (hari >= startDay && hari <= endDay) {
            String labelHari = "Tgl ${hari.toString().padLeft(2, '0')}";
            akumulasiHarian[labelHari] =
                (akumulasiHarian[labelHari] ?? 0.0) + item.nominal.toDouble();
          }
        }
      } catch (e) {
        debugPrint(e.toString());
      }
    }

    return akumulasiHarian.entries.toList();
  }

  List<MapEntry<String, double>> get penjualanGrafikData =>
      penjualanHarianGrafikData;
  List<MapEntry<String, double>> get PenjualanGrafikData =>
      penjualanHarianGrafikData;
  List<KomisiItem> get riwayatMobilTerjual => _komisiData?.data.result ?? [];
}
