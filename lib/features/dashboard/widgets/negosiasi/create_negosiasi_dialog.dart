import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:reseller_app_tav/core/theme/negosiasi_theme.dart';
import 'package:reseller_app_tav/features/auth/screens/widget/thousand_sparator.dart';
import 'package:reseller_app_tav/features/dashboard/models/negosiasi_response_model.dart';
import 'package:reseller_app_tav/features/dashboard/providers/negosiasi_provider.dart';
import 'package:reseller_app_tav/features/dashboard/providers/profile_provider.dart';
import 'package:reseller_app_tav/features/dashboard/screens/room_chat_screen.dart';
import 'package:reseller_app_tav/features/dashboard/services/stock_car_service.dart';
import 'package:reseller_app_tav/features/dashboard/widgets/negosiasi/not_support_credit_dialog.dart';

import '../../../../core/widget/cutsom_alert_widget.dart';

class CreateNegotiationDialog {
  static void show(
    BuildContext context, {
    NegotiationResult? editItem,
    VoidCallback? onSuccess,
    Map<String, dynamic>? initialCar,
  }) {
    if (initialCar != null) {
      debugPrint("DEBUG NEGO CAR: ${initialCar.toString()}");
    }

    final stockCarService = StockCarService();

    final profileProvider = Provider.of<ProfileProvider>(
      context,
      listen: false,
    );
    final profileData = profileProvider.profileData;

    final String defaultAgentName = (profileData?['name'] ?? '')
        .toString()
        .toUpperCase();
    final String defaultAgentPhone =
        profileData?['no_whatsapp'] ??
        profileData?['no_wa'] ??
        profileData?['phone'] ??
        '';
    int? selectedCarId = editItem?.carId ?? initialCar?['id'];
    String selectedCarName =
        editItem?.car?.carName ??
        initialCar?['name'] ??
        "Pilih Mobil yang Akan Ditawar";

    dynamic selectedCarCashPrice =
        editItem?.car?.nominalPembelian ?? initialCar?['cash_price'];

    dynamic selectedCarCreditPrice =
        editItem?.car?.creditPrice ??
        editItem?.car?.nominalPembelian ??
        initialCar?['credit_price'] ??
        initialCar?['cash_price'];

    String selectedPaymentType = editItem?.paymentType ?? 'CASH';

    final bidderController = TextEditingController(
      text: editItem?.bidder ?? defaultAgentName,
    );
    final phoneController = TextEditingController(
      text: editItem?.bidderPhone ?? defaultAgentPhone,
    );
    final priceController = TextEditingController(
      text: editItem?.negotiatedPrice.toString() ?? '',
    );

    String formatCurrency(dynamic value) {
      if (value == null) return "Rp 0";
      final int val = value is int
          ? value
          : int.tryParse(value.toString()) ?? 0;
      return NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 0,
      ).format(val);
    }

    void openCarSelectionSheet(
      BuildContext dialogContext,
      StateSetter setDialogState,
    ) {
      final searchController = TextEditingController();
      List<dynamic> cars = [];
      bool isSearching = false;

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: const Color(0xFF161616),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          side: BorderSide(color: NegotiationTheme.colorBorder),
        ),
        builder: (sheetContext) {
          return StatefulBuilder(
            builder: (context, setSheetState) {
              Future<void> searchCars(String query) async {
                if (query.isEmpty) {
                  setSheetState(() {
                    cars = [];
                  });
                  return;
                }
                setSheetState(() => isSearching = true);
                try {
                  final response = await stockCarService.fetchStockCars(
                    page: 1,
                    perPage: 20,
                    searchName: query,
                  );
                  if (response['status'] == true && response['data'] != null) {
                    setSheetState(() {
                      cars = response['data']['result'] ?? [];
                    });
                  }
                } catch (e) {
                  debugPrint('Error fetch cars: $e');
                } finally {
                  setSheetState(() => isSearching = false);
                }
              }

              return Container(
                padding: EdgeInsets.only(
                  top: 16,
                  left: 16,
                  right: 16,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                ),
                height: MediaQuery.of(context).size.height * 0.65,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: NegotiationTheme.colorBorder,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "CARI UNIT MOBIL",
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: searchController,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      onChanged: (value) => searchCars(value),
                      decoration: InputDecoration(
                        hintText: "Ketik nama unit mobil...",
                        hintStyle: const TextStyle(
                          color: NegotiationTheme.colorGrayText,
                          fontSize: 12,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: NegotiationTheme.colorGold,
                          size: 20,
                        ),
                        filled: true,
                        fillColor: Colors.black,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: NegotiationTheme.colorBorder,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: NegotiationTheme.colorGold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: isSearching
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: NegotiationTheme.colorRed,
                              ),
                            )
                          : cars.isEmpty
                          ? Center(
                              child: Text(
                                searchController.text.isEmpty
                                    ? "Ketik nama mobil untuk memulai pencarian"
                                    : "Unit mobil tidak ditemukan",
                                style: const TextStyle(
                                  color: NegotiationTheme.colorGrayText,
                                  fontSize: 12,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                            )
                          : ListView.separated(
                              itemCount: cars.length,
                              separatorBuilder: (_, __) => Container(
                                color: NegotiationTheme.colorBorder,
                                height: 0.5,
                              ),
                              itemBuilder: (context, index) {
                                final car = cars[index];
                                final int id = car['id'] ?? 0;
                                final String name = car['name'] ?? '-';
                                final String cover = car['car_cover'] ?? '';
                                final dynamic cashPrice =
                                    car['nominal_pembelian'] ?? 0;
                                final dynamic creditPrice =
                                    car['promo_credit_price'] ??
                                    car['nominal_pembelian'] ??
                                    0;

                                return ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 6,
                                    horizontal: 4,
                                  ),
                                  leading: Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: NegotiationTheme.colorBorder,
                                      ),
                                    ),
                                    child: cover.isNotEmpty
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                            child: Image.network(
                                              cover,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  const Icon(
                                                    Icons.directions_car,
                                                    color: NegotiationTheme
                                                        .colorGrayText,
                                                    size: 20,
                                                  ),
                                            ),
                                          )
                                        : const Icon(
                                            Icons.directions_car,
                                            color:
                                                NegotiationTheme.colorGrayText,
                                            size: 20,
                                          ),
                                  ),
                                  title: Text(
                                    name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Montserrat',
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 4),
                                      Wrap(
                                        spacing: 12,
                                        runSpacing: 4,
                                        children: [
                                          Text(
                                            "Cash: ${formatCurrency(cashPrice)}",
                                            style: const TextStyle(
                                              color: Colors.green,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: 'Montserrat',
                                            ),
                                          ),
                                          Text(
                                            "Credit: ${formatCurrency(creditPrice)}",
                                            style: const TextStyle(
                                              color: NegotiationTheme.colorGold,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: 'Montserrat',
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        "ID Unit: #$id",
                                        style: const TextStyle(
                                          color: NegotiationTheme.colorGrayText,
                                          fontSize: 10,
                                          fontFamily: 'Montserrat',
                                        ),
                                      ),
                                    ],
                                  ),
                                  onTap: () {
                                    setDialogState(() {
                                      selectedCarId = id;
                                      selectedCarName = name;
                                      selectedCarCashPrice = cashPrice;
                                      selectedCarCreditPrice = creditPrice;
                                    });
                                    Navigator.pop(sheetContext);
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1A1A1A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: NegotiationTheme.colorBorder),
              ),
              title: Text(
                editItem != null ? "EDIT NEGOSIASI" : "BUAT NEGOSIASI BARU",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Montserrat',
                  letterSpacing: 0.5,
                ),
              ),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(bottom: 6.0),
                        child: Text(
                          "Pilih Unit Mobil",
                          style: TextStyle(
                            color: NegotiationTheme.colorGrayText,
                            fontSize: 11,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () =>
                            openCarSelectionSheet(context, setDialogState),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: selectedCarId != null
                                  ? NegotiationTheme.colorGold
                                  : NegotiationTheme.colorBorder,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      selectedCarName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: selectedCarId != null
                                            ? Colors.white
                                            : NegotiationTheme.colorGrayText,
                                        fontSize: 12,
                                        fontWeight: selectedCarId != null
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        fontFamily: 'Montserrat',
                                      ),
                                    ),
                                    if (selectedCarId != null) ...[
                                      const SizedBox(height: 6),
                                      Wrap(
                                        spacing: 10,
                                        runSpacing: 4,
                                        children: [
                                          Text(
                                            "Cash: ${formatCurrency(selectedCarCashPrice)}",
                                            style: const TextStyle(
                                              color: Colors.green,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Montserrat',
                                            ),
                                          ),
                                          Text(
                                            "Credit: ${formatCurrency(selectedCarCreditPrice)}",
                                            style: const TextStyle(
                                              color: NegotiationTheme.colorGold,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Montserrat',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.arrow_drop_down_circle_rounded,
                                color: NegotiationTheme.colorGold,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildField(
                        bidderController,
                        "Nama Penawar",
                        TextInputType.text,
                        textCapitalization: TextCapitalization.characters,
                        inputFormatters: [
                          TextInputFormatter.withFunction((oldValue, newValue) {
                            return newValue.copyWith(
                              text: newValue.text.toUpperCase(),
                            );
                          }),
                        ],
                      ),
                      _buildField(
                        phoneController,
                        "Nomor Telepon",
                        TextInputType.phone,
                      ),
                      _buildField(
                        priceController,
                        "Nominal Nego Harga",
                        TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          ThousandsSeparatorInputFormatter(),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Expanded(
                            child: Text(
                              "Tipe Pembayaran:",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: ['CASH', 'CREDIT'].map((type) {
                              bool isSelected = selectedPaymentType == type;
                              return ChoiceChip(
                                label: Text(
                                  type,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.black
                                        : Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                selected: isSelected,
                                selectedColor: NegotiationTheme.colorGold,
                                backgroundColor: Colors.black,
                                onSelected: (val) {
                                  if (val)
                                    setDialogState(
                                      () => selectedPaymentType = type,
                                    );
                                },
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text(
                    "BATAL",
                    style: TextStyle(
                      color: NegotiationTheme.colorGrayText,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: NegotiationTheme.colorRed, 
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8), 
                    ),
                  ),
                  onPressed: () async {
                    if (selectedCarId == null ||
                        bidderController.text.isEmpty ||
                        priceController.text.isEmpty) {
                      CustomAnimatedAlert.show(
                        context,
                        "Lengkapi semua data & pilih unit mobil terlebih dahulu!",
                        false,
                      ); 
                      return;
                    }

                    final cleanPriceString = priceController.text.replaceAll(
                      RegExp(r'[^0-9]'),
                      '',
                    ); 
                    final int negotiatedPriceValue =
                        int.tryParse(cleanPriceString) ?? 0; 

                    final provider = Provider.of<NegotiationProvider>(
                      context,
                      listen: false,
                    ); 

                    final newlyCreatedNegotiation = await provider
                        .submitNegotiation(
                          id: editItem?.id, 
                          carId: selectedCarId!, 
                          bidder: bidderController.text, 
                          bidderPhone: phoneController.text, 
                          negotiatedPrice: negotiatedPriceValue, 
                          paymentType: selectedPaymentType, 
                        );

                    if (context.mounted) {
                      Navigator.pop(
                        dialogContext,
                      ); // Tutup dialog input form[cite: 9]

                      if (newlyCreatedNegotiation != null) {
                        CustomAnimatedAlert.show(
                          context,
                          "Berhasil memproses room negosiasi!",
                          true,
                        ); 
                        if (onSuccess != null) {
                          onSuccess(); 
                        }
                        provider.prepareNewChatRoom(); //
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            settings: const RouteSettings(
                              name: 'RoomChatScreen',
                            ), //
                            builder: (_) => RoomChatScreen(
                              negotiation: newlyCreatedNegotiation,
                            ), //[cite: 10]
                          ),
                        );
                      } else {
                        final errorMsg =
                            provider.errorMessage ??
                            "Terjadi kesalahan."; 

                        if (errorMsg.toLowerCase().contains("payment type") ||
                            errorMsg.toLowerCase().contains("tidak valid")) {
                          CreditNotSupportedDialog.show(context); 
                        } else {
                          CustomAnimatedAlert.show(
                            context,
                            errorMsg,
                            false,
                          ); 
                        }
                      }
                    }
                  },
                  child: const Text(
                    "SUBMIT",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Montserrat',
                    ),
                  ), 
                ),
              ],
            );
          },
        );
      },
    );
  }

  static Widget _buildField(
    TextEditingController controller,
    String label,
    TextInputType inputType, {
    List<TextInputFormatter>? inputFormatters,
    TextCapitalization textCapitalization =
        TextCapitalization.none, // 💡 Ditambahkan sebagai parameter opsional
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
        controller: controller,
        keyboardType: inputType,
        inputFormatters: inputFormatters,
        textCapitalization: textCapitalization,
        style: const TextStyle(color: Colors.white, fontSize: 13),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: NegotiationTheme.colorGrayText,
            fontSize: 12,
          ),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: NegotiationTheme.colorBorder),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: NegotiationTheme.colorGold),
          ),
        ),
      ),
    );
  }
}
