import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../logic/providers/auth_providers.dart';
import '../../../../logic/providers/restaurant_providers.dart';
import '../../../../data/models/restaurant_model.dart';
import '../../../../core/utils/haptic_feedback.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../customer/widgets/common/loading_state_widget.dart';
import '../../../customer/widgets/common/error_state_widget.dart';

/// Restaurant Profile & Settings Screen
class RestaurantProfileScreen extends ConsumerStatefulWidget {
  const RestaurantProfileScreen({super.key});

  @override
  ConsumerState<RestaurantProfileScreen> createState() =>
      _RestaurantProfileScreenState();
}

class _RestaurantProfileScreenState
    extends ConsumerState<RestaurantProfileScreen> {
  String? _restaurantId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRestaurantData();
    });
  }

  Future<void> _loadRestaurantData() async {
    final user = ref.read(currentUserProvider);
    if (user != null) {
      // For mock, use first restaurant ID to match Home Screen
      // In real app, this would come from user's restaurant
      final restaurantId = '1'; // Koshary Abou Tarek - matches Home Screen
      setState(() {
        _restaurantId = restaurantId;
      });
      // Invalidate to force refresh
      ref.invalidate(restaurantByIdProvider(restaurantId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final l10n = context.l10n;

    // Ensure restaurantId is loaded
    if (_restaurantId == null && user != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadRestaurantData();
      });
    }

    if (user == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          title: Text(
            l10n.restaurantProfile,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          iconTheme: const IconThemeData(color: AppColors.textPrimary),
        ),
        body: Center(
          child: Text(
            l10n.pleaseLoginFirst,
            style: const TextStyle(color: AppColors.textPrimary),
          ),
        ),
      );
    }

    if (_restaurantId == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          title: Text(
            l10n.restaurantProfile,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          iconTheme: const IconThemeData(color: AppColors.textPrimary),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final restaurantAsync = ref.watch(restaurantByIdProvider(_restaurantId!));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          l10n.restaurantProfile,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              context.push('/restaurant/edit-profile');
            },
          ),
        ],
      ),
      body: restaurantAsync.when(
        data: (restaurant) {
          if (restaurant == null) {
            return ErrorStateWidget(
              message: l10n.restaurantNotFound,
              onRetry: () {
                ref.invalidate(restaurantByIdProvider(_restaurantId!));
              },
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Restaurant Image & Info Card
                _RestaurantInfoCard(
                  restaurant: restaurant,
                ).animate().fadeIn(delay: 100.ms).slideY(begin: -0.1, end: 0),
                const SizedBox(height: 24),

                // Restaurant Details
                _InfoSection(
                  title: l10n.restaurantInfo,
                  children: [
                    _InfoRow(
                      icon: Icons.restaurant,
                      label: l10n.restaurantName,
                      value: restaurant.name,
                    ),
                    _InfoRow(
                      icon: Icons.description_outlined,
                      label: l10n.restaurantDescriptionDetail,
                      value: restaurant.description,
                    ),
                    _InfoRow(
                      icon: Icons.access_time,
                      label: l10n.deliveryTimeMinutes,
                      value:
                          '${restaurant.deliveryTime.toInt()} ${l10n.minutes}',
                    ),
                    _InfoRow(
                      icon: Icons.delivery_dining,
                      label: l10n.deliveryFeeAmount,
                      value: CurrencyFormatter.formatPrice(
                        restaurant.deliveryFee,
                        context,
                      ),
                    ),
                    if (restaurant.minOrderAmount != null)
                      _InfoRow(
                        icon: Icons.shopping_bag_outlined,
                        label: l10n.minimumOrderAmount,
                        value: CurrencyFormatter.formatPrice(
                          restaurant.minOrderAmount!,
                          context,
                        ),
                      ),
                    _InfoRow(
                      icon: Icons.location_on,
                      label: l10n.restaurantAddress,
                      value: restaurant.address,
                    ),
                  ],
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
                const SizedBox(height: 24),

                // Settings Menu
                _SettingsSection(
                  l10n: l10n,
                  onSettingsTap: () {
                    context.push('/restaurant/settings');
                  },
                ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
        loading: () => const LoadingStateWidget(),
        error:
            (error, stack) => ErrorStateWidget(
              message: l10n.failedToLoad,
              error: error.toString(),
              onRetry: () {
                ref.invalidate(restaurantByIdProvider(_restaurantId!));
              },
            ),
      ),
    );
  }
}

/// Restaurant Info Card Widget
class _RestaurantInfoCard extends StatelessWidget {
  const _RestaurantInfoCard({required this.restaurant});

  final RestaurantModel restaurant;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [AppColors.cardShadow],
      ),
      child: Column(
        children: [
          // Restaurant Image
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: DecorationImage(
                image: NetworkImage(restaurant.imageUrl),
                fit: BoxFit.cover,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Restaurant Name
          Text(
            restaurant.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: restaurant.isOpen ? AppColors.success : AppColors.error,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  restaurant.isOpen ? Icons.check_circle : Icons.cancel,
                  color: AppColors.textPrimary,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  restaurant.isOpen
                      ? context.l10n.restaurantIsOpen
                      : context.l10n.restaurantIsClosed,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Info Section Widget
class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [AppColors.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

/// Info Row Widget
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Settings Section Widget
class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.l10n, required this.onSettingsTap});

  final AppLocalizations l10n;
  final VoidCallback onSettingsTap;

  @override
  Widget build(BuildContext context) {
    return Container(
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
              l10n.restaurantSettings,
              style: const TextStyle(color: AppColors.textPrimary),
            ),
            trailing: const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
            ),
            onTap: () {
              HapticFeedbackUtil.lightImpact();
              onSettingsTap();
            },
          ),
          const Divider(color: AppColors.border, height: 1),
          ListTile(
            leading: const Icon(
              Icons.help_outline,
              color: AppColors.textSecondary,
            ),
            title: Text(
              l10n.helpSupport,
              style: const TextStyle(color: AppColors.textPrimary),
            ),
            trailing: const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
            ),
            onTap: () {
              HapticFeedbackUtil.lightImpact();
              // Navigate to help
            },
          ),
        ],
      ),
    );
  }
}
