import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:reseller_app_tav/features/auth/providers/auth_provider.dart';
import 'package:reseller_app_tav/features/dashboard/models/negosiasi_response_model.dart';
import 'package:reseller_app_tav/features/dashboard/providers/negosiasi_provider.dart';
import 'package:reseller_app_tav/features/dashboard/screens/detail_transaksi_screen.dart';
import 'package:reseller_app_tav/features/dashboard/widgets/negosiasi/chat/chat_card_widget.dart';
import 'package:reseller_app_tav/features/dashboard/widgets/negosiasi/chat/chat_input_field.dart';
import 'package:reseller_app_tav/features/dashboard/widgets/negosiasi/modal_approve_nego.dart';

class RoomChatScreen extends StatefulWidget {
  final NegotiationResult negotiation;

  const RoomChatScreen({super.key, required this.negotiation});

  @override
  State<RoomChatScreen> createState() => RoomChatScreenState();
}

class RoomChatScreenState extends State<RoomChatScreen> {
  bool _isPanelExpanded = false;
  bool _hasShownSuccessDialog = false;
  final ScrollController _panelScrollController = ScrollController();
  final ScrollController _chatScrollController = ScrollController();
  late NegotiationResult _currentNegotiation;

  @override
  void initState() {
    super.initState();
    _currentNegotiation = widget.negotiation;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        final provider = Provider.of<NegotiationProvider>(
          context,
          listen: false,
        );
        final int currentUserId =
            Provider.of<AuthProvider>(context, listen: false).userId ?? 0;

        provider.prepareNewChatRoom();

        // 1. Ambil list obrolan chat
        await provider.fetchRoomChats(_currentNegotiation.id);

        // 2. 🟢 TAMBAHKAN INI: Tarik detail negosiasi terbaru dari API untuk memperbarui status global kamar
        await provider.fetchDetailNegotiation(_currentNegotiation.id);

        // 3. Nyalakan Socket listener
        provider.listenNegotiationChat(_currentNegotiation.id, currentUserId);
      }
    });
  }

  void changeNegotiationRoom(NegotiationResult newNegotiation) {
    final int currentUserId = context.read<AuthProvider>().userId ?? 0;

    setState(() {
      _currentNegotiation = newNegotiation;
      _isPanelExpanded = false;
      _hasShownSuccessDialog = false; // Reset flag pengunci modal
    });

    final provider = context.read<NegotiationProvider>();
    provider.prepareNewChatRoom();

    // Jalankan secara berurutan
    Future.microtask(() async {
      await provider.fetchRoomChats(_currentNegotiation.id);
      await provider.fetchDetailNegotiation(
        _currentNegotiation.id,
      ); // 🟢 Ambil status ter-update room baru
      provider.joinRoom(_currentNegotiation.id, currentUserId);
    });
  }

  // FUNGSI MODAL KONFIRMASI HAPUS DESIGN MODERN & PRESTIGE
  void _showDeleteConfirmationDialog(
    BuildContext context,
    NegotiationProvider provider,
  ) {
    final int totalSelected = provider.selectedChatIds.length;
    if (totalSelected == 0) return;

    final String alertMessage = totalSelected == 1
        ? "Apakah Anda yakin ingin menghapus pesan ini? Tindakan ini akan menghapus riwayat chat secara permanen."
        : "Apakah Anda yakin ingin menghapus $totalSelected pesan ini? Tindakan ini akan menghapus riwayat chat secara permanen.";

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // Sudut melengkung modern
          ),
          backgroundColor: const Color(
            0xFF1A1A1A,
          ), // Menggunakan latar belakang Black/Dark dari tema[cite: 3]
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. ICON DECORATION CONTAINER (RED & GOLD BORDER)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(
                      0xFFE52525,
                    ).withOpacity(0.1), // Sentuhan Red Brand
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(
                        0xFFD4AF37,
                      ).withOpacity(0.3), // Aksentuasi warna Gold[cite: 3]
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: Color(0xFFE52525), // Red Brand[cite: 1]
                    size: 36,
                  ),
                ),
                const SizedBox(height: 20),

                // 2. TITLE TEXT (WHITE & GOLD)
                const Text(
                  "HAPUS PESAN",
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: Colors.white, // White Palette
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 12),

                // 3. CONTENT TEXT (GRAY)
                Text(
                  alertMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF8E8E93), // Gray Palette
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 28),

                // 4. ACTION BUTTONS ROW
                Row(
                  children: [
                    // TOMBOL BATAL (GRAY OUTLINE MODERN)
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Color(0xFF333333),
                          ), // Dark Gray Border
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text(
                          "BATAL",
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            color: Color(0xFF8E8E93), // Gray Palette
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // TOMBOL HAPUS (SOLID RED SIGNATURE)
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(
                            0xFFE52525,
                          ), // Red Brand[cite: 1]
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () async {
                          Navigator.pop(dialogContext); // Tutup modal

                          final success = await provider.deleteSelectedMessages(
                            _currentNegotiation.id,
                          );

                          if (success && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  'Pesan berhasil dihapus dari server.',
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 12,
                                  ),
                                ),
                                backgroundColor: const Color(
                                  0xFF1A1A1A,
                                ), // Black[cite: 3]
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            );
                          }
                        },
                        child: const Text(
                          "YA, HAPUS",
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            letterSpacing: 0.5,
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
      },
    );
  }

  @override
  void dispose() {
    _panelScrollController.dispose();
    _chatScrollController.dispose();
    super.dispose();
  }

  String _formatRupiah(num? value) {
    if (value == null) return 'Rp 0';
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(value);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NegotiationProvider>(context);

    //  PERBAIKAN UTAMA: Gunakan listen: true (atau tanpa listen: false) di dalam build
    // agar ketika ID dari session manager selesai dimuat, UI langsung mendeteksi ID barunya.
    final int currentUserId = Provider.of<AuthProvider>(context).userId ?? 0;

    // 1. Ambil status dari provider atau fallback ke model parameter awal
    String currentStatus = provider.selectedNegotiationDetail?.status?.toUpperCase() ??
        _currentNegotiation.status.toUpperCase();

    // 2. 🟢 BYPASS EMERGENCY: Jika status masih kosong/belum update, intip data object map dari chat terakhir
    if (!(currentStatus.contains('ACC') || currentStatus.contains('REJECT')) && provider.chatMessages.isNotEmpty) {
      try {
        final firstMsg = provider.chatMessages.first;
        if (firstMsg.negotiation != null && firstMsg.negotiation!['status'] != null) {
          currentStatus = firstMsg.negotiation!['status'].toString().toUpperCase();
        }
      } catch (_) {}
    }

    // LOG UNTUK MEMASTIKAN VALUE REALTIME KAMU
    debugPrint('🔥 [ROOM CHAT TRIGGER CHECK] Status Kamar Saat Ini: "$currentStatus" | Sudah Pernah Tampil? $_hasShownSuccessDialog');

    // 3. JALANKAN TRIGGER DIALOG
    if ((currentStatus == 'ACC_CEO' || currentStatus == 'ACC_COO' || 
         currentStatus == 'REJECT_COO' || currentStatus == 'REJECT_CEO') &&
        !_hasShownSuccessDialog) {
      
      _hasShownSuccessDialog = true;
      final bool isRoomApproved = currentStatus == 'ACC_CEO' || currentStatus == 'ACC_COO';

      WidgetsBinding.instance.addPostFrameCallback((_) {
        SuccessDealDialog.show(
          context,
          isApproved: isRoomApproved,
          onRedirect: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => DetailTransaksiScreen(
                  transactionId: _currentNegotiation.id,
                ),
              ),
            );
          },
        );
      });
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: provider.isDeleteMode
          ? AppBar(
              backgroundColor: const Color(0xFF1A1A1A),
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => provider.toggleDeleteMode(false),
              ),
              title: Text(
                "${provider.selectedChatIds.length} Terpilih",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => provider.selectAllMessages(currentUserId),
                  child: const Text(
                    "Pilih Semua",
                    style: TextStyle(
                      color: Color(0xFFD4AF37),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete_sweep_rounded,
                    color: Colors.redAccent,
                  ),
                  onPressed: () =>
                      _showDeleteConfirmationDialog(context, provider),
                ),
              ],
            )
          : AppBar(
              backgroundColor: Colors.white,
              elevation: 0.5,
              toolbarHeight: 80,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.black,
                  size: 20,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              titleSpacing: 0,
              title: Consumer<NegotiationProvider>(
                builder: (context, provider, child) {
                  final car = _currentNegotiation.car;
                  final paymentType =
                      _currentNegotiation.paymentType?.toUpperCase() ?? 'CASH';
                  final dynamic hargaAsliMobil =
                      (paymentType == 'CREDIT' || paymentType == 'KREDIT')
                      ? (car?.creditPrice ?? 0)
                      : (car?.nominalPembelian ?? 0);

                  final hargaTawarAgen =
                      (provider.selectedNegotiationDetail?.id ==
                          _currentNegotiation.id)
                      ? (provider.selectedNegotiationDetail?.negotiatedPrice ??
                            _currentNegotiation.negotiatedPrice ??
                            0)
                      : (_currentNegotiation.negotiatedPrice ?? 0);

                  return Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          car?.carName ?? 'Detail Negosiasi',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: paymentType == 'CASH'
                                    ? const Color(0xFF2196F3).withOpacity(0.1)
                                    : const Color(0xFF9C27B0).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                paymentType,
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: paymentType == 'CASH'
                                      ? const Color(0xFF1976D2)
                                      : const Color(0xFF7B1FA2),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _formatRupiah(hargaAsliMobil),
                              style: const TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF8E8E93),
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              size: 12,
                              color: Color(0xFF8E8E93),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _formatRupiah(hargaTawarAgen),
                              style: const TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFFE52525),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
      body: Column(
        children: [
          Expanded(
            child: provider.chatMessages.isEmpty
                ? const Center(
                    child: Text(
                      "Belum ada pesan negosiasi",
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        color: Colors.grey,
                      ),
                    ),
                  )
                : ListView.builder(
                    key: ValueKey(provider.chatMessages.length),
                    controller: _chatScrollController,
                    padding: const EdgeInsets.only(
                      top: 16,
                      left: 14,
                      right: 14,
                      bottom: 20,
                    ),
                    reverse: true,
                    itemCount: provider.chatMessages.length,
                    itemBuilder: (context, index) {
                      final chatItem = provider.chatMessages[index];

                      // 🟢 PERBAIKAN MUTLAK:
                      // Jika typeUser secara eksplisit adalah 'agen', maka itu ADALAH pesan kamu,
                      // baik ketika userIdPengirim bernilai 0 (karena bug parsing JSON) maupun normal.
                      final bool isMessageFromMe =
                          (chatItem.typeUser.toLowerCase() == 'agen') ||
                          (chatItem.userIdPengirim.toString() ==
                                  currentUserId.toString() &&
                              chatItem.userIdPengirim != 0);

                      if (!isMessageFromMe) {
                        final bool isRead = chatItem.logNegotiationChat.any(
                          (log) => log.typeUser.toLowerCase() == 'agen',
                        );
                        if (!isRead) {
                          provider.readChatMessage(
                            negotiationId: _currentNegotiation.id,
                            chatId: chatItem.id,
                          );
                        }
                      }

                      return Row(
                        children: [
                          if (provider.isDeleteMode)
                            Checkbox(
                              activeColor: const Color(0xFFE52525),
                              value: provider.selectedChatIds.contains(
                                chatItem.id,
                              ),
                              onChanged: isMessageFromMe
                                  ? (_) => provider.toggleSelectMessage(
                                      chatItem.id,
                                    )
                                  : null,
                            ),
                          Expanded(
                            child: GestureDetector(
                              onLongPress: () {
                                if (isMessageFromMe) {
                                  provider.toggleDeleteMode(true);
                                  provider.toggleSelectMessage(chatItem.id);
                                }
                              },
                              onTap: () {
                                if (provider.isDeleteMode && isMessageFromMe) {
                                  provider.toggleSelectMessage(chatItem.id);
                                }
                              },
                              child: ChatCardWidget(
                                message: chatItem,
                                isMeCustom: isMessageFromMe,
                                roomStatus: currentStatus,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
          if (!provider.isDeleteMode)
            ChatInputField(negotiationId: _currentNegotiation.id),
        ],
      ),
    );
  }
}
