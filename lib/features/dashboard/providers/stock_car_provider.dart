import 'dart:async';

import 'package:flutter/material.dart';

import '../services/stock_car_service.dart';

class StockCarProvider with ChangeNotifier {
  final StockCarService _carService = StockCarService();

  List<dynamic> _cars = [];
  bool _isLoading = false;
  String _searchQuery = '';
  List<String> _selectedStatuses = ['SEMUA'];

  int _currentPage = 1;
  int _totalData = 0;
  int _lastPage = 1;
  int _perPage = 10;

  Timer? _debounce;

  List<dynamic> get cars => _cars;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  List<String> get selectedStatuses => _selectedStatuses;
  int get currentPage => _currentPage;
  int get lastPage => _lastPage;
  int get totalData => _totalData;

  Future<void> fetchCars({int page = 1}) async {
    _isLoading = true;
    _currentPage = page;
    notifyListeners();

    try {
      final response = await _carService.fetchStockCars(
        page: _currentPage,
        perPage: _perPage,
        searchName: _searchQuery,
        statuses: _selectedStatuses,
      );

      if (response['status'] == true) {
        final data = response['data'];
        _cars = data['result'];
        _totalData = data['total_data'];
        _lastPage = data['last_page'];
      }
    } catch (e) {
      debugPrint("Error Fetching Cars: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      fetchCars(page: 1);
    });
  }

  void toggleStatus(String status) {
    final formattedStatus = status.toUpperCase();

    if (formattedStatus == 'SEMUA') {
      _selectedStatuses = ['SEMUA'];
    } else {
      _selectedStatuses.remove('SEMUA');
      if (_selectedStatuses.contains(formattedStatus)) {
        _selectedStatuses.remove(formattedStatus);
      } else {
        _selectedStatuses.add(formattedStatus);
      }
    }

    if (_selectedStatuses.isEmpty) {
      _selectedStatuses = ['SEMUA'];
    }
    fetchCars(page: 1);
  }
}
