import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reseller_app_tav/features/dashboard/providers/negosiasi_provider.dart';
import 'package:reseller_app_tav/features/dashboard/widgets/negosiasi/transaksi_card_item.dart'; // Jalur import card
import 'package:reseller_app_tav/features/dashboard/widgets/paginate_footer_bar.dart';

import 'customer_screen.dart';

class TransaksiScreen extends StatefulWidget {
  const TransaksiScreen({super.key});

  @override
  State<TransaksiScreen> createState() => _TransaksiScreenState();
}

class _TransaksiScreenState extends State<TransaksiScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 1;
  final int _perPage = 3;

  double _fabTop = 0;
  double _fabLeft = 0;
  bool _isFabPositionInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    context.read<NegotiationProvider>().fetchTransactions(
      isRefresh: true,
      page: _currentPage,
      perPage: _perPage,
      searchCarOrBidder: _searchController.text.trim().isEmpty
          ? null
          : _searchController.text.trim(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isFabPositionInitialized) {
      final mediaQuery = MediaQuery.of(context);
      _fabTop = mediaQuery.size.height * 0.65;
      _fabLeft = mediaQuery.size.width - 180;
      _isFabPositionInitialized = true;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          "Transaksi",
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1A1A1A),
            letterSpacing: -0.5,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: 12,
              top: 4,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF1F3F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                onSubmitted: (_) {
                  setState(() => _currentPage = 1);
                  _loadData();
                },
                decoration: InputDecoration(
                  hintText: "Cari mobil atau nama penawar transaksi...",
                  hintStyle: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 13,
                    color: Color(0xFF8E8E93),
                    fontWeight: FontWeight.w500,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: Color(0xFF8E8E93),
                    size: 20,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.clear_rounded,
                            color: Color(0xFF8E8E93),
                            size: 18,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _currentPage = 1);
                            _loadData();
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Consumer<NegotiationProvider>(
        builder: (context, provider, child) {
          if (provider.isTransactionLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE52525)),
              ),
            );
          }

          if (provider.transactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.assignment_turned_in_rounded,
                    size: 44,
                    color: Color(0xFF8E8E93),
                  ),
                  SizedBox(height: 12),
                  Text(
                    "Tidak ada data transaksi ditemukan",
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF8E8E93),
                    ),
                  ),
                ],
              ),
            );
          }

          final size = MediaQuery.of(context).size;
          final maxTop = size.height - 280;
          final maxLeft = size.width - 160;

          return Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: RefreshIndicator(
                      color: const Color(0xFFE52525),
                      onRefresh: () async => _loadData(),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: provider.transactions.length,
                        itemBuilder: (context, index) {
                          final transactionItem = provider.transactions[index];

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFFEFEFEF),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: TransaksiItemCard(
                                negotiation: transactionItem,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // Pagination Bar Bawah[cite: 11]
                  PaginationFooterBar(
                    currentPage: _currentPage,
                    hasMore: provider.hasMoreData,
                    onPreviousPressed: _currentPage > 1
                        ? () {
                            setState(() => _currentPage--);
                            _loadData();
                          }
                        : null,
                    onNextPressed: provider.hasMoreData
                        ? () {
                            setState(() => _currentPage++);
                            _loadData();
                          }
                        : null,
                  ),
                ],
              ),

              Positioned(
                top: _fabTop,
                left: _fabLeft,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      _fabTop = (_fabTop + details.delta.dy).clamp(
                        16.0,
                        maxTop,
                      );
                      _fabLeft = (_fabLeft + details.delta.dx).clamp(
                        16.0,
                        maxLeft,
                      );
                    });
                  },
                  child: Material(
                    elevation: 8,
                    shadowColor: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: const Color(0xFFD4AF37),
                          width: 1.5,
                        ),
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CustomerScreen(),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(30),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.people_alt_rounded,
                              color: Color(0xFFE52525),
                              size: 18,
                            ),

                            SizedBox(width: 8),
                            Text(
                              "Data Customer",
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w800,
                                fontSize: 11,
                                color: Colors.white,
                                letterSpacing: 0.2,
                              ),
                            ),
                            SizedBox(width: 6),
                            Icon(
                              Icons.drag_indicator_rounded,
                              color: Color(0xFF8E8E93),
                              size: 14,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
