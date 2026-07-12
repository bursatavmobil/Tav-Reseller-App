import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:reseller_app_tav/core/widget/cutsom_alert_widget.dart';

import '../../../core/theme/app_assets.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widget/custom_logout_widget.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/screens/login_screen.dart';

class Sidebar extends StatelessWidget {
  final String activeMenu;
  final Function(String) onMenuSelected;

  const Sidebar({
    super.key,
    required this.activeMenu,
    required this.onMenuSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppTheme.bgContainerCard,
      child: SafeArea(
        child: Column(
          children: [
            DrawerHeader(
              margin: EdgeInsets.zero,
              padding: const EdgeInsets.all(16.0),
              decoration: const BoxDecoration(color: Colors.black),
              child: Center(
                child: SvgPicture.asset(AppAssets.logoReseller, width: 140),
              ),
            ),
            const SizedBox(height: 8),

            _buildDrawerItem(
              context: context,
              icon: Icons.dashboard_rounded,
              title: "Dashboard",
            ),

            _buildDrawerItem(
              context: context,
              icon: Icons.directions_car_rounded,
              title: "Stok Mobil",
            ),

            _buildDrawerItem(
              context: context,
              icon: Icons.account_balance_wallet_rounded,
              title: "Saldo & Komisi",
            ),

            _buildDrawerItem(
              context: context,
              icon: Icons.calendar_month_rounded,
              title: 'Jadwal Kunjungan',
            ),

            _buildDrawerItem(
              context: context,
              icon: Icons.message_rounded,
              title: 'Chat Negosiasi',
            ),

            _buildDrawerItem(
              context: context,
              icon: Icons.person_rounded,
              title: "Profil",
            ),

            const Spacer(),
            const Divider(height: 1, thickness: 1),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Material(
                    color: Colors.transparent,
                    child: Consumer<AuthProvider>(
                      builder: (context, authProvider, child) {
                        return InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: authProvider.isLoading
                              ? null
                              : () {
                                  CustomLogoutDialog.show(
                                    context,
                                    onCancel: () {
                                      Navigator.pop(context);
                                    },
                                    onConfirm: () async {
                                      Navigator.pop(context);

                                      try {
                                        await authProvider.logout();

                                        if (context.mounted) {
                                          CustomAnimatedAlert.show(
                                            context,
                                            "Berhasil keluar dari akun.",
                                            true,
                                          );

                                          await Future.delayed(
                                            const Duration(milliseconds: 1500),
                                          );

                                          if (context.mounted) {
                                            Navigator.pushAndRemoveUntil(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const LoginScreen(),
                                              ),
                                              (route) => false,
                                            );
                                          }
                                        }
                                      } catch (e) {
                                        if (context.mounted) {
                                          final cleanErrorMessage = e
                                              .toString()
                                              .replaceAll('Exception: ', '');
                                          CustomAnimatedAlert.show(
                                            context,
                                            cleanErrorMessage.isNotEmpty
                                                ? cleanErrorMessage
                                                : "Gagal melakukan logout.",
                                            false,
                                          );
                                        }
                                      }
                                    },
                                  );
                                },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                authProvider.isLoading
                                    ? const SizedBox(
                                        height: 16,
                                        width: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.grey,
                                              ),
                                        ),
                                      )
                                    : Text(
                                        "Keluar",
                                        style: TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.logout_rounded,
                                  color: AppTheme.primaryButtonContainer,
                                  size: 22,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
  }) {
    final bool isSelected = activeMenu == title;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        selected: isSelected,
        selectedTileColor: AppTheme.primaryButtonContainer,
        tileColor: Colors.transparent,
        leading: Icon(
          icon,
          color: isSelected ? Colors.white : AppTheme.primaryButton,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : Colors.black87,
          ),
        ),
        onTap: () {
          onMenuSelected(title);
          Navigator.pop(context);
        },
      ),
    );
  }
}
