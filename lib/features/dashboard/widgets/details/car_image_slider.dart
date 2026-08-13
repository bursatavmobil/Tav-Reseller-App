import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../providers/car_detail_provider.dart';

class CarImageSlider extends StatefulWidget {
  final List<dynamic> images;
  final String carName;
  final String status;

  const CarImageSlider({
    super.key,
    required this.images,
    required this.carName,
    required this.status,
  });

  @override
  State<CarImageSlider> createState() => _CarImageSliderState();
}

class _CarImageSliderState extends State<CarImageSlider> {
  late PageController _pageController;
  final Dio _dio = Dio();
  Function(int index, double progress, String name)? _updateProgressDialog;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _dio.close();
    super.dispose();
  }

  // === FUNGSI SHARE ===
  Future<void> _shareCar() async {
    final provider = context.read<CarDetailProvider>();
    final displayImages = widget.images.isEmpty ? [] : widget.images;

    final String salesText =
        "🔥 *PENAWARAN SPESIAL* 🔥\n\n"
        "Halo! Ada penawaran menarik nih untuk *${widget.carName}*.\n\n"
        "✅ Kondisi prima & terawat\n"
        "✅ Harga bersaing (Bisa Cash/Kredit)\n"
        "✅ Dokumen lengkap & proses cepat\n\n"
        "Yuk, buruan cek sebelum kehabisan! Balas pesan ini untuk tanya-tanya harga spesial atau cek unit langsung. 🚗💨";

    if (displayImages.isEmpty) {
      await Share.share(salesText);
      return;
    }

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Menyiapkan gambar untuk dibagikan...'),
          duration: Duration(seconds: 1),
        ),
      );

      final currentImageUrl =
          displayImages[provider.currentImageIndex]['image_url'];
      final file = await DefaultCacheManager().getSingleFile(currentImageUrl);

      await Share.shareXFiles([XFile(file.path)], text: salesText);
    } catch (e) {
      await Share.share(salesText);
    }
  }

  // === POP-UP DIALOG KONFIRMASI DOWNLOAD (SAAS STYLE) ===
  Future<void> _confirmAndDownload() async {
    if (widget.images.isEmpty) return;

    final int totalImages = widget.images.length;

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE52320).withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.photo_library_outlined,
                  color: Color(0xFFE52320),
                  size: 36,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                "Konfirmasi Unduhan",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Montserrat',
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Ingin download image sebanyak $totalImages di gallery anda?",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                  height: 1.4,
                  fontFamily: 'Montserrat',
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text(
                        "Batal",
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE52320),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        "Download",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirm == true) {
      _downloadAllImagesToGallery();
    }
  }

  // === FUNGSI DOWNLOAD & SIMPAN KE GALERI ===
  Future<void> _downloadAllImagesToGallery() async {
    // Cek/Minta Izin Penyimpanan Galeri
    final hasAccess = await Gal.hasAccess();
    if (!hasAccess) {
      final requestGranted = await Gal.requestAccess();
      if (!requestGranted) {
        _showCustomSnackBar(
          'Izin galeri diperlukan untuk menyimpan gambar.',
          isSuccess: false,
        );
        return;
      }
    }

    int totalFiles = widget.images.length;
    int currentFileIndex = 0;
    double currentProgress = 0.0;
    String currentFileName = "";

    // 1. Modal Progress Unduhan (SaaS Professional Design)
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            _updateProgressDialog = (int index, double progress, String name) {
              setDialogState(() {
                currentFileIndex = index;
                currentProgress = progress;
                currentFileName = name;
              });
            };

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: Colors.white,
              child: Padding(
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
                            color: const Color(0xFFE52320).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.cloud_download_rounded,
                            color: Color(0xFFE52320),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Mengunduh ke Galeri",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  fontFamily: 'Montserrat',
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "Proses ${currentFileIndex + 1} dari $totalFiles berkas",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF64748B),
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      currentFileName,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF475569),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: currentProgress,
                        minHeight: 8,
                        backgroundColor: const Color(0xFFF1F5F9),
                        color: const Color(0xFFE52320),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.photo_album_outlined,
                              size: 12,
                              color: Color(0xFF94A3B8),
                            ),
                            SizedBox(width: 4),
                            Text(
                              "Tersimpan di Galeri Utama",
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          "${(currentProgress * 100).toStringAsFixed(0)}%",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Color(0xFFE52320),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    // 2. Eksekusi Download & Integrasi Media Store/Galeri
    try {
      final tempDir = await getTemporaryDirectory();

      for (int i = 0; i < widget.images.length; i++) {
        final url = widget.images[i]['image_url']?.toString() ?? '';
        if (url.isEmpty) continue;

        String fileName = url.split('/').last;
        if (!fileName.contains('.')) {
          fileName = "car_${widget.carName.replaceAll(' ', '_')}_$i.jpg";
        }

        final tempPath = "${tempDir.path}/$fileName";

        // Download sementara ke Cache Temp
        await _dio.download(
          url,
          tempPath,
          onReceiveProgress: (received, total) {
            if (total != -1) {
              double progress = received / total;
              _updateProgressDialog?.call(i, progress, fileName);
            }
          },
        );

        // Pindahkan ke Galeri Publik Peranti
        await Gal.putImage(tempPath, album: "Reseller Mobil");

        // Hapus file sementara di Temp
        final tempFile = File(tempPath);
        if (await tempFile.exists()) {
          await tempFile.delete();
        }
      }

      // Tutup dialog progress
      if (mounted) Navigator.of(context, rootNavigator: true).pop();

      // Tampilkan Dialog Sukses
      if (mounted) {
        _showSuccessDialog(totalFiles);
      }
    } catch (e) {
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
      _showCustomSnackBar('Gagal mengunduh gambar: $e', isSuccess: false);
    }
  }

  // === POP-UP DIALOG SUKSES DESIGN MODERN (SAAS) ===
  void _showSuccessDialog(int count) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFDCFCE7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF16A34A),
                  size: 44,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                "Unduhan Berhasil!",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Montserrat',
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Berhasil menyimpan $count gambar ke dalam galeri foto peranti Anda.",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                  fontFamily: 'Montserrat',
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.photo_album_rounded,
                      size: 18,
                      color: Color(0xFFE52320),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Album: Reseller Mobil / Galeri Utama",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF334155),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E293B),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Selesai",
                    style: TextStyle(
                      fontSize: 13,
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
  }

  void _showCustomSnackBar(String message, {required bool isSuccess}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CarDetailProvider>();
    final displayImages = widget.images.isEmpty ? [] : widget.images;

    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // MAIN IMAGE SLIDER + TOMBOL SHARE
          Stack(
            children: [
              SizedBox(
                height: 230,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: displayImages.length,
                  onPageChanged: provider.setImageIndex,
                  itemBuilder: (context, index) {
                    final imgUrl = displayImages[index]['image_url'] ?? '';
                    return CachedNetworkImage(
                      imageUrl: imgUrl,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    );
                  },
                ),
              ),

              if (widget.status.toLowerCase() == 'booking')
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                    child: Center(
                      child: Transform.rotate(
                        angle: -0.2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white, width: 3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            "BOOKED",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'Montserrat',
                              letterSpacing: 4,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

              Positioned(
                right: 16,
                top: 16,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.share,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: _shareCar,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // SLIDER KECIL / THUMBNAIL
          if (displayImages.isNotEmpty)
            SizedBox(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: displayImages.length,
                itemBuilder: (context, index) {
                  final imgUrl = displayImages[index]['image_url'] ?? '';
                  final isSelected = provider.currentImageIndex == index;
                  return GestureDetector(
                    onTap: () {
                      provider.setImageIndex(index);
                      _pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      width: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFFE52320)
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: CachedNetworkImage(
                          imageUrl: imgUrl,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

          const SizedBox(height: 4),

          // TOMBOL DOWNLOAD ALL IMAGE HD
          InkWell(
            onTap: _confirmAndDownload,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Icon(
                    Icons.cloud_download_outlined,
                    color: Color(0xFFE52320),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Download Image HD",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF222222),
                            fontFamily: 'Montserrat',
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          "Simpan semua foto aset mobil ini langsung ke Galeri HP",
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.grey[400],
                    size: 14,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}