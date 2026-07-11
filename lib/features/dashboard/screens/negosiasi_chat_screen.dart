// lib/features/dashboard/screens/negosiasi_chat_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reseller_app_tav/features/dashboard/providers/negosiasi_provider.dart';
import 'package:reseller_app_tav/features/dashboard/widgets/negosiasi/create_negosiasi_dialog.dart';
import 'package:reseller_app_tav/features/dashboard/widgets/negosiasi/negosiasi_card_item.dart';

class NegosiasiChatScreen extends StatefulWidget {
  const NegosiasiChatScreen({super.key});

  @override
  State<NegosiasiChatScreen> createState() => _NegosiasiChatScreenState();
}

class _NegosiasiChatScreenState extends State<NegosiasiChatScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 1;
  final int _perPage = 3; // Menampilkan 3 data per halaman sesuai permintaan

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    // Memanggil API dengan query pencarian dan limit 3 data
    context.read<NegotiationProvider>().fetchAllNegotiations(
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
    return Scaffold(
      backgroundColor: const Color(
        0xFFF8F9FA,
      ), // Latar belakang putih redup yang bersih
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          "Negosiasi",
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1A1A1A),
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          Container(
            width: 28,
            height: 28,
            margin: const EdgeInsets.only(right: 8),
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 211, 0, 0),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: GestureDetector(
                onTap: () {
                  CreateNegotiationDialog.show(
                    context,
                    onSuccess: () => _loadData(),
                  ); //[cite: 8]
                },
                child: const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size:
                      20, // Ukuran diatur ke 20 agar pas dan proporsional di dalam kontainer ukuran 28
                ),
              ),
            ),
          ),
        ],
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
                  hintText: "Cari mobil atau nama penawar...",
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
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE52525)),
              ),
            );
          }

          if (provider.negotiations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.gavel_rounded,
                    size: 44,
                    color: Color(0xFF8E8E93),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Tidak ada data negosiasi ditemukan",
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

          return Column(
            children: [
              // List Data Negosiasi dengan Kartu Berdesain Putih + Bayangan Tipis
              Expanded(
                child: RefreshIndicator(
                  color: const Color(0xFFE52525),
                  onRefresh: () async => _loadData(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.negotiations.length,
                    itemBuilder: (context, index) {
                      final negotiationItem = provider.negotiations[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white, // Container Putih murni
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFFEFEFEF),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(
                                0.03,
                              ), // Shadow super tipis dan bersih
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: NegotiationItemCard(
                            item: negotiationItem,
                            onEdit: () {
                              CreateNegotiationDialog.show(
                                context,
                                editItem: negotiationItem,
                                onSuccess: () => _loadData(),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Pagination Bar di bagian paling bawah
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: const Color(0xFFEFEFEF), width: 1),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Halaman $_currentPage",
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF8E8E93),
                      ),
                    ),
                    Row(
                      children: [
                        // Tombol Previous Page
                        OutlinedButton(
                          onPressed: _currentPage > 1
                              ? () {
                                  setState(() => _currentPage--);
                                  _loadData();
                                }
                              : null,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: _currentPage > 1
                                  ? const Color(0xFFEFEFEF)
                                  : Colors.transparent,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Row(
                            children: const [
                              Icon(
                                Icons.arrow_back_ios_new_rounded,
                                size: 12,
                                color: Color(0xFF1A1A1A),
                              ),
                              SizedBox(width: 4),
                              Text(
                                "Prev",
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1A1A1A),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Tombol Next Page
                        OutlinedButton(
                          onPressed: provider.hasMoreData
                              ? () {
                                  setState(() => _currentPage++);
                                  _loadData();
                                }
                              : null,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: provider.hasMoreData
                                  ? const Color(0xFFEFEFEF)
                                  : Colors.transparent,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Row(
                            children: const [
                              Text(
                                "Next",
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1A1A1A),
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 12,
                                color: Color(0xFF1A1A1A),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
