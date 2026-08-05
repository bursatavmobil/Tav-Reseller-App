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
    
    // Memastikan pengecekan berjalan setelah frame pertama dirender
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkIfScrollNotNeeded();
    });
  }

  // Pengecekan real-time saat user melakukan scroll
  void _checkScrollPosition() {
    if (_scrollController.hasClients) {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 10) {
        if (!_hasReadToBottom) {
          setState(() {
            _hasReadToBottom = true;
          });
        }
      }
    }
  }

  // SOLUSI TABLET: Jika konten pendek/layar besar sehingga tidak ada area scrollable, langsung buka checkbox
  void _checkIfScrollNotNeeded() {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      if (maxScroll <= 0) {
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
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;

    // RESPONSIVE BREAKPOINTS CONFIGURATION (Tablet, L, M, S)
    double dialogWidth = screenWidth * 0.92; // Default Mobile M/S
    double maxDialogHeight = screenSize.height * 0.85;
    double paddingValue = 16.0;
    double titleFontSize = 15.0;
    double bodyFontSize = 11.0;

    if (screenWidth >= 600) {
      // TABLET
      dialogWidth = 580; 
      maxDialogHeight = screenSize.height * 0.70; // Lebih pendek di tablet agar proporsional
      paddingValue = 28.0;
      titleFontSize = 18.0;
      bodyFontSize = 13.0;
    } else if (screenWidth >= 400) {
      // MOBILE L (e.g. iPhone Pro Max, Pixel XL)
      dialogWidth = screenWidth * 0.90;
      paddingValue = 20.0;
      titleFontSize = 16.0;
      bodyFontSize = 11.5;
    } else if (screenWidth <= 320) {
      // MOBILE S (e.g. iPhone SE gen 1)
      dialogWidth = screenWidth * 0.95;
      paddingValue = 12.0;
      titleFontSize = 13.0;
      bodyFontSize = 10.0;
    }

    return Dialog(
      backgroundColor: const Color(0xFF141414),
      insetPadding: EdgeInsets.symmetric(
        horizontal: screenWidth >= 600 ? 0 : 12, 
        vertical: 24
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF2C2C2C), width: 1),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: dialogWidth,
        constraints: BoxConstraints(
          maxHeight: maxDialogHeight,
        ),
        padding: EdgeInsets.all(paddingValue),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER SECTION
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE52525).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.gavel_rounded,
                    color: const Color(0xFFE52525),
                    size: screenWidth >= 600 ? 28 : 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Persetujuan Kemitraan",
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Montserrat',
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Kebijakan Privasi & Ketentuan Reseller",
                        style: TextStyle(
                          color: const Color(0xFF8E8E93),
                          fontFamily: 'Montserrat',
                          fontSize: titleFontSize - 4,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // CONTENT TERMS (SCROLLABLE AREA)
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
                          bodyFontSize + 1,
                        ),
                        _buildBodyText(
                          "Untuk mematuhi regulasi perdagangan yang berlaku dan mencegah tindakan fraud, Anda diwajibkan mengunggah data identitas resmi (KTP), foto verifikasi wajah, serta informasi rekening bank yang valid. Seluruh data ini digunakan secara eksklusif untuk otentikasi hak akses kemitraan Anda.",
                          bodyFontSize,
                        ),
                        _buildSectionTitle(
                          "2. Kerahasiaan Informasi Unit & Harga Grosir",
                          bodyFontSize + 1,
                        ),
                        _buildBodyText(
                          "Sebagai reseller resmi aplikasi ini, Anda diberikan hak eksklusif untuk melihat harga modal, nilai komisi, dan status negosiasi internal. Anda dilarang keras menyebarluaskan tangkapan layar, struktur margin, atau database unit kendaraan di luar kepentingan transaksi konsumen internal aplikasi.",
                          bodyFontSize,
                        ),
                        _buildSectionTitle(
                          "3. Kebijakan Sistem Negosiasi & Batas Penawaran",
                          bodyFontSize + 1,
                        ),
                        _buildBodyText(
                          "Setiap aktivitas penawaran harga (negotiation room) yang Anda lakukan wajib didasari oleh intensi transaksi yang nyata. Penyalahgunaan fitur negosiasi (seperti spamming nominal tidak rasional atau manipulasi antrean transaksi) dapat memicu pembekuan hak akses akun secara sepihak.",
                          bodyFontSize,
                        ),
                        _buildSectionTitle(
                          "4. Keamanan Akun & Penyalahgunaan Data Pihak Ketiga",
                          bodyFontSize + 1,
                        ),
                        _buildBodyText(
                          "Kredensial akun reseller Anda bersifat rahasia dan melekat pada data pribadi Anda pribadi. Segala bentuk kerugian transaksi atau penyalahgunaan fitur akibat kelalaian pembagian akses login dengan pihak ketiga sepenuhnya berada di luar tanggung jawab manajemen platform.",
                          bodyFontSize,
                        ),
                        _buildSectionTitle(
                          "5. Kepatuhan Hukum & Pencairan Saldo Komisi",
                          bodyFontSize + 1,
                        ),
                        _buildBodyText(
                          "Seluruh proses penarikan saldo keuntungan atau pencairan dana bonus komisi wajib melalui proses peninjauan sistem kepatuhan transaksi. Kami berhak melakukan penangguhan apabila terdeteksi adanya indikasi pencucian uang atau anomali aktivitas manipulasi sistem data penjualan.",
                          bodyFontSize,
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // DYNAMIC AREA: WARNING BANNER OR CHECKBOX
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: !_hasReadToBottom
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4A373).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.arrow_downward_rounded,
                            color: Color(0xFFD4A373),
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Silakan baca seluruh poin dokumen di atas hingga akhir untuk mengaktifkan persetujuan.",
                              style: TextStyle(
                                color: const Color(0xFFD4A373),
                                fontFamily: 'Montserrat',
                                fontSize: bodyFontSize - 1,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Theme(
                      data: ThemeData(
                        unselectedWidgetColor: const Color(0xFF8E8E93),
                      ),
                      child: CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          "Saya telah membaca, memahami, dan menyetujui seluruh ketentuan privasi kemitraan reseller di atas.",
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Montserrat',
                            fontSize: bodyFontSize,
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
            const SizedBox(height: 16),

            // BUTTON ACTION ACTION
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF2C2C2C)),
                      padding: EdgeInsets.symmetric(
                        vertical: screenWidth >= 600 ? 18 : 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "TOLAK",
                      style: TextStyle(
                        color: const Color(0xFF8E8E93),
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w700,
                        fontSize: bodyFontSize + 1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: (_hasReadToBottom && _isCheckboxChecked)
                          ? const Color(0xFFE52525)
                          : const Color(0xFF2C2C2C),
                      padding: EdgeInsets.symmetric(
                        vertical: screenWidth >= 600 ? 18 : 14,
                      ),
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
                        fontSize: bodyFontSize + 1,
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

  Widget _buildSectionTitle(String title, double fontSize) {
    return Padding(
      padding: const EdgeInsets.only(top: 14.0, bottom: 6.0),
      child: Text(
        title,
        style: TextStyle(
          color: const Color(0xFFD4A373),
          fontFamily: 'Montserrat',
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildBodyText(String text, double fontSize) {
    return Text(
      text,
      textAlign: TextAlign.justify,
      style: TextStyle(
        color: const Color(0xFFABABAB),
        fontFamily: 'Montserrat',
        fontSize: fontSize,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
    );
  }
}