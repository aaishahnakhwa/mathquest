import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';

class GameTheme {
  static ThemeData get themeData {
    final baseTextTheme = ThemeData.light().textTheme;

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: GameColors.background,
      primaryColor: GameColors.turquoise,
      colorScheme: ColorScheme.fromSeed(
        seedColor: GameColors.turquoise,
        primary: GameColors.turquoise,
        secondary: GameColors.sunnyYellow,
        surface: GameColors.surfaceWarm,
        error: GameColors.coral,
      ),
      textTheme: GoogleFonts.nunitoTextTheme(baseTextTheme).copyWith(
        displayLarge: GoogleFonts.fredoka(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: GameColors.navyText,
        ),
        displayMedium: GoogleFonts.fredoka(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: GameColors.navyText,
        ),
        displaySmall: GoogleFonts.fredoka(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: GameColors.navyText,
        ),
        headlineMedium: GoogleFonts.fredoka(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: GameColors.navyText,
        ),
        titleLarge: GoogleFonts.fredoka(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: GameColors.navyText,
        ),
        bodyLarge: GoogleFonts.nunito(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: GameColors.navyText,
        ),
        bodyMedium: GoogleFonts.nunito(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: GameColors.navyTextSecondary,
        ),
      ),
      cardTheme: CardThemeData(
        color: GameColors.cardBg,
        elevation: 4,
        shadowColor: GameColors.navyText.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: GameColors.cardBorder, width: 2),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: GameColors.surfaceWarm,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: GameColors.sunnyYellow, width: 3),
        ),
      ),
    );
  }
}
