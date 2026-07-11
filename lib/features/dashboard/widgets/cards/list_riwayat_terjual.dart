import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:reseller_app_tav/features/dashboard/providers/dashboard_provider.dart';

class RiwayatMobilTerjualCard extends StatelessWidget {
  const RiwayatMobilTerjualCard({super.key});

  String _formatTanggal(String dateStr) {
    try {
      final DateTime dt = DateTime.parse(dateStr);
      return DateFormat('d MMMM yyyy', 'id_ID').format(dt);
    } catch (e) {
      return dateStr;
    }
  }

  String _formatKeJuta(int nominal) {
    double juta = nominal / 1000000;
    if (juta % 1 == 0) {
      return "+${juta.toStringAsFixed(0)} Juta";
    }
    return "+${juta.toStringAsFixed(1)} Juta";
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DashboardProvider>();
    final listMobil = provider.riwayatMobilTerjual;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Riwayat Komisi",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4A4A4A),
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 12),
          if (listMobil.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  "Belum ada riwayat penjualan mobil",
                  style: TextStyle(
                    color: Colors.grey,
                    fontFamily: 'Montserrat',
                    fontSize: 13,
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: listMobil.length,
              separatorBuilder: (context, index) => const Divider(
                color: Color(0xFFF5F5F5),
                height: 24,
                thickness: 1,
              ),
              itemBuilder: (context, index) {
                final item = listMobil[index];
                final order = item.order;
                final car = order?.car;

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: car?.carCover != null && car!.carCover.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: car.carCover,
                              width: 54,
                              height: 54,
                              fit: BoxFit.cover,
                              cacheKey: item.updatedAt.isNotEmpty
                                  ? item.updatedAt
                                  : item.createdAt,
                              placeholder: (context, url) => Container(
                                width: 54,
                                height: 54,
                                color: Colors.grey[100],
                                child: const Center(
                                  child: SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Color(0xFFE52525),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                width: 54,
                                height: 54,
                                color: Colors.grey[200],
                                child: const Icon(
                                  Icons.directions_car,
                                  color: Colors.grey,
                                  size: 24,
                                ),
                              ),
                            )
                          : Container(
                              width: 54,
                              height: 54,
                              color: Colors.grey[200],
                              child: const Icon(
                                Icons.directions_car,
                                color: Colors.grey,
                                size: 24,
                              ),
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            car?.name ?? "Unit Mobil Terjual",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1D1D1D),
                              fontFamily: 'Montserrat',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${_formatTanggal(item.createdAt)}  •  ${order?.orderType ?? 'CASH'}  •  ${car?.currentMileage ?? '-'} ",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: item.nominal >= 2000000
                                ? const Color(0xFFE2F9EC)
                                : const Color(0xFFEAEAEA),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            item.nominal >= 2000000 ? "Cair" : "Pending",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: item.nominal >= 2000000
                                  ? const Color(0xFF28C76F)
                                  : const Color(0xFF6E6E6E),
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _formatKeJuta(item.nominal),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4A4A4A),
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}
