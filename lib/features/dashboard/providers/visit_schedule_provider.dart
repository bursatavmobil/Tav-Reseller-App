import 'package:flutter/material.dart';

import '../models/visit_schedule_model.dart';
import '../services/visit_schedule_service.dart';

class VisitScheduleProvider extends ChangeNotifier {
  final VisitScheduleService _visitService = VisitScheduleService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Map<String, dynamic> _counters = {"aktif": 0, "batal": 0, "selesai": 0};
  Map<String, dynamic> get counters => _counters;

  List<VisitScheduleItem> _schedules = [];
  List<VisitScheduleItem> get schedules => _schedules;

  Future<void> loadAllVisitData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final counterRes = await _visitService.fetchCounterStatus();
      final listRes = await _visitService.fetchVisitSchedules(
        page: 1,
        perPage: 100,
      );
      final parsedModel = VisitScheduleResponseModel.fromJson(listRes);

      _counters = counterRes['data'] ?? {"aktif": 0, "batal": 0, "selesai": 0};
      _schedules = parsedModel.data.result;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveSchedule({
    int? id,
    required int carId,
    required String tipe,
    required String namaKonsumen,
    required String tanggal,
    required String jam,
    required String catatan,
  }) async {
    try {
      await _visitService.upsertVisitSchedule(
        id: id,
        carId: carId,
        tipe: tipe,
        namaKonsumen: namaKonsumen,
        tanggal: tanggal,
        jam: jam,
        catatan: catatan,
      );
      await loadAllVisitData();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> cancelSchedule(int id) async {
    try {
      final isSuccess = await _visitService.cancelSchedule(id);
      if (isSuccess) {
        await loadAllVisitData();
      } else {
        throw Exception("Gagal membatalkan kunjungan, silakan coba lagi.");
      }
    } catch (e) {
      rethrow;
    }
  }
}
