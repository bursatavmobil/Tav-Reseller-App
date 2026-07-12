import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reseller_app_tav/features/dashboard/providers/dashboard_provider.dart';
import 'package:reseller_app_tav/features/dashboard/widgets/profile/kyc_multistepform_modal.dart';

class KycRestrictionWidget extends StatelessWidget {
  final String message;

  const KycRestrictionWidget({
    super.key,
    this.message =
        "Akun Anda belum melakukan verifikasi atau belum disetujui oleh admin.",
  });

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = context.watch<DashboardProvider>();

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFFFFFAEA),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFFFE0B2), width: 2),
              ),
              child: const Icon(
                Icons.gpp_maybe_rounded,
                color: Color(0xFFF57C00),
                size: 54,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Akses Fitur Terbatas',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF222222),
                fontFamily: 'Montserrat',
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF666666),
                fontFamily: 'Montserrat',
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 180,
              height: 46,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE52525),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 2,
                ),
                onPressed: dashboardProvider.isLoading
                    ? null
                    : () {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => KycMultiStepFormModal(
                            onSuccess: () async {
                              await context
                                  .read<DashboardProvider>()
                                  .loadDashboardData();
                            },
                          ),
                        );
                      },
                icon: dashboardProvider.isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.refresh_rounded, color: Colors.white),
                label: Text(
                  dashboardProvider.isLoading ? 'Memuat...' : 'Segarkan Data',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
