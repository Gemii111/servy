import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../data/models/order_model.dart';
import '../../../../logic/providers/order_providers.dart';
import '../../../../logic/providers/auth_providers.dart';
import '../../../../logic/providers/driver_providers.dart';
import '../../../../core/utils/haptic_feedback.dart';
import '../../../../core/services/navigation_service.dart';
import '../../../../logic/providers/restaurant_providers.dart';
import '../../../customer/widgets/common/loading_state_widget.dart';
import '../../../customer/widgets/common/error_state_widget.dart';

/// Driver Order Details Screen
class DriverOrderDetailsScreen extends ConsumerWidget {
  const DriverOrderDetailsScreen({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final driver = ref.watch(currentUserProvider);
    final orderAsync = ref.watch(orderByIdProvider(orderId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          context.l10n.orderDetails,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: orderAsync.when(
        data: (order) {
          if (order == null) {
            return ErrorStateWidget(
              message: context.l10n.orderNotFound,
              onRetry: () {
                ref.invalidate(orderByIdProvider(orderId));
              },
            );
          }

          return _OrderDetailsContent(order: order, driverId: driver?.id ?? '');
        },
        loading: () => const LoadingStateWidget(),
        error:
            (error, stack) => ErrorStateWidget(
              message: context.l10n.failedToLoadOrder,
              error: error.toString(),
              onRetry: () {
                ref.invalidate(orderByIdProvider(orderId));
              },
            ),
      ),
    );
  }
}

/// Order Details Content Widget
class _OrderDetailsContent extends ConsumerWidget {
  const _OrderDetailsContent({required this.order, required this.driverId});

  final OrderModel order;
  final String driverId;

  Future<void> _navigateToRestaurant(
    BuildContext context,
    WidgetRef ref,
  ) async {
    HapticFeedbackUtil.mediumImpact();
    try {
      final restaurant = await ref.read(
        restaurantByIdProvider(order.restaurantId).future,
      );
      if (restaurant != null) {
        final success = await NavigationService.instance.startNavigation(
          latitude: restaurant.latitude,
          longitude: restaurant.longitude,
          label: restaurant.name,
        );
        if (!success && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.l10n.failedToOpenMaps),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.l10n.restaurantNotFound),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _navigateToCustomer(BuildContext context) async {
    HapticFeedbackUtil.mediumImpact();
    final success = await NavigationService.instance.startNavigation(
      latitude: order.deliveryAddress.latitude,
      longitude: order.deliveryAddress.longitude,
      label: order.deliveryAddress.fullAddress,
    );
    if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.failedToOpenMaps),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final canUpdateStatus =
        order.status == OrderStatus.outForDelivery ||
        order.status == OrderStatus.accepted ||
        order.status == OrderStatus.ready;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Order Status Card
          _StatusCard(order: order),
          const SizedBox(height: 16),

          // Restaurant Info Card
          _RestaurantInfoCard(
            order: order,
            onNavigate: () => _navigateToRestaurant(context, ref),
            onShowMap: () {
              HapticFeedbackUtil.mediumImpact();
              context.push('/driver/map/${order.id}');
            },
          ),
          const SizedBox(height: 16),

          // Delivery Address Card
          _DeliveryAddressCard(
            order: order,
            onNavigate: () => _navigateToCustomer(context),
            onShowMap: () {
              HapticFeedbackUtil.mediumImpact();
              context.push('/driver/map/${order.id}');
            },
          ),
          const SizedBox(height: 16),

          // Order Items Card
          _OrderItemsCard(order: order),
          const SizedBox(height: 16),

          // Order Summary Card
          _OrderSummaryCard(order: order, context: context),
          const SizedBox(height: 16),

          // Action Buttons
          if (canUpdateStatus) ...[
            if (order.status == OrderStatus.accepted)
              _ActionButton(
                icon: Icons.check_circle,
                label: l10n.markAsPickedUp,
                color: AppColors.primary,
                onPressed:
                    () => _handleUpdateStatus(
                      context,
                      ref,
                      OrderStatus.outForDelivery,
                    ),
              ),
            if (order.status == OrderStatus.outForDelivery) ...[
              const SizedBox(height: 12),
              _ActionButton(
                icon: Icons.location_on,
                label: l10n.navigateToCustomer,
                color: AppColors.accent,
                onPressed: () => _navigateToCustomer(context),
              ),
              const SizedBox(height: 12),
              _ActionButton(
                icon: Icons.done_all,
                label: l10n.markAsDelivered,
                color: AppColors.success,
                onPressed:
                    () => _handleUpdateStatus(
                      context,
                      ref,
                      OrderStatus.delivered,
                    ),
              ),
            ],
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Future<void> _handleUpdateStatus(
    BuildContext context,
    WidgetRef ref,
    OrderStatus newStatus,
  ) async {
    HapticFeedbackUtil.mediumImpact();

    try {
      // Get current driver info
      final authState = ref.read(authProvider);
      final driver = authState.valueOrNull;

      final repository = ref.read(orderRepositoryProvider);
      await repository.updateOrderStatus(
        orderId: order.id,
        status: newStatus,
        driverId: driver?.id,
        driverName: driver?.name,
      );

      // Refresh order and earnings
      ref.invalidate(orderByIdProvider(order.id));
      if (driver != null) {
        ref.invalidate(driverEarningsProvider(driver.id));
        ref.invalidate(driverActiveOrdersProvider(driver.id));
        ref.invalidate(driverOrderHistoryProvider(driver.id));
      }

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order status updated to ${newStatus.displayName}'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

      // Navigate back if delivered
      if (newStatus == OrderStatus.delivered && context.mounted) {
        Future.delayed(const Duration(seconds: 1), () {
          if (context.mounted) {
            context.pop();
          }
        });
      }
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
}

/// Status Card Widget
class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.order});

  final OrderModel order;

  Color _getStatusColor() {
    switch (order.status) {
      case OrderStatus.pending:
        return AppColors.secondary;
      case OrderStatus.accepted:
      case OrderStatus.preparing:
        return AppColors.accent;
      case OrderStatus.ready:
      case OrderStatus.outForDelivery:
        return AppColors.primary;
      case OrderStatus.delivered:
        return AppColors.success;
      case OrderStatus.cancelled:
        return AppColors.error;
    }
  }

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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getStatusColor().withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.local_shipping,
              color: _getStatusColor(),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order Status',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  order.status.displayName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(),
                  ),
                ),
              ],
            ),
          ),
          if (order.estimatedDeliveryTime != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'ETA',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_getMinutesUntil(order.estimatedDeliveryTime!)} min',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.1, end: 0);
  }

  int _getMinutesUntil(DateTime targetTime) {
    final now = DateTime.now();
    final difference = targetTime.difference(now);
    return difference.inMinutes > 0 ? difference.inMinutes : 0;
  }
}

/// Restaurant Info Card
class _RestaurantInfoCard extends StatelessWidget {
  const _RestaurantInfoCard({
    required this.order,
    required this.onNavigate,
    required this.onShowMap,
  });

  final OrderModel order;
  final VoidCallback onNavigate;
  final VoidCallback onShowMap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.restaurant,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.pickupFrom,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.restaurantName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.navigation, color: AppColors.accent),
                onPressed: onNavigate,
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.1, end: 0);
  }
}

/// Delivery Address Card
class _DeliveryAddressCard extends StatelessWidget {
  const _DeliveryAddressCard({
    required this.order,
    required this.onNavigate,
    required this.onShowMap,
  });

  final OrderModel order;
  final VoidCallback onNavigate;
  final VoidCallback onShowMap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.location_on,
                  color: AppColors.accent,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.deliverTo,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.deliveryAddress.addressLine,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      order.deliveryAddress.city,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.map, color: AppColors.primary),
                    tooltip: l10n.map,
                    onPressed: onShowMap,
                  ),
                  IconButton(
                    icon: const Icon(Icons.navigation, color: AppColors.accent),
                    tooltip: l10n.navigateToCustomer,
                    onPressed: onNavigate,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1, end: 0);
  }
}

/// Order Items Card
class _OrderItemsCard extends StatelessWidget {
  const _OrderItemsCard({required this.order});

  final OrderModel order;

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
          Text(
            context.l10n.orderItems,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...order.items.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${item.quantity}x',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (item.extras.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            item.extras.join(', '),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Text(
                    CurrencyFormatter.formatPrice(
                      item.price * item.quantity,
                      context,
                    ),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0);
  }
}

/// Order Summary Card
class _OrderSummaryCard extends StatelessWidget {
  const _OrderSummaryCard({required this.order, required this.context});

  final OrderModel order;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
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
          Text(
            l10n.orderSummary,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _SummaryRow(label: l10n.subtotal, value: order.subtotal),
          if (order.tax != null)
            _SummaryRow(label: l10n.tax, value: order.tax!),
          if (order.discount != null)
            _SummaryRow(
              label: l10n.discount,
              value: -order.discount!,
              isDiscount: true,
            ),
          _SummaryRow(label: l10n.deliveryFee, value: order.deliveryFee),
          const Divider(color: AppColors.border, height: 24),
          _SummaryRow(label: l10n.total, value: order.total, isTotal: true),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0);
  }
}

/// Summary Row Widget
class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.isTotal = false,
    this.isDiscount = false,
  });

  final String label;
  final double value;
  final bool isTotal;
  final bool isDiscount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            isDiscount
                ? '-${CurrencyFormatter.formatPrice(value.abs(), context)}'
                : CurrencyFormatter.formatPrice(value, context),
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: FontWeight.bold,
              color:
                  isDiscount
                      ? AppColors.success
                      : (isTotal ? AppColors.primary : AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

/// Action Button Widget
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 24),
        label: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: AppColors.textPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1, end: 0);
  }
}
