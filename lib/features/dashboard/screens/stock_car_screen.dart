import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:reseller_app_tav/features/dashboard/providers/stock_car_provider.dart';
import 'package:reseller_app_tav/features/dashboard/screens/detail_car_screen.dart';
import 'package:reseller_app_tav/features/dashboard/widgets/cards/card_grid_item.dart';

class StockCarScreen extends StatefulWidget {
  const StockCarScreen({Key? key}) : super(key: key);

  @override
  State<StockCarScreen> createState() => _StockCarScreenState();
}

class _StockCarScreenState extends State<StockCarScreen> {
  bool _isFilterExpanded = true;
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StockCarProvider>(context, listen: false).fetchCars();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StockCarProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: GestureDetector(
          onTap: () {
            setState(() {
              _isFilterExpanded = !_isFilterExpanded;
            });
          },
          behavior: HitTestBehavior.opaque,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Stock Mobil',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(
                _isFilterExpanded
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
                color: Colors.black87,
                size: 22,
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          if (_isFilterExpanded) _buildHeaderFilter(provider),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Menampilkan ${provider.cars.length} dari ${provider.totalData} unit",
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isGridView = false;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: !_isGridView
                                ? Colors.white
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: !_isGridView
                                ? [
                                    const BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 2,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.list,
                                size: 16,
                                color: !_isGridView
                                    ? Colors.black
                                    : Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "List",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: !_isGridView
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: !_isGridView
                                      ? Colors.black
                                      : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isGridView = true;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _isGridView
                                ? Colors.white
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: _isGridView
                                ? [
                                    const BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 2,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.grid_view_rounded,
                                size: 16,
                                color: _isGridView ? Colors.black : Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "Kartu",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: _isGridView
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: _isGridView
                                      ? Colors.black
                                      : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: provider.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.red),
                  )
                : provider.cars.isEmpty
                ? const Center(child: Text("Mobil tidak ditemukan."))
                : _isGridView
                ? GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          mainAxisExtent: 260,
                        ),
                    itemCount: provider.cars.length,
                    itemBuilder: (context, index) {
                      final car = provider.cars[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CarDetailScreen(carId: car['id']),
                            ),
                          );
                        },
                        child: CarGridItem(car: car),
                      );
                    },
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: provider.cars.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final car = provider.cars[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CarDetailScreen(carId: car['id']),
                            ),
                          );
                        },
                        child: _buildCarRowItem(car),
                      );
                    },
                  ),
          ),
          _buildPaginationBar(provider),
        ],
      ),
    );
  }

  Widget _buildHeaderFilter(StockCarProvider provider) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEEEEE),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    onChanged: provider.updateSearchQuery,
                    decoration: const InputDecoration(
                      hintText: 'Honda SUV',
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                      prefixIcon: Icon(Icons.search, color: Colors.black),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),
              Container(
                height: 46,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFE52320),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    'Cari',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildFilterChip(provider, 'SEMUA', 'Semua'),
              const SizedBox(width: 8),
              _buildFilterChip(provider, 'AVAILABLE', 'Ready'),
              const SizedBox(width: 8),
              _buildFilterChip(provider, 'BOOKING', 'Booked'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    StockCarProvider provider,
    String rawValue,
    String label,
  ) {
    final isSelected = provider.selectedStatuses.contains(rawValue);
    return GestureDetector(
      onTap: () => provider.toggleStatus(rawValue),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEAEAEA) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.grey[400]! : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildCarRowItem(dynamic car) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    final price = currencyFormat
        .format(car['cash_price'] ?? 0)
        .replaceAll("Rp", "+Rp");
    final status = car['status'] ?? 'AVAILABLE';

    Color badgeColor;
    Color textColor;
    String statusLabel;

    switch (status) {
      case 'BOOKING':
        badgeColor = const Color(0xFFD0E6FF);
        textColor = const Color(0xFF1A73E8);
        statusLabel = 'Booked';
        break;
      case 'SOLD':
        badgeColor = const Color(0xFFE0E0E0);
        textColor = const Color(0xFF757575);
        statusLabel = 'Sold';
        break;
      default:
        badgeColor = const Color(0xFFD4F7DF);
        textColor = const Color(0xFF137333);
        statusLabel = 'Ready';
    }

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: CachedNetworkImage(
              imageUrl: car['car_cover'] ?? '',
              width: 90,
              height: 65,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[200],
                child: const Icon(Icons.image, color: Colors.grey),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[300],
                child: const Icon(Icons.broken_image),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  car['name'] ?? '-',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF222222),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${car['car_year']} · ${car['fuel_type']} · ${car['current_mileage']}",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 2),
                Text(
                  car['store_location']?['name'] ?? 'Jabodetabek',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationBar(StockCarProvider provider) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 16),
            onPressed: provider.currentPage > 1
                ? () => provider.fetchCars(page: provider.currentPage - 1)
                : null,
          ),
          Text(
            "Halaman ${provider.currentPage} dari ${provider.lastPage}",
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, size: 16),
            onPressed: provider.currentPage < provider.lastPage
                ? () => provider.fetchCars(page: provider.currentPage + 1)
                : null,
          ),
        ],
      ),
    );
  }
}
