import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../providers/car_detail_provider.dart';

class CarImageSlider extends StatefulWidget {
  final List<dynamic> images;
  final String carName;

  const CarImageSlider({
    super.key,
    required this.images,
    required this.carName,
  });

  @override
  State<CarImageSlider> createState() => _CarImageSliderState();
}

class _CarImageSliderState extends State<CarImageSlider> {
  late PageController _pageController;
  final Dio _dio = Dio();

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

  // === FUNGSI DOWNLOAD DENGAN TAMPILAN MODERN ===
  Future<void> _downloadAllImages() async {
    if (widget.images.isEmpty) return;

    Directory? downloadDir;
    String folderLabel = "";
    
    if (Platform.isAndroid) {
      downloadDir = Directory('/storage/emulated/0/Download');
      folderLabel = "Penyimpanan Internal > Download";
      if (!await downloadDir.exists()) {
        downloadDir = await getExternalStorageDirectory();
        folderLabel = "Penyimpanan Aplikasi (External Storage)";
      }
    } else {
      downloadDir = await getApplicationDocumentsDirectory();
      folderLabel = "Files App > Documents";
    }

    if (downloadDir == null) {
      _showCustomSnackBar('Gagal mengakses penyimpanan perangkat.', isSuccess: false);
      return;
    }

    int totalFiles = widget.images.length;
    int currentFileIndex = 0;
    double currentProgress = 0.0;
    String currentFileName = "";

    // 1. Tampilkan Dialog Progress dengan Desain Minimalis/Modern
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE52320).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
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
                                "Mengunduh File HD",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  fontFamily: 'Montserrat',
                                  color: Color(0xFF222222),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "Mendownload ${currentFileIndex + 1} dari $totalFiles foto",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
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
                        color: Color(0xFF555555),
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
                        backgroundColor: Colors.grey[100],
                        color: const Color(0xFFE52320),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Lokasi: $folderLabel",
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[500],
                            fontStyle: FontStyle.italic,
                          ),
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

    // 2. Eksekusi Download Loop
    try {
      for (int i = 0; i < widget.images.length; i++) {
        final url = widget.images[i]['image_url']?.toString() ?? '';
        if (url.isEmpty) continue;

        String fileName = url.split('/').last;
        if (!fileName.contains('.')) {
          fileName = "car_${widget.carName.replaceAll(' ', '_')}_$i.jpg";
        }

        final savePath = "${downloadDir.path}/$fileName";

        await _dio.download(
          url,
          savePath,
          onReceiveProgress: (received, total) {
            if (total != -1) {
              double progress = received / total;
              _updateProgressDialog?.call(i, progress, fileName);
            }
          },
        );
      }

      // Tutup Dialog setelah sukses
      if (mounted) Navigator.of(context, rootNavigator: true).pop();

      // 3. Tampilkan Dialog Sukses yang Informatif dan Modern
      if (mounted) {
        _showSuccessDialog(totalFiles, folderLabel);
      }
    } catch (e) {
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
      _showCustomSnackBar('Gagal mengunduh gambar: $e', isSuccess: false);
    }
  }

  // === POP-UP ALERT SUKSES DESIGN MODERN ===
  void _showSuccessDialog(int count, String pathLocation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Colors.green,
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Unduhan Berhasil!",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                fontFamily: 'Montserrat',
                color: Color(0xFF222222),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Berhasil menyimpan $count gambar resolusi HD ke perangkat Anda.",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.grey,
                fontFamily: 'Montserrat',
              ),
            ),
            const SizedBox(height: 16),
            // Panel Informasi Folder Penyimpanan
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.folder_open_rounded, size: 16, color: Color(0xFFE52320)),
                      SizedBox(width: 6),
                      Text(
                        "Lokasi Penyimpanan:",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF222222),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    pathLocation,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[700],
                      fontFamily: 'Courier', // Font bergaya monospace untuk path agar rapi
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF222222),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Selesai",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
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

  Function(int index, double progress, String name)? _updateProgressDialog;

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
            onTap: _downloadAllImages,
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
                          "Dapatkan semua foto aset mobil ini ke penyimpanan",
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