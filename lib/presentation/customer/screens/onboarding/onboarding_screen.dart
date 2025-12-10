import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/datasources/local_storage_service.dart';
import '../../widgets/common/custom_button.dart';
import '../../../../core/localization/app_localizations.dart';

/// Onboarding screen with multiple pages
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  List<OnboardingPageData> _getPages(BuildContext context) {
    final l10n = context.l10n;
    return [
      OnboardingPageData(
        title: l10n.orderYourFavoriteFood,
        description: l10n.orderYourFavoriteFoodDescription,
        icon: Icons.restaurant_menu,
        color: const Color(0xFF00D9A5),
      ),
      OnboardingPageData(
        title: l10n.fastDelivery,
        description: l10n.fastDeliveryDescription,
        icon: Icons.local_shipping,
        color: const Color(0xFFFF6B35),
      ),
      OnboardingPageData(
        title: l10n.easyPayment,
        description: l10n.easyPaymentDescription,
        icon: Icons.payment,
        color: const Color(0xFF3B82F6),
      ),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage(BuildContext context) {
    final pages = _getPages(context);
    if (_currentPage < pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _skipOnboarding() {
    _finishOnboarding();
  }

  Future<void> _finishOnboarding() async {
    // Save onboarding completed flag
    final storage = LocalStorageService.instance;
    await storage.save(AppConstants.onboardingCompletedKey, true);

    if (!mounted) return;
    // Navigate to user type selection after onboarding
    context.go('/user-type-selection');
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;
    final l10n = context.l10n;
    final pages = _getPages(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
                child: TextButton(
                  onPressed: _skipOnboarding,
                  child: Text(
                    l10n.skip,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            // Page view
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: pages.length,
                itemBuilder: (context, index) {
                  return _OnboardingPage(data: pages[index]);
                },
              ),
            ),
            // Page indicators
            Padding(
              padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 8.0 : 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  pages.length,
                  (index) => _PageIndicator(isActive: index == _currentPage),
                ),
              ),
            ),
            SizedBox(height: isSmallScreen ? 16 : 24),
            // Next/Get Started button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: CustomButton(
                text:
                    _currentPage == pages.length - 1
                        ? l10n.getStarted
                        : l10n.next,
                onPressed: () => _nextPage(context),
              ),
            ),
            SizedBox(height: isSmallScreen ? 16 : 24),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({required this.data});

  final OnboardingPageData data;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 24.0 : 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: isSmallScreen ? 20 : 40),
            // Icon
            Container(
                  width: isSmallScreen ? 120 : 150,
                  height: isSmallScreen ? 120 : 150,
                  decoration: BoxDecoration(
                    color: data.color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    data.icon,
                    size: isSmallScreen ? 60 : 80,
                    color: data.color,
                  ),
                )
                .animate()
                .scale(delay: 200.ms, duration: 600.ms)
                .fadeIn(delay: 200.ms, duration: 600.ms),
            SizedBox(height: isSmallScreen ? 32 : 48),
            // Title
            Text(
                  data.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 24 : 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                )
                .animate()
                .fadeIn(delay: 400.ms, duration: 600.ms)
                .slideY(begin: 0.2, end: 0, delay: 400.ms, duration: 600.ms),
            SizedBox(height: isSmallScreen ? 12 : 16),
            // Description
            Text(
                  data.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                )
                .animate()
                .fadeIn(delay: 600.ms, duration: 600.ms)
                .slideY(begin: 0.2, end: 0, delay: 600.ms, duration: 600.ms),
            SizedBox(height: isSmallScreen ? 20 : 40),
          ],
        ),
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  const _PageIndicator({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : AppColors.border,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class OnboardingPageData {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  OnboardingPageData({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
