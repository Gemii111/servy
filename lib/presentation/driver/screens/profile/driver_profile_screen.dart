import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../logic/providers/auth_providers.dart';
import '../../../../logic/providers/driver_providers.dart';
import '../../../../data/models/driver_earnings_model.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../customer/widgets/common/loading_state_widget.dart';
import '../../../../core/utils/haptic_feedback.dart';

/// Profile screen for Driver app
class DriverProfileScreen extends ConsumerWidget {
  const DriverProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final l10n = context.l10n;

    if (user == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            l10n.profile,
            style: const TextStyle(color: AppColors.textPrimary),
          ),
          backgroundColor: AppColors.background,
        ),
        body: const Center(child: LoadingStateWidget()),
      );
    }

    // Get driver earnings for stats
    final earningsAsync = ref.watch(driverEarningsProvider(user.id));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          l10n.profile,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SingleChildScrollView(
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
                      user.name?.substring(0, 1).toUpperCase() ?? 'D',
                      style: const TextStyle(
                        fontSize: 40,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
                .animate()
                .scale(delay: 200.ms, duration: 600.ms)
                .fadeIn(delay: 200.ms, duration: 600.ms),
            const SizedBox(height: 16),
            // Name
            Text(
                  user.name ?? 'Driver',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                )
                .animate()
                .fadeIn(delay: 400.ms, duration: 600.ms)
                .slideY(begin: 0.2, end: 0),
            const SizedBox(height: 8),
            // Email
            Text(
                  user.email,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                )
                .animate()
                .fadeIn(delay: 500.ms, duration: 600.ms)
                .slideY(begin: 0.2, end: 0),
            const SizedBox(height: 32),

            // Driver Stats
            earningsAsync.when(
              data: (earnings) => _DriverStatsCard(earnings: earnings),
              loading:
                  () => Container(
                    height: 120,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Center(child: LoadingStateWidget()),
                  ),
              error: (error, stack) => const SizedBox.shrink(),
            ),

            const SizedBox(height: 24),

            // Menu Items
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border),
                boxShadow: [AppColors.cardShadow],
              ),
              child: Column(
                children: [
                  ListTile(
                        leading: const Icon(
                          Icons.person_outline,
                          color: AppColors.primary,
                        ),
                        title: Text(
                          l10n.editProfile,
                          style: const TextStyle(color: AppColors.textPrimary),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: AppColors.textSecondary,
                        ),
                        onTap: () {
                          HapticFeedbackUtil.lightImpact();
                          context.push('/driver/edit-profile');
                        },
                      )
                      .animate()
                      .fadeIn(delay: 600.ms, duration: 400.ms)
                      .slideX(begin: -0.2, end: 0),
                  Divider(color: AppColors.border, height: 1),
                  ListTile(
                        leading: const Icon(
                          Icons.account_circle_outlined,
                          color: AppColors.accent,
                        ),
                        title: Text(
                          'Driver Information',
                          style: const TextStyle(color: AppColors.textPrimary),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: AppColors.textSecondary,
                        ),
                        onTap: () {
                          HapticFeedbackUtil.lightImpact();
                          // Navigate to driver info
                        },
                      )
                      .animate()
                      .fadeIn(delay: 700.ms, duration: 400.ms)
                      .slideX(begin: -0.2, end: 0),
                  Divider(color: AppColors.border, height: 1),
                  ListTile(
                        leading: const Icon(
                          Icons.verified_outlined,
                          color: AppColors.success,
                        ),
                        title: Text(
                          'Verification',
                          style: const TextStyle(color: AppColors.textPrimary),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: AppColors.textSecondary,
                        ),
                        onTap: () {
                          HapticFeedbackUtil.lightImpact();
                          // Navigate to verification
                        },
                      )
                      .animate()
                      .fadeIn(delay: 800.ms, duration: 400.ms)
                      .slideX(begin: -0.2, end: 0),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Settings & Support
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border),
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
                          l10n.settings,
                          style: const TextStyle(color: AppColors.textPrimary),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: AppColors.textSecondary,
                        ),
                        onTap: () {
                          HapticFeedbackUtil.lightImpact();
                          context.push('/driver/settings');
                        },
                      )
                      .animate()
                      .fadeIn(delay: 900.ms, duration: 400.ms)
                      .slideX(begin: -0.2, end: 0),
                  Divider(color: AppColors.border, height: 1),
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
                      )
                      .animate()
                      .fadeIn(delay: 1000.ms, duration: 400.ms)
                      .slideX(begin: -0.2, end: 0),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Logout
            Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.border),
                    boxShadow: [AppColors.cardShadow],
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.logout, color: AppColors.error),
                    title: Text(
                      l10n.logout,
                      style: const TextStyle(color: AppColors.error),
                    ),
                    onTap: () async {
                      HapticFeedbackUtil.mediumImpact();
                      await ref.read(authProvider.notifier).logout();
                      if (context.mounted) {
                        context.go('/driver/login');
                      }
                    },
                  ),
                )
                .animate()
                .fadeIn(delay: 1100.ms, duration: 400.ms)
                .slideX(begin: -0.2, end: 0),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

/// Driver Stats Card Widget
class _DriverStatsCard extends StatelessWidget {
  const _DriverStatsCard({required this.earnings});

  final DriverEarningsModel? earnings;

  @override
  Widget build(BuildContext context) {
    return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatItem(
                    icon: Icons.local_shipping,
                    value: '${earnings?.totalDeliveries ?? 0}',
                    label: context.l10n.totalDeliveries,
                  ),
                  _StatItem(
                    icon: Icons.attach_money,
                    value: CurrencyFormatter.formatPrice(
                      earnings?.totalEarnings ?? 0.0,
                      context,
                    ),
                    label: 'Total Earnings',
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatItem(
                    icon: Icons.today,
                    value: '${earnings?.todayDeliveries ?? 0}',
                    label: "Today's Deliveries",
                  ),
                  _StatItem(
                    icon: Icons.trending_up,
                    value: CurrencyFormatter.formatPrice(
                      earnings?.averageEarningPerDelivery ?? 0.0,
                      context,
                    ),
                    label: 'Avg/Delivery',
                  ),
                ],
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(delay: 600.ms, duration: 600.ms)
        .slideY(begin: 0.2, end: 0);
  }
}

/// Stat Item Widget
class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: AppColors.textPrimary, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textPrimary.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
