import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/datasources/local_storage_service.dart';
import '../../../../logic/providers/auth_providers.dart';

/// Splash screen - First screen shown when app launches
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeAndNavigate();
  }

  Future<void> _initializeAndNavigate() async {
    // Wait for minimum splash duration
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Initialize auth state if not already done
    final authNotifier = ref.read(authProvider.notifier);
    await authNotifier.initialize();

    if (!mounted) return;

    // Wait a bit more for auth state to settle
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    // Check authentication status
    final isAuthenticated = ref.read(isAuthenticatedProvider);
    final user = ref.read(currentUserProvider);

    // Check if onboarding is completed
    final storage = LocalStorageService.instance;
    final onboardingCompleted =
        storage.get<bool>(AppConstants.onboardingCompletedKey) ?? false;

    if (isAuthenticated && user != null) {
      // User is logged in, navigate based on user type
      switch (user.userType) {
        case 'customer':
          context.go('/customer/home');
          break;
        case 'driver':
          context.go('/driver/home');
          break;
        case 'restaurant':
          context.go('/restaurant/home');
          break;
        default:
          context.go('/customer/home');
      }
    } else if (onboardingCompleted) {
      // Onboarding done but not logged in, allow guest browsing or show user type selection
      // Allow direct access to home as guest
      context.go('/customer/home');
    } else {
      // First time, show onboarding
      context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.primaryGradient),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo/Icon
              Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.restaurant_menu,
                      size: 60,
                      color: AppColors.primary,
                    ),
                  )
                  .animate()
                  .scale(delay: 200.ms, duration: 600.ms, curve: Curves.easeOut)
                  .fadeIn(delay: 200.ms, duration: 600.ms),
              const SizedBox(height: 32),
              // App Name
              Text(
                    AppStrings.appName,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      letterSpacing: 1.2,
                    ),
                  )
                  .animate()
                  .fadeIn(delay: 400.ms, duration: 600.ms)
                  .slideY(begin: 0.2, end: 0, delay: 400.ms, duration: 600.ms),
              const SizedBox(height: 8),
              Text(
                    'Food Delivery Platform',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textPrimary.withOpacity(0.9),
                    ),
                  )
                  .animate()
                  .fadeIn(delay: 600.ms, duration: 600.ms)
                  .slideY(begin: 0.2, end: 0, delay: 600.ms, duration: 600.ms),
            ],
          ),
        ),
      ),
    );
  }
}
