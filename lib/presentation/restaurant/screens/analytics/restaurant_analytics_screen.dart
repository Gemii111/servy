import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../logic/providers/auth_providers.dart';
import '../../../../logic/providers/restaurant_providers.dart';
import '../../../../data/models/restaurant_statistics_model.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../customer/widgets/common/loading_state_widget.dart';
import '../../../customer/widgets/common/error_state_widget.dart';

/// Restaurant Analytics & Reports Screen
class RestaurantAnalyticsScreen extends ConsumerStatefulWidget {
  const RestaurantAnalyticsScreen({super.key});

  @override
  ConsumerState<RestaurantAnalyticsScreen> createState() =>
      _RestaurantAnalyticsScreenState();
}

class _RestaurantAnalyticsScreenState
    extends ConsumerState<RestaurantAnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _restaurantId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRestaurantData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
      ref.invalidate(restaurantStatisticsProvider(restaurantId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final l10n = context.l10n;

    if (user == null || _restaurantId == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          title: Text(
            l10n.viewAnalytics,
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

    final statisticsAsync = ref.watch(
      restaurantStatisticsProvider(_restaurantId!),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          l10n.viewAnalytics,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: [
            Tab(text: l10n.today),
            Tab(text: l10n.week),
            Tab(text: l10n.month),
          ],
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        onRefresh: () async {
          if (_restaurantId != null) {
            ref.invalidate(restaurantStatisticsProvider(_restaurantId!));
          }
        },
        child: statisticsAsync.when(
          data:
              (stats) => TabBarView(
                controller: _tabController,
                children: [
                  _TodayAnalyticsTab(stats: stats),
                  _WeekAnalyticsTab(stats: stats),
                  _MonthAnalyticsTab(stats: stats),
                ],
              ),
          loading: () => const LoadingStateWidget(),
          error:
              (error, stack) => ErrorStateWidget(
                message: l10n.failedToLoad,
                error: error.toString(),
                onRetry: () {
                  if (_restaurantId != null) {
                    ref.invalidate(
                      restaurantStatisticsProvider(_restaurantId!),
                    );
                  }
                },
              ),
        ),
      ),
    );
  }
}

/// Today Analytics Tab
class _TodayAnalyticsTab extends StatelessWidget {
  const _TodayAnalyticsTab({required this.stats});

  final RestaurantStatisticsModel stats;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Summary Cards
          _SummaryCard(
            icon: Icons.receipt_long,
            title: l10n.totalOrders,
            value: '${stats.todayOrders}',
            subtitle: l10n.todaysOrders,
            color: AppColors.primary,
          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0),
          const SizedBox(height: 16),
          _SummaryCard(
            icon: Icons.attach_money,
            title: l10n.totalRevenue,
            value: CurrencyFormatter.formatPrice(stats.todayRevenue, context),
            subtitle: l10n.todaysRevenue,
            color: AppColors.success,
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
          const SizedBox(height: 16),
          _SummaryCard(
            icon: Icons.shopping_cart,
            title: l10n.averageOrderValue,
            value: CurrencyFormatter.formatPrice(
              stats.averageOrderValue,
              context,
            ),
            subtitle: l10n.perOrder,
            color: AppColors.accent,
          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0),
          const SizedBox(height: 24),

          // Order Status Breakdown
          _OrderStatusSection(
            stats: stats,
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),
        ],
      ),
    );
  }
}

/// Week Analytics Tab
class _WeekAnalyticsTab extends StatelessWidget {
  const _WeekAnalyticsTab({required this.stats});

  final RestaurantStatisticsModel stats;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SummaryCard(
            icon: Icons.receipt_long,
            title: l10n.totalOrders,
            value: '${stats.weeklyOrders}',
            subtitle: l10n.weeklyOrders,
            color: AppColors.primary,
          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0),
          const SizedBox(height: 16),
          _SummaryCard(
            icon: Icons.attach_money,
            title: l10n.totalRevenue,
            value: CurrencyFormatter.formatPrice(stats.weeklyRevenue, context),
            subtitle: l10n.weeklyRevenue,
            color: AppColors.success,
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
          const SizedBox(height: 16),
          _SummaryCard(
            icon: Icons.trending_up,
            title: l10n.averageOrderValue,
            value:
                stats.weeklyOrders > 0
                    ? CurrencyFormatter.formatPrice(
                      stats.weeklyRevenue / stats.weeklyOrders,
                      context,
                    )
                    : CurrencyFormatter.formatPrice(0, context),
            subtitle: l10n.perOrder,
            color: AppColors.accent,
          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0),
        ],
      ),
    );
  }
}

/// Month Analytics Tab
class _MonthAnalyticsTab extends StatelessWidget {
  const _MonthAnalyticsTab({required this.stats});

  final RestaurantStatisticsModel stats;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SummaryCard(
            icon: Icons.receipt_long,
            title: l10n.totalOrders,
            value: '${stats.monthlyOrders}',
            subtitle: l10n.monthlyOrders,
            color: AppColors.primary,
          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0),
          const SizedBox(height: 16),
          _SummaryCard(
            icon: Icons.attach_money,
            title: l10n.totalRevenue,
            value: CurrencyFormatter.formatPrice(stats.monthlyRevenue, context),
            subtitle: l10n.monthlyRevenue,
            color: AppColors.success,
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
          const SizedBox(height: 16),
          _SummaryCard(
            icon: Icons.trending_up,
            title: l10n.averageOrderValue,
            value:
                stats.monthlyOrders > 0
                    ? CurrencyFormatter.formatPrice(
                      stats.monthlyRevenue / stats.monthlyOrders,
                      context,
                    )
                    : CurrencyFormatter.formatPrice(0, context),
            subtitle: l10n.perOrder,
            color: AppColors.accent,
          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0),
        ],
      ),
    );
  }
}

/// Summary Card Widget
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [AppColors.cardShadow],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
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

/// Order Status Section Widget
class _OrderStatusSection extends StatelessWidget {
  const _OrderStatusSection({required this.stats});

  final RestaurantStatisticsModel stats;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
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
            l10n.orderStatus,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _StatusRow(
            label: l10n.pendingOrders,
            value: '${stats.pendingOrders}',
            color: AppColors.secondary,
          ),
          const SizedBox(height: 12),
          _StatusRow(
            label: l10n.activeOrdersCount,
            value: '${stats.activeOrders}',
            color: AppColors.success,
          ),
        ],
      ),
    );
  }
}

/// Status Row Widget
class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
