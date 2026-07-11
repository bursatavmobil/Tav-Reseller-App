import 'dart:async';

import 'package:flutter/material.dart';
import 'package:reseller_app_tav/features/dashboard/services/stock_car_service.dart';

class CarSelectorWidget extends StatefulWidget {
  final int? initialCarId;
  final String? initialCarName;
  final Function(int id, String name) onCarSelected;

  const CarSelectorWidget({
    super.key,
    this.initialCarId,
    this.initialCarName,
    required this.onCarSelected,
  });

  @override
  State<CarSelectorWidget> createState() => _CarSelectorWidgetState();
}

class _CarSelectorWidgetState extends State<CarSelectorWidget> {
  final _stockCarService = StockCarService();
  final _searchController = TextEditingController();

  List<dynamic> _carsList = [];
  bool _isLoading = false;
  int _currentPage = 1;
  static const int _itemsPerPage = 3;
  Timer? _debounce;

  int? _selectedId;

  @override
  void initState() {
    super.initState();
    _selectedId = widget.initialCarId;
    _fetchCars();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _fetchCars({String? query}) async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final res = await _stockCarService.fetchStockCars(
        page: 1,
        perPage: 100,
        searchName: query,
      );

      if (mounted) {
        setState(() {
          List<dynamic> fetched = res['data']['result'] ?? [];

          if (widget.initialCarId != null && query == null) {
            bool exists = fetched.any((c) => c['id'] == widget.initialCarId);
            if (!exists && widget.initialCarName != null) {
              fetched.insert(0, {
                'id': widget.initialCarId,
                'name': widget.initialCarName,
                'no_plat': '-',
                'car_year': '-',
              });
            }
          }

          _carsList = fetched;
          _currentPage = 1;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _fetchCars(query: query.trim());
    });
  }

  @override
  Widget build(BuildContext context) {
    final int startIndex = (_currentPage - 1) * _itemsPerPage;
    final int endIndex = startIndex + _itemsPerPage;
    final List<dynamic> paginatedCars = _carsList.isEmpty
        ? []
        : _carsList.sublist(
            startIndex,
            endIndex > _carsList.length ? _carsList.length : endIndex,
          );
    final int totalPages = (_carsList.length / _itemsPerPage).ceil();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Pilih Mobil",
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _searchController,
          onChanged: _onSearchChanged,
          style: const TextStyle(fontFamily: 'Montserrat', fontSize: 13),
          decoration: InputDecoration(
            hintText: 'Ketik nama mobil untuk mencari...',
            prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 20),
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: _isLoading
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(color: Colors.red),
                  ),
                )
              : _carsList.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      "Mobil tidak ditemukan",
                      style: TextStyle(fontFamily: 'Montserrat', fontSize: 12),
                    ),
                  ),
                )
              : Column(
                  children: [
                    ...paginatedCars.map((car) {
                      final bool isSelected = _selectedId == car['id'];
                      return GestureDetector(
                        onTap: () {
                          setState(() => _selectedId = car['id']);
                          widget.onCarSelected(car['id'], car['name'] ?? '');
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.red.shade50
                                : Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.red
                                  : Colors.grey.shade200,
                              width: isSelected ? 1.5 : 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isSelected
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_off,
                                color: isSelected ? Colors.red : Colors.grey,
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      car['name'] ?? '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 13,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      "Plat: ${car['no_plat'] ?? '-'} • Tahun: ${car['car_year'] ?? '-'}",
                                      style: const TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 11,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Halaman $_currentPage dari $totalPages",
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.chevron_left),
                              onPressed: _currentPage > 1
                                  ? () => setState(() => _currentPage--)
                                  : null,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            const SizedBox(width: 16),
                            IconButton(
                              icon: const Icon(Icons.chevron_right),
                              onPressed: _currentPage < totalPages
                                  ? () => setState(() => _currentPage++)
                                  : null,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}
