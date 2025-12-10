import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../data/models/driver_earnings_model.dart';
import '../../../../logic/providers/driver_providers.dart';
import '../../../../logic/providers/auth_providers.dart';
import '../../../customer/widgets/common/loading_state_widget.dart';
import '../../../customer/widgets/common/error_state_widget.dart';

/// Earnings Dashboard Screen for Driver
class EarningsDashboardScreen extends ConsumerWidget {
  const EarningsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final driver = ref.watch(currentUserProvider);
    final l10n = context.l10n;

    if (driver == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Text(
            l10n.pleaseLoginFirst,
            style: const TextStyle(color: AppColors.textPrimary),
          ),
        ),
      );
    }

    final earningsAsync = ref.watch(driverEarningsProvider(driver.id));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          l10n.earnings,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        onRefresh: () async {
          ref.invalidate(driverEarningsProvider(driver.id));
        },
        child: earningsAsync.when(
          data: (earnings) => _EarningsContent(earnings: earnings),
          loading: () => const LoadingStateWidget(),
          error: (error, stack) => ErrorStateWidget(
            message: 'Failed to load earnings',
            error: error.toString(),
            onRetry: () {
              ref.invalidate(driverEarningsProvider(driver.id));
            },
          ),
        ),
      ),
    );
  }
}

/// Earnings Content Widget
class _EarningsContent extends StatelessWidget {
  const _EarningsContent({required this.earnings});

  final DriverEarningsModel earnings;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Today's Earnings Card
          _EarningsCard(
            title: l10n.todaysEarnings,
            amount: earnings.todayEarnings,
            deliveries: earnings.todayDeliveries,
            color: AppColors.primary,
            icon: Icons.today,
          )
              .animate()
              .fadeIn(duration: 300.ms)
              .slideY(begin: -0.1, end: 0),
          const SizedBox(height: 16),

          // Stats Row
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: l10n.totalDeliveries,
                  value: '${earnings.totalDeliveries}',
                  icon: Icons.local_shipping,
                  color: AppColors.accent,
                )
                    .animate()
                    .fadeIn(delay: 100.ms)
                    .slideX(begin: -0.1, end: 0),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatCard(
                  title: 'Average',
                  value: CurrencyFormatter.formatPrice(
                    earnings.averageEarningPerDelivery,
                    context,
                  ),
                  icon: Icons.trending_up,
                  color: AppColors.success,
                )
                    .animate()
                    .fadeIn(delay: 200.ms)
                    .slideX(begin: 0.1, end: 0),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Period Earnings
          Text(
            'Earnings by Period',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          )
              .animate()
              .fadeIn(delay: 300.ms),
          const SizedBox(height: 16),

          _PeriodEarningsCard(
            title: 'This Week',
            amount: earnings.weekEarnings,
            deliveries: earnings.weekDeliveries,
            color: AppColors.secondary,
          )
              .animate()
              .fadeIn(delay: 400.ms)
              .slideY(begin: 0.1, end: 0),
          const SizedBox(height: 12),

          _PeriodEarningsCard(
            title: 'This Month',
            amount: earnings.monthEarnings,
            deliveries: earnings.monthDeliveries,
            color: AppColors.accent,
          )
              .animate()
              .fadeIn(delay: 500.ms)
              .slideY(begin: 0.1, end: 0),
          const SizedBox(height: 12),

          _PeriodEarningsCard(
            title: 'Total',
            amount: earnings.totalEarnings,
            deliveries: earnings.totalDeliveries,
            color: AppColors.primary,
            isTotal: true,
          )
              .animate()
              .fadeIn(delay: 600.ms)
              .slideY(begin: 0.1, end: 0),
          const SizedBox(height: 24),

          // Weekly Chart
          if (earnings.weeklyEarnings.isNotEmpty) ...[
            Text(
              'Last 7 Days',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            )
                .animate()
                .fadeIn(delay: 700.ms),
            const SizedBox(height: 16),
            _WeeklyChart(earnings: earnings.weeklyEarnings)
                .animate()
                .fadeIn(delay: 800.ms)
                .slideY(begin: 0.1, end: 0),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

/// Earnings Card Widget
class _EarningsCard extends StatelessWidget {
  const _EarningsCard({
    required this.title,
    required this.amount,
    required this.deliveries,
    required this.color,
    required this.icon,
  });

  final String title;
  final double amount;
  final int deliveries;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.textPrimary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.textPrimary, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            CurrencyFormatter.formatPrice(amount, context),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.local_shipping,
                size: 16,
                color: AppColors.textPrimary.withOpacity(0.8),
              ),
              const SizedBox(width: 8),
              Text(
                '$deliveries deliveries',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Stat Card Widget
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: [AppColors.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Period Earnings Card
class _PeriodEarningsCard extends StatelessWidget {
  const _PeriodEarningsCard({
    required this.title,
    required this.amount,
    required this.deliveries,
    required this.color,
    this.isTotal = false,
  });

  final String title;
  final double amount;
  final int deliveries;
  final Color color;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isTotal ? color : AppColors.border,
          width: isTotal ? 2 : 1,
        ),
        boxShadow: isTotal
            ? [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ]
            : [AppColors.cardShadow],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isTotal ? Icons.account_balance_wallet : Icons.calendar_today,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  CurrencyFormatter.formatPrice(amount, context),
                  style: TextStyle(
                    fontSize: isTotal ? 20 : 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$deliveries',
                style: TextStyle(
                  fontSize: isTotal ? 18 : 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                'deliveries',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Weekly Chart Widget
class _WeeklyChart extends StatelessWidget {
  const _WeeklyChart({required this.earnings});

  final List<EarningsDayModel> earnings;

  @override
  Widget build(BuildContext context) {
    final maxEarnings = earnings.map((e) => e.earnings).reduce(
          (a, b) => a > b ? a : b,
        );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: [AppColors.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Daily Earnings',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: earnings.asMap().entries.map((entry) {
              final dayEarnings = entry.value;
              final height = maxEarnings > 0
                  ? (dayEarnings.earnings / maxEarnings) * 100
                  : 0.0;

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(minWidth: 20),
                        height: height.clamp(20.0, 100.0),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getDayName(dayEarnings.date.weekday),
                        style: const TextStyle(
                          fontSize: 9,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        CurrencyFormatter.formatPrice(dayEarnings.earnings, context),
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }
}

