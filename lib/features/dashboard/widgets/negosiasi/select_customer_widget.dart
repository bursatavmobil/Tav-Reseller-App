import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reseller_app_tav/features/dashboard/providers/negosiasi_provider.dart';

class SelectCustomerSheet extends StatefulWidget {
  final Function(dynamic selectedCustomer) onSelectConfirmed;

  const SelectCustomerSheet({super.key, required this.onSelectConfirmed});

  static void show(
    BuildContext context, {
    required Function(dynamic selectedCustomer) onSelectConfirmed,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A1A), // 🖤 Black Theme Premium
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) =>
          SelectCustomerSheet(onSelectConfirmed: onSelectConfirmed),
    );
  }

  @override
  State<SelectCustomerSheet> createState() => _SelectCustomerSheetState();
}

class _SelectCustomerSheetState extends State<SelectCustomerSheet> {
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 1;
  final int _perPage = 5;
  List<dynamic> _customers = [];
  dynamic _selectedCustomerData;
  bool _isLoading = false;
  bool _hasMore = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final service = context.read<NegotiationProvider>().negotiationService;
      final res = await service.getAllCustomers(
        page: _currentPage,
        perPage: _perPage,
        searchName: _searchController.text.trim().isEmpty
            ? null
            : _searchController.text.trim(),
      );

      if (res.data['status'] == true) {
        setState(() {
          _customers = res.data['data']['result'];
          _hasMore = _currentPage < res.data['data']['last_page'];
        });
      }
    } catch (e) {
      debugPrint("Gagal load customer sheet: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle Top Indikator
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF333333),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Pilih Customer Penerima",
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 14),

            // Field Cari Data Kustomer
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF262626),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Montserrat',
                  fontSize: 13,
                ),
                onSubmitted: (_) {
                  setState(() => _currentPage = 1);
                  _fetchData();
                },
                decoration: const InputDecoration(
                  hintText: "Cari nama customer...",
                  hintStyle: TextStyle(
                    color: Color(0xFF8E8E93),
                    fontFamily: 'Montserrat',
                    fontSize: 13,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: Color(0xFF8E8E93),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Daftar List Kustomer
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Color(0xFFE52525)),
                      ),
                    )
                  : _customers.isEmpty
                  ? const Center(
                      child: Text(
                        "Customer tidak ditemukan",
                        style: TextStyle(
                          color: Color(0xFF8E8E93),
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _customers.length,
                      itemBuilder: (context, index) {
                        final c = _customers[index];
                        final bool isPicked =
                            _selectedCustomerData != null &&
                            _selectedCustomerData['id'] == c['id'];

                        return GestureDetector(
                          onTap: () {
                            setState(() => _selectedCustomerData = c);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isPicked
                                  ? const Color(0xFF262626)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isPicked
                                    ? const Color(0xFFD4AF37)
                                    : const Color(0xFF333333),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.person_pin_rounded,
                                  color: isPicked
                                      ? const Color(0xFFD4AF37)
                                      : const Color(0xFF8E8E93),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        c['first_name'] ?? 'No Name',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Montserrat',
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        c['phone'] ?? '-',
                                        style: const TextStyle(
                                          color: Color(0xFF8E8E93),
                                          fontSize: 11,
                                          fontFamily: 'Montserrat',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isPicked)
                                  const Icon(
                                    Icons.check_circle_rounded,
                                    color: Color(0xFFD4AF37),
                                    size: 18,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // Pagination Mini Control
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Halaman $_currentPage",
                    style: const TextStyle(
                      color: Color(0xFF8E8E93),
                      fontSize: 11,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                        onPressed: _currentPage > 1
                            ? () {
                                setState(() => _currentPage--);
                                _fetchData();
                              }
                            : null,
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                        onPressed: _hasMore
                            ? () {
                                setState(() => _currentPage++);
                                _fetchData();
                              }
                            : null,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Tombol Konfirmasi Kirim Dinamis di Paling Bawah
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: // 🟢 TAMBAHKAN LOG DEBUG PADA ELEVATED BUTTON DI PALING BAWAH SCREEN SHEET
              ElevatedButton(
                onPressed: _selectedCustomerData == null
                    ? null
                    : () {
                        // ==================== 🛠️ DEBUG LOG START ====================
                        debugPrint(
                          "==================================================",
                        );
                        debugPrint(
                          "🚀 [DEBUG ACTION] USER CLICKED SEND REQUEST PAYMENT",
                        );
                        debugPrint(
                          "👤 CUSTOMER ID    : ${_selectedCustomerData['id']}",
                        );
                        debugPrint(
                          "NAME           : ${_selectedCustomerData['first_name']}",
                        );
                        debugPrint(
                          "✉️ EMAIL           : ${_selectedCustomerData['email']}",
                        );
                        debugPrint(
                          "📞 PHONE           : ${_selectedCustomerData['phone']}",
                        );
                        debugPrint("RAW OBJECT     : $_selectedCustomerData");
                        debugPrint(
                          "==================================================",
                        );
                        // ===================== 🛠️ DEBUG LOG END =====================

                        Navigator.pop(context);
                        widget.onSelectConfirmed(_selectedCustomerData);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE52525),
                  disabledBackgroundColor: const Color(0xFF262626),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  _selectedCustomerData != null
                      ? "KIRIM KE ${_selectedCustomerData['first_name'].toString().toUpperCase()}"
                      : "PILIH CUSTOMER TERLEBIH DAHULU",
                  style: TextStyle(
                    color: _selectedCustomerData != null
                        ? Colors.white
                        : const Color(0xFF8E8E93),
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
