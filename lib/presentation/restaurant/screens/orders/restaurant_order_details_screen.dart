import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/order_model.dart';
import '../../../../logic/providers/order_providers.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/haptic_feedback.dart';
import '../../../customer/widgets/common/loading_state_widget.dart';
import '../../../customer/widgets/common/error_state_widget.dart';

/// Restaurant Order Details Screen
class RestaurantOrderDetailsScreen extends ConsumerWidget {
  const RestaurantOrderDetailsScreen({
    super.key,
    required this.orderId,
  });

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

          return _OrderDetailsContent(order: order);
        },
        loading: () => const LoadingStateWidget(),
        error: (error, stack) => ErrorStateWidget(
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
  const _OrderDetailsContent({required this.order});

  final OrderModel order;

  Future<void> _handleUpdateStatus(
    BuildContext context,
    WidgetRef ref,
    OrderStatus newStatus,
  ) async {
    HapticFeedbackUtil.mediumImpact();

    try {
      final repository = ref.read(orderRepositoryProvider);
      await repository.updateOrderStatus(
        orderId: order.id,
        status: newStatus,
      );

      // Refresh order and restaurant orders
      ref.invalidate(orderByIdProvider(order.id));
      ref.invalidate(restaurantOrdersProvider(order.restaurantId));

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.orderStatusUpdated),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Status Card
          _StatusCard(order: order),
          const SizedBox(height: 24),

          // Customer Info Card
          _CustomerInfoCard(order: order),
          const SizedBox(height: 16),

          // Delivery Address Card
          _DeliveryAddressCard(order: order),
          const SizedBox(height: 24),

          // Order Items
          Text(
            l10n.orderItems,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...order.items.map((item) => _OrderItemCard(item: item)),
          const SizedBox(height: 24),

          // Order Summary
          _OrderSummaryCard(order: order),
          const SizedBox(height: 24),

          // Action Buttons
          _ActionButtons(
            order: order,
            onUpdateStatus: (status) => _handleUpdateStatus(context, ref, status),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

/// Status Card Widget
class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [AppColors.cardShadow],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.textPrimary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getStatusIcon(order.status),
              color: AppColors.textPrimary,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.orderStatus,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  order.status.displayName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 200.ms)
        .slideY(begin: -0.1, end: 0);
  }

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.pending;
      case OrderStatus.accepted:
        return Icons.check_circle_outline;
      case OrderStatus.preparing:
        return Icons.restaurant;
      case OrderStatus.ready:
        return Icons.check_circle;
      case OrderStatus.outForDelivery:
        return Icons.local_shipping;
      case OrderStatus.delivered:
        return Icons.done_all;
      case OrderStatus.cancelled:
        return Icons.cancel;
    }
  }
}

/// Customer Info Card Widget
class _CustomerInfoCard extends StatelessWidget {
  const _CustomerInfoCard({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [AppColors.cardShadow],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.person_outline,
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
                  context.l10n.customer,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Customer ${order.userId.substring(0, 8)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 300.ms)
        .slideX(begin: -0.1, end: 0);
  }
}

/// Delivery Address Card Widget
class _DeliveryAddressCard extends StatelessWidget {
  const _DeliveryAddressCard({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [AppColors.cardShadow],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                  context.l10n.deliveryAddress,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  order.deliveryAddress.fullAddress,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 400.ms)
        .slideX(begin: -0.1, end: 0);
  }
}

/// Order Item Card Widget
class _OrderItemCard extends StatelessWidget {
  const _OrderItemCard({required this.item});

  final OrderItemModel item;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.restaurant,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${item.quantity}x',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                CurrencyFormatter.formatPrice(item.price * item.quantity, context),
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
    )
        .animate()
        .fadeIn(delay: 500.ms)
        .slideX(begin: -0.1, end: 0);
  }
}

/// Order Summary Card Widget
class _OrderSummaryCard extends StatelessWidget {
  const _OrderSummaryCard({required this.order});

  final OrderModel order;

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
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
          _SummaryRow(
            label: l10n.subtotal,
            value: CurrencyFormatter.formatPrice(order.subtotal, context),
          ),
          const SizedBox(height: 8),
          _SummaryRow(
            label: l10n.deliveryFee,
            value: CurrencyFormatter.formatPrice(order.deliveryFee, context),
          ),
          if (order.tax != null) ...[
            const SizedBox(height: 8),
            _SummaryRow(
              label: l10n.tax,
              value: CurrencyFormatter.formatPrice(order.tax!, context),
            ),
          ],
          if (order.discount != null && order.discount! > 0) ...[
            const SizedBox(height: 8),
            _SummaryRow(
              label: l10n.discount,
              value: '-${CurrencyFormatter.formatPrice(order.discount!, context)}',
              valueColor: AppColors.success,
            ),
          ],
          const Divider(color: AppColors.border, height: 24),
          _SummaryRow(
            label: l10n.total,
            value: CurrencyFormatter.formatPrice(order.total, context),
            isTotal: true,
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 600.ms)
        .slideY(begin: 0.1, end: 0);
  }
}

/// Summary Row Widget
class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isTotal = false,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 20 : 14,
            fontWeight: FontWeight.bold,
            color: valueColor ?? (isTotal ? AppColors.primary : AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}

/// Action Buttons Widget
class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.order,
    required this.onUpdateStatus,
  });

  final OrderModel order;
  final Function(OrderStatus) onUpdateStatus;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Accept Order Button (for pending orders)
        if (order.status == OrderStatus.pending)
          ElevatedButton.icon(
            onPressed: () => onUpdateStatus(OrderStatus.accepted),
            icon: const Icon(Icons.check_circle),
            label: Text(l10n.acceptOrder),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: AppColors.textPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          )
              .animate()
              .fadeIn(delay: 700.ms)
              .slideY(begin: 0.1, end: 0),

        // Start Preparing Button (for accepted orders)
        if (order.status == OrderStatus.accepted) ...[
          ElevatedButton.icon(
            onPressed: () => onUpdateStatus(OrderStatus.preparing),
            icon: const Icon(Icons.restaurant),
            label: Text(l10n.startPreparing),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.textPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          )
              .animate()
              .fadeIn(delay: 700.ms)
              .slideY(begin: 0.1, end: 0),
          const SizedBox(height: 12),
        ],

        // Mark as Ready Button (for preparing orders)
        if (order.status == OrderStatus.preparing) ...[
          ElevatedButton.icon(
            onPressed: () => onUpdateStatus(OrderStatus.ready),
            icon: const Icon(Icons.check_circle),
            label: Text(l10n.markAsReady),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: AppColors.textPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          )
              .animate()
              .fadeIn(delay: 700.ms)
              .slideY(begin: 0.1, end: 0),
          const SizedBox(height: 12),
        ],

        // Cancel Order Button (for pending/accepted/preparing orders)
        if (order.status == OrderStatus.pending ||
            order.status == OrderStatus.accepted ||
            order.status == OrderStatus.preparing)
          OutlinedButton.icon(
            onPressed: () => _showCancelDialog(context, onUpdateStatus),
            icon: const Icon(Icons.cancel),
            label: Text(l10n.cancelOrder),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          )
              .animate()
              .fadeIn(delay: 800.ms)
              .slideY(begin: 0.1, end: 0),
      ],
    );
  }

  void _showCancelDialog(
    BuildContext context,
    Function(OrderStatus) onUpdateStatus,
  ) {
    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          l10n.cancelOrder,
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'Are you sure you want to cancel this order?',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              l10n.cancel,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onUpdateStatus(OrderStatus.cancelled);
            },
            child: Text(
              l10n.yes,
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

