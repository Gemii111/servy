import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../data/models/order_model.dart';
import '../../../../logic/providers/order_providers.dart';
import '../../../../logic/providers/auth_providers.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../widgets/common/loading_state_widget.dart';
import '../../widgets/common/error_state_widget.dart';

/// Order details screen
class OrderDetailsScreen extends ConsumerWidget {
  const OrderDetailsScreen({
    super.key,
    required this.orderId,
  });

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Find order from user orders
    final user = ref.watch(currentUserProvider);
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text(context.l10n.orderDetails)),
        body: Center(child: Text(context.l10n.pleaseLoginFirst)),
      );
    }

    final ordersAsync = ref.watch(userOrdersProvider(user.id));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.card,
        title: Text(
          context.l10n.orderDetails,
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: ordersAsync.when(
        data: (orders) {
          final order = orders.firstWhere(
            (o) => o.id == orderId,
            orElse: () => throw Exception('Order not found'),
          );
          return _buildOrderDetails(context, order);
        },
        loading: () => const LoadingStateWidget(),
        error: (error, stack) => ErrorStateWidget(
          message: context.l10n.failedToLoadOrder,
          error: error.toString(),
          showGoBack: true,
        ),
      ),
    );
  }

  Widget _buildOrderDetails(BuildContext context, OrderModel order) {
    final statusColor = _getStatusColor(order.status);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: statusColor),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: statusColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Status',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order.status.displayName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
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
                        'Estimated',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatTime(order.estimatedDeliveryTime!),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Restaurant Info
          _SectionTitle(title: 'Restaurant'),
          const SizedBox(height: 12),
          _InfoCard(
            icon: Icons.restaurant,
            title: order.restaurantName,
            subtitle: '${context.l10n.orderNumber}${order.id.substring(order.id.length - 6)}',
          ),
          const SizedBox(height: 24),
          // Order Items
          _SectionTitle(title: context.l10n.orderItems),
          const SizedBox(height: 12),
          ...order.items.map((item) => _OrderItemCard(item: item)),
          const SizedBox(height: 24),
          // Delivery Address
          _SectionTitle(title: context.l10n.deliveryAddress),
          const SizedBox(height: 12),
          _InfoCard(
            icon: Icons.location_on,
            title: order.deliveryAddress.label,
            subtitle: order.deliveryAddress.fullAddress,
          ),
          const SizedBox(height: 24),
          // Payment Info
          _SectionTitle(title: 'Payment'),
          const SizedBox(height: 12),
          _InfoCard(
            icon: order.paymentMethod == 'cash' ? Icons.money : Icons.credit_card,
            title: order.paymentMethod == 'cash' ? context.l10n.cashOnDelivery : context.l10n.creditCard,
            subtitle: '${context.l10n.total}: ${CurrencyFormatter.formatPrice(order.total, context)}',
          ),
          const SizedBox(height: 24),
          // Order Summary
          _SectionTitle(title: context.l10n.orderSummary),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.border),
              boxShadow: [AppColors.cardShadow],
            ),
            child: Column(
              children: [
                _SummaryRow(label: 'Subtotal', value: CurrencyFormatter.formatPrice(order.subtotal, context)),
                const SizedBox(height: 8),
                _SummaryRow(label: 'Delivery Fee', value: CurrencyFormatter.formatPrice(order.deliveryFee, context)),
                if (order.tax != null) ...[
                  const SizedBox(height: 8),
                  _SummaryRow(label: 'Tax', value: CurrencyFormatter.formatPrice(order.tax!, context)),
                ],
                Divider(height: 24, color: AppColors.border),
                _SummaryRow(
                  label: 'Total',
                  value: CurrencyFormatter.formatPrice(order.total, context),
                  isTotal: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Track Order Button (if active)
          if (order.status != OrderStatus.delivered && order.status != OrderStatus.cancelled)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  context.push('/order-tracking/${order.id}');
                },
                icon: const Icon(Icons.location_on),
                label: Text(context.l10n.trackOrder),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ),
          // Rate Order Button (if delivered)
          if (order.status == OrderStatus.delivered) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  context.push('/review-order/${order.id}');
                },
                icon: const Icon(Icons.star),
                label: Text(context.l10n.rateYourOrder),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.warning,
                  foregroundColor: AppColors.textPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return AppColors.warning;
      case OrderStatus.accepted:
        return AppColors.accent;
      case OrderStatus.preparing:
        return AppColors.primary;
      case OrderStatus.ready:
        return Colors.teal;
      case OrderStatus.outForDelivery:
        return Colors.indigo;
      case OrderStatus.delivered:
        return AppColors.success;
      case OrderStatus.cancelled:
        return AppColors.error;
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);

    if (difference.inMinutes <= 0) {
      return 'Delivered';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min';
    } else {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''}';
    }
  }
}

/// Section title widget
class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
    );
  }
}

/// Info card widget
class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: [AppColors.cardShadow],
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
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

/// Order item card widget
class _OrderItemCard extends StatelessWidget {
  const _OrderItemCard({required this.item});

  final OrderItemModel item;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '${item.quantity}x',
                style: const TextStyle(
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
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (item.extras.isNotEmpty)
                  Text(
                    'Extras: ${item.extras.join(', ')}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            CurrencyFormatter.formatPrice(item.price * item.quantity, context),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Summary row widget
class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  final String label;
  final String value;
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
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: FontWeight.bold,
            color: isTotal ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

