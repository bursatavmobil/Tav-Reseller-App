import 'dart:io';

import 'package:flutter/material.dart';
import 'package:reseller_app_tav/features/dashboard/providers/profile_provider.dart';

class KycFormTabView extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final ProfileProvider provider;

  final TextEditingController noKtpController;
  final TextEditingController tempatLahirController;
  final TextEditingController tanggalLahirController;
  final TextEditingController subDistrictController;
  final TextEditingController rtController;
  final TextEditingController rwController;
  final TextEditingController alamatController;
  final TextEditingController waDaruratController;
  final TextEditingController bankController;
  final TextEditingController namaRekeningController;
  final TextEditingController noRekeningController;

  final String jenisKelamin;
  final ValueChanged<String?> onJenisKelaminChanged;

  final File? fotoKtpFile;
  final File? fotoKtpSelfieFile;
  final File? fotoKK;

  final String? existingFotoKtpUrl;
  final String? existingFotoSelfieUrl;
  final String? existingKKUrl;

  final VoidCallback onPickFotoKtp;
  final VoidCallback onPickFotoKtpSelfie;
  final VoidCallback onPickFotoKK;
  final VoidCallback onSubmit;

  final bool isEditing;
  final bool hasExistingData;
  final VoidCallback onToggleEdit;
  final Widget? customBankDropdown;

  const KycFormTabView({
    super.key,
    required this.formKey,
    required this.provider,
    required this.noKtpController,
    required this.tempatLahirController,
    required this.tanggalLahirController,
    required this.subDistrictController,
    required this.rtController,
    required this.rwController,
    required this.alamatController,
    required this.waDaruratController,
    required this.bankController,
    required this.namaRekeningController,
    required this.noRekeningController,
    required this.jenisKelamin,
    required this.onJenisKelaminChanged,
    required this.fotoKtpFile,
    required this.fotoKtpSelfieFile,
    required this.fotoKK,
    this.existingKKUrl,
    this.existingFotoKtpUrl,
    this.existingFotoSelfieUrl,
    this.customBankDropdown,
    required this.onPickFotoKtp,
    required this.onPickFotoKtpSelfie,
    required this.onPickFotoKK,
    required this.onSubmit,
    required this.isEditing,
    required this.hasExistingData,
    required this.onToggleEdit,
  });

  @override
  State<KycFormTabView> createState() => _KycFormTabViewState();
}

class _KycFormTabViewState extends State<KycFormTabView> {
  OverlayEntry? _overlayEntry;

  void _showBouncingTooltip(BuildContext context, Offset globalPosition) {
    _overlayEntry?.remove();
    _overlayEntry = null;

    final overlay = Overlay.of(context);
    _overlayEntry = OverlayEntry(
      builder: (context) => _BouncingTooltipWidget(
        position: globalPosition,
        onDismiss: () {
          _overlayEntry?.remove();
          _overlayEntry = null;
        },
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  @override
  Widget build(BuildContext context) {
    final bool isFieldEnabled = !widget.hasExistingData || widget.isEditing;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Form(
        key: widget.formKey,
        child: Column(
          children: [
            // BANNER PETUNJUK DOUBLE TAP EDIT
            if (widget.hasExistingData && !widget.isEditing)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE52525).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFE52525).withOpacity(0.2),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.touch_app_outlined,
                      size: 16,
                      color: Color(0xFFE52525),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Petunjuk: Ketuk field 2x untuk mulai mengedit berkas KYC.',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFE52525),
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFEAEAEA), width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Formulir Validasi Dokumen KYC',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      if (widget.hasExistingData)
                        IconButton(
                          onPressed: widget.provider.isKycSaving
                              ? null
                              : widget.onToggleEdit,
                          icon: Icon(
                            widget.isEditing
                                ? Icons.close_rounded
                                : Icons.edit_note_rounded,
                            color: widget.isEditing
                                ? const Color(0xFFE52525)
                                : const Color(0xFF666666),
                            size: 24,
                          ),
                        ),
                    ],
                  ),
                  const Divider(color: Color(0xFFF0F0F0)),
                  const SizedBox(height: 8),

                  _buildInputField(
                    icon: Icons.contact_mail_outlined,
                    title: 'Nomor KTP',
                    controller: widget.noKtpController,
                    enabled: isFieldEnabled,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 14),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Jenis Kelamin',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF666666),
                        ),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: widget.jenisKelamin,
                        items: const [
                          DropdownMenuItem(
                            value: 'laki-laki',
                            child: Text(
                              'Laki-Laki',
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'perempuan',
                            child: Text(
                              'Perempuan',
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                        onChanged: isFieldEnabled
                            ? widget.onJenisKelaminChanged
                            : null,
                        decoration: InputDecoration(
                          isDense: true,
                          filled: !isFieldEnabled,
                          fillColor: isFieldEnabled
                              ? Colors.white
                              : const Color(0xFFF9F9F9),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 10,
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color(0xFFEAEAEA),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color(0xFFCCCCCC),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: _buildInputField(
                          icon: Icons.location_city,
                          title: 'Tempat Lahir',
                          controller: widget.tempatLahirController,
                          enabled: isFieldEnabled,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInputField(
                          icon: Icons.calendar_today,
                          title: 'Tanggal Lahir (YYYY-MM-DD)',
                          controller: widget.tanggalLahirController,
                          enabled: isFieldEnabled,
                          keyboardType: TextInputType.datetime,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: _buildInputField(
                          icon: Icons.pin_drop,
                          title: 'Sub District ID',
                          controller: widget.subDistrictController,
                          enabled: isFieldEnabled,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildInputField(
                          icon: Icons.explore,
                          title: 'RT',
                          controller: widget.rtController,
                          enabled: isFieldEnabled,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildInputField(
                          icon: Icons.explore,
                          title: 'RW',
                          controller: widget.rwController,
                          enabled: isFieldEnabled,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  _buildInputField(
                    icon: Icons.home_outlined,
                    title: 'Alamat Sesuai KTP',
                    controller: widget.alamatController,
                    enabled: isFieldEnabled,
                  ),
                  const SizedBox(height: 14),
                  _buildInputField(
                    icon: Icons.phone_callback,
                    title: 'No WhatsApp Darurat',
                    controller: widget.waDaruratController,
                    enabled: isFieldEnabled,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 14),

                  widget.customBankDropdown ??
                      _buildInputField(
                        icon: Icons.account_balance_outlined,
                        title: 'Nama Bank Transfer',
                        controller: widget.bankController,
                        enabled: isFieldEnabled,
                      ),
                  const SizedBox(height: 14),
                  _buildInputField(
                    icon: Icons.badge_outlined,
                    title: 'Nama Pemilik Rekening',
                    controller: widget.namaRekeningController,
                    enabled: isFieldEnabled,
                  ),
                  const SizedBox(height: 14),
                  _buildInputField(
                    icon: Icons.credit_card,
                    title: 'Nomor Rekening Bank',
                    controller: widget.noRekeningController,
                    enabled: isFieldEnabled,
                    keyboardType: TextInputType.number,
                  ),

                  const SizedBox(height: 20),
                  const Text(
                    'Unggah Dokumen Pendukung',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.85,
                    children: [
                      _buildImagePreviewBox(
                        'Foto KTP',
                        widget.fotoKtpFile,
                        widget.existingFotoKtpUrl,
                        isFieldEnabled ? widget.onPickFotoKtp : null,
                      ),
                      _buildImagePreviewBox(
                        'KTP+Selfie',
                        widget.fotoKtpSelfieFile,
                        widget.existingFotoSelfieUrl,
                        isFieldEnabled ? widget.onPickFotoKtpSelfie : null,
                      ),
                      _buildImagePreviewBox(
                        'Foto KK',
                        widget.fotoKK,
                        widget.existingKKUrl,
                        isFieldEnabled ? widget.onPickFotoKK : null,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreviewBox(
    String label,
    File? localFile,
    String? remoteUrl,
    VoidCallback? onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          color: const Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: onTap != null
                ? const Color(0xFFCCCCCC)
                : const Color(0xFFEAEAEA),
            width: 1.5,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(9),
          child: Builder(
            builder: (context) {
              if (localFile != null) {
                return Image.file(
                  localFile,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                );
              }

              if (remoteUrl != null && remoteUrl.isNotEmpty) {
                return Image.network(
                  remoteUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  headers: const {'Accept': 'application/json'},
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: const Color(0xFFF5F5F5),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.broken_image_outlined,
                            color: Colors.redAccent,
                            size: 24,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Gagal memuat gambar',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.camera_enhance_outlined,
                    color: onTap != null
                        ? const Color(0xFFE52525)
                        : const Color(0xFF888888),
                    size: 28,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF666666),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required IconData icon,
    required String title,
    required TextEditingController controller,
    required bool enabled,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return GestureDetector(
      onTapUp: (details) {
        if (!enabled) {
          _showBouncingTooltip(context, details.globalPosition);
        }
      },
      onDoubleTap: () {
        if (!enabled) widget.onToggleEdit();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[500],
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            enabled: enabled,
            validator: (v) =>
                v == null || v.isEmpty ? '$title wajib diisi' : null,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF222222),
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              isDense: true,
              filled: !enabled,
              fillColor: enabled ? Colors.white : const Color(0xFFF9F9F9),
              prefixIcon: Icon(icon, size: 18, color: const Color(0xFF666666)),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 10,
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFEAEAEA)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Color(0xFFE52525),
                  width: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BouncingTooltipWidget extends StatefulWidget {
  final Offset position;
  final VoidCallback onDismiss;

  const _BouncingTooltipWidget({
    required this.position,
    required this.onDismiss,
  });

  @override
  State<_BouncingTooltipWidget> createState() => _BouncingTooltipWidgetState();
}

class _BouncingTooltipWidgetState extends State<_BouncingTooltipWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _controller.forward();

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _controller.reverse().then((_) => widget.onDismiss());
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.position.dx - 100,
      top: widget.position.dy - 55,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.touch_app, color: Colors.amber, size: 14),
                SizedBox(width: 6),
                Text(
                  'Ketuk 2x untuk edit',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
