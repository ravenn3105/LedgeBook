import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Core Colors
  static const primaryColor = Color(0xFF6C4FDB);
  static const secondaryColor = Color(0xFF8B7CF6);

  // Backgrounds
  static const backgroundColor = Color(0xFFF8F4FF);
  static const surfaceColor = Colors.white;
  static const cardColor = Colors.white;

  // Text Colors
  static const textPrimary = Color(0xFF1A1A2E);
  static const textSecondary = Color(0xFF6B7280);
  static const textMuted = Color(0xFF9CA3AF);

  // Utility Colors
  static const successColor = Color(0xFF10B981);
  static const errorColor = Color(0xFFEF4444);
  static const warningColor = Color(0xFFF59E0B);

  // Borders & Dividers
  static const borderColor = Color(0xFFE5E7EB);
  static const dividerColor = Color(0xFFF3F4F6);

  // Light Theme
  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: backgroundColor,
      cardColor: cardColor,
      dividerColor: dividerColor,

      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        background: backgroundColor,
        surface: surfaceColor,
        brightness: Brightness.light,
      ),

      textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
        headlineLarge: GoogleFonts.inter(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),

        headlineMedium: GoogleFonts.inter(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),

        titleLarge: GoogleFonts.inter(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),

        titleMedium: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),

        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          color: textPrimary,
        ),

        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          color: textSecondary,
        ),

        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          color: textMuted,
        ),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: backgroundColor,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,

        titleTextStyle: GoogleFonts.inter(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),

        iconTheme: const IconThemeData(
          color: textPrimary,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,

          minimumSize: const Size(double.infinity, 54),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),

          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: surfaceColor,
          foregroundColor: textPrimary,

          side: const BorderSide(
            color: borderColor,
          ),

          minimumSize: const Size(double.infinity, 54),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),

          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: borderColor,
          ),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: borderColor,
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: primaryColor,
            width: 1.5,
          ),
        ),

        hintStyle: GoogleFonts.inter(
          color: textMuted,
          fontSize: 14,
        ),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,

        selectedLabelStyle: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),

        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 11,
        ),
      ),

      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(
            color: dividerColor,
          ),
        ),
      ),
    );
  }
}