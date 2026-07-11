import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reseller_app_tav/features/dashboard/widgets/visits/visit_counter_header.dart';
import 'package:reseller_app_tav/features/dashboard/widgets/visits/visit_floating_button.dart'; // Import widget baru
import 'package:reseller_app_tav/features/dashboard/widgets/visits/visit_form_modal.dart';
import 'package:reseller_app_tav/features/dashboard/widgets/visits/visit_history_list.dart';

import '../providers/visit_schedule_provider.dart';

class VisitScheduleScreen extends StatefulWidget {
  const VisitScheduleScreen({super.key});

  @override
  State<VisitScheduleScreen> createState() => _VisitScheduleScreenState();
}

class _VisitScheduleScreenState extends State<VisitScheduleScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<VisitScheduleProvider>().loadAllVisitData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VisitScheduleProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Clean Light Gray background
      body: RefreshIndicator(
        onRefresh: () => provider.loadAllVisitData(),
        color: Colors.black,
        child: provider.isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.black),
              )
            : provider.errorMessage != null
            ? Center(
                child: Text(
                  provider.errorMessage!,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    color: Colors.red,
                  ),
                ),
              )
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    VisitCounterHeader(counters: provider.counters),
                    const Padding(
                      padding: EdgeInsets.only(left: 16.0, top: 8, bottom: 8),
                      child: Text(
                        "Riwayat Kunjungan",
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    VisitHistoryList(
                      items: provider.schedules,
                      onEdit: (item) {
                        VisitFormModal.show(
                          context,
                          editItem: item,
                          onSuccess: () {
                            provider.loadAllVisitData();
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
      ),
      // Menggunakan Custom Floating Button Modular Baru
      floatingActionButton: VisitFloatingButton(
        onPressed: () {
          VisitFormModal.show(
            context,
            onSuccess: () {
              provider.loadAllVisitData();
            },
          );
        },
      ),
    );
  }
}
