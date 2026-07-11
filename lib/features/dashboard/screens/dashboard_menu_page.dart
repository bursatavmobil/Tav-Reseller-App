import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reseller_app_tav/features/dashboard/providers/dashboard_provider.dart';
import 'package:reseller_app_tav/features/dashboard/widgets/dashboard_overview_card.dart';

class DashboardMenuPage extends StatefulWidget {
  const DashboardMenuPage({super.key});

  @override
  State<DashboardMenuPage> createState() => _DashboardMenuPageState();
}

class _DashboardMenuPageState extends State<DashboardMenuPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().loadDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Agen'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<DashboardProvider>().loadDashboardData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Consumer<DashboardProvider>(
                builder: (context, dashboardProvider, child) {
                  if (dashboardProvider.isLoading) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40.0),
                        child: CircularProgressIndicator(color: Colors.black),
                      ),
                    );
                  }

                  if (dashboardProvider.errorMessage != null) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                        child: Column(
                          children: [
                            Text(
                              'Gagal memuat data keuangan: ${dashboardProvider.errorMessage}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.red),
                            ),
                            TextButton(
                              onPressed: () =>
                                  dashboardProvider.loadDashboardData(),
                              child: const Text('Coba Lagi'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return DashboardOverviewCards(
                    saldoKeuntungan: dashboardProvider.saldoKeuntungan,
                    pemasukanBulanIni: dashboardProvider.pemasukanBulanIni,
                    unitTerjual: dashboardProvider.unitTerjual,
                    persentasePemasukan: -6.5,
                    persentaseUnit: 6.5,
                    onTarikSaldoPressed: () {
                      debugPrint('Tombol Tarik Saldo Ditekan');
                    },
                    onLihatDetailPressed: () {
                      debugPrint('Tombol Lihat Detail Ditekan');
                    },
                  );
                },
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
