import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reseller_app_tav/features/dashboard/providers/profile_provider.dart';
import 'package:reseller_app_tav/features/dashboard/widgets/details/car_image_slider.dart';
import 'package:reseller_app_tav/features/dashboard/widgets/details/car_price.dart';
import 'package:reseller_app_tav/features/dashboard/widgets/details/car_share_copywrite.dart';
import 'package:reseller_app_tav/features/dashboard/widgets/details/car_spesification.dart';
import 'package:reseller_app_tav/features/dashboard/widgets/negosiasi/create_negosiasi_dialog.dart';

import '../providers/car_detail_provider.dart';

class CarDetailScreen extends StatelessWidget {
  final int carId;

  const CarDetailScreen({super.key, required this.carId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CarDetailProvider()..loadCarDetail(carId),
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F4F4),
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.black,
              size: 18,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Detail Mobil',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0.5,
        ),
        body: Consumer<CarDetailProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFFE52320)),
              );
            }

            if (provider.errorMessage != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      provider.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => provider.loadCarDetail(carId),
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              );
            }

            final car = provider.carData;
            if (car == null) {
              return const Center(child: Text('Data tidak ditemukan'));
            }

            final infoKomisi =
                provider.infoKomisiData ??
                {"cash": 0, "kredit_batas_bawah": 0, "kredit_batas_atas": 0};

            return SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 80),
              child: Column(
                children: [
                  CarImageSlider(
                    images: car['car_images'] ?? [],
                    carName: car['name'],
                    status: car['status'] ?? '',
                  ),
                  const SizedBox(height: 8),
                  CarShareFormat(car: car),
                  const SizedBox(height: 8),
                  CarPriceDetail(car: car, nominalKomisi: infoKomisi),
                  const SizedBox(height: 8),
                  CarSpecification(car: car),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        ),

        bottomNavigationBar: Consumer<CarDetailProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading || provider.carData == null) {
              return const SizedBox.shrink();
            }

            final car = provider.carData!;
            final bool isBooked =
                car['status'].toString().toLowerCase() == 'booking';

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isBooked
                        ? Colors.grey[400]
                        : const Color(0xFFE52525),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  onPressed: isBooked
                      ? null
                      : () async {
                          final profileProvider = Provider.of<ProfileProvider>(
                            context,
                            listen: false,
                          );

                          if (profileProvider.profileData == null) {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (_) => const Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFFE52320),
                                ),
                              ),
                            );

                            await profileProvider.loadProfileData();

                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          }

                          if (context.mounted) {
                            CreateNegotiationDialog.show(
                              context,
                              initialCar: provider.carData,
                              onSuccess: () {
                                debugPrint(
                                  '[CAR DETAIL] Negosiasi berhasil dibuat dari detail mobil.',
                                );
                              },
                            );
                          }
                        },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isBooked ? Icons.block_rounded : Icons.gavel_rounded,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isBooked
                            ? 'Unit Sudah Dibooking'
                            : 'Booking Now (Mulai Nego)',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
