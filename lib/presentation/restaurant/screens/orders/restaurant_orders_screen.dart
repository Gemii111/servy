import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../logic/providers/auth_providers.dart';
import '../../../../logic/providers/order_providers.dart';
import '../../../../data/models/order_model.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/haptic_feedback.dart';
import '../../../customer/widgets/common/empty_state_widget.dart';
import '../../../customer/widgets/common/loading_state_widget.dart';
import '../../../customer/widgets/common/error_state_widget.dart';
import 'package:intl/intl.dart';
import '../../../../logic/providers/restaurant_providers.dart';

/// Restaurant Orders Screen - Display and manage all restaurant orders
class RestaurantOrdersScreen extends ConsumerStatefulWidget {
  const RestaurantOrdersScreen({super.key});

  @override
  ConsumerState<RestaurantOrdersScreen> createState() =>
      _RestaurantOrdersScreenState();
}

class _RestaurantOrdersScreenState
    extends ConsumerState<RestaurantOrdersScreen> {
  String _selectedFilter =
      'all'; // 'all', 'pending', 'preparing', 'ready', 'completed'

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final l10n = context.l10n;

    if (user == null) {
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

    // For now, use first restaurant ID from mock data
    final restaurantId = '1'; // Mock restaurant ID

    final ordersAsync = ref.watch(restaurantOrdersProvider(restaurantId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          l10n.restaurantOrders,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: _buildFilterChips(l10n),
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        onRefresh: () async {
          ref.invalidate(restaurantOrdersProvider(restaurantId));
        },
        child: ordersAsync.when(
          data: (orders) {
            final filteredOrders = _filterOrders(orders);
            if (filteredOrders.isEmpty) {
              return EmptyStateWidget(
                icon: Icons.receipt_long_outlined,
                title: l10n.noRestaurantOrders,
                message:
                    _selectedFilter == 'all'
                        ? l10n.noOrdersYet
                        : '${l10n.noOrdersYet} (${_getFilterLabel(_selectedFilter, l10n)})',
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredOrders.length,
              itemBuilder: (context, index) {
                return _OrderCard(
                      order: filteredOrders[index],
                      onTap: () {
                        HapticFeedbackUtil.lightImpact();
                        context.push(
                          '/restaurant/orders/${filteredOrders[index].id}',
                        );
                      },
                    )
                    .animate()
                    .fadeIn(delay: (50 * index).ms)
                    .slideY(begin: 0.1, end: 0);
              },
            );
          },
          loading: () => const LoadingStateWidget(),
          error:
              (error, stack) => ErrorStateWidget(
                message: l10n.failedToLoadOrders,
                error: error.toString(),
                onRetry: () {
                  ref.invalidate(restaurantOrdersProvider(restaurantId));
                },
              ),
        ),
      ),
    );
  }

  Widget _buildFilterChips(AppLocalizations l10n) {
    final filters = [
      {'key': 'all', 'label': l10n.all},
      {'key': 'pending', 'label': l10n.pending},
      {'key': 'preparing', 'label': l10n.preparing},
      {'key': 'ready', 'label': l10n.ready},
      {'key': 'completed', 'label': l10n.delivered},
    ];

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter['key'];
          return FilterChip(
            selected: isSelected,
            label: Text(filter['label'] as String),
            onSelected: (selected) {
              setState(() {
                _selectedFilter = filter['key'] as String;
              });
              HapticFeedbackUtil.lightImpact();
            },
            selectedColor: AppColors.primary.withOpacity(0.3),
            checkmarkColor: AppColors.primary,
            labelStyle: TextStyle(
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            backgroundColor: AppColors.card,
            side: BorderSide(
              color: isSelected ? AppColors.primary : AppColors.border,
            ),
          );
        },
      ),
    );
  }

  List<OrderModel> _filterOrders(List<OrderModel> orders) {
    switch (_selectedFilter) {
      case 'pending':
        return orders
            .where((order) => order.status == OrderStatus.pending)
            .toList();
      case 'preparing':
        return orders
            .where((order) => order.status == OrderStatus.preparing)
            .toList();
      case 'ready':
        return orders
            .where((order) => order.status == OrderStatus.ready)
            .toList();
      case 'completed':
        return orders
            .where((order) => order.status == OrderStatus.delivered)
            .toList();
      default:
        return orders;
    }
  }

  String _getFilterLabel(String filter, AppLocalizations l10n) {
    switch (filter) {
      case 'pending':
        return l10n.pending;
      case 'preparing':
        return l10n.preparing;
      case 'ready':
        return l10n.ready;
      case 'completed':
        return l10n.delivered;
      default:
        return l10n.all;
    }
  }
}

/// Order Card Widget
class _OrderCard extends ConsumerWidget {
  const _OrderCard({required this.order, required this.onTap});

  final OrderModel order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final dateFormat = DateFormat('MMM dd, yyyy - hh:mm a');
    final isArabic = l10n.isArabic;
    final dateFormatAr = DateFormat('yyyy MMMM dd - hh:mm a', 'ar');

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
          boxShadow: [AppColors.cardShadow],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${l10n.orderNumber}${order.id.substring(0, 8)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isArabic
                            ? dateFormatAr.format(order.createdAt)
                            : dateFormat.format(order.createdAt),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    order.status.displayName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(order.status),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    order.deliveryAddress.fullAddress,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${order.items.length} ${order.items.length == 1 ? 'item' : 'items'}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  CurrencyFormatter.formatPrice(order.total, context),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            // Accept Button for Pending Orders
            if (order.status == OrderStatus.pending) ...[
              const SizedBox(height: 12),
              const Divider(color: AppColors.border, height: 1),
              const SizedBox(height: 12),
              _AcceptButton(order: order, restaurantId: order.restaurantId),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return AppColors.secondary;
      case OrderStatus.accepted:
      case OrderStatus.preparing:
        return AppColors.accent;
      case OrderStatus.ready:
        return AppColors.success;
      case OrderStatus.outForDelivery:
        return AppColors.primary;
      case OrderStatus.delivered:
        return AppColors.success;
      case OrderStatus.cancelled:
        return AppColors.error;
    }
  }
}

/// Accept Button Widget for Pending Orders
class _AcceptButton extends ConsumerWidget {
  const _AcceptButton({
    required this.order,
    required this.restaurantId,
  });

  final OrderModel order;
  final String restaurantId;

  Future<void> _handleAcceptOrder(
    BuildContext context,
    WidgetRef ref,
  ) async {
    HapticFeedbackUtil.mediumImpact();

    try {
      final repository = ref.read(orderRepositoryProvider);
      await repository.updateOrderStatus(
        orderId: order.id,
        status: OrderStatus.accepted,
      );

      // Refresh orders and statistics, and invalidate orderById provider
      ref.invalidate(restaurantOrdersProvider(restaurantId));
      ref.invalidate(restaurantStatisticsProvider(restaurantId));
      ref.invalidate(orderByIdProvider(order.id));

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.orderAcceptedSuccess),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _handleAcceptOrder(context, ref),
        icon: const Icon(Icons.check_circle, size: 20),
        label: Text(l10n.acceptOrder),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.success,
          foregroundColor: AppColors.textPrimary,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
