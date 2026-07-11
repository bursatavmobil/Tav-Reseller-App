import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:reseller_app_tav/features/dashboard/models/negosiasi_response_model.dart';
import 'package:reseller_app_tav/features/dashboard/providers/negosiasi_provider.dart';
import 'package:reseller_app_tav/features/dashboard/widgets/negosiasi/chat/chat_card_widget.dart';
import 'package:reseller_app_tav/features/dashboard/widgets/negosiasi/chat/chat_input_field.dart';
import 'package:reseller_app_tav/features/dashboard/widgets/negosiasi/collapsed_floating_action.dart';
import 'package:reseller_app_tav/features/dashboard/widgets/negosiasi/create_negosiasi_dialog.dart';
import 'package:reseller_app_tav/features/dashboard/widgets/negosiasi/expand_list_panel.dart';

class RoomChatScreen extends StatefulWidget {
  final NegotiationResult negotiation;

  const RoomChatScreen({super.key, required this.negotiation});

  @override
  State<RoomChatScreen> createState() => RoomChatScreenState();
}

class RoomChatScreenState extends State<RoomChatScreen> {
  bool _isPanelExpanded = false;
  final ScrollController _panelScrollController = ScrollController();
  final ScrollController _chatScrollController = ScrollController();
  Timer? _pollingTimer;
  late NegotiationResult _currentNegotiation;

  @override
  void initState() {
    super.initState();
    _currentNegotiation = widget.negotiation;
    context.read<NegotiationProvider>().prepareNewChatRoom();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<NegotiationProvider>().fetchRoomChats(
          _currentNegotiation.id,
        );
        _startPolling();
      }
    });
  }

  void changeNegotiationRoom(NegotiationResult newNegotiation) {
    _pollingTimer?.cancel();

    setState(() {
      _currentNegotiation = newNegotiation;
      _isPanelExpanded = false;
    });

    context.read<NegotiationProvider>().prepareNewChatRoom();
    context.read<NegotiationProvider>().fetchRoomChats(_currentNegotiation.id);
    _startPolling();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        context.read<NegotiationProvider>().fetchRoomChats(
          _currentNegotiation.id,
        );
      }
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
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
    final car = _currentNegotiation.car;
    final paymentType =
        _currentNegotiation.paymentType?.toUpperCase() ?? 'CASH';
    final dynamic hargaAsliMobil =
        (paymentType == 'CREDIT' || paymentType == 'KREDIT')
        ? (car?.creditPrice ?? car?.creditPrice ?? 0)
        : (car?.nominalPembelian ?? car?.nominalPembelian ?? 0);

    final hargaTawarAgen = _currentNegotiation.negotiatedPrice ?? 0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
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
        title: Padding(
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
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
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
              ),
            ],
          ),
        ),
      ),
      body: Consumer<NegotiationProvider>(
        builder: (context, provider, child) {
          return Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child:
                        provider.isChatLoading && provider.chatMessages.isEmpty
                        ? const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFFE52525),
                              ),
                            ),
                          )
                        : provider.chatMessages.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.chat_bubble_outline_rounded,
                                  size: 48,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Belum ada percakapan',
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF8E8E93),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            controller: _chatScrollController,
                            reverse: true,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            itemCount: provider.chatMessages.length,
                            itemBuilder: (context, index) {
                              final message = provider.chatMessages[index];
                              return ChatCardWidget(message: message);
                            },
                          ),
                  ),
                  ChatInputField(negotiationId: _currentNegotiation.id),
                ],
              ),
              if (_isPanelExpanded)
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () => setState(() => _isPanelExpanded = false),
                    child: Container(color: Colors.black.withOpacity(0.2)),
                  ),
                ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 350),
                curve: Curves.fastOutSlowIn,
                right: 16,
                top: _isPanelExpanded
                    ? MediaQuery.of(context).size.height * 0.02
                    : 12,
                left: _isPanelExpanded ? 16 : null,
                child: _isPanelExpanded
                    ? ExpandedListPanel(
                        provider: provider,
                        scrollController: _panelScrollController,
                        onClosePanel: () =>
                            setState(() => _isPanelExpanded = false),
                        onCreateTap: () =>
                            CreateNegotiationDialog.show(context),
                      )
                    : CollapsedFloatingAction(
                        provider: provider,
                        onOpenPanel: () {
                          context
                              .read<NegotiationProvider>()
                              .fetchAllNegotiations(isRefresh: true);
                          setState(() => _isPanelExpanded = true);
                        },
                        onCreateTap: () =>
                            CreateNegotiationDialog.show(context),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
