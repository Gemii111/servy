import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../logic/providers/cart_providers.dart';

/// Shared Bottom Navigation Bar for Customer app
class CustomerBottomNavBar extends ConsumerWidget {
  const CustomerBottomNavBar({
    super.key,
    required this.currentIndex,
  });

  final int currentIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final cartItemCount = ref.watch(cartItemCountProvider);
    
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: NavigationBar(
        backgroundColor: AppColors.surface,
        selectedIndex: currentIndex,
        indicatorColor: AppColors.primary.withOpacity(0.2),
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.go('/customer/home');
              break;
            case 1:
              context.go('/customer/orders');
              break;
            case 2:
              context.go('/customer/profile');
              break;
          }
        },
        destinations: [
          NavigationDestination(
            icon: _CartBadgeIcon(
              icon: const Icon(
                Icons.home_outlined,
                color: AppColors.textSecondary,
              ),
              badgeCount: cartItemCount,
            ),
            selectedIcon: _CartBadgeIcon(
              icon: const Icon(
                Icons.home,
                color: AppColors.primary,
              ),
              badgeCount: cartItemCount,
            ),
            label: l10n?.home ?? AppStrings.home,
          ),
          NavigationDestination(
            icon: const Icon(
              Icons.receipt_long_outlined,
              color: AppColors.textSecondary,
            ),
            selectedIcon: const Icon(
              Icons.receipt_long,
              color: AppColors.primary,
            ),
            label: l10n?.orders ?? AppStrings.orders,
          ),
          NavigationDestination(
            icon: const Icon(
              Icons.person_outline,
              color: AppColors.textSecondary,
            ),
            selectedIcon: const Icon(
              Icons.person,
              color: AppColors.primary,
            ),
            label: l10n?.profile ?? AppStrings.profile,
          ),
        ],
      ),
    );
  }
}

/// Icon with cart badge
class _CartBadgeIcon extends StatelessWidget {
  const _CartBadgeIcon({
    required this.icon,
    required this.badgeCount,
  });

  final Widget icon;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    if (badgeCount <= 0) {
      return icon;
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        icon,
        Positioned(
          right: -8,
          top: -8,
          child: Container(
            padding: badgeCount > 99
                ? const EdgeInsets.symmetric(horizontal: 4, vertical: 2)
                : const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.error,
              shape: badgeCount > 99
                  ? BoxShape.rectangle
                  : BoxShape.circle,
              borderRadius: badgeCount > 99
                  ? BorderRadius.circular(8)
                  : null,
            ),
            constraints: const BoxConstraints(
              minWidth: 16,
              minHeight: 16,
            ),
            child: Center(
              child: Text(
                badgeCount > 99 ? '99+' : '$badgeCount',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

