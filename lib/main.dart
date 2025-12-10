import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/performance_utils.dart';
import 'data/services/api_service.dart';
import 'core/constants/api_constants.dart';
import 'data/datasources/local_storage_service.dart';
import 'core/providers/locale_provider.dart';
import 'core/services/connectivity_service.dart';
import 'core/localization/app_localizations_delegate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure image cache for better performance
  PerformanceUtils.configureImageCache();

  // Initialize Hive local storage
  await LocalStorageService.instance.init();

  // Initialize API Service
  ApiService.instance.init(baseUrl: ApiConstants.baseUrl);

  // Initialize Connectivity Service and start checking
  ConnectivityService.instance.checkConnectivity();
  ConnectivityService.instance.startPeriodicCheck();

  runApp(const ProviderScope(child: ServyApp()));
}

/// Main app widget
/// This app serves as the entry point for all three apps (Customer, Driver, Restaurant)
/// In production, you might want to create separate entry points for each app
class ServyApp extends ConsumerWidget {
  const ServyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'Servy - Food Delivery',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.customerTheme, // Dark theme only
      locale: locale,
      supportedLocales: const [Locale('en', ''), Locale('ar', '')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        AppLocalizationsDelegate(),
      ],
      builder: (context, child) {
        // Set text direction based on locale (RTL for Arabic, LTR for English)
        return Directionality(
          textDirection:
              locale.languageCode == 'ar'
                  ? TextDirection.rtl
                  : TextDirection.ltr,
          child: child!,
        );
      },
      routerConfig: AppRouter.router,
    );
  }
}
