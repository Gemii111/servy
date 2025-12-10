import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/haptic_feedback.dart';

/// User Type Selection Screen - Choose between Customer, Driver, or Restaurant
class UserTypeSelectionScreen extends StatelessWidget {
  const UserTypeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/onboarding');
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              // App Logo
              Container(
                    width: 100,
                    height: 100,
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.restaurant_menu,
                      size: 50,
                      color: AppColors.textPrimary,
                    ),
                  )
                  .animate()
                  .scale(delay: 200.ms, duration: 600.ms)
                  .fadeIn(delay: 200.ms, duration: 600.ms),

              // Title
              Text(
                    l10n.welcomeToApp,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  )
                  .animate()
                  .fadeIn(delay: 400.ms, duration: 600.ms)
                  .slideY(begin: 0.2, end: 0),
              const SizedBox(height: 8),
              Text(
                    l10n.selectUserType,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  )
                  .animate()
                  .fadeIn(delay: 500.ms, duration: 600.ms)
                  .slideY(begin: 0.2, end: 0),
              const SizedBox(height: 48),

              // Customer Card
              _UserTypeCard(
                    icon: Icons.shopping_bag,
                    title: l10n.customer,
                    description: l10n.customerDescription,
                    color: AppColors.primary,
                    onTap: () {
                      HapticFeedbackUtil.mediumImpact();
                      context.push('/login?type=customer');
                    },
                  )
                  .animate()
                  .fadeIn(delay: 600.ms, duration: 600.ms)
                  .slideX(begin: -0.2, end: 0),
              const SizedBox(height: 16),

              // Driver Card
              _UserTypeCard(
                    icon: Icons.local_shipping,
                    title: l10n.driver,
                    description: l10n.driverDescription,
                    color: AppColors.accent,
                    onTap: () {
                      HapticFeedbackUtil.mediumImpact();
                      context.push('/register?type=driver');
                    },
                  )
                  .animate()
                  .fadeIn(delay: 700.ms, duration: 600.ms)
                  .slideX(begin: -0.2, end: 0),
              const SizedBox(height: 16),

              // Restaurant Card
              _UserTypeCard(
                    icon: Icons.restaurant,
                    title: l10n.restaurant,
                    description: l10n.restaurantDescription,
                    color: AppColors.secondary,
                    onTap: () {
                      HapticFeedbackUtil.mediumImpact();
                      context.push('/register?type=restaurant');
                    },
                  )
                  .animate()
                  .fadeIn(delay: 800.ms, duration: 600.ms)
                  .slideX(begin: -0.2, end: 0),
              const SizedBox(height: 32),

              // Already have account? Login
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    l10n.alreadyHaveAccount,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  TextButton(
                    onPressed: () {
                      context.push('/user-type-login');
                    },
                    child: Text(
                      l10n.login,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 900.ms, duration: 600.ms),

              const SizedBox(height: 24),

              // Divider
              Divider(
                color: AppColors.border.withOpacity(0.5),
                thickness: 1,
                indent: 40,
                endIndent: 40,
              ),

              const SizedBox(height: 20),

              // Browse as Guest Button (Secondary - Light Color)
              Center(
                child: TextButton(
                  onPressed: () {
                    HapticFeedbackUtil.mediumImpact();
                    context.go('/customer/home');
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  child: Text(
                    l10n.browseAsGuest,
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.textSecondary.withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

/// User Type Card Widget
class _UserTypeCard extends StatelessWidget {
  const _UserTypeCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border),
          boxShadow: [AppColors.cardShadow],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 20,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
