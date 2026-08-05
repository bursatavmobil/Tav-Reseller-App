import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:reseller_app_tav/core/theme/app_assets.dart'; // Import AppAssets
import 'package:reseller_app_tav/features/dashboard/models/negosiasi_response_model.dart';
import 'package:reseller_app_tav/features/dashboard/providers/negosiasi_provider.dart';
import 'package:reseller_app_tav/features/dashboard/widgets/negosiasi/select_customer_widget.dart';
import 'package:reseller_app_tav/features/dashboard/widgets/negosiasi/success_payment_dialog.dart';

class DetailTransaksiScreen extends StatefulWidget {
  final int transactionId;

  const DetailTransaksiScreen({super.key, required this.transactionId});

  @override
  State<DetailTransaksiScreen> createState() => _DetailTransaksiScreenState();
}

class _DetailTransaksiScreenState extends State<DetailTransaksiScreen> {
  bool _isLoading = true;
  NegotiationResult? _transactionDetail;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  void _loadDetail() async {
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });
    try {
      final service = context.read<NegotiationProvider>().negotiationService;
      final data = await service.getDetailTransaction(widget.transactionId);
      setState(() {
        _transactionDetail = data;
      });
    } catch (e) {
      setState(() {
        _errorMsg = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _formatRupiah(num? value) {
    if (value == null) return 'Rp 0';
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(value);
  }

  void _executeSendPayment(int customerId, String customerName) async {
    final provider = context.read<NegotiationProvider>();

    final result = await provider.requestTransactionPayment(
      transactionId: widget.transactionId,
      customerId: customerId,
    );

    if (context.mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        AnimatedStatusDialog.show(
          context,
          isSuccess: result['success'] == true,
          title: result['success'] == true ? "Request Sent" : "Request Failed",
          message: result['message'] ?? "Terjadi kesalahan proses data.",
        );
      });

      if (result['success'] == true) {
        _loadDetail();
      }
    }
  }

  // 🟢 POP-UP KONFIRMASI DENGAN APPASSETS.IMAGEQUESTION & BORDER GOLD PREMIUM
  void _showResendConfirmation(int customerId) {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFD4AF37), width: 1.5),
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
                        _executeSendPayment(customerId, "Customer");
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

  @override
  Widget build(BuildContext context) {
    final dynamic rawObj = _transactionDetail;
    final agenTransaksi = rawObj?.agenTransaksi;
    final String currentStatus = (agenTransaksi?.status ?? '')
        .toString()
        .toLowerCase();
    final bool isLunas =
        currentStatus == 'already_paid' || currentStatus == 'paid';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Color(0xFF1A1A1A)),
        title: const Text(
          "Detail Transaksi",
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE52525)),
              ),
            )
          : _errorMsg != null
          ? Center(
              child: Text(
                _errorMsg!,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  color: Colors.red,
                ),
              ),
            )
          : Stack(
              children: [
                Positioned.fill(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 110),
                    child: _buildContentCore(),
                  ),
                ),
                if (isLunas)
                  Positioned.fill(
                    child: ClipRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
                        child: Container(
                          color: Colors.white.withOpacity(0.12),
                          child: Center(
                            child: Transform.rotate(
                              angle: -0.25,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color(0xFFD4AF37),
                                    width: 4.5,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  color: const Color(0xFF1A1A1A).withOpacity(0.9),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFD4AF37).withOpacity(0.3),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: const Text(
                                  "L U N A S",
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 44,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFFD4AF37),
                                    letterSpacing: 6.0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 24,
                  child: _buildFloatingBottomBar(currentStatus, agenTransaksi),
                ),
              ],
            ),
    );
  }

  Widget _buildContentCore() {
    final car = _transactionDetail!.car;
    final paymentType = _transactionDetail!.paymentType.toUpperCase();
    final String statusDisplay = _transactionDetail!.status == 'ACC_CEO'
        ? 'Approved By CEO'
        : (_transactionDetail!.status == 'ACC_COO'
              ? 'Approved By COO'
              : 'Approved');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 230,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFEFEFEF),
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
                  size: 50,
                )
              : null,
        ),
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF37).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: const Color(0xFFD4AF37).withOpacity(0.4),
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      statusDisplay,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFB8860B),
                      ),
                    ),
                  ),
                  Text(
                    car?.noPlat ?? '-',
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                car?.carName ?? 'Mobil Transaksi',
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1A1A1A),
                  letterSpacing: -0.3,
                ),
              ),
              const Divider(height: 36, color: Color(0xFFF1F3F5)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Metode Pembayaran",
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 12,
                      color: Color(0xFF8E8E93),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    paymentType,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Rincian Nominal Finansial",
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1A1A1A),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Harga Awal Kendaraan",
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 12,
                      color: Color(0xFF8E8E93),
                    ),
                  ),
                  Text(
                    _formatRupiah(_transactionDetail!.startingPrice),
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 13,
                      color: Color(0xFF1A1A1A),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Harga Kesepakatan Akhir",
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  Text(
                    _formatRupiah(_transactionDetail!.negotiatedPrice),
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFE52525),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Data Akun Penawar",
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1A1A1A),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 10),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFF1F3F5),
                  child: Icon(
                    Icons.person_outline_rounded,
                    color: Color(0xFF8E8E93),
                  ),
                ),
                title: Text(
                  _transactionDetail!.bidder,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                subtitle: Text(
                  _transactionDetail!.bidderPhone,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 12,
                    color: Color(0xFF8E8E93),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingBottomBar(String currentStatus, dynamic agenTransaksi) {
    final bool isLunas =
        currentStatus == 'already_paid' || currentStatus == 'paid';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFEFEFEF), width: 1),
      ),
      padding: const EdgeInsets.all(12),
      child: currentStatus == 'send'
          ? Row(
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
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        _showResendConfirmation(agenTransaksi.userId),
                    icon: const Icon(
                      Icons.refresh_rounded,
                      size: 14,
                      color: Color(0xFFD4AF37),
                    ),
                    label: const Text(
                      "Kirim Ulang",
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFD4AF37),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFD4AF37)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            )
          : SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isLunas
                    ? null
                    : () {
                        SelectCustomerSheet.show(
                          context,
                          onSelectConfirmed: (customer) {
                            final int cid = customer['id'] is String
                                ? int.tryParse(customer['id']) ?? 0
                                : (customer['id'] ?? 0);
                            _executeSendPayment(
                              cid,
                              customer['first_name'] ?? 'Customer',
                            );
                          },
                        );
                      },
                icon: Icon(
                  isLunas ? Icons.verified_user_rounded : Icons.send_rounded,
                  size: 14,
                  color: Colors.white,
                ),
                label: Text(
                  isLunas ? "Transaksi Lunas" : "Kirim Request Pembayaran",
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
                    side: isLunas
                        ? const BorderSide(
                            color: Color(0xFFD4AF37),
                            width: 1.8,
                          )
                        : BorderSide.none,
                  ),
                  shadowColor: isLunas
                      ? const Color(0xFFD4AF37).withOpacity(0.4)
                      : Colors.transparent,
                ),
              ),
            ),
    );
  }
}