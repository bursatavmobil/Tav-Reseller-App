import 'dart:io';

import 'package:flutter/material.dart';
import 'package:reseller_app_tav/features/dashboard/providers/profile_provider.dart';

class KycFormTabView extends StatelessWidget {
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

  // URL Gambar dari API (S3) jika sudah ada data sebelumnya
  final String? existingFotoKtpUrl;
  final String? existingFotoSelfieUrl;
  final String? existingKKUrl;

  final VoidCallback onPickFotoKtp;
  final VoidCallback onPickFotoKtpSelfie;
  final VoidCallback onPickFotoKK;
  final VoidCallback onSubmit;

  // Properti Tambahan untuk Edit Mode
  final bool isEditing;
  final bool hasExistingData;
  final VoidCallback onToggleEdit;

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
    required this.onPickFotoKtp,
    required this.onPickFotoKtpSelfie,
    required this.onPickFotoKK,
    required this.onSubmit,
    required this.isEditing,
    required this.hasExistingData,
    required this.onToggleEdit,
  });

  @override
  Widget build(BuildContext context) {
    final bool isFieldEnabled = !hasExistingData || isEditing;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Form(
        key: formKey,
        child: Column(
          children: [
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
                      if (hasExistingData)
                        IconButton(
                          onPressed: provider.isKycSaving ? null : onToggleEdit,
                          icon: Icon(
                            isEditing
                                ? Icons.close_rounded
                                : Icons.edit_note_rounded,
                            color: isEditing
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
                    controller: noKtpController,
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
                        value: jenisKelamin,
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
                            ? onJenisKelaminChanged
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
                          controller: tempatLahirController,
                          enabled: isFieldEnabled,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInputField(
                          icon: Icons.calendar_today,
                          title: 'Tanggal Lahir (YYYY-MM-DD)',
                          controller: tanggalLahirController,
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
                          controller: subDistrictController,
                          enabled: isFieldEnabled,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildInputField(
                          icon: Icons.explore,
                          title: 'RT',
                          controller: rtController,
                          enabled: isFieldEnabled,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildInputField(
                          icon: Icons.explore,
                          title: 'RW',
                          controller: rwController,
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
                    controller: alamatController,
                    enabled: isFieldEnabled,
                  ),
                  const SizedBox(height: 14),
                  _buildInputField(
                    icon: Icons.phone_callback,
                    title: 'No WhatsApp Darurat',
                    controller: waDaruratController,
                    enabled: isFieldEnabled,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 14),

                  _buildInputField(
                    icon: Icons.account_balance_outlined,
                    title: 'Nama Bank Transfer',
                    controller: bankController,
                    enabled: isFieldEnabled,
                  ),
                  const SizedBox(height: 14),
                  _buildInputField(
                    icon: Icons.badge_outlined,
                    title: 'Nama Pemilik Rekening',
                    controller: namaRekeningController,
                    enabled: isFieldEnabled,
                  ),
                  const SizedBox(height: 14),
                  _buildInputField(
                    icon: Icons.credit_card,
                    title: 'Nomor Rekening Bank',
                    controller: noRekeningController,
                    enabled: isFieldEnabled,
                    keyboardType: TextInputType.number,
                  ),

                  const SizedBox(height: 20),
                  const Text(
                    'Unggah Dokumen Pendukung',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  // Bagian Picker Image box: Tetap tampil preview di edit maupun non-edit mode
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3, // 3 kolom
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.85,
                    children: [
                      _buildImagePreviewBox(
                        'Foto KTP',
                        fotoKtpFile,
                        existingFotoKtpUrl,
                        isFieldEnabled ? onPickFotoKtp : null,
                      ),
                      _buildImagePreviewBox(
                        'KTP+Selfie',
                        fotoKtpSelfieFile,
                        existingFotoSelfieUrl,
                        isFieldEnabled ? onPickFotoKtpSelfie : null,
                      ),
                      _buildImagePreviewBox(
                        'Foto KK',
                        fotoKK,
                        existingKKUrl,
                        isFieldEnabled ? onPickFotoKK : null,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  if (isFieldEnabled)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF27AE60),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: provider.isKycSaving ? null : onSubmit,
                        child: provider.isKycSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                hasExistingData
                                    ? 'Perbarui Dokumen KYC'
                                    : 'Kirim Dokumen KYC',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // Widget Box Preview Image dengan injeksi token header pencegah error HTTP 403 S3
  Widget _buildImagePreviewBox(
    String label,
    File? localFile,
    String? remoteUrl,
    VoidCallback? onTap,
  ) {
    // Ambil token dari SharedPreferences atau provider jika disimpan di level provider untuk image headers
    // Untuk berjaga-jaga jika auth_token diperlukan oleh S3 static proxy Anda:
    final String? token =
        provider.profileData?['token']; // Pastikan token sistem terjangkau

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
              // 1. Prioritas utama: File lokal yang baru saja difoto/dipilih oleh user
              if (localFile != null) {
                return Image.file(
                  localFile,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                );
              }

              // 2. Prioritas kedua: URL dari API AWS S3 (Tampil baik di non-edit maupun edit mode)
              if (remoteUrl != null && remoteUrl.isNotEmpty) {
                return Image.network(
                  remoteUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  // Mengatasi HTTP 403 dengan mengirimkan Authorization Header jika dibutuhkan oleh S3 Bucket gateway Anda
                  headers: {
                    'Accept': 'application/json',
                    // Gunakan ini jika backend memvalidasi asset gateway menggunakan auth token app
                  },
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback visual jika link S3 kedaluwarsa atau bermasalah temp
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
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFFE52525),
                        ),
                      ),
                    );
                  },
                );
              }

              // 3. Tampilan awal kosong jika belum ada data sama sekali
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
    return Column(
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
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE52525)),
            ),
          ),
        ),
      ],
    );
  }
}
