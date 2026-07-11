import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CarPriceDetail extends StatelessWidget {
  final Map<String, dynamic> car;
  final Map<String, dynamic> nominalKomisi;

  const CarPriceDetail({
    super.key,
    required this.car,
    required this.nominalKomisi,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final creditPrice = currencyFormat.format(car['credit_price'] ?? 0);
    final cashPrice = currencyFormat.format(car['cash_price'] ?? 0);

    final creditKomisiBawah = currencyFormat.format(
      nominalKomisi['kredit_batas_bawah'] ?? 0,
    );
    final creditKomisiAtas = currencyFormat.format(
      nominalKomisi['kredit_batas_atas'] ?? 0,
    );

    final cashKomisi = currencyFormat.format(nominalKomisi['cash'] ?? 0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFEAEAEA), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Harga Kredit',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF222222),
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(width: 5),
                Row(
                  children: [
                    Text(
                      creditPrice,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 5),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Kredit Komisi',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF222222),
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(width: 5),
                Row(
                  children: [
                    Text(
                      creditKomisiBawah,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Color.fromARGB(255, 247, 0, 0),
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    Text(
                      ' - $creditKomisiAtas',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Color.fromARGB(255, 247, 0, 0),
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(
              height: 12,
            ), // Ditambahkan sedikit spasi antar seksi agar rapi (sesuai UI Anda)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Harga Cash',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF222222),
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(width: 5),
                Row(
                  children: [
                    Text(
                      cashPrice,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 5),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cash Komisi',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF222222),
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(width: 5),
                Row(
                  children: [
                    Text(
                      cashKomisi,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Color.fromARGB(255, 247, 0, 0),
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
