import 'package:flutter/material.dart';
import 'package:reseller_app_tav/features/dashboard/widgets/cards/list_riwayat_terjual.dart';
import 'package:reseller_app_tav/features/dashboard/widgets/cards/riwayat_list_penarikan.dart';
import 'package:reseller_app_tav/features/dashboard/widgets/cards/saldo_overview_card.dart';
import 'package:reseller_app_tav/features/dashboard/widgets/tarik_saldo_modal.dart';

import '../../auth/services/auth_service.dart';
import '../services/saldo_service.dart';

class SaldoScreen extends StatefulWidget {
  const SaldoScreen({super.key});

  @override
  State<SaldoScreen> createState() => _SaldoScreenState();
}

class _SaldoScreenState extends State<SaldoScreen> {
  final SaldoService _saldoService = SaldoService();
  final AuthApiService _authService = AuthApiService();

  bool _isLoading = true;
  String? _errorMessage;

  int _totalPemasukan = 0;
  int _totalPengeluaran = 0;
  int _saldoKeuntungan = 0;
  List<dynamic> _rawPenarikanList = [];

  @override
  void initState() {
    super.initState();
    _loadSaldoData();
  }

  Future<void> _loadSaldoData() async {
    try {
      if (!mounted) return;
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final komisiResponse = await _saldoService.fetchRiwayatKomisi(
        page: 1,
        perPage: 100,
      );

      int hitungPemasukan = 0;
      if (komisiResponse['status'] == true && komisiResponse['data'] != null) {
        final Map<String, dynamic> dataPayload = komisiResponse['data'];
        final List<dynamic> listKomisi = dataPayload['result'] ?? [];

        for (var item in listKomisi) {
          hitungPemasukan += (item['nominal'] as num? ?? 0).toInt();
        }
      }

      final penarikanResponse = await _saldoService.fetchRiwayatPenarikan(
        page: 1,
        perPage: 100,
      );

      int hitungPengeluaran = 0;
      List<dynamic> listPenarikanMentah = [];

      if (penarikanResponse['status'] == true &&
          penarikanResponse['data'] != null) {
        final Map<String, dynamic> dataPayloadPenarikan =
            penarikanResponse['data'];
        listPenarikanMentah = dataPayloadPenarikan['result'] ?? [];

        for (var item in listPenarikanMentah) {
          final String status = item['status']?.toString().toLowerCase() ?? '';
          if (status == 'sukses' || status == 'diajukan') {
            hitungPengeluaran += (item['nominal'] as num? ?? 0).toInt();
          }
        }
      }

      if (!mounted) return;
      setState(() {
        _totalPemasukan = hitungPemasukan;
        _totalPengeluaran = hitungPengeluaran;
        _saldoKeuntungan = _totalPemasukan - _totalPengeluaran;
        _rawPenarikanList = listPenarikanMentah;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE52525)),
                ),
              )
            : RefreshIndicator(
                onRefresh: _loadSaldoData,
                color: const Color(0xFFE52525),
                child: ScrollConfiguration(
                  behavior: const ScrollBehavior().copyWith(overscroll: false),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 20.0,
                    ),
                    child: _errorMessage != null
                        ? Container(
                            height: MediaQuery.of(context).size.height * 0.6,
                            alignment: Alignment.center,
                            child: Text(
                              _errorMessage!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SaldoOverviewCards(
                                saldoKeuntungan: _saldoKeuntungan,
                                totalPemasukan: _totalPemasukan,
                                onTarikSaldoPressed: () {
                                  TarikSaldoModal.show(context);
                                },
                              ),

                              const SizedBox(height: 8),

                              RiwayatPenarikanList(
                                listPenarikan: _rawPenarikanList,
                              ),
                              const SizedBox(height: 8),
                              const RiwayatMobilTerjualCard(),
                            ],
                          ),
                  ),
                ),
              ),
      ),
    );
  }
}
