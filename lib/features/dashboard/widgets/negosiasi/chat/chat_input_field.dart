import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:reseller_app_tav/features/auth/providers/auth_provider.dart';
import 'package:reseller_app_tav/features/dashboard/providers/dashboard_provider.dart';
import 'package:reseller_app_tav/features/dashboard/providers/negosiasi_provider.dart';

class ChatInputField extends StatefulWidget {
  final int negotiationId;

  const ChatInputField({super.key, required this.negotiationId});

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  final TextEditingController _textController = TextEditingController();
  int? _selectedNominal;
  File? _selectedImage;

  String _formatRupiah(int value) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(value);
  }

  Future<void> _handlePickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
        debugPrint("📸 [UI] Gambar dipilih: ${image.path}");
      }
    } catch (e) {
      debugPrint("❌ 📸 [UI Error] Gagal memilih gambar: $e");
    }
  }

  void _executeDirectSendNominal(int nominal) async {
    final provider = Provider.of<NegotiationProvider>(context, listen: false);
    final dashboardProvider = Provider.of<DashboardProvider>(
      context,
      listen: false,
    );
    final String namaAgenAktif = dashboardProvider.profile?.name ?? "Agen";
    final int currentUserId = context.read<AuthProvider>().userId ?? 0;

    try {
      await provider.sendChatMessage(
        negotiationId: widget.negotiationId,
        currentUserId: currentUserId,
        pengirimName: namaAgenAktif,
        pesan: null,
        nominal: nominal,
        gambarFile: null,
      );

      if (provider.errorMessage != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengirim nominal: ${provider.errorMessage}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan lokal: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showNominalBottomSheet(BuildContext context) {
    final TextEditingController nominalController = TextEditingController();

    if (_selectedNominal != null) {
      nominalController.text = _selectedNominal!.toString();
      final formatter = RupiahInputFormatter();
      final textValue = TextEditingValue(text: _selectedNominal!.toString());
      nominalController.value = formatter.formatEditUpdate(
        TextEditingValue.empty,
        textValue,
      );
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Masukkan Nominal Penawaran',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nominalController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  RupiahInputFormatter(),
                ],
                decoration: const InputDecoration(
                  hintText: 'Rp 0',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Batal',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE52525),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () {
                      final String cleanText = nominalController.text
                          .replaceAll(RegExp(r'[^0-9]'), '');
                      final int? targetNominal = int.tryParse(cleanText);

                      if (targetNominal != null && targetNominal > 0) {
                        Navigator.pop(context);
                        _executeDirectSendNominal(targetNominal);
                      }
                    },
                    icon: const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                    label: const Text(
                      'Send',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _handleSendMessage() async {
    final String text = _textController.text.trim();

    if (text.isEmpty && _selectedNominal == null && _selectedImage == null) {
      return;
    }

    final provider = Provider.of<NegotiationProvider>(context, listen: false);
    final dashboardProvider = Provider.of<DashboardProvider>(
      context,
      listen: false,
    );
    final String namaAgenAktif = dashboardProvider.profile?.name ?? "Agen";

    final String currentText = text;
    final int? nominalToSend = _selectedNominal;
    final File? imageToSend = _selectedImage;
    final int currentUserId = context.read<AuthProvider>().userId ?? 0;

    _textController.clear();
    setState(() {
      _selectedNominal = null;
      _selectedImage = null;
    });

    try {
      await provider.sendChatMessage(
        negotiationId: widget.negotiationId,
        currentUserId: currentUserId,
        pengirimName: namaAgenAktif,
        pesan: currentText.isNotEmpty ? currentText : null,
        nominal: nominalToSend,
        gambarFile: imageToSend,
      );

      if (provider.errorMessage != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengirim: ${provider.errorMessage}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan lokal: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_selectedImage != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFFAFAFA),
              border: Border(top: BorderSide(color: Color(0xFFE5E5EA))),
            ),
            child: Row(
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        _selectedImage!,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 2,
                      right: 2,
                      child: GestureDetector(
                        onTap: () {
                          debugPrint("🗑 [UI] Gambar dibatalkan oleh user");
                          setState(() => _selectedImage = null);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Gambar siap dikirim',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF666666),
                    ),
                  ),
                ),
              ],
            ),
          ),
        if (_selectedNominal != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: const Color(0xFFF5F5F5),
            child: Row(
              children: [
                const Icon(
                  Icons.calculate_rounded,
                  color: Color(0xFFE52525),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'Penawaran: ${_formatRupiah(_selectedNominal!)}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF222222),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    debugPrint("🗑 [UI] Nominal dibatalkan oleh user");
                    setState(() => _selectedNominal = null);
                  },
                  child: const Icon(
                    Icons.cancel_rounded,
                    color: Colors.grey,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFE0E0E0))),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.add_photo_alternate_rounded,
                    color: Color(0xFFE52525),
                    size: 24,
                  ),
                  onPressed: _handlePickImage,
                ),
                IconButton(
                  icon: const Icon(
                    Icons.calculate_rounded,
                    color: Color(0xFFE52525),
                    size: 22,
                  ),
                  onPressed: () => _showNominalBottomSheet(context),
                ),
                Expanded(
                  child: TextField(
                    controller: _textController,
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _handleSendMessage(),
                    decoration: InputDecoration(
                      hintText: 'Tulis pesan...',
                      hintStyle: const TextStyle(
                        color: Color(0xFF8E8E93),
                        fontSize: 13,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF2F2F7),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: Color(0xFFE5E5EA)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFFE52525),
                  child: IconButton(
                    icon: const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                    onPressed: _handleSendMessage,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class RupiahInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }
    if (newValue.selection.baseOffset == 0) return newValue;

    final int value = int.parse(
      newValue.text.replaceAll(RegExp(r'[^0-9]'), ''),
    );
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final String newText = formatter.format(value);

    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
