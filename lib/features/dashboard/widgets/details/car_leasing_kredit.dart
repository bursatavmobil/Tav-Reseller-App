import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:reseller_app_tav/features/dashboard/services/leasing_service.dart';

class CarLeasingDetail extends StatefulWidget {
  final int carId;

  const CarLeasingDetail({super.key, required this.carId});

  @override
  State<CarLeasingDetail> createState() => _CarLeasingDetailState();
}

class _CarLeasingDetailState extends State<CarLeasingDetail> {
  final CarLeasingService _leasingService = CarLeasingService();
  late Future<List<dynamic>> _leasingFuture;

  @override
  void initState() {
    super.initState();
    _leasingFuture = _leasingService.fetchCarLeasing(widget.carId);
  }

  String _formatRupiah(num number) {
    final NumberFormat currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return currencyFormatter.format(number);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _leasingFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: const Center(
              child: CircularProgressIndicator(color: Color(0xFFE52525)),
            ),
          );
        }

        if (snapshot.hasError) {
          return Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Informasi Simulasi Leasing',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Gagal memuat data leasing: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ],
            ),
          );
        }

        final leasingList = snapshot.data ?? [];

        if (leasingList.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Text(
                    'Pembiayaan & Partner Kredit',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Montserrat',
                      color: Color(0xFF222222),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: leasingList.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final leasingGroup = leasingList[index];
                  final leasingInfo = leasingGroup['leasing'] ?? {};
                  final items = leasingGroup['items'] as List<dynamic>? ?? [];

                  final String name = leasingInfo['name'] ?? 'Leasing';
                  final String? iconUrl = leasingInfo['icon_url'];

                  return Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAFAFA),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Theme(
                      data: Theme.of(
                        context,
                      ).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        tilePadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 4,
                        ),
                        leading: iconUrl != null && iconUrl.isNotEmpty
                            ? Image.network(
                                iconUrl,
                                width: 40,
                                height: 40,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(
                                      Icons.business,
                                      color: Colors.grey,
                                      size: 30,
                                    ),
                              )
                            : const Icon(
                                Icons.business,
                                color: Colors.grey,
                                size: 30,
                              ),
                        title: Text(
                          name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        subtitle: Text(
                          '${items.length} Paket Opsi tersedia',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                            child: Column(
                              children: items.map((item) {
                                final num dp = item['down_payment'] ?? 0;
                                final num cicilan = item['cicilan'] ?? 0;
                                final int tenor = item['tenor'] ?? 0;

                                return Container(
                                  margin: const EdgeInsets.only(top: 8),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.grey.shade200,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.03),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Uang Muka (DP)',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          Text(
                                            _formatRupiah(dp),
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Divider(height: 16),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Cicilan ($tenor Bulan)',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                '${_formatRupiah(cicilan)}/bln',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFFE52525),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFFF0F0),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              '$tenor Bln',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFFE52525),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
