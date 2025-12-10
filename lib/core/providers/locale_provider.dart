import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/local_storage_service.dart';

/// Locale provider to manage app language
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('en')) {
    _loadLocale();
  }

  static const String _localeKey = 'app_locale';

  Future<void> _loadLocale() async {
    final savedLocale = LocalStorageService.instance.get<String>(_localeKey);
    if (savedLocale != null && (savedLocale == 'en' || savedLocale == 'ar')) {
      state = Locale(savedLocale);
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (locale.languageCode != 'en' && locale.languageCode != 'ar') {
      return; // Only support en and ar
    }
    state = locale;
    await LocalStorageService.instance.save(_localeKey, locale.languageCode);
  }

  void toggleLocale() {
    final newLocale = state.languageCode == 'en' ? const Locale('ar') : const Locale('en');
    setLocale(newLocale);
  }
  
  String get currentLanguage => state.languageCode == 'ar' ? 'العربية' : 'English';
}

