import '../../core/localization/app_localizations.dart';
import 'package:flutter/material.dart';

/// Currency formatter utility
class CurrencyFormatter {
  CurrencyFormatter._();

  /// Format price with currency symbol
  static String formatPrice(double price, BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) {
      return '${price.toStringAsFixed(2)} EGP';
    }
    
    // Use Egyptian Pound (EGP) for both languages
    if (l10n.isArabic) {
      return '${price.toStringAsFixed(2)} جنيه';
    } else {
      return '${price.toStringAsFixed(2)} EGP';
    }
  }

  /// Get currency symbol
  static String getCurrencySymbol(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) {
      return 'EGP';
    }
    
    if (l10n.isArabic) {
      return 'جنيه';
    } else {
      return 'EGP';
    }
  }
}

