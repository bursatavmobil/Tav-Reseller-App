import 'package:flutter/material.dart';

class KycPrivacyAgreementModal extends StatefulWidget {
  final VoidCallback onAccept;

  const KycPrivacyAgreementModal({super.key, required this.onAccept});

  static void show(BuildContext context, {required VoidCallback onAccept}) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.85),
      transitionDuration: const Duration(milliseconds: 450),
      pageBuilder: (context, anim1, anim2) =>
          KycPrivacyAgreementModal(onAccept: onAccept),
      transitionBuilder: (context, anim1, anim2, child) {
        final curvedValue = Curves.fastOutSlowIn.transform(anim1.value);
        return Transform.translate(
          offset: Offset(0, (1 - curvedValue) * 300),
          child: Opacity(opacity: anim1.value, child: child),
        );
      },
    );
  }

  @override
  State<KycPrivacyAgreementModal> createState() =>
      _KycPrivacyAgreementModalState();
}

class _KycPrivacyAgreementModalState extends State<KycPrivacyAgreementModal> {
  final ScrollController _scrollController = ScrollController();
  bool _hasReadToBottom = false;
  bool _isCheckboxChecked = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_checkScrollPosition);
  }

  void _checkScrollPosition() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 10) {
      if (!_hasReadToBottom) {
        setState(() {
          _hasReadToBottom = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF141414),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF2C2C2C), width: 1),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.82,
        ),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE52525).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.gavel_rounded,
                    color: Color(0xFFE52525),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Persetujuan Kemitraan",
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Montserrat',
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        "Kebijakan Privasi & Ketentuan Reseller",
                        style: TextStyle(
                          color: Color(0xFF8E8E93),
                          fontFamily: 'Montserrat',
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1C1E),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF2C2C2C), width: 1),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Scrollbar(
                    controller: _scrollController,
                    thumbVisibility: true,
                    child: ListView(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      children: [
                        _buildSectionTitle(
                          "1. Pengumpulan Dokumen & Validasi KYC",
                        ),
                        _buildBodyText(
                          "Untuk mematuhi regulasi perdagangan yang berlaku dan mencegah tindakan fraud, Anda diwajibkan mengunggah data identitas resmi (KTP), foto verifikasi wajah, serta informasi rekening bank yang valid. Seluruh data ini digunakan secara eksklusif untuk otentikasi hak akses kemitraan Anda.",
                        ),
                        _buildSectionTitle(
                          "2. Kerahasiaan Informasi Unit & Harga Grosir",
                        ),
                        _buildBodyText(
                          "Sebagai reseller resmi aplikasi ini, Anda diberikan hak eksklusif untuk melihat harga modal, nilai komisi, dan status negosiasi internal. Anda dilarang keras menyebarluaskan tangkapan layar, struktur margin, atau database unit kendaraan di luar kepentingan transaksi konsumen internal aplikasi.",
                        ),
                        _buildSectionTitle(
                          "3. Kebijakan Sistem Negosiasi & Batas Penawaran",
                        ),
                        _buildBodyText(
                          "Setiap aktivitas penawaran harga (negotiation room) yang Anda lakukan wajib didasari oleh intensi transaksi yang nyata. Penyalahgunaan fitur negosiasi (seperti spamming nominal tidak rasional atau manipulasi antrean transaksi) dapat memicu pembekuan hak akses akun secara sepihak.",
                        ),
                        _buildSectionTitle(
                          "4. Keamanan Akun & Penyalahgunaan Data Pihak Ketiga",
                        ),
                        _buildBodyText(
                          "Kredensial akun reseller Anda bersifat rahasia dan melekat pada data pribadi Anda pribadi. Segala bentuk kerugian transaksi atau penyalahgunaan fitur akibat kelalaian pembagian akses login dengan pihak ketiga sepenuhnya berada di luar tanggung jawab manajemen platform.",
                        ),
                        _buildSectionTitle(
                          "5. Kepatuhan Hukum & Pencairan Saldo Komisi",
                        ),
                        _buildBodyText(
                          "Seluruh proses penarikan saldo keuntungan atau pencairan dana bonus komisi wajib melalui proses peninjauan sistem kepatuhan transaksi. Kami berhak melakukan penangguhan apabila terdeteksi adanya indikasi pencucian uang atau anomali aktivitas manipulasi sistem data penjualan.",
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (!_hasReadToBottom)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4A373).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: const [
                    Icon(
                      Icons.arrow_downward_rounded,
                      color: Color(0xFFD4A373),
                      size: 16,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Silakan baca seluruh poin dokumen di atas hingga akhir untuk mengaktifkan persetujuan.",
                        style: TextStyle(
                          color: Color(0xFFD4A373),
                          fontFamily: 'Montserrat',
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (_hasReadToBottom)
              AnimatedOpacity(
                opacity: _hasReadToBottom ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Theme(
                    data: ThemeData(
                      unselectedWidgetColor: const Color(0xFF8E8E93),
                    ),
                    child: CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        "Saya telah membaca, memahami, dan menyetujui seluruh ketentuan privasi kemitraan reseller di atas.",
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Montserrat',
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                      value: _isCheckboxChecked,
                      activeColor: const Color(0xFFE52525),
                      checkColor: Colors.white,
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: (val) {
                        setState(() {
                          _isCheckboxChecked = val ?? false;
                        });
                      },
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF2C2C2C)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "TOLAK",
                      style: TextStyle(
                        color: Color(0xFF8E8E93),
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            (_hasReadToBottom && _isCheckboxChecked)
                            ? const Color(0xFFE52525)
                            : const Color(0xFF2C2C2C),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: (_hasReadToBottom && _isCheckboxChecked)
                          ? () {
                              Navigator.pop(context);
                              widget.onAccept();
                            }
                          : null,
                      child: Text(
                        "LANJUTKAN",
                        style: TextStyle(
                          color: (_hasReadToBottom && _isCheckboxChecked)
                              ? Colors.white
                              : const Color(0xFF555555),
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 14.0, bottom: 6.0),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFFD4A373),
          fontFamily: 'Montserrat',
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildBodyText(String text) {
    return Text(
      text,
      textAlign: TextAlign.justify,
      style: const TextStyle(
        color: Color(0xFFABABAB),
        fontFamily: 'Montserrat',
        fontSize: 11,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
    );
  }
}
