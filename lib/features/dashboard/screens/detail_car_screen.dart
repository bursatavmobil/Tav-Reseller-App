import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reseller_app_tav/features/dashboard/widgets/details/car_image_slider.dart';
import 'package:reseller_app_tav/features/dashboard/widgets/details/car_price.dart';
import 'package:reseller_app_tav/features/dashboard/widgets/details/car_share_copywrite.dart';
import 'package:reseller_app_tav/features/dashboard/widgets/details/car_spesification.dart';

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
              child: Column(
                children: [
                  CarImageSlider(images: car['car_images'] ?? [], carName: car['name'],),
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
      ),
    );
  }
}
