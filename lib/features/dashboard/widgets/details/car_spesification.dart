import 'package:flutter/material.dart';

class CarSpecification extends StatelessWidget {
  final Map<String, dynamic> car;

  const CarSpecification({super.key, required this.car});

  @override
  Widget build(BuildContext context) {
    final kilometer = car['current_mileage']?.toString() ?? "-";
    final transmisi = car['transmission'] is Map
        ? car['transmission']['name']?.toString() ?? "-"
        : "-";
    final bahanBakar = car['fuel_type']?.toString() ?? "-";
    final tahunRakit = car['car_year']?.toString() ?? "-";

    final merek = car['brand'] is Map
        ? car['brand']['name']?.toString() ?? "-"
        : "-";
    final model = car['car_model'] is Map
        ? car['car_model']['name']?.toString() ?? "-"
        : "-";
    final variant = car['variation'] is Map
        ? car['variation']['name']?.toString() ?? "-"
        : "-";
    final type = car['type'] is Map
        ? car['type']['name']?.toString() ?? "-"
        : "-";
    final warna = car['color'] is Map
        ? car['color']['name']?.toString() ?? "-"
        : "-";
    final plat = car['no_plat']?.toString() ?? "-";

    String tahunStnk = "-";
    if (car['stnk_validity_period'] != null &&
        car['stnk_validity_period'].toString().contains('-')) {
      tahunStnk = car['stnk_validity_period'].toString().split('-').first;
    } else if (car['stnk_year'] != null) {
      tahunStnk = car['stnk_year'].toString();
    }

    final List<dynamic> fiturList = car['car_features'] ?? [];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFEAEAEA), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Spesifikasi',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF222222),
                fontFamily: 'Montserrat',
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildHighlightBox(
                    Icons.speed_outlined,
                    'Kilometer',
                    kilometer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildHighlightBox(
                    Icons.settings_input_component_outlined,
                    'Transmisi',
                    transmisi,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildHighlightBox(
                    Icons.local_gas_station_outlined,
                    'Bahan Bakar',
                    bahanBakar,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildHighlightBox(
                    Icons.calendar_today_outlined,
                    'Tahun Rakit',
                    tahunRakit,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            _buildSpecRow('Merek', merek),
            _buildSpecRow('Model', model),
            _buildSpecRow('Variant', variant),
            _buildSpecRow('Type', type),
            _buildSpecRow('Warna', warna),
            _buildSpecRow('Plat', plat),
            _buildSpecRow('Kilometer', kilometer),
            _buildSpecRow('Tahun STNK', tahunStnk),
            const SizedBox(height: 16),

            if (fiturList.isNotEmpty) ...[
              const Divider(color: Color(0xFFEAEAEA), thickness: 1),
              const SizedBox(height: 16),
              const Text(
                'Fitur',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF222222),
                  fontFamily: 'Montserrat',
                ),
              ),
              const SizedBox(height: 16),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: fiturList.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = fiturList[index];
                  String fiturName = "-";

                  if (item is Map) {
                    fiturName = item['name']?.toString() ?? "-";
                  } else {
                    fiturName = item.toString();
                  }

                  return Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Color(0xFF34A853),
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        fiturName,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF222222),
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHighlightBox(IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEAEAEA), width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF222222), size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF777777),
                    fontFamily: 'Montserrat',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF222222),
                    fontFamily: 'Montserrat',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF555555),
              fontFamily: 'Montserrat',
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF222222),
              fontFamily: 'Montserrat',
            ),
          ),
        ],
      ),
    );
  }
}
