import 'package:flutter/material.dart';

/// Application color palette for Dark Theme
class AppColors {
  AppColors._();

  // Primary Colors
  static const Color primary = Color(0xFFD22EF2); // Neon Purple
  static const Color secondary = Color(0xFFFF7D29); // Hot Orange
  static const Color accent = Color(0xFF0094FF); // Neon Blue

  // Status Colors
  static const Color success = Color(0xFF00D26A);
  static const Color error = Color(0xFFFF4C4C);
  static const Color warning = Color(0xFFFFB800);
  static const Color info = Color(0xFF0094FF);

  // Background Colors
  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF1F232A);
  static const Color surfaceVariant = Color(0xFF2A2F38);
  static const Color card = Color(0xFF1F232A);

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFCCCCCC);
  static const Color textTertiary = Color(0xFF999999);
  static const Color textDisabled = Color(0xFF666666);

  // Border Colors
  static const Color border = Color(0xFF2A2F38);
  static const Color borderLight = Color(0xFF3A3F48);

  // Gradient Colors
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

  // Shadow Colors
  static BoxShadow get cardShadow => BoxShadow(
        color: Colors.black.withOpacity(0.3),
        blurRadius: 20,
        offset: const Offset(0, 8),
        spreadRadius: 0,
      );

  static BoxShadow get buttonShadow => BoxShadow(
        color: primary.withOpacity(0.4),
        blurRadius: 15,
        offset: const Offset(0, 5),
        spreadRadius: 0,
      );

  // Overlay Colors
  static Color overlay = Colors.black.withOpacity(0.6);
  static Color overlayLight = Colors.black.withOpacity(0.3);
}

