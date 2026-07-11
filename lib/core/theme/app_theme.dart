import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color bgMainScreen = Color(0xFFF7F5F1);
  static const Color bgContainerCard = Color(0xFFFFFFFF);
  static const Color borderStroke = Color(0xFFE6E6E6);
  static const Color primaryButtonContainer = Color(0xFFE52020);
  static const Color primaryButton = Color(0xFF3F3F3F);
  static const Color fillField = Color(0xFFEDEDED);
  static const Color borderField = Color(0xFFBDBDBD);

  static ThemeData get lightTheme {
    return ThemeData(
      scaffoldBackgroundColor: bgMainScreen,
      useMaterial3: true,
      textTheme: GoogleFonts.montserratTextTheme(
        ThemeData.light().textTheme,
      ).copyWith(
        titleLarge: GoogleFonts.montserrat(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
        titleMedium: GoogleFonts.montserrat(
          color: Colors.black87,
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
        bodyLarge: GoogleFonts.montserrat(
          color: Colors.black54,
          fontWeight: FontWeight.normal, 
          fontSize: 14,
        ),
      ),
    );
  }
}