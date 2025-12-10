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
import '../../../customer/widgets/common/empty_state_widget.dart';
import '../../../customer/widgets/common/loading_state_widget.dart';
import '../../../customer/widgets/common/error_state_widget.dart';

/// Screen showing available delivery requests for driver
class DeliveryRequestsScreen extends ConsumerWidget {
  const DeliveryRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final driver = ref.watch(currentUserProvider);
    final availableOrdersAsync = ref.watch(availableDeliveryRequestsProvider);

    if (driver == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Text(
            context.l10n.pleaseLoginFirst,
            style: const TextStyle(color: AppColors.textPrimary),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          context.l10n.availableOrders,
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
          ref.invalidate(availableDeliveryRequestsProvider);
        },
        child: availableOrdersAsync.when(
          data: (orders) {
            if (orders.isEmpty) {
              return EmptyStateWidget(
                icon: Icons.delivery_dining_outlined,
                title: context.l10n.noOrdersAvailable,
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              cacheExtent: 500,
              itemBuilder: (context, index) {
                final order = orders[index];
                return DeliveryRequestCard(
                      order: order,
                      onAccept: () => _handleAcceptOrder(context, ref, order),
                      onReject: () => _handleRejectOrder(context, ref, order),
                      onViewDetails: () {
                        context.push('/driver/order-details/${order.id}');
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
                message: context.l10n.failedToLoadOrders,
                error: error.toString(),
                onRetry: () {
                  ref.invalidate(availableDeliveryRequestsProvider);
                },
              ),
        ),
      ),
    );
  }

  Future<void> _handleAcceptOrder(
    BuildContext context,
    WidgetRef ref,
    OrderModel order,
  ) async {
    HapticFeedbackUtil.mediumImpact();

    try {
      final driver = ref.read(currentUserProvider);
      if (driver == null) {
        throw Exception('Please login first');
      }

      final repository = ref.read(orderRepositoryProvider);
      await repository.acceptDeliveryRequest(
        driverId: driver.id,
        orderId: order.id,
      );

      // Refresh available orders and invalidate orderById provider
      ref.invalidate(availableDeliveryRequestsProvider);
      ref.invalidate(orderByIdProvider(order.id));
      ref.invalidate(driverActiveOrdersProvider(driver.id));
      ref.invalidate(driverEarningsProvider(driver.id));

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${context.l10n.acceptOrder} #${order.id.substring(0, 8)}',
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

      // Navigate to active orders or order details
      if (context.mounted) {
        // Wait a bit for the provider to update
        await Future.delayed(const Duration(milliseconds: 300));
        if (context.mounted) {
          context.push('/driver/order-details/${order.id}');
        }
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

  Future<void> _handleRejectOrder(
    BuildContext context,
    WidgetRef ref,
    OrderModel order,
  ) async {
    HapticFeedbackUtil.lightImpact();

    try {
      final driver = ref.read(currentUserProvider);
      if (driver == null) {
        throw Exception('Please login first');
      }

      final repository = ref.read(orderRepositoryProvider);
      await repository.rejectDeliveryRequest(
        driverId: driver.id,
        orderId: order.id,
      );

      // Refresh available orders
      ref.invalidate(availableDeliveryRequestsProvider);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${context.l10n.rejectOrder} #${order.id.substring(0, 8)}',
          ),
          backgroundColor: AppColors.error,
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
}

/// Delivery request card widget
class DeliveryRequestCard extends StatelessWidget {
  const DeliveryRequestCard({
    super.key,
    required this.order,
    required this.onAccept,
    required this.onReject,
    required this.onViewDetails,
  });

  final OrderModel order;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onViewDetails;

  int _getMinutesUntil(DateTime targetTime) {
    final now = DateTime.now();
    final difference = targetTime.difference(now);
    return difference.inMinutes > 0 ? difference.inMinutes : 0;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border),
        boxShadow: [AppColors.cardShadow],
      ),
      child: InkWell(
        onTap: onViewDetails,
        borderRadius: BorderRadius.circular(28),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Order ID and Time
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #${order.id.substring(0, 8)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (order.estimatedDeliveryTime != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_getMinutesUntil(order.estimatedDeliveryTime!)} ${context.l10n.min}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Restaurant Info
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.restaurant,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.pickupFrom,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          order.restaurantName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Customer Location
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.location_on,
                      color: AppColors.accent,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.deliverTo,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          order.deliveryAddress.addressLine,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Delivery Fee
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.l10n.deliveryFee,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    CurrencyFormatter.formatPrice(order.deliveryFee, context),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Divider(color: AppColors.border),
              const SizedBox(height: 8),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onReject,
                      icon: const Icon(Icons.close, size: 18),
                      label: Text(
                        context.l10n.rejectOrder,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: onAccept,
                      icon: const Icon(Icons.check, size: 20),
                      label: Text(
                        context.l10n.acceptOrder,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: AppColors.textPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
