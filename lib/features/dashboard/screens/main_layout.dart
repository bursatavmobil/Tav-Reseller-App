import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reseller_app_tav/features/auth/providers/auth_provider.dart';
import 'package:reseller_app_tav/features/auth/screens/login_screen.dart';
import 'package:reseller_app_tav/features/dashboard/screens/negosiasi_chat_screen.dart';
import 'package:reseller_app_tav/features/dashboard/screens/profile_page.dart';
import 'package:reseller_app_tav/features/dashboard/screens/saldo_screen.dart';
import 'package:reseller_app_tav/features/dashboard/screens/stock_car_screen.dart';
import 'package:reseller_app_tav/features/dashboard/screens/visit_schedule_screen.dart';
import 'package:reseller_app_tav/features/dashboard/widgets/chart/penjualan_chart.dart';
import 'package:reseller_app_tav/features/dashboard/widgets/dashboard_overview_card.dart';
import 'package:reseller_app_tav/features/dashboard/widgets/profile/kyc_getkeeper_modal.dart';
import 'package:reseller_app_tav/features/dashboard/widgets/profile/kyc_no_verif_view.dart';
import 'package:reseller_app_tav/features/dashboard/widgets/tarik_saldo_modal.dart';

import '../../../core/theme/app_theme.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/cards/list_riwayat_terjual.dart';
import '../widgets/navbar.dart';
import '../widgets/sidebar.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _activeMenu = 'Dashboard';
  late final AuthProvider _authProvider;
  bool _isKycChecked = false;

  @override
  void initState() {
    super.initState();
    _authProvider = context.read<AuthProvider>();
    _authProvider.addListener(_handleAuthLogoutListener);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initDashboardAndVerifyKyc();
      }
    });
  }

  @override
  void dispose() {
    _authProvider.removeListener(_handleAuthLogoutListener);
    super.dispose();
  }

  void _initDashboardAndVerifyKyc() async {
    try {
      // Menunggu animasi Fade selesai seutuhnya sebelum mengisi data
      await Future.delayed(const Duration(milliseconds: 350));
      if (!mounted) return;

      final dashboardProvider = context.read<DashboardProvider>();
      debugPrint('[MAIN LAYOUT] Memulai pengambilan data dashboard...');
      await dashboardProvider.loadDashboardData();

      if (!mounted) return;

      final currentProfile = dashboardProvider.profile;

      if (currentProfile != null) {
        if (!_isKycChecked) {
          setState(() {
            _isKycChecked = true;
          });

          KycGatekeeperModal.checkAndShow(
            context,
            currentProfile,
            onKycSuccess: () {
              if (mounted) {
                setState(() {
                  _isKycChecked = false;
                });
                _initDashboardAndVerifyKyc();
              }
            },
          );
        }
      } else {
        debugPrint('[MAIN LAYOUT ERROR] profile bernilai NULL.');
      }
    } catch (e) {
      debugPrint('[MAIN LAYOUT EXCEPTION] $e');
    }
  }

  void _handleAuthLogoutListener() {
    if (_authProvider.userName == null && mounted) {
      debugPrint(
        '[MAIN LAYOUT] Sesi kosong terdeteksi via Listener. Mengalihkan ke LoginScreen...',
      );

      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // PERBAIKAN ANIMASI OUT: Menggunakan Fade murni linier tanpa bounce/slide meluncur
            return FadeTransition(
              opacity: CurvedAnimation(parent: animation, curve: Curves.linear),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 250),
        ),
        (route) => false,
      );
    }
  }

  Widget _buildContent() {
    final dashboardProvider = context.watch<DashboardProvider>();
    final profile = dashboardProvider.profile;

    if (dashboardProvider.isLoading && profile == null) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            AppTheme.primaryButtonContainer,
          ),
        ),
      );
    }

    bool isNotApproved =
        profile == null || profile.status?.toLowerCase() != "approved";

    switch (_activeMenu) {
      case 'Dashboard':
        if (isNotApproved) {
          return const KycRestrictionWidget(
            message:
                "Akun Anda belum diverifikasi atau belum disetujui oleh admin. Hubungi admin untuk membuka akses menu Stok Mobil.",
          );
        }
        return _buildDashboardPage();

      case 'Stok Mobil':
        if (isNotApproved) {
          return const KycRestrictionWidget(
            message:
                "Akun Anda belum diverifikasi atau belum disetujui oleh admin. Hubungi admin untuk membuka akses menu Stok Mobil.",
          );
        }
        return const StockCarScreen();

      case 'Jadwal Kunjungan':
        if (isNotApproved) {
          return const KycRestrictionWidget(
            message:
                "Akses menu Jadwal Kunjungan dibatasi hingga akun Anda resmi disetujui oleh admin.",
          );
        }
        return const VisitScheduleScreen();

      case 'Saldo & Komisi':
        if (isNotApproved) {
          return const KycRestrictionWidget(
            message:
                "Fitur Saldo & Komisi Finansial hanya dapat diakses oleh mitra akun yang telah terverifikasi.",
          );
        }
        return const SaldoScreen();

      case 'Chat Negosiasi':
        if (isNotApproved) {
          return const KycRestrictionWidget(
            message:
                "Fitur Saldo & Komisi Finansial hanya dapat diakses oleh mitra akun yang telah terverifikasi.",
          );
        }
        return const NegosiasiChatScreen();

      case 'Profil':
        return const ProfilePage();

      default:
        return _buildDashboardPage();
    }
  }

  Widget _buildDashboardPage() {
    return RefreshIndicator(
      onRefresh: () async {
        if (mounted) {
          setState(() {
            _isKycChecked = false;
          });
          _initDashboardAndVerifyKyc();
        }
      },
      color: AppTheme.primaryButtonContainer,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Consumer<DashboardProvider>(
              builder: (context, dashboardProvider, child) {
                if (dashboardProvider.isLoading &&
                    dashboardProvider.saldoKeuntungan == 0) {
                  return const SizedBox(
                    height: 300,
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.primaryButtonContainer,
                        ),
                      ),
                    ),
                  );
                }

                return Column(
                  children: [
                    DashboardOverviewCards(
                      saldoKeuntungan: dashboardProvider.saldoKeuntungan,
                      pemasukanBulanIni: dashboardProvider.pemasukanBulanIni,
                      unitTerjual: dashboardProvider.unitTerjual,
                      persentasePemasukan: 0.0,
                      persentaseUnit: 0.0,
                      onTarikSaldoPressed: () => TarikSaldoModal.show(context),
                      onLihatDetailPressed: () {
                        setState(() {
                          _activeMenu = "Saldo & Komisi";
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    const PenjualanChartCard(),
                    const SizedBox(height: 20),
                    const RiwayatMobilTerjualCard(),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTheme.bgMainScreen,
      appBar: Navbar(scaffoldKey: _scaffoldKey),
      drawer: Sidebar(
        activeMenu: _activeMenu,
        onMenuSelected: (menuName) {
          setState(() {
            _activeMenu = menuName;
          });
        },
      ),
      body: SafeArea(child: _buildContent()),
    );
  }
}
