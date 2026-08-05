import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:reseller_app_tav/core/theme/negosiasi_theme.dart';
import 'package:reseller_app_tav/features/dashboard/models/negosiasi_response_model.dart';
import 'package:reseller_app_tav/features/dashboard/providers/negosiasi_provider.dart';
import 'package:reseller_app_tav/features/dashboard/screens/room_chat_screen.dart';

class NegotiationItemCard extends StatelessWidget {
  final NegotiationResult item;
  final VoidCallback? onEdit;

  const NegotiationItemCard({super.key, required this.item, this.onEdit});

  String _formatCurrency(int value) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(value);
  }

  @override
  Widget build(BuildContext context) {
    Color statusColor = item.status.toUpperCase() == 'ACC_CEO'
        ? Colors.green
        : (item.status.toUpperCase() == 'REJECTED'
              ? NegotiationTheme.colorRed
              : NegotiationTheme.colorGold);

    return GestureDetector(
      onTap: () {
        final negotiationProvider = Provider.of<NegotiationProvider>(
          context,
          listen: false,
        );

        bool diDalamChatRoom = false;
        dynamic targetState;
        
        context.visitAncestorElements((element) {
          if (element.widget is RoomChatScreen) {
            diDalamChatRoom = true;
            targetState = (element as StatefulElement).state;
            return false;
          }
          return true;
        });

        if (diDalamChatRoom && targetState != null) {
          targetState.changeNegotiationRoom(item);
        } else {
          negotiationProvider.prepareNewChatRoom();
          Navigator.push(
            context,
            MaterialPageRoute(
              settings: const RouteSettings(name: 'RoomChatScreen'),
              builder: (_) => RoomChatScreen(negotiation: item),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: NegotiationTheme.colorCardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: NegotiationTheme.colorBorder, width: 1),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 75,
                    height: 75,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: NegotiationTheme.colorBorder),
                    ),
                    child: item.car?.carCover != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              item.car!.carCover!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Icon(
                            Icons.directions_car,
                            color: NegotiationTheme.colorGrayText,
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                item.car?.carName ?? "Unit ID: #${item.carId}",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                item.status,
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.bidder,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Telp: ${item.bidderPhone}",
                              style: const TextStyle(
                                color: NegotiationTheme.colorGrayText,
                                fontSize: 11,
                              ),
                            ),
                            if (onEdit != null)
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: NegotiationTheme.colorGold,
                                  size: 18,
                                ),
                                onPressed: onEdit,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: NegotiationTheme.colorBorder, height: 1),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildPriceInfo(
                    "HARGA AWAL",
                    _formatCurrency(item.startingPrice),
                    Colors.white,
                  ),
                  _buildPriceInfo(
                    "PENAWARAN (${item.paymentType})",
                    _formatCurrency(item.negotiatedPrice),
                    Colors.green,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceInfo(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: NegotiationTheme.colorGrayText,
            fontSize: 9,
            fontFamily: 'Montserrat',
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}