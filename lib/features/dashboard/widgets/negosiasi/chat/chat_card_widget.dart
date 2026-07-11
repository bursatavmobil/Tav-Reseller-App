// lib/features/dashboard/widgets/negosiasi/chat/chat_card_widget.dart
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:reseller_app_tav/features/dashboard/models/negosiasi_chat_response_model.dart';

class ChatCardWidget extends StatefulWidget {
  final NegotiationChatItem message;
  const ChatCardWidget({super.key, required this.message});

  @override
  State<ChatCardWidget> createState() => _ChatCardWidgetState();
}

class _ChatCardWidgetState extends State<ChatCardWidget> {
  Uint8List? _cachedImageBytes;
  String? _extractedTextMessage;

  @override
  void initState() {
    super.initState();
    _processMessagePayload();
  }

  @override
  void didUpdateWidget(covariant ChatCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.message.pesan != oldWidget.message.pesan || widget.message.id != oldWidget.message.id) {
      _processMessagePayload();
    }
  }

  void _processMessagePayload() {
    final String? rawPesan = widget.message.pesan;

    if (rawPesan == null) {
      _cachedImageBytes = null;
      _extractedTextMessage = null;
      return;
    }

    if (rawPesan.startsWith("DATA_IMAGE:")) {
      try {
        if (rawPesan.contains("||TEXT_MSG:")) {
          final List<String> parts = rawPesan.split("||TEXT_MSG:");
          final String base64String = parts[0].replaceFirst("DATA_IMAGE:", "");
          _extractedTextMessage = parts[1];
          _cachedImageBytes = base64Decode(base64String.trim());
        } else {
          final String base64String = rawPesan.replaceFirst("DATA_IMAGE:", "");
          _extractedTextMessage = null;
          _cachedImageBytes = base64Decode(base64String.trim());
        }
      } catch (e) {
        debugPrint("Error parsing base64 image: $e");
        _cachedImageBytes = null;
        _extractedTextMessage = rawPesan;
      }
    } else {
      _cachedImageBytes = null;
      _extractedTextMessage = rawPesan;
    }
  }

  void _showFullImagePreview(BuildContext context, Uint8List imageBytes) {
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
                  builder: (context, child) {
                    return Container(
                      color: Colors.black.withOpacity(animation.value * 0.9),
                    );
                  },
                ),
                // Main Content
                SafeArea(
                  child: Stack(
                    children: [
                      Center(
                        child: AnimatedBuilder(
                          animation: animation,
                          builder: (context, child) {
                            final double scale = 0.85 + (animation.value * 0.15);
                            return Transform.scale(
                              scale: scale,
                              child: Opacity(
                                opacity: animation.value,
                                child: child,
                              ),
                            );
                          },
                          child: InteractiveViewer(
                            minScale: 1.0,
                            maxScale: 4.0,
                            child: Image.memory(
                              imageBytes,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      
                      Positioned(
                        top: 16,
                        left: 16,
                        right: 16,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
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
                            if (widget.message.waktu.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  widget.message.waktu,
                                  style: const TextStyle(
                                    fontFamily: 'Montserrat',
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 250),
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
    final bool isMe = widget.message.typeUser.toLowerCase() == 'agen';
    final int? nominalTransaksi = widget.message.nominal;
    final bool hasNominal = nominalTransaksi != null && nominalTransaksi > 0;
    final bool isApproved = widget.message.isApprove ?? false;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double maxBubbleWidth = constraints.maxWidth * 0.75;

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            width: maxBubbleWidth,
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (hasNominal)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isApproved
                          ? const Color(0xFF1B4332)
                          : (isMe ? const Color(0xFFE52525) : const Color(0xFF1A1A1A)),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: (isApproved || !isMe) ? const Color(0xFFD4AF37) : Colors.white.withOpacity(0.6),
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
                                    isApproved ? Icons.verified_rounded : Icons.gavel_rounded,
                                    color: isApproved ? const Color(0xFFD4AF37) : (isMe ? Colors.white : const Color(0xFFD4AF37)),
                                    size: 14,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      isApproved
                                          ? "PENAWARAN DISETUJUI"
                                          : (isMe ? "PENAWARAN ANDA" : "PENAWARAN ADMIN"),
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        color: isApproved ? const Color(0xFFD4AF37) : (isMe ? Colors.white.withOpacity(0.9) : const Color(0xFFD4AF37)),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isApproved)
                              const Padding(
                                padding: EdgeInsets.only(left: 4),
                                child: Icon(
                                  Icons.done_all_rounded,
                                  color: Color(0xFFD4AF37),
                                  size: 16,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _formatRupiah(nominalTransaksi),
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                Container(
                  decoration: BoxDecoration(
                    color: isApproved
                        ? const Color(0xFF1B4332).withOpacity(0.15)
                        : (isMe ? const Color(0xFFE52525) : const Color(0xFFF1F1F1)),
                    border: isApproved
                        ? Border.all(color: const Color(0xFF1B4332).withOpacity(0.4), width: 1)
                        : null,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(14),
                      topRight: const Radius.circular(14),
                      bottomLeft: isMe ? const Radius.circular(14) : Radius.zero,
                      bottomRight: isMe ? Radius.zero : const Radius.circular(14),
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_cachedImageBytes != null)
                        GestureDetector(
                          onTap: () => _showFullImagePreview(context, _cachedImageBytes!),
                          child: Container(
                            constraints: const BoxConstraints(maxHeight: 200),
                            width: double.infinity,
                            child: Image.memory(
                              _cachedImageBytes!,
                              fit: BoxFit.cover,
                              gaplessPlayback: true,
                            ),
                          ),
                        ),
                      if (_extractedTextMessage != null && _extractedTextMessage!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          child: Text(
                            _extractedTextMessage!,
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isApproved
                                  ? const Color(0xFF1B4332)
                                  : (isMe ? Colors.white : const Color(0xFF1A1A1A)),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    widget.message.waktu,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      color: Color(0xFF8E8E93),
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                    ),
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