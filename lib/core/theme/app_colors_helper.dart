import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_colors_light.dart';

/// Helper class to get colors based on current theme brightness
class AppColorsHelper {
  AppColorsHelper._();

  /// Get background color based on theme
  static Color background(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? AppColors.background
        : AppColorsLight.background;
  }

  /// Get surface color based on theme
  static Color surface(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? AppColors.surface
        : AppColorsLight.surface;
  }

  /// Get card color based on theme
  static Color card(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? AppColors.card : AppColorsLight.card;
  }

  /// Get text primary color based on theme
  static Color textPrimary(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? AppColors.textPrimary
        : AppColorsLight.textPrimary;
  }

  /// Get text secondary color based on theme
  static Color textSecondary(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? AppColors.textSecondary
        : AppColorsLight.textSecondary;
  }

  /// Get text tertiary color based on theme
  static Color textTertiary(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? AppColors.textTertiary
        : AppColorsLight.textTertiary;
  }

  /// Get border color based on theme
  static Color border(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? AppColors.border
        : AppColorsLight.border;
  }

  /// Get card shadow based on theme
  static BoxShadow cardShadow(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? AppColors.cardShadow
        : AppColorsLight.cardShadow;
  }

  /// Primary color (same in both themes)
  static Color get primary => AppColors.primary;

  /// Secondary color (same in both themes)
  static Color get secondary => AppColors.secondary;

  /// Accent color (same in both themes)
  static Color get accent => AppColors.accent;

  /// Error color (same in both themes)
  static Color get error => AppColors.error;

  /// Success color (same in both themes)
  static Color get success => AppColors.success;

  /// Warning color (same in both themes)
  static Color get warning => AppColors.warning;
}
