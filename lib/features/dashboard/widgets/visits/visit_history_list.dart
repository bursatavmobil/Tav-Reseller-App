import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reseller_app_tav/features/dashboard/models/visit_schedule_model.dart';
import 'package:reseller_app_tav/features/dashboard/providers/visit_schedule_provider.dart';

import 'visit_detail_modal.dart';

class VisitHistoryList extends StatelessWidget {
  final List<VisitScheduleItem> items;
  final Function(VisitScheduleItem) onEdit;

  const VisitHistoryList({
    super.key,
    required this.items,
    required this.onEdit,
  });

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'aktif':
        return const Color.fromARGB(255, 39, 142, 174);
      case 'sukses':
        return const Color.fromARGB(255, 39, 174, 46);
      case 'negosiasi':
        return const Color(0xFF27AE60);
      case 'menunggu':
      case 'pending':
        return const Color(0xFFE67E22);
      case 'dibatalkan':
      case 'cancelled':
      case 'cancel':
        return const Color(0xFF8E8E8E);
      default:
        return const Color(0xFF8E8E93);
    }
  }

  void _confirmCancel(BuildContext context, int id) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) => const SizedBox.shrink(),
      transitionBuilder: (dialogContext, anim1, anim2, child) {
        return Transform.scale(
          scale: CurvedAnimation(parent: anim1, curve: Curves.bounceOut).value,
          child: FadeTransition(
            opacity: anim1,
            child: AlertDialog(
              backgroundColor: const Color(0xFF1A1A1A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: const Color(0xFFE52525).withOpacity(0.4),
                  width: 1.5,
                ),
              ),
              title: Row(
                children: const [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Color(0xFFE52525),
                    size: 22,
                  ),
                  SizedBox(width: 10),
                  Text(
                    "Batal Kunjungan",
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              content: const Text(
                "Apakah Anda yakin ingin membatalkan rencana jadwal kunjungan ini?",
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  color: Color(0xFF8E8E93),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                ),
              ),
              actionsPadding: const EdgeInsets.only(
                right: 16,
                bottom: 16,
                left: 16,
              ),
              actions: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF2C2C2E)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          "Kembali",
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            color: Color(0xFF8E8E93),
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(dialogContext);
                          await context
                              .read<VisitScheduleProvider>()
                              .cancelSchedule(id);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE52525),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          "Ya, Batalkan",
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 80.0),
          child: Text(
            "Belum ada riwayat kunjungan.",
            style: TextStyle(
              fontFamily: 'Montserrat',
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final String currentStatus = item.status.toLowerCase().trim();
        final bool isCancelled =
            currentStatus == 'dibatalkan' ||
            currentStatus == 'cancelled' ||
            currentStatus == 'cancel';

        final bool isCanCancel =
            (currentStatus == 'aktif' || currentStatus == 'pending') &&
            !isCancelled;
        final Color statusColor = _getStatusColor(item.status);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: isCancelled ? const Color(0xFFF4F5F6) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isCancelled
                  ? const Color(0xFFE1E3E6)
                  : const Color(0xFFEAEAEA),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isCancelled ? 0.01 : 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: InkWell(
            onTap: () => VisitDetailModal.show(context, item),
            borderRadius: BorderRadius.circular(14),
            child: Stack(
              children: [
                Positioned(
                  top: 6,
                  left: -26,
                  child: Transform.rotate(
                    angle: -math.pi / 4,
                    child: Container(
                      width: 90,
                      height: 20,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: statusColor,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Text(
                        item.status.toUpperCase(),
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 44.0,
                    top: 14.0,
                    right: 14.0,
                    bottom: 14.0,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.tipe.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                backgroundColor: Colors.transparent,
                                fontWeight: FontWeight.w900,
                                fontSize: 10,
                                letterSpacing: 0.5,
                                color: isCancelled
                                    ? const Color(0xFF8E8E93)
                                    : const Color(0xFF666666),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              item.namaKonsumen,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                color: isCancelled
                                    ? const Color(0xFF666666)
                                    : const Color(0xFF1A1A1A),
                              ),
                            ),
                            if (item.car != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                "${item.car!.name} (${item.car!.noPlat.toUpperCase()})",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isCancelled
                                      ? const Color(0xFF8E8E93)
                                      : const Color(0xFF666666),
                                ),
                              ),
                            ],
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(
                                  Icons.access_time_rounded,
                                  size: 12,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "${item.tanggal} • ${item.jam}",
                                  style: const TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 11,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!isCancelled) ...[
                            IconButton(
                              icon: const Icon(
                                Icons.edit_note_rounded,
                                color: Colors.black87,
                                size: 24,
                              ),
                              tooltip: 'Edit Kunjungan',
                              onPressed: () => onEdit(item),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                          if (isCanCancel) ...[
                            const SizedBox(height: 12),
                            IconButton(
                              icon: const Icon(
                                Icons.cancel_presentation_rounded,
                                color: Color(0xFFE52525),
                                size: 20,
                              ),
                              tooltip: 'Batalkan Kunjungan',
                              onPressed: () => _confirmCancel(context, item.id),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
