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
        return const Color(0xFFE52525);
      default:
        return const Color(0xFF8E8E93);
    }
  }

  void _confirmCancel(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE52525).withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFFE52525),
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Batalkan Kunjungan',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Apakah Anda yakin ingin membatalkan rencana jadwal kunjungan ini?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 13,
                  color: Color(0xFF666666),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFCCCCCC)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: const StadiumBorder(),
                      ),
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text(
                        'Kembali',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE52525),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: const StadiumBorder(),
                      ),
                      onPressed: () async {
                        Navigator.pop(dialogContext);
                        await context
                            .read<VisitScheduleProvider>()
                            .cancelSchedule(id);
                      },
                      child: const Text(
                        'Ya, Batal',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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
        final bool isCanCancel =
            item.status.toLowerCase() == 'menunggu' ||
            item.status.toLowerCase() == 'pending';

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFEAEAEA), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(
                                item.status,
                              ).withOpacity(0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item.status.toUpperCase(),
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: _getStatusColor(item.status),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              item.tipe,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.namaKonsumen,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      if (item.car != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          "${item.car!.name} (${item.car!.noPlat.toUpperCase()})",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF666666),
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
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.visibility_outlined,
                        color: Colors.black87,
                        size: 20,
                      ),
                      tooltip: 'Lihat Detail',
                      onPressed: () => VisitDetailModal.show(context, item),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.edit_note_rounded,
                        color: Colors.black87,
                        size: 22,
                      ),
                      tooltip: 'Edit Kunjungan',
                      onPressed: () => onEdit(item),
                    ),
                    if (isCanCancel)
                      IconButton(
                        icon: const Icon(
                          Icons.cancel_presentation_rounded,
                          color: Color(0xFFE52525),
                          size: 20,
                        ),
                        tooltip: 'Batalkan Kunjungan',
                        onPressed: () => _confirmCancel(context, item.id),
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
}
