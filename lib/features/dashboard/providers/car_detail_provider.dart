import 'package:flutter/material.dart';
import 'package:reseller_app_tav/features/dashboard/services/info_komisi_service.dart';

import '../services/car_detail_service.dart';

class CarDetailProvider extends ChangeNotifier {
  final CarDetailService _service = CarDetailService();
  final InfoKomisiService _infoKomisiService = InfoKomisiService();

  Map<String, dynamic>? _carData;
  bool _isLoading = false;
  String? _errorMessage;
  int _currentImageIndex = 0;

  Map<String, dynamic>? _infoKomisiData;
  Map<String, dynamic>? get infoKomisiData => _infoKomisiData;

  Map<String, dynamic>? get carData => _carData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get currentImageIndex => _currentImageIndex;

  void setImageIndex(int index) {
    _currentImageIndex = index;
    notifyListeners();
  }

  Future<void> loadCarDetail(int carId) async {
    _isLoading = true;
    _errorMessage = null;
    _currentImageIndex = 0;
    notifyListeners();

    try {
      final results = await Future.wait([
        _service.fetchDetailCar(carId),
        _infoKomisiService.fetchInfoKomisi(),
      ]);

      final carResponse = results[0];
      final komisiResponse = results[1];

      if (carResponse['status'] == true) {
        _carData = carResponse['data'];
      } else {
        _errorMessage = carResponse['text'] ?? 'Gagal mengambil data mobil';
      }

      if (komisiResponse['status'] == true && komisiResponse['data'] != null) {
        _infoKomisiData = komisiResponse['data'];
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadInfoKomisiData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _infoKomisiService.fetchInfoKomisi();
      if (response['status'] == true && response['data'] != null) {
        _infoKomisiData = response['data'];
      } else {
        _errorMessage = 'Gagal memuat data info komisi.';
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
