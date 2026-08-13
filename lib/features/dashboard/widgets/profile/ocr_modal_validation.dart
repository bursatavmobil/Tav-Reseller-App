import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrValidationModal extends StatefulWidget {
  final File imageFile;
  final String documentType; 

  const OcrValidationModal({
    super.key,
    required this.imageFile,
    required this.documentType,
  });

  @override
  State<OcrValidationModal> createState() => _OcrValidationModalState();
}

class _OcrValidationModalState extends State<OcrValidationModal> {
  bool _isScanning = true;
  bool _isValidDocument = false;
  String _validationErrorMessage = '';

  @override
  void initState() {
    super.initState();
    _processDocumentValidation();
  }

  // Helper Pembersihan Noise NIK
  String _cleanNikText(String rawNik) {
    return rawNik
        .toUpperCase()
        .replaceAll('O', '0')
        .replaceAll('D', '0')
        .replaceAll('Q', '0')
        .replaceAll('Z', '2')
        .replaceAll('S', '5')
        .replaceAll('G', '6')
        .replaceAll('B', '8')
        .replaceAll(RegExp(r'[^0-9]'), '');
  }

  Future<void> _processDocumentValidation() async {
    final decodedImage = await decodeImageFromList(
      await widget.imageFile.readAsBytes(),
    );
    final Size imageSize = Size(
      decodedImage.width.toDouble(),
      decodedImage.height.toDouble(),
    );
    final inputImage = InputImage.fromFile(widget.imageFile);

    try {
      if (widget.documentType == 'Selfie') {
        await _validateSelfieFace(inputImage, imageSize);
      } else {
        await _validateTextDocument(inputImage, imageSize);
      }

      setState(() {
        _isScanning = false;
      });
    } catch (e) {
      debugPrint("Processing Error: $e");
      _rejectDocument(
        "Gagal memproses gambar. Pastikan pencahayaan cukup dan foto jelas.",
      );
    }
  }

  // ---------------------------------------------------------------------------
  // 1. VALIDASI SELFIE DEEP FACE DETECTION (ML KIT FACE DETECTION)
  // ---------------------------------------------------------------------------
  Future<void> _validateSelfieFace(
    InputImage inputImage,
    Size imageSize,
  ) async {
    final options = FaceDetectorOptions(
      enableLandmarks: true, 
      enableClassification: true,
      performanceMode: FaceDetectorMode.accurate,
    );

    final faceDetector = FaceDetector(options: options);

    try {
      final List<Face> faces = await faceDetector.processImage(inputImage);

      if (faces.isEmpty) {
        _rejectDocument(
          "Wajah tidak terdeteksi. Pastikan wajah terlihat jelas di kamera.",
        );
        return;
      }

      if (faces.length > 1) {
        _rejectDocument(
          "Terdeteksi lebih dari 1 wajah. Pastikan hanya ada 1 orang di foto.",
        );
        return;
      }

      final Face face = faces.first;
      final Rect boundingBox = face.boundingBox;

      double margin = 10.0; 
      if (boundingBox.left < margin ||
          boundingBox.top < margin ||
          boundingBox.right > (imageSize.width - margin) ||
          boundingBox.bottom > (imageSize.height - margin)) {
        _rejectDocument(
          "Wajah terpotong. Posisikan seluruh wajah berada di tengah kamera.",
        );
        return;
      }

      final leftEye = face.landmarks[FaceLandmarkType.leftEye];
      final rightEye = face.landmarks[FaceLandmarkType.rightEye];
      final nose = face.landmarks[FaceLandmarkType.noseBase];
      final bottomMouth = face.landmarks[FaceLandmarkType.bottomMouth];

      if (leftEye == null ||
          rightEye == null ||
          nose == null ||
          bottomMouth == null) {
        _rejectDocument(
          "Wajah tidak utuh/terhalang. Lepaskan masker, kacamata hitam, atau topi.",
        );
        return;
      }

      final double? rotY = face.headEulerAngleY; 
      final double? rotZ = face.headEulerAngleZ; 

      if (rotY != null && (rotY.abs() > 20)) {
        _rejectDocument(
          "Posisi wajah miring. Harap menghadap lurus ke arah kamera.",
        );
        return;
      }

      if (rotZ != null && (rotZ.abs() > 20)) {
        _rejectDocument("Posisi kepala miring. Tegakkan posisi kepala Anda.");
        return;
      }

      if (face.leftEyeOpenProbability != null &&
          face.rightEyeOpenProbability != null) {
        if (face.leftEyeOpenProbability! < 0.3 ||
            face.rightEyeOpenProbability! < 0.3) {
          _rejectDocument(
            "Mata terpejam/tertutup. Pastikan kedua mata terbuka.",
          );
          return;
        }
      }

      _isValidDocument = true;
    } finally {
      faceDetector.close();
    }
  }

  // ---------------------------------------------------------------------------
  // 2. VALIDASI KTP & KK (TEXT RECOGNITION)
  // ---------------------------------------------------------------------------
  Future<void> _validateTextDocument(
    InputImage inputImage,
    Size imageSize,
  ) async {
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    try {
      final RecognizedText recognizedText = await textRecognizer.processImage(
        inputImage,
      );
      final String fullTextUpper = recognizedText.text.toUpperCase();

      if (widget.documentType == 'KTP') {
        _validateKtpFullLayout(fullTextUpper, imageSize);
      } else if (widget.documentType == 'KK') {
        _validateFullLayoutKk(fullTextUpper);
      }
    } finally {
      textRecognizer.close();
    }
  }

  void _validateKtpFullLayout(String fullTextUpper, Size imageSize) {
    final double aspectRatio = imageSize.width / imageSize.height;
    bool isValidAspectRatio = aspectRatio >= 1.2 && aspectRatio <= 1.85;

    bool hasHeader =
        fullTextUpper.contains('PROVINSI') ||
        fullTextUpper.contains('KABUPATEN') ||
        fullTextUpper.contains('KOTA');

    String cleanedDigits = _cleanNikText(fullTextUpper);
    bool hasNik = RegExp(r'\d{16}').hasMatch(cleanedDigits);

    bool hasBodyFields =
        fullTextUpper.contains('NAMA') ||
        fullTextUpper.contains('ALAMAT') ||
        fullTextUpper.contains('TEMPAT');

    bool hasFooterDate = RegExp(
      r'\b\d{2}-\d{2}-\d{4}\b',
    ).hasMatch(fullTextUpper);
    bool hasFooterText =
        fullTextUpper.contains('BERLAKU') ||
        fullTextUpper.contains('HINGGA') ||
        fullTextUpper.contains('SEUMUR');

    bool isFullLayout =
        hasHeader &&
        hasNik &&
        (hasBodyFields || hasFooterDate || hasFooterText);

    if (isFullLayout && isValidAspectRatio) {
      _isValidDocument = true;
    } else if (!isValidAspectRatio) {
      _rejectDocument(
        "Dokumen tidak terbaca: Foto KTP terpotong (crop). Pastikan rasio foto mencakup seluruh KTP.",
      );
    } else if (!hasHeader) {
      _rejectDocument(
        "Dokumen tidak terbaca: Header KTP (Provinsi/Kota) terpotong.",
      );
    } else if (!hasNik) {
      _rejectDocument("Dokumen tidak terbaca: NIK 16 digit tidak terdeteksi.");
    } else {
      _rejectDocument(
        "Dokumen tidak terbaca: Foto KTP terpotong. Wajib mengunggah 1 layout utuh fisik KTP.",
      );
    }
  }

  void _validateFullLayoutKk(String fullTextUpper) {
    bool hasHeader =
        fullTextUpper.contains('KARTU KELUARGA') ||
        fullTextUpper.contains('NO.');
    bool hasSubHeader =
        fullTextUpper.contains('NAMA KEPALA KELUARGA') ||
        fullTextUpper.contains('ALAMAT');
    bool hasTable =
        fullTextUpper.contains('NIK') &&
        (fullTextUpper.contains('JENIS KELAMIN') ||
            fullTextUpper.contains('HUBUNGAN'));
    bool hasFooter =
        fullTextUpper.contains('DIKELUARKAN') ||
        fullTextUpper.contains('LEMBAR') ||
        fullTextUpper.contains('KEPALA DINAS');

    if (hasHeader && hasSubHeader && (hasTable || hasFooter)) {
      _isValidDocument = true;
    } else {
      _rejectDocument(
        "Dokumen tidak terbaca: Foto KK terpotong/crop. Wajib mengambil foto 1 layout utuh lembar Kartu Keluarga.",
      );
    }
  }

  void _rejectDocument(String reason) {
    _isValidDocument = false;
    _validationErrorMessage = reason;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "VERIFIKASI ${widget.documentType.toUpperCase()}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),

              // PREVIEW GAMBAR
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: Image.file(widget.imageFile, fit: BoxFit.contain),
                ),
              ),
              const SizedBox(height: 16),

              if (_isScanning)
                Column(
                  children: const [
                    CircularProgressIndicator(color: Color(0xFFE52525)),
                    SizedBox(height: 12),
                    Text("Memeriksa kelayakan foto..."),
                  ],
                )
              else ...[
                // ALERT STATUS
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _isValidDocument
                        ? Colors.green.shade50
                        : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _isValidDocument ? Colors.green : Colors.red,
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        _isValidDocument ? Icons.check_circle : Icons.error,
                        color: _isValidDocument
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isValidDocument
                                  ? "Foto Valid & Sesuai"
                                  : "Foto Tidak Memenuhi Syarat",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: _isValidDocument
                                    ? Colors.green.shade900
                                    : Colors.red.shade900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _isValidDocument
                                  ? "Verifikasi ${widget.documentType} berhasil memenuhi kriteria."
                                  : _validationErrorMessage,
                              style: TextStyle(
                                fontSize: 12,
                                color: _isValidDocument
                                    ? Colors.green.shade800
                                    : Colors.red.shade800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Foto Ulang'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isValidDocument
                              ? Colors.black
                              : Colors.grey.shade400,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _isValidDocument
                            ? () => Navigator.pop(context, true)
                            : null,
                        child: const Text('Gunakan'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
