import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:reseller_app_tav/features/dashboard/models/negosiasi_chat_response_model.dart';
import 'package:reseller_app_tav/features/dashboard/providers/negosiasi_provider.dart';
import 'package:reseller_app_tav/features/dashboard/services/api_config.dart';

class ChatCardWidget extends StatefulWidget {
  final NegotiationChatItem message;
  final bool? isMeCustom;
  final String roomStatus; // 🟢 TAMBAHKAN PARAMETER INI

  const ChatCardWidget({
    super.key,
    required this.message,
    this.isMeCustom,
    required this.roomStatus, // 🟢 DIJADIKAN REQUIRED
  });

  @override
  State<ChatCardWidget> createState() => _ChatCardWidgetState();
}

class _ChatCardWidgetState extends State<ChatCardWidget> {
  Uint8List? _cachedImageBytes;
  String? _extractedTextMessage;
  String? _localImagePath;
  String? _remoteImageUrl;

  @override
  void initState() {
    super.initState();
    _processMessagePayload();
  }

  @override
  void didUpdateWidget(covariant ChatCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.message.pesan != oldWidget.message.pesan ||
        widget.message.id != oldWidget.message.id ||
        widget.message.logNegotiationChat.length !=
            oldWidget.message.logNegotiationChat.length) {
      _processMessagePayload();
    }
  }

  void _processMessagePayload() {
    final String? rawPesan = widget.message.pesan;

    _cachedImageBytes = null;
    _localImagePath = null;
    _remoteImageUrl = null;
    _extractedTextMessage = null;

    if (rawPesan == null || rawPesan.isEmpty) {
      return;
    }

    String cleanImagePayload = rawPesan;
    if (rawPesan.contains("||TEXT_MSG:")) {
      final List<String> parts = rawPesan.split("||TEXT_MSG:");
      cleanImagePayload = parts[0];
      _extractedTextMessage = parts[1];
    }

    if (cleanImagePayload.startsWith("LOCAL_FILE:")) {
      _localImagePath = cleanImagePayload.replaceFirst("LOCAL_FILE:", "");
      return;
    }

    if (cleanImagePayload.startsWith("DATA_IMAGE:")) {
      try {
        final String base64String = cleanImagePayload.replaceFirst(
          "DATA_IMAGE:",
          "",
        );
        _cachedImageBytes = base64Decode(base64String.trim());
      } catch (e) {
        debugPrint("Error parsing base64 image: $e");
        _extractedTextMessage = rawPesan;
      }
      return;
    }

    final String checkUrl = cleanImagePayload.trim().toLowerCase();
    final bool isUrlImage =
        checkUrl.contains("/storage/") ||
        checkUrl.contains("/uploads/") ||
        checkUrl.endsWith(".jpg") ||
        checkUrl.endsWith(".png") ||
        checkUrl.endsWith(".jpeg") ||
        checkUrl.contains("chat");

    if (isUrlImage) {
      _remoteImageUrl = cleanImagePayload.startsWith("http")
          ? cleanImagePayload
          : "${ApiConfig.baseUrl}/$cleanImagePayload";
      return;
    }

    _extractedTextMessage = rawPesan;
  }

  void _showFullImagePreview(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        pageBuilder: (context, animation, secondaryAnimation) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: Stack(
              children: [
                AnimatedBuilder(
                  animation: animation,
                  builder: (context, child) => Container(
                    color: Colors.black.withOpacity(animation.value * 0.9),
                  ),
                ),
                SafeArea(
                  child: Stack(
                    children: [
                      Center(
                        child: InteractiveViewer(
                          minScale: 1.0,
                          maxScale: 4.0,
                          child: _localImagePath != null
                              ? Image.file(
                                  File(_localImagePath!),
                                  fit: BoxFit.contain,
                                )
                              : _remoteImageUrl != null
                              ? Image.network(
                                  _remoteImageUrl!,
                                  fit: BoxFit.contain,
                                )
                              : Image.memory(
                                  _cachedImageBytes!,
                                  fit: BoxFit.contain,
                                ),
                        ),
                      ),
                      Positioned(
                        top: 16,
                        left: 16,
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                              color: Colors.black,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatRupiah(int value) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(value);
  }

  @override
  Widget build(BuildContext context) {
    final negotiationProvider = Provider.of<NegotiationProvider>(context, listen: false);
    final String currentRoomStatus = widget.roomStatus.toUpperCase().trim();

    final bool isMe =
        widget.isMeCustom ?? (widget.message.typeUser.toLowerCase() == 'agen');

    final int? nominalTransaksi = widget.message.nominal;
    final bool hasNominal = nominalTransaksi != null && nominalTransaksi > 0;
    
    // 1. Hanya true jika item chat ini yang MEMANG DI-APPROVE secara spesifik
    final bool isApproved = widget.message.isApprove ?? false;

    // 2. 🟢 DETEKSI NOMINAL TERBARU (Mencegah perubahan massal)
    bool isLatestNominal = false;
    if (hasNominal && negotiationProvider.chatMessages.isNotEmpty) {
      try {
        // Cari item pertama di dalam list chat yang memiliki komponen nominal transaksi
        final latestNominalItem = negotiationProvider.chatMessages.firstWhere(
          (msg) => msg.nominal != null && msg.nominal! > 0,
        );
        // Jika ID item ini sama dengan ID item nominal terbaru di list, tandai sebagai true
        if (latestNominalItem.id == widget.message.id) {
          isLatestNominal = true;
        }
      } catch (_) {
        // Jika tidak ditemukan item nominal lain, fallback ke false
        isLatestNominal = false;
      }
    }

    // 3. 🟢 KONDISI REJECT DIPERKETAT: Room berstatus REJECT, item tidak di-approve, DAN harus merupakan penawaran TERBARU
    final bool isRejected = !isApproved && 
                            isLatestNominal && 
                            (currentRoomStatus == 'REJECT_COO' || currentRoomStatus == 'REJECT_CEO');

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double maxBubbleWidth = constraints.maxWidth * 0.75;

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            width: maxBubbleWidth,
            child: Column(
              crossAxisAlignment: isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (hasNominal)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      // 🟢 CARD NOMINAL (Urutan warna dievaluasi dengan benar)
                      color: isApproved
                          ? const Color(0xFF1B4332)
                          : (isRejected
                                ? const Color(
                                    0xFF2C1A1A,
                                  ) // Merah Gelap saat ditolak
                                : (isMe
                                      ? const Color(0xFFE52525)
                                      : const Color(0xFF1A1A1A))),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isApproved
                            ? const Color(0xFFD4AF37)
                            : (isRejected
                                  ? const Color(0xFFE52525).withOpacity(0.5)
                                  : (!isMe
                                        ? const Color(0xFFD4AF37)
                                        : Colors.white.withOpacity(0.6))),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Row(
                                children: [
                                  Icon(
                                    isApproved
                                        ? Icons.verified_rounded
                                        : (isRejected
                                              ? Icons.cancel_outlined
                                              : Icons.gavel_rounded),
                                    color: isApproved
                                        ? const Color(0xFFD4AF37)
                                        : (isRejected
                                              ? const Color(0xFFE52525)
                                              : (isMe
                                                    ? Colors.white
                                                    : const Color(0xFFD4AF37))),
                                    size: 14,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      isApproved
                                          ? "PENAWARAN DISETUJUI"
                                          : (isRejected
                                                ? "PENAWARAN DITOLAK"
                                                : (isMe
                                                      ? "PENAWARAN ANDA"
                                                      : "PENAWARAN ADMIN")),
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        color: isApproved
                                            ? const Color(0xFFD4AF37)
                                            : (isRejected
                                                  ? const Color(0xFFE52525)
                                                  : (isMe
                                                        ? Colors.white
                                                              .withOpacity(0.9)
                                                        : const Color(
                                                            0xFFD4AF37,
                                                          ))),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _formatRupiah(nominalTransaksi),
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: isRejected ? Colors.grey[500] : Colors.white,
                            decoration: isRejected
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),

                // 🟢 BUBBLE TEXT DI BAWAH CARD NOMINAL
                Container(
                  decoration: BoxDecoration(
                    color: isApproved
                        ? const Color(0xFF1B4332).withOpacity(0.15)
                        : (isRejected
                              ? const Color(
                                  0xFF2C1A1A,
                                ) // 🟢 Pastikan kondisi reject diprioritaskan di atas isMe
                              : (isMe
                                    ? const Color(0xFFE52525)
                                    : const Color(0xFFF1F1F1))),
                    border: isApproved
                        ? Border.all(
                            color: const Color(0xFF1B4332).withOpacity(0.4),
                            width: 1,
                          )
                        : (isRejected
                              ? Border.all(
                                  color: const Color(
                                    0xFFE52525,
                                  ).withOpacity(0.4),
                                  width: 1,
                                )
                              : null),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(14),
                      topRight: const Radius.circular(14),
                      bottomLeft: isMe
                          ? const Radius.circular(14)
                          : Radius.zero,
                      bottomRight: isMe
                          ? Radius.zero
                          : const Radius.circular(14),
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_localImagePath != null ||
                          _remoteImageUrl != null ||
                          _cachedImageBytes != null)
                        GestureDetector(
                          onTap: () => _showFullImagePreview(context),
                          child: Container(
                            constraints: const BoxConstraints(maxHeight: 200),
                            width: double.infinity,
                            child: _localImagePath != null
                                ? Image.file(
                                    File(_localImagePath!),
                                    fit: BoxFit.cover,
                                  )
                                : _remoteImageUrl != null
                                ? Image.network(
                                    _remoteImageUrl!,
                                    fit: BoxFit.cover,
                                  )
                                : Image.memory(
                                    _cachedImageBytes!,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                      if (_extractedTextMessage != null &&
                          _extractedTextMessage!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          child: Text(
                            _extractedTextMessage!,
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isApproved
                                  ? const Color(0xFF1B4332)
                                  : (isRejected
                                        ? const Color(
                                            0xFFE52525,
                                          ) // Teks deskripsi reject menggunakan merah aksen
                                        : (isMe
                                              ? Colors.white
                                              : const Color(0xFF1A1A1A))),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 2),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.message.waktu,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          color: Color(0xFF8E8E93),
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        Builder(
                          builder: (context) {
                            final bool isReadByOpponent = widget
                                .message
                                .logNegotiationChat
                                .any(
                                  (log) =>
                                      log.typeUser.toLowerCase() == 'admin' ||
                                      log.typeUser.toLowerCase() == 'system',
                                );

                            return Icon(
                              isReadByOpponent
                                  ? Icons.done_all_rounded
                                  : Icons.done_rounded,
                              size: 12,
                              color: isReadByOpponent
                                  ? const Color(0xFF2196F3)
                                  : const Color(0xFF8E8E93),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
