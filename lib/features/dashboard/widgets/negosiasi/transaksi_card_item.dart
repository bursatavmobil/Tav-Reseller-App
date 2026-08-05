import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:reseller_app_tav/core/theme/app_assets.dart';
import 'package:reseller_app_tav/features/dashboard/models/negosiasi_response_model.dart';
import 'package:reseller_app_tav/features/dashboard/providers/negosiasi_provider.dart';
import 'package:reseller_app_tav/features/dashboard/screens/detail_transaksi_screen.dart';
import 'package:reseller_app_tav/features/dashboard/widgets/negosiasi/select_customer_widget.dart';

import 'success_payment_dialog.dart';

class TransaksiItemCard extends StatelessWidget {
  final NegotiationResult negotiation;

  const TransaksiItemCard({super.key, required this.negotiation});

  String _formatRupiah(num? value) {
    if (value == null) return 'Rp 0';
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(value);
  }

  void _executeSendPayment(
    BuildContext context,
    int customerId,
    String customerName,
  ) async {
    final provider = context.read<NegotiationProvider>();

    final result = await provider.requestTransactionPayment(
      transactionId: negotiation.id,
      customerId: customerId,
    );

    if (context.mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        AnimatedStatusDialog.show(
          context,
          isSuccess: result['success'] == true,
          title: result['success'] == true ? "Permintaan Pembayaran" : "Permintaan Gagal",
          message: result['message'] ?? "Terjadi kesalahan proses data.",
        );
      });
    }
  }

  void _showResendConfirmation(BuildContext context, int customerId) {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFD4AF37), width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 90,
                width: 90,
                child: Image.asset(
                  AppAssets.imageQuestion,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.help_outline_rounded,
                      color: Color(0xFFD4AF37),
                      size: 60,
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Kirim Ulang Request",
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Apakah Anda yakin ingin mengirim ulang link tagihan pembayaran ke customer ini?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  color: Color(0xFF8E8E93),
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF333333)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text(
                        "Batal",
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          color: Color(0xFF8E8E93),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE52525),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        _executeSendPayment(context, customerId, "Customer");
                      },
                      child: const Text(
                        "Ya, Kirim",
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
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

  Widget _buildPaymentStatusBadge(String status) {
    Color badgeColor;
    Color textColor;
    String labelText;

    switch (status.toLowerCase()) {
      case 'send':
      case 'pending':
        badgeColor = const Color(0xFFD4AF37).withOpacity(0.12);
        textColor = const Color(0xFFB8860B);
        labelText = "Permintaan Terkirim";
        break;
      case 'already_paid':
      case 'paid':
        badgeColor = const Color(0xFF22C55E).withOpacity(0.12);
        textColor = const Color(0xFF22C55E);
        labelText = "Pembayaran Berhasil";
        break;
      case 'failed':
      case 'expired':
        badgeColor = const Color(0xFFE52525).withOpacity(0.12);
        textColor = const Color(0xFFE52525);
        labelText = "Pembayaran Gagal";
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: textColor.withOpacity(0.4), width: 0.6),
      ),
      child: Text(
        labelText,
        style: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 8,
          fontWeight: FontWeight.w900,
          color: textColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final car = negotiation.car;
    final paymentType = (negotiation.paymentType ?? 'CASH').toUpperCase();
    final provider = Provider.of<NegotiationProvider>(context);
    final dynamic rawObj = negotiation;
    final agenTransaksi = rawObj.agenTransaksi;
    final String currentStatus = (agenTransaksi?.status ?? '')
        .toString()
        .toLowerCase();

    final String statusDisplay = negotiation.status == 'ACC_CEO'
        ? 'Approved By CEO'
        : (negotiation.status == 'ACC_COO' ? 'Approved By COO' : 'Approved');

    return Container(
      padding: const EdgeInsets.all(14.0),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    DetailTransaksiScreen(transactionId: negotiation.id),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F3F5),
                    borderRadius: BorderRadius.circular(10),
                    image: car?.carCover != null
                        ? DecorationImage(
                            image: NetworkImage(car!.carCover!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: car?.carCover == null
                      ? const Icon(
                          Icons.directions_car_rounded,
                          color: Color(0xFF8E8E93),
                          size: 24,
                        )
                      : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: paymentType == 'CASH'
                                      ? const Color(0xFF2196F3).withOpacity(0.1)
                                      : const Color(
                                          0xFF9C27B0,
                                        ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  paymentType,
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: paymentType == 'CASH'
                                        ? const Color(0xFF1976D2)
                                        : const Color(0xFF7B1FA2),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              _buildPaymentStatusBadge(currentStatus),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD4AF37).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              statusDisplay,
                              style: const TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 8,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFB8860B),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        car?.carName ?? 'Mobil Transaksi',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Penawar: ${negotiation.bidder} (${car?.noPlat ?? ''})",
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF8E8E93),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Harga Deal:",
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF8E8E93),
                            ),
                          ),
                          Text(
                            _formatRupiah(negotiation.negotiatedPrice),
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFE52525),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 24, color: Color(0xFFEFEFEF)),
          if (currentStatus == 'send')
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: null,
                    icon: const Icon(
                      Icons.check_circle_rounded,
                      size: 14,
                      color: Color(0xFF8E8E93),
                    ),
                    label: const Text(
                      "Request Terkirim",
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF1F3F5),
                      disabledBackgroundColor: const Color(0xFFF1F3F5),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: provider.isSendingPayment
                        ? null
                        : () => _showResendConfirmation(
                            context,
                            agenTransaksi.userId,
                          ),
                    icon: provider.isSendingPayment
                        ? const SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.5,
                              valueColor: AlwaysStoppedAnimation(
                                Color(0xFFD4AF37),
                              ),
                            ),
                          )
                        : const Icon(
                            Icons.refresh_rounded,
                            size: 14,
                            color: Color(0xFFD4AF37),
                          ),
                    label: Text(
                      provider.isSendingPayment ? "Mengirim..." : "Kirim Ulang",
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFD4AF37),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFD4AF37)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            )
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed:
                    currentStatus == 'already_paid' || currentStatus == 'paid'
                    ? null
                    : () {
                        SelectCustomerSheet.show(
                          context,
                          onSelectConfirmed: (customer) {
                            final int cid = customer['id'] is String
                                ? int.tryParse(customer['id']) ?? 0
                                : (customer['id'] ?? 0);
                            _executeSendPayment(
                              context,
                              cid,
                              customer['first_name'] ?? 'Customer',
                            );
                          },
                        );
                      },
                icon: Icon(
                  currentStatus == 'already_paid' || currentStatus == 'paid'
                      ? Icons.verified_user_rounded
                      : Icons.send_rounded,
                  size: 14,
                  color: Colors.white,
                ),
                label: Text(
                  currentStatus == 'already_paid' || currentStatus == 'paid'
                      ? "Transaksi Sukses"
                      : "Kirim Request Pembayaran",
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE52525),
                  disabledBackgroundColor: const Color(0xFF1A1A1A),
                  disabledForegroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: currentStatus == 'already_paid' ||
                            currentStatus == 'paid'
                        ? const BorderSide(
                            color: Color(0xFFD4AF37),
                            width: 1.5,
                          )
                        : BorderSide.none,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}