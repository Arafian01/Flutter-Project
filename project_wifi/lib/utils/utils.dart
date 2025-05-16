import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Warna tema utama untuk StrongNet
class AppColors {
  static const Color primaryRed = Color(0xFFD32F2F); // Merah utama
  static const Color secondaryRed = Color(0xFFFF5252); // Merah muda untuk gradien
  static const Color backgroundLight = Color(0xFFF5F5F5); // Latar belakang abu-abu muda
  static const Color textPrimary = Color(0xFF212121); // Teks utama hitam
  static const Color textSecondary = Color(0xFF424242); // Teks sekunder abu-abu gelap
  static const Color accentBlack = Color(0xFF212121); // Aksen hitam untuk garis
  static const Color white = Color(0xFFFFFFFF); // Putih untuk kontras
}

// Konfigurasi tema aplikasi
class AppTheme {
  static ThemeData get theme => ThemeData(
    primaryColor: AppColors.primaryRed,
    scaffoldBackgroundColor: AppColors.backgroundLight,
    fontFamily: GoogleFonts.poppins().fontFamily,
    textTheme: TextTheme(
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      titleLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: AppColors.textPrimary,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryRed,
        foregroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.accentBlack),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primaryRed, width: 2),
      ),
      labelStyle: const TextStyle(color: AppColors.textSecondary),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primaryRed,
      foregroundColor: AppColors.white,
    ),
  );
}

// Konstanta untuk ukuran dan padding
class AppSizes {
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double iconSizeSmall = 20.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 60.0; // Untuk ikon WiFi besar
}

// Konstanta untuk string atau aset lainnya
class AppAssets {
  static const String logoPath = 'assets/images/logo.png'; // Ganti dengan path logo StrongNet
}