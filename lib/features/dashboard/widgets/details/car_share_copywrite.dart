import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CarShareFormat extends StatefulWidget {
  final Map<String, dynamic> car;

  const CarShareFormat({super.key, required this.car});

  @override
  State<CarShareFormat> createState() => _CarShareFormatState();
}

class _CarShareFormatState extends State<CarShareFormat>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final currencyFormat = NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _getMarketplaceText() {
    final cashPrice = currencyFormat.format(widget.car['cash_price'] ?? 0);
    final creditPrice = currencyFormat.format(widget.car['credit_price'] ?? 0);
    return "DIJUAL: ${widget.car['name'] ?? '-'}\n\n"
        "Spesifikasi Utama:\n"
        "- Tahun: ${widget.car['car_year'] ?? '-'}\n"
        "- Jarak Tempuh: ${widget.car['current_mileage'] ?? '-'} Km\n"
        "- Transmisi: ${widget.car['transmission']?['name'] ?? '-'}\n"
        "- Bahan Bakar: ${widget.car['fuel_type'] ?? '-'}\n"
        "- Lokasi: ${widget.car['store_location']?['name'] ?? 'TAV Mobil'}\n\n"
        "Harga Terbaik:\n"
        "Harga Cash: $cashPrice\n"
        "Harga Kredit: $creditPrice\n\n"
        "Kondisi mobil sangat terawat, siap pakai, dokumen lengkap terjamin aman.";
  }

  String _getSocialMediaText() {
    final cashPrice = currencyFormat.format(widget.car['cash_price'] ?? 0);
    final creditPrice = currencyFormat.format(widget.car['credit_price'] ?? 0);
    return "🔥 *DIJUAL CEPAT: ${widget.car['name'] ?? '-'}* 🔥\n\n"
        "📍 *Spesifikasi Kendaraan:*\n"
        "• Tahun: ${widget.car['car_year'] ?? '-'}\n"
        "• Jarak Tempuh: ${widget.car['current_mileage'] ?? '-'} Km\n"
        "• Transmisi: ${widget.car['transmission']?['name'] ?? '-'}\n"
        "• Bahan Bakar: ${widget.car['fuel_type'] ?? '-'}\n"
        "• Lokasi Unit: ${widget.car['store_location']?['name'] ?? 'TAV Mobil'}\n\n"
        "💰 *Penawaran Harga Terbaik:*\n"
        "💵 Harga Cash: $cashPrice\n"
        "💳 Harga Kredit: $creditPrice\n\n"
        "Segera hubungi kami untuk informasi lebih lanjut dan jadwalkan inspeksi unit! 🚗💨";
  }

  void _copyToClipboard() {
    final textToCopy = _tabController.index == 0
        ? _getMarketplaceText()
        : _getSocialMediaText();
    Clipboard.setData(ClipboardData(text: textToCopy)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Format konten berhasil disalin!'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Format Konten Reseller',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              fontFamily: 'Montserrat',
              color: Color(0xFF222222),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 3,
                child: TabBar(
                  controller: _tabController,
                  isScrollable: false,
                  labelColor: const Color(0xFFE52320),
                  unselectedLabelColor: Colors.grey,
                  labelStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Montserrat',
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Montserrat',
                  ),
                  indicatorColor: const Color(0xFFE52320),
                  indicatorWeight: 2,
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelPadding: EdgeInsets.zero,
                  tabs: const [
                    Tab(text: 'Marketplace'),
                    Tab(text: 'WA / IG'),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              InkWell(
                onTap: _copyToClipboard,
                borderRadius: BorderRadius.circular(4),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.copy_rounded,
                        size: 14,
                        color: Color(0xFFE52320),
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Copy',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE52320),
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFEAEAEA)),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F9F9),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFEAEAEA)),
            ),
            child: AnimatedBuilder(
              animation: _tabController,
              builder: (context, child) {
                return Text(
                  _tabController.index == 0
                      ? _getMarketplaceText()
                      : _getSocialMediaText(),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF444444),
                    height: 1.6,
                    fontFamily: 'Montserrat',
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
