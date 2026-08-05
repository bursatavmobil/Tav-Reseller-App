import 'package:flutter/material.dart';
import 'package:reseller_app_tav/features/dashboard/models/profile_response_model.dart';
import 'package:reseller_app_tav/features/dashboard/widgets/profile/kyc_multistepform_modal.dart';
import 'package:reseller_app_tav/features/dashboard/widgets/profile/kyc_privasi_kebijakan_modal.dart';
import 'package:reseller_app_tav/features/dashboard/widgets/profile/kyc_status_progress.dart';

class KycGatekeeperModal {
  static void checkAndShow(
    BuildContext context,
    ProfileData profile, {
    required VoidCallback onKycSuccess,
  }) {
    if (!Navigator.canPop(context) &&
        ModalRoute.of(context)?.isCurrent == false) {
      debugPrint(
        '[KYC GATEKEEPER] Dicegah meletup karena rute saat ini berada di luar otentikasi/sedang transisi.',
      );
      return;
    }

    final String status = (profile.status).toLowerCase().trim();
    final dynamic agenData = profile.agenData;
    final int? agenId = _getAgenId(profile);

    debugPrint('[KYC GATEKEEPER] Memeriksa status akun: "$status"');

    if (status == 'new') {
      _showBouncingDialog(
        context: context,
        title: "Selamat Datang!",
        description:
            "Silakan melengkapi verifikasi data dokumen KYC terlebih dahulu untuk mengaktifkan seluruh fitur reseller Anda.",
        buttonText: "Isi Dokumen KYC",
        icon: Icons.assignment_ind_rounded,
        iconColor: const Color(0xFFE52525),
        onPressed: () {
          if (ModalRoute.of(context)?.isCurrent == true) {
            Navigator.of(context).pop();

            KycPrivacyAgreementModal.show(
              context,
              onAccept: () {
                _showMultiStepForm(context, onKycSuccess);
              },
            );
          }
        },
      );
      return;
    }

    if (status == 'submission' && (agenData != null || agenId != null)) {
      _showStatusStepper(context, status);
      return;
    }

    if (status == 'submission' || status == 'in_review') {
      _showStatusStepper(context, status);
      return;
    }

    if (status == 'suspended') {
      // 🟢 DIUBAH: Teruskan objek profile secara utuh ke dialog suspended
      _showSuspendedDialog(context, profile, onKycSuccess);
      return;
    }
  }

  static int? _getAgenId(ProfileData profile) {
    if (profile.id != 0) return profile.id;
    final dynamic agenData = profile.agenData;
    if (agenData == null) return null;
    try {
      if (agenData is Map) {
        return agenData['agen_id'] as int?;
      }
    } catch (_) {}
    return null;
  }

  static void _showBouncingDialog({
    required BuildContext context,
    required String title,
    required String description,
    required String buttonText,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onPressed,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 500),
          curve: Curves.elasticOut,
          builder: (context, value, child) {
            return Transform.scale(scale: value, child: child);
          },
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 60, color: iconColor),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE52525),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        if (ModalRoute.of(dialogContext)?.isCurrent == true) {
                          Navigator.of(dialogContext).pop();
                          KycPrivacyAgreementModal.show(
                            context,
                            onAccept: () {
                              _showMultiStepForm(context, onPressed);
                            },
                          );
                        }
                      },
                      child: Text(
                        buttonText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // 🟢 PERBAIKAN DEKLARASI FUNGSI: Menerima kycId dan profileData secara resmi
  static void _showMultiStepForm(
    BuildContext context,
    VoidCallback onKycSuccess, {
    int? kycId,
    ProfileData? profileData,
  }) {
    if (!context.mounted) return;
    
    // 🔍 LOG DEBUG PENGIRIMAN DIALOG
    debugPrint('==================================================');
    debugPrint('[GATEKEEPER DIALOG] Memicu showGeneralDialog...');
    debugPrint('Mengirim kycId ke Form Modal      : $kycId');
    debugPrint('Mengirim profileData ke Form Modal : ${profileData?.name}');
    debugPrint('==================================================');

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, a1, a2) => KycMultiStepFormModal(
        onSuccess: onKycSuccess,
        kycId: kycId,                  // 🟢 TERUSKAN KE MULTISTEP FORM
        profileData: profileData,      // 🟢 TERUSKAN KE MULTISTEP FORM
      ),
    );
  }

  static void _showStatusStepper(BuildContext context, String status) {
    final String cleanStatus = status.toLowerCase().trim();
    final bool isReview = cleanStatus == 'in_review';

    String statusTitle = "Status Pengajuan Data";
    String statusBadgeText = "Akun Sedang Diproses";
    String statusDescription =
        "Berikut adalah update status request pengajuan akun reseller anda:";

    if (cleanStatus == 'submission') {
      statusTitle = "Permintaan Diterima";
      statusBadgeText = "Antrean Pengajuan";
      statusDescription =
          "Selamat, request dokumen KYC Anda telah kami terima. Silakan menunggu beberapa saat untuk proses review oleh tim admin panel.";
    } else if (cleanStatus == 'in_review') {
      statusTitle = "Akun Sedang Ditinjau";
      statusBadgeText = "Sedang Ditinjau Tim Verifikasi";
      statusDescription =
          "Dokumen Anda sedang dalam proses pengecekan intensif oleh Tim Admin. Seluruh fitur akan terbuka setelah akun disetujui.";
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        elevation: 0,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _AnimatedReviewIcon(
                isReview: isReview || cleanStatus == 'submission',
              ),
              const SizedBox(height: 20),
              Text(
                statusTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Montserrat',
                  color: Color(0xFF222222),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE52525).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  statusBadgeText,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Montserrat',
                    color: Color(0xFFE52525),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                statusDescription,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF666666),
                  fontSize: 13,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 28),
              KycStatusStepper(currentStatus: cleanStatus),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: const StadiumBorder(),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Mengerti",
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void _showSuspendedDialog(
    BuildContext context,
    ProfileData profile,
    VoidCallback onKycSuccess,
  ) {
    final int? currentKycId = _getAgenId(profile);

    // 🔍 LOG DEBUG AWAL DIALOG SUSPENDED
    debugPrint('==================================================');
    debugPrint('[GATEKEEPER] Menampilkan Dialog Suspended...');
    debugPrint('Data ID Agen Terbaca  : $currentKycId');
    debugPrint('Data Nama Agen Terbaca: ${profile.name}');
    debugPrint('==================================================');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        elevation: 0,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _AnimatedReviewIcon(isReview: true, useSuspendedIcon: true),
              const SizedBox(height: 20),
              const Text(
                "Akun Ditangguhkan",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Montserrat',
                  color: Color(0xFF222222),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE52525).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  "Perlu Pengajuan Ulang",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Montserrat',
                    color: Color(0xFFE52525),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Mohon maaf, hak akses kemitraan reseller Anda ditangguhkan sementara. Silakan lakukan pembaruan data dan kirim ulang dokumen KYC Anda untuk verifikasi ulang.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF666666),
                  fontSize: 13,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: const StadiumBorder(),
                  ),
                  onPressed: () {
                    if (ModalRoute.of(dialogContext)?.isCurrent == true) {
                      Navigator.of(dialogContext).pop();
                      
                      debugPrint('[GATEKEEPER] Menampilkan Kebijakan Privasi Kemitraan...');
                      
                      KycPrivacyAgreementModal.show(
                        context,
                        onAccept: () {
                          debugPrint('[GATEKEEPER] Klik Lanjutkan Diterima. Mengarahkan Ke Form Utama...');
                          
                          // 🟢 OPER DATA KE PARAMETER YANG SUDAH RESMI DI DEFINISIKAN
                          _showMultiStepForm(
                            context,
                            onKycSuccess,
                            kycId: currentKycId,
                            profileData: profile,
                          );
                        },
                      );
                    }
                  },
                  child: const Text(
                    "Perbarui Data KYC",
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedReviewIcon extends StatefulWidget {
  final bool isReview;
  final bool useSuspendedIcon;

  const _AnimatedReviewIcon({
    required this.isReview,
    this.useSuspendedIcon = false,
  });

  @override
  State<_AnimatedReviewIcon> createState() => _AnimatedReviewIconState();
}

class _AnimatedReviewIconState extends State<_AnimatedReviewIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: -22.5 / 360,
      end: 22.5 / 360,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (widget.isReview) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _animation,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFE52525).withOpacity(0.06),
          shape: BoxShape.circle,
        ),
        child: Icon(
          widget.useSuspendedIcon
              ? Icons.gavel_rounded
              : (widget.isReview
                    ? Icons.pending_actions_rounded
                    : Icons.cloud_done_rounded),
          size: 56,
          color: const Color(0xFFE52525),
        ),
      ),
    );
  }
}