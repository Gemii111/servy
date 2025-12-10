import 'package:flutter/material.dart';

/// Application color palette for Light Theme
class AppColorsLight {
  AppColorsLight._();

  // Primary Colors (Same as dark for consistency)
  static const Color primary = Color(0xFFD22EF2); // Neon Purple
  static const Color secondary = Color(0xFFFF7D29); // Hot Orange
  static const Color accent = Color(0xFF0094FF); // Neon Blue

  // Status Colors
  static const Color success = Color(0xFF00D26A);
  static const Color error = Color(0xFFFF4C4C);
  static const Color warning = Color(0xFFFFB800);
  static const Color info = Color(0xFF0094FF);

  // Background Colors (Light)
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF5F5F5);
  static const Color surfaceVariant = Color(0xFFE0E0E0);
  static const Color card = Color(0xFFFFFFFF);

  // Text Colors (Dark for light theme)
  static const Color textPrimary = Color(0xFF121212);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textTertiary = Color(0xFF999999);
  static const Color textDisabled = Color(0xFFCCCCCC);

  // Border Colors
  static const Color border = Color(0xFFE0E0E0);
  static const Color borderLight = Color(0xFFF0F0F0);

  // Gradient Colors (Same as dark)
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFD22EF2), // Neon Purple
      Color(0xFFFF7D29), // Hot Orange
    ],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0094FF), // Neon Blue
      Color(0xFF00D26A), // Success Green
    ],
  );

  // Shadow Colors (Lighter shadows for light theme)
  static BoxShadow get cardShadow => BoxShadow(
        color: Colors.black.withOpacity(0.08),
        blurRadius: 20,
        offset: const Offset(0, 4),
        spreadRadius: 0,
      );

  static BoxShadow get buttonShadow => BoxShadow(
        color: primary.withOpacity(0.3),
        blurRadius: 15,
        offset: const Offset(0, 3),
        spreadRadius: 0,
      );

  // Overlay Colors
  static Color overlay = Colors.black.withOpacity(0.4);
  static Color overlayLight = Colors.black.withOpacity(0.2);
}

