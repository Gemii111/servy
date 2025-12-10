import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_colors_light.dart';

/// Extension on BuildContext to easily access theme-aware colors
extension ThemeExtension on BuildContext {
  /// Get background color based on current theme
  Color get backgroundColor {
    final brightness = Theme.of(this).brightness;
    return brightness == Brightness.dark
        ? AppColors.background
        : AppColorsLight.background;
  }

  /// Get surface color based on current theme
  Color get surfaceColor {
    final brightness = Theme.of(this).brightness;
    return brightness == Brightness.dark
        ? AppColors.surface
        : AppColorsLight.surface;
  }

  /// Get card color based on current theme
  Color get cardColor {
    final brightness = Theme.of(this).brightness;
    return brightness == Brightness.dark ? AppColors.card : AppColorsLight.card;
  }

  /// Get text primary color based on current theme
  Color get textPrimaryColor {
    final brightness = Theme.of(this).brightness;
    return brightness == Brightness.dark
        ? AppColors.textPrimary
        : AppColorsLight.textPrimary;
  }

  /// Get text secondary color based on current theme
  Color get textSecondaryColor {
    final brightness = Theme.of(this).brightness;
    return brightness == Brightness.dark
        ? AppColors.textSecondary
        : AppColorsLight.textSecondary;
  }

  /// Get border color based on current theme
  Color get borderColor {
    final brightness = Theme.of(this).brightness;
    return brightness == Brightness.dark
        ? AppColors.border
        : AppColorsLight.border;
  }

  /// Get card shadow based on current theme
  BoxShadow get cardShadow {
    final brightness = Theme.of(this).brightness;
    return brightness == Brightness.dark
        ? AppColors.cardShadow
        : AppColorsLight.cardShadow;
  }
}
