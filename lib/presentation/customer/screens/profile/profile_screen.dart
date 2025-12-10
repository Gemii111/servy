import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../logic/providers/auth_providers.dart';
import '../../widgets/common/bottom_nav_bar.dart';
import '../../widgets/common/cart_app_bar_icon.dart';
import '../../../../core/widgets/back_button_handler.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';

/// Profile screen for Customer app
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final theme = Theme.of(context);

    return BackButtonHandler(
      onBackPressed: () {
        // Go to home instead of closing app
        context.go('/customer/home');
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            context.l10n.profile,
            style: const TextStyle(color: AppColors.textPrimary),
          ),
          backgroundColor: AppColors.background,
          elevation: 0,
          automaticallyImplyLeading: false, // Remove back button
          actions: const [
            CartAppBarIcon(),
          ],
        ),
      body: user == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 80,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      context.l10n.pleaseLoginFirst,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      context.l10n.loginOrRegisterToCheckout,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          context.push('/login?type=customer');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.textPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          context.l10n.login,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          context.push('/register?type=customer');
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: AppColors.primary, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: Text(
                          context.l10n.register,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  // Profile Avatar
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.primaryGradient,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.transparent,
                      child: Text(
                        user.name?.substring(0, 1).toUpperCase() ?? 'U',
                        style: const TextStyle(
                          fontSize: 40,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Name
                  Text(
                    user.name ?? 'User',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Email
                  Text(
                    user.email,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Menu Items
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [AppColors.cardShadow],
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(
                            Icons.person_outline,
                            color: AppColors.textSecondary,
                          ),
                          title: Text(
                            context.l10n.editProfile,
                            style: const TextStyle(color: AppColors.textPrimary),
                          ),
                          trailing: const Icon(
                            Icons.chevron_right,
                            color: AppColors.textSecondary,
                          ),
                          onTap: () {
                            context.push('/edit-profile');
                          },
                        ),
                        Divider(color: AppColors.border, height: 1),
                        ListTile(
                          leading: const Icon(
                            Icons.location_on_outlined,
                            color: AppColors.textSecondary,
                          ),
                          title: Text(
                            context.l10n.addresses,
                            style: const TextStyle(color: AppColors.textPrimary),
                          ),
                          trailing: const Icon(
                            Icons.chevron_right,
                            color: AppColors.textSecondary,
                          ),
                          onTap: () {
                            context.push('/addresses');
                          },
                        ),
                        Divider(color: AppColors.border, height: 1),
                        ListTile(
                          leading: const Icon(
                            Icons.payment_outlined,
                            color: AppColors.textSecondary,
                          ),
                          title: Text(
                            context.l10n.paymentMethods,
                            style: const TextStyle(color: AppColors.textPrimary),
                          ),
                          trailing: const Icon(
                            Icons.chevron_right,
                            color: AppColors.textSecondary,
                          ),
                          onTap: () {
                            context.push('/payment-methods');
                          },
                        ),
                        Divider(color: AppColors.border, height: 1),
                        ListTile(
                          leading: const Icon(
                            Icons.notifications_outlined,
                            color: AppColors.textSecondary,
                          ),
                          title: Text(
                            context.l10n.notifications,
                            style: const TextStyle(color: AppColors.textPrimary),
                          ),
                          trailing: const Icon(
                            Icons.chevron_right,
                            color: AppColors.textSecondary,
                          ),
                          onTap: () {
                            // Navigate to notifications
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [AppColors.cardShadow],
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(
                            Icons.settings_outlined,
                            color: AppColors.textSecondary,
                          ),
                          title: Text(
                            context.l10n.settings,
                            style: const TextStyle(color: AppColors.textPrimary),
                          ),
                          trailing: const Icon(
                            Icons.chevron_right,
                            color: AppColors.textSecondary,
                          ),
                          onTap: () {
                            context.push('/settings');
                          },
                        ),
                        Divider(color: AppColors.border, height: 1),
                        ListTile(
                          leading: const Icon(
                            Icons.help_outline,
                            color: AppColors.textSecondary,
                          ),
                          title: Text(
                            context.l10n.helpSupport,
                            style: const TextStyle(color: AppColors.textPrimary),
                          ),
                          trailing: const Icon(
                            Icons.chevron_right,
                            color: AppColors.textSecondary,
                          ),
                          onTap: () {
                            // Navigate to help
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Logout
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [AppColors.cardShadow],
                    ),
                    child: ListTile(
                      leading: const Icon(
                        Icons.logout,
                        color: AppColors.error,
                      ),
                      title: Text(
                        context.l10n.logout,
                        style: const TextStyle(color: AppColors.error),
                      ),
                      onTap: () async {
                        await ref.read(authProvider.notifier).logout();
                        if (context.mounted) {
                          context.go('/login?type=customer');
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
        bottomNavigationBar: const CustomerBottomNavBar(currentIndex: 2),
      ),
    );
  }
}


