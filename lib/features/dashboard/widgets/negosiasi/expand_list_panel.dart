import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reseller_app_tav/core/theme/negosiasi_theme.dart';
import 'package:reseller_app_tav/features/dashboard/providers/negosiasi_provider.dart';
import 'package:reseller_app_tav/features/dashboard/widgets/negosiasi/create_negosiasi_dialog.dart';
import 'package:reseller_app_tav/features/dashboard/widgets/negosiasi/negosiasi_card_item.dart';

class ExpandedListPanel extends StatelessWidget {
  final NegotiationProvider provider;
  final ScrollController scrollController;
  final VoidCallback onClosePanel;
  final VoidCallback onCreateTap;

  const ExpandedListPanel({
    super.key,
    required this.provider,
    required this.scrollController,
    required this.onClosePanel,
    required this.onCreateTap,
  });

  @override
  Widget build(BuildContext context) {
    final double panelWidth = MediaQuery.of(context).size.width - 32;

    return Container(
      width: panelWidth,
      constraints: const BoxConstraints(maxHeight: 400),
      decoration: BoxDecoration(
        color: NegotiationTheme.colorPanelBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: NegotiationTheme.colorBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize
            .min, 
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.forum_rounded,
                      color: NegotiationTheme.colorGold,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "List Negosiasi",
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    if (provider.totalNewNegotiations > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: NegotiationTheme.colorRed,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          "${provider.totalNewNegotiations}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: onCreateTap,
                      icon: const Icon(
                        Icons.add_circle_outline_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                      tooltip: "Buat Pengajuan Baru",
                    ),
                    IconButton(
                      onPressed: onClosePanel,
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(color: NegotiationTheme.colorBorder, height: 1),

          Expanded(
            child: provider.isLoading && provider.negotiations.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(
                      color: NegotiationTheme.colorRed,
                    ),
                  )
                : provider.negotiations.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text(
                        "Belum ada data negosiasi",
                        style: TextStyle(
                          color: Colors.grey,
                          fontFamily: 'Montserrat',
                          fontSize: 13,
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.all(12),
                    itemCount:
                        provider.negotiations.length +
                        (provider.hasMoreData ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == provider.negotiations.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(
                              color: NegotiationTheme.colorRed,
                            ),
                          ),
                        );
                      }

                      final negotiationItem = provider.negotiations[index];
                      return NegotiationItemCard(
                        item: negotiationItem,
                        onEdit: () {
                          CreateNegotiationDialog.show(
                            context,
                            editItem: negotiationItem,
                            onSuccess: () {
                              Provider.of<NegotiationProvider>(
                                context,
                                listen: false,
                              ).fetchAllNegotiations(isRefresh: true);
                            },
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
