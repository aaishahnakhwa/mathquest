import 'package:flutter/material.dart';

class GameColors {
  // Primary Adventure Colors (Bright, Cheerful, Energetic)
  static const Color skyBlue = Color(0xFF38BDF8);
  static const Color skyBlueDark = Color(0xFF0284C7);
  static const Color skyBlueLight = Color(0xFFE0F2FE);

  static const Color turquoise = Color(0xFF0EA5E9);
  static const Color teal = Color(0xFF14B8A6);
  static const Color tealDark = Color(0xFF0D9488);

  static const Color freshGreen = Color(0xFF22C55E);
  static const Color freshGreenDark = Color(0xFF15803D);
  static const Color freshGreenLight = Color(0xFFDCFCE7);

  static const Color sunnyYellow = Color(0xFFFACC15);
  static const Color yellowOrange = Color(0xFFF59E0B);
  static const Color yellowDark = Color(0xFFD97706);

  static const Color orange = Color(0xFFF97316);
  static const Color orangeDark = Color(0xFFC2410C);

  static const Color coral = Color(0xFFFF6B6B);
  static const Color coralDark = Color(0xFFDC2626);
  static const Color coralLight = Color(0xFFFEE2E2);

  static const Color purpleAccent = Color(0xFF8B5CF6);
  static const Color pinkAccent = Color(0xFFEC4899);

  // Candy Crush Jelly Colors & Highlights
  static const Color jellyPink = Color(0xFFFF2A85);
  static const Color jellyPinkDark = Color(0xFFB80053);
  static const Color jellyGreen = Color(0xFF10B981);
  static const Color jellyGreenDark = Color(0xFF047857);
  static const Color jellyYellow = Color(0xFFFFB800);
  static const Color jellyYellowDark = Color(0xFFB45309);
  static const Color jellyCyan = Color(0xFF06B6D4);
  static const Color jellyCyanDark = Color(0xFF0E7490);
  static const Color jellyPurple = Color(0xFFA855F7);
  static const Color jellyPurpleDark = Color(0xFF7E22CE);

  // Background & Surface
  static const Color background = Color(0xFFF0FDF4);
  static const Color surfaceWarm = Color(0xFFFFFBEB);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFFE2E8F0);

  // Deep Navy for Typography & High Contrast
  static const Color navyText = Color(0xFF0F172A);
  static const Color navyTextSecondary = Color(0xFF475569);
  static const Color navyTextMuted = Color(0xFF94A3B8);

  // Currency & Reward Colors
  static const Color coinGold = Color(0xFFFFB800);
  static const Color gemPurple = Color(0xFFA855F7);
  static const Color xpBlue = Color(0xFF3B82F6);
  static const Color heartRed = Color(0xFFEF4444);
  static const Color streakOrange = Color(0xFFFF6B00);

  // Level Node Colors
  static const Color nodeUnlocked = Color(0xFF22C55E);
  static const Color nodeCurrent = Color(0xFFFFB800);
  static const Color nodeLocked = Color(0xFFCBD5E1);

  // Glossy Candy Gradients
  static const LinearGradient jellyPinkGradient = LinearGradient(
    colors: [Color(0xFFFF69B4), Color(0xFFFF1493), Color(0xFFC71585)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient jellyGreenGradient = LinearGradient(
    colors: [Color(0xFF34D399), Color(0xFF10B981), Color(0xFF047857)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient jellyYellowGradient = LinearGradient(
    colors: [Color(0xFFFDE047), Color(0xFFFFB800), Color(0xFFD97706)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient jellyCyanGradient = LinearGradient(
    colors: [Color(0xFF38BDF8), Color(0xFF06B6D4), Color(0xFF097969)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient jellyPurpleGradient = LinearGradient(
    colors: [Color(0xFFC084FC), Color(0xFFA855F7), Color(0xFF6B21A8)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient skyGradient = LinearGradient(
    colors: [Color(0xFF38BDF8), Color(0xFF0284C7)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient greenGradient = LinearGradient(
    colors: [Color(0xFF4ADE80), Color(0xFF16A34A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient yellowGradient = LinearGradient(
    colors: [Color(0xFFFDE047), Color(0xFFD97706)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient coralGradient = LinearGradient(
    colors: [Color(0xFFFF8787), Color(0xFFE11D48)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFFE0F2FE), Color(0xFFF0FDF4)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
