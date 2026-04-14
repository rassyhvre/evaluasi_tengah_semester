import 'package:flutter/material.dart';

/// Design tokens for the Smart Plant Monitor app.
/// All colors, gradients, shadows, and spacing constants live here
/// for a consistent, maintainable design system.
class PlantTheme {
  PlantTheme._();

  // ── Primary Colors ──
  static const Color primaryGreen = Color(0xFF2D6A4F);
  static const Color primaryGreenLight = Color(0xFF40916C);
  static const Color primaryGreenDark = Color(0xFF1B4332);
  static const Color accentGreen = Color(0xFF52B788);
  static const Color mintGreen = Color(0xFF95D5B2);
  static const Color paleGreen = Color(0xFFD8F3DC);

  // ── Semantic Colors ──
  static const Color warning = Color(0xFFF4A261);
  static const Color danger = Color(0xFFE76F51);
  static const Color info = Color(0xFF4DA8DA);
  static const Color success = Color(0xFF2D6A4F);

  // ── Surface / Background ──
  static const Color scaffoldBg = Color(0xFFF0F7F4);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color cardBgDark = Color(0xFF1A2E27);
  static const Color surfaceGreen = Color(0xFFE8F5EE);

  // ── Text ──
  static const Color textPrimary = Color(0xFF1B1B1F);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textOnGreen = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFF9CA3AF);

  // ── Gradients ──
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryGreen, accentGreen],
  );

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primaryGreenDark, primaryGreen, accentGreen],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), Color(0xFFF0F7F4)],
  );

  static const LinearGradient moistureGradient = LinearGradient(
    colors: [Color(0xFF4DA8DA), Color(0xFF2D6A4F)],
  );

  static const LinearGradient temperatureGradient = LinearGradient(
    colors: [Color(0xFFF4A261), Color(0xFFE76F51)],
  );

  static const LinearGradient humidityGradient = LinearGradient(
    colors: [Color(0xFF52B788), Color(0xFF4DA8DA)],
  );

  static const LinearGradient lightGradient = LinearGradient(
    colors: [Color(0xFFF4D35E), Color(0xFFF4A261)],
  );

  // ── Shadows ──
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: primaryGreen.withValues(alpha: 0.08),
      blurRadius: 20,
      offset: const Offset(0, 4),
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> elevatedShadow = [
    BoxShadow(
      color: primaryGreen.withValues(alpha: 0.15),
      blurRadius: 30,
      offset: const Offset(0, 8),
      spreadRadius: 0,
    ),
  ];

  // ── Border Radius ──
  static const double radiusSm = 12.0;
  static const double radiusMd = 16.0;
  static const double radiusLg = 24.0;
  static const double radiusXl = 32.0;

  // ── Spacing ──
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;

  // ── Animation Durations ──
  static const Duration animFast = Duration(milliseconds: 200);
  static const Duration animNormal = Duration(milliseconds: 400);
  static const Duration animSlow = Duration(milliseconds: 800);

  /// Get moisture status color based on percentage.
  static Color moistureColor(double value) {
    if (value >= 60) return success;
    if (value >= 35) return warning;
    return danger;
  }

  /// Get temperature status color.
  static Color temperatureColor(double value) {
    if (value >= 20 && value <= 30) return success;
    if (value >= 15 && value <= 35) return warning;
    return danger;
  }

  /// Get a human-readable moisture status label.
  static String moistureLabel(double value) {
    if (value >= 70) return 'Optimal';
    if (value >= 50) return 'Good';
    if (value >= 35) return 'Low';
    return 'Critical';
  }
}
