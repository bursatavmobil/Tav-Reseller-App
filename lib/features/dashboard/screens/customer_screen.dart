import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reseller_app_tav/features/dashboard/providers/negosiasi_provider.dart';
import 'package:reseller_app_tav/features/dashboard/widgets/negosiasi/cutsomer_card_item.dart';
import 'package:reseller_app_tav/features/dashboard/widgets/negosiasi/form_customer_dialog.dart';
import 'package:reseller_app_tav/features/dashboard/widgets/paginate_footer_bar.dart';

class CustomerScreen extends StatefulWidget {
  const CustomerScreen({super.key});

  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 1;
  final int _perPage = 10;
  List<dynamic> _customerList = [];
  bool _isLoading = false;
  bool _hasMore = false;

  @override
  void initState() {
    super.initState();
    _fetchCustomers();
  }

  // Fungsi internal load data memanfaatkan service yang ditambahkan
  void _fetchCustomers() async {
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
          _customerList = res.data['data']['result'];
          _hasMore = _currentPage < res.data['data']['last_page'];
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1A1A1A)),
        title: const Text(
          "Customer Agen",
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1A1A1A),
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.person_add_alt_1_rounded,
              color: Color(0xFFE52525),
            ),
            onPressed: () =>
                UpsertCustomerDialog.show(context, onSuccess: _fetchCustomers),
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
                  _fetchCustomers();
                },
                decoration: InputDecoration(
                  hintText: "Cari nama customer...",
                  hintStyle: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 13,
                    color: Color(0xFF8E8E93),
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: Color(0xFF8E8E93),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Color(0xFFE52525)),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: _customerList.isEmpty
                      ? const Center(
                          child: Text(
                            "Tidak ada data customer",
                            style: TextStyle(fontFamily: 'Montserrat'),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _customerList.length,
                          itemBuilder: (context, index) {
                            final item = _customerList[index];
                            return CustomerItemCard(
                              customer: item,
                              onEdit: () => UpsertCustomerDialog.show(
                                context,
                                customer: item,
                                onSuccess: _fetchCustomers,
                              ),
                            );
                          },
                        ),
                ),
                // Pagination Bar bawah
                PaginationFooterBar(
                  currentPage: _currentPage,
                  hasMore: _hasMore,
                  onPreviousPressed: _currentPage > 1
                      ? () {
                          setState(() => _currentPage--);
                          _fetchCustomers();
                        }
                      : null,
                  onNextPressed: _hasMore
                      ? () {
                          setState(() => _currentPage++);
                          _fetchCustomers();
                        }
                      : null,
                ),
              ],
            ),
    );
  }
}
