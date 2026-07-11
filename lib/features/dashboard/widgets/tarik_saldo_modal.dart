import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:reseller_app_tav/core/theme/app_assets.dart';
import 'package:reseller_app_tav/core/widget/cutsom_alert_widget.dart';
import 'package:reseller_app_tav/core/widget/tarik_saldo_success_dialog.dart';

import '../providers/dashboard_provider.dart';

class TarikSaldoModal extends StatefulWidget {
  const TarikSaldoModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const TarikSaldoModal(),
    );
  }

  @override
  State<TarikSaldoModal> createState() => _TarikSaldoModalState();
}

class _TarikSaldoModalState extends State<TarikSaldoModal> {
  final TextEditingController _nominalController = TextEditingController(
    text: '0',
  );
  int _nominalRaw = 0;

  String _formatRupiah(int value) {
    String str = value.toString();
    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return str.replaceAllMapped(reg, (Match match) => '${match[1]}.');
  }

  void _updateNominal(int value) {
    setState(() {
      _nominalRaw = value;
      _nominalController.text = _formatRupiah(value);
    });
  }

  String _getBankLogo(String bankName) {
    switch (bankName.toUpperCase().trim()) {
      case 'BCA':
        return AppAssets.logoBca;
      case 'BNI':
        return AppAssets.logoBni;
      case 'BRI':
        return AppAssets.logoBri;
      case 'MANDIRI':
        return AppAssets.logoMandiri;
      default:
        return AppAssets.defaultBank;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DashboardProvider>();
    final double bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final String bankName = provider.profile?.agenData?.bank ?? 'BCA';
    final String noRek = provider.profile?.agenData?.noRekening ?? '***4421';
    final String namaPemilik =
        provider.profile?.agenData?.namaDiRekening ?? 'a/n Rangga Pratama';

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + bottomPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tarik Saldo',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Montserrat',
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(height: 1),
          const SizedBox(height: 20),
          const Text(
            'Saldo Tersedia',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Rp ${_formatRupiah(provider.saldoKeuntungan)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    fontFamily: 'Montserrat',
                  ),
                ),
                const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          const Text(
            'Nominal Pencairan',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _nominalController,
            keyboardType: TextInputType.number,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              fontFamily: 'Montserrat',
            ),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (val) {
              int parsed = int.tryParse(val) ?? 0;
              _nominalRaw = parsed;
              _nominalController.value = TextEditingValue(
                text: _formatRupiah(parsed),
                selection: TextSelection.collapsed(
                  offset: _formatRupiah(parsed).length,
                ),
              );
            },
            decoration: InputDecoration(
              prefixText: 'Rp ',
              prefixStyle: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              _buildShortcutChip('Rp 1 jt', 1000000),
              _buildShortcutChip('Rp 2.5 jt', 2500000),
              _buildShortcutChip('Rp 5 jt', 5000000),
              _buildShortcutChip('Semua', provider.saldoKeuntungan),
            ],
          ),
          const SizedBox(height: 24),

          // FIELD 3: REKENING TUJUAN
          const Text(
            'Rekening Tujuan',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: Row(
              children: [
                Image.asset(
                  _getBankLogo(bankName),
                  width: 48,
                  height: 24,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.credit_card,
                      size: 28,
                      color: Colors.grey,
                    );
                  },
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$bankName $noRek',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        namaPemilik,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Implementasi Custom Dropdown/Ubah Rekening
                  },
                  child: const Text(
                    'Ubah',
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Estimasi cair max 2 hari kerja',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
              fontStyle: FontStyle.italic,
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 28),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Colors.black54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Batal',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      fontFamily: 'Montserrat',
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
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed:
                      (_nominalRaw <= 0 ||
                          _nominalRaw > provider.saldoKeuntungan)
                      ? null
                      : () async {
                          final navigatorContext = Navigator.of(context);
                          final buildContext = context;

                          bool success = await context
                              .read<DashboardProvider>()
                              .submitPenarikan(_nominalRaw);

                          navigatorContext.pop();

                          if (success) {
                            if (buildContext.mounted) {
                              TarikSaldoSuccessDialog.show(buildContext);
                            }
                          } else {
                            if (buildContext.mounted) {
                              final errorMsg =
                                  buildContext
                                      .read<DashboardProvider>()
                                      .errorMessage ??
                                  "Gagal memproses penarikan saldo.";

                              CustomAnimatedAlert.show(
                                buildContext,
                                errorMsg,
                                false,
                              );
                            }
                          }
                        },
                  child: const Text(
                    'Lanjutkan',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShortcutChip(String label, int value) {
    return ActionChip(
      label: Text(
        label,
        style: const TextStyle(fontSize: 12, fontFamily: 'Montserrat'),
      ),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      onPressed: () => _updateNominal(value),
    );
  }
}
