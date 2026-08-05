import 'package:flutter/material.dart';
import 'package:reseller_app_tav/features/dashboard/models/visit_schedule_model.dart';

class VisitDetailModal {
  static Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'disetujui':
      case 'approved':
      case 'sukses':
        return Colors.black;
      case 'menunggu':
      case 'pending':
        return const Color(0xFF666666);
      case 'dibatalkan':
      case 'cancelled':
      case 'cancel':
        return const Color(0xFFE52525);
      default:
        return const Color(0xFF8E8E93);
    }
  }

  static void show(BuildContext context, VisitScheduleItem item) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'DetailKunjungan',
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, anim1, anim2) => const SizedBox(),
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: 0.96 + (0.04 * anim1.value),
          child: Opacity(
            opacity: anim1.value,
            child: Dialog(
              elevation: 0,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: Colors.white,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 20,
                      ),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Color(0xFFEAEAEA),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.assignment_outlined,
                                size: 20,
                                color: Colors.black,
                              ),
                              SizedBox(width: 8),
                              Text(
                                "Detail Kunjungan",
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF1A1A1A),
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
                              color: _getStatusColor(
                                item.status,
                              ).withOpacity(0.08),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              item.status.toUpperCase(),
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: _getStatusColor(item.status),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildModernDataTile(
                              icon: Icons.person_outline_rounded,
                              label: "Nama Konsumen",
                              value: item.namaKonsumen,
                            ),
                            const SizedBox(height: 12),

                            Row(
                              children: [
                                Expanded(
                                  child: _buildModernDataTile(
                                    icon: Icons.layers_outlined,
                                    label: 'Tipe Layanan',
                                    value: item.tipe,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildModernDataTile(
                                    icon: Icons.calendar_today_rounded,
                                    label: 'Waktu Temu',
                                    value:
                                        "${item.tanggal}\n${item.jam.substring(0, item.jam.length > 5 ? 5 : item.jam.length)} WIB",
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            if (item.car != null) ...[
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF9F9F9),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFEAEAEA),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.directions_car_filled_outlined,
                                          size: 14,
                                          color: Color(0xFF666666),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          "Unit Mobil Yang Dipilih"
                                              .toUpperCase(),
                                          style: const TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontSize: 9,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 0.5,
                                            color: Color(0xFF8E8E93),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: Image.network(
                                            item.car!.carCover ?? '',
                                            width: 52,
                                            height: 52,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                                  return Container(
                                                    width: 52,
                                                    height: 52,
                                                    color: const Color(
                                                      0xFFEAEAEA,
                                                    ),
                                                    child: const Icon(
                                                      Icons
                                                          .image_not_supported_outlined,
                                                      size: 18,
                                                      color: Color(0xFF8E8E93),
                                                    ),
                                                  );
                                                },
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.car!.name,
                                                style: const TextStyle(
                                                  fontFamily: 'Montserrat',
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFF1A1A1A),
                                                ),
                                              ),
                                              const SizedBox(height: 3),
                                              Text(
                                                item.car!.noPlat.toUpperCase(),
                                                style: const TextStyle(
                                                  fontFamily: 'Montserrat',
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w800,
                                                  color: Color(0xFFE52525),
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],

                            _buildModernDataTile(
                              icon: Icons.notes_rounded,
                              label: 'Catatan / Keterangan',
                              value: item.catatan.isEmpty
                                  ? 'Tidak ada catatan tambahan untuk kunjungan ini.'
                                  : item.catatan,
                            ),
                          ],
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(
                        left: 24,
                        right: 24,
                        bottom: 24,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: const StadiumBorder(),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            "Tutup Detail",
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  static Widget _buildModernDataTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEAEAEA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: const Color(0xFF666666)),
              const SizedBox(width: 6),
              Text(
                label.toUpperCase(),
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  color: Color(0xFF8E8E93),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
