import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RiwayatPenarikanList extends StatelessWidget {
  final List<dynamic> listPenarikan;

  const RiwayatPenarikanList({super.key, required this.listPenarikan});

  String _formatRupiah(int value) {
    String str = value.toString();
    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return str.replaceAllMapped(reg, (Match match) => '${match[1]}.');
  }

  String _formatDateTime(String rawDate) {
    try {
      DateTime parsed = DateTime.parse(rawDate).toLocal();
      return DateFormat('dd MMMM yyyy, HH:mm', 'id_ID').format(parsed);
    } catch (_) {
      return rawDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4.0, top: 18.0, bottom: 10.0),
          child: Text(
            'Riwayat Penarikan Saldo',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF222222),
              fontFamily: 'Montserrat',
            ),
          ),
        ),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFEAEAEA), width: 1.5),
          ),
          child: listPenarikan.isEmpty
              ? Container(
                  padding: const EdgeInsets.all(24.0),
                  alignment: Alignment.center,
                  child: Text(
                    'Belum ada riwayat penarikan saldo.',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontFamily: 'Montserrat',
                      fontSize: 13,
                    ),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: listPenarikan.length,
                  separatorBuilder: (context, index) => const Divider(
                    color: Color(0xFFF1F1F1),
                    thickness: 1,
                    height: 1,
                  ),
                  itemBuilder: (context, index) {
                    final item = listPenarikan[index];
                    final String bank = item['bank']?.toString() ?? '-';
                    final String noRekening =
                        item['no_rekening']?.toString() ?? '-';
                    final String createdAt =
                        item['created_at']?.toString() ?? '';
                    final int nominal = (item['nominal'] as num? ?? 0).toInt();
                    final String status =
                        item['status']?.toString().toLowerCase() ?? 'diajukan';

                    Color badgeBgColor = const Color(0xFFFFF4E5);
                    Color badgeTextColor = const Color(0xFFFF9800);
                    String statusText = 'Diajukan';

                    if (status == 'sukses') {
                      badgeBgColor = const Color(0xFFE8F9EE);
                      badgeTextColor = const Color(0xFF27AE60);
                      statusText = 'Sukses';
                    } else if (status == 'gagal' || status == 'ditolak') {
                      badgeBgColor = const Color(0xFFFFEAEA);
                      badgeTextColor = const Color(0xFFE52525);
                      statusText = 'Gagal';
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF8F9FA),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.account_balance_wallet_outlined,
                              color: Color(0xFF666666),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$bank - $noRekening',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF222222),
                                    fontFamily: 'Montserrat',
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatDateTime(createdAt),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[500],
                                    fontFamily: 'Montserrat',
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '-Rp ${_formatRupiah(nominal)}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF222222),
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: badgeBgColor,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  statusText,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: badgeTextColor,
                                    fontFamily: 'Montserrat',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
