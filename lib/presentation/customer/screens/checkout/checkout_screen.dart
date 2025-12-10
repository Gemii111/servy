import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../logic/providers/cart_providers.dart';
import '../../../../logic/providers/address_providers.dart';
import '../../../../logic/providers/auth_providers.dart';
import '../../../../logic/providers/order_providers.dart';
import '../../../../logic/providers/restaurant_providers.dart';
import '../../../../data/models/address_model.dart';
import '../../../../data/models/restaurant_model.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../widgets/common/loading_state_widget.dart';

/// Checkout screen
class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  String _selectedPaymentMethod = 'cash';
  String? _couponCode;
  double? _discount;
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final user = ref.watch(currentUserProvider);
    final selectedAddress = ref.watch(selectedAddressProvider);

    // Get restaurant for delivery fee
    final restaurantId = cart.isNotEmpty ? cart.first.restaurantId : null;
    final restaurantAsync =
        restaurantId != null
            ? ref.watch(restaurantByIdProvider(restaurantId))
            : const AsyncValue<RestaurantModel?>.data(null);

    // Calculate total with discount
    final deliveryFee = restaurantAsync.when(
      data: (restaurant) => restaurant?.deliveryFee ?? 5.0,
      loading: () => 5.0,
      error: (_, __) => 5.0,
    );
    final total = _calculateTotal(cart, deliveryFee, _discount);

    if (user == null) {
      // Guest user - show login/register dialog
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(context.l10n.checkout),
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => context.pop(),
          ),
        ),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 80,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    context.l10n.pleaseRegisterToCheckout,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    context.l10n.youMustLoginToCheckout,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _showLoginRegisterDialog(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        context.l10n.loginOrRegisterToCheckout,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => context.pop(),
                    child: Text(
                      context.l10n.cancel,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final addressesAsync = ref.watch(userAddressesProvider(user.id));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          context.l10n.checkout,
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body:
          cart.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.shopping_cart_outlined,
                      size: 64,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      context.l10n.cartIsEmpty,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Delivery Address Section
                    _SectionTitle(title: 'Delivery Address'),
                    const SizedBox(height: 12),
                    addressesAsync.when(
                      data: (addresses) {
                        // Auto-select default address if not selected
                        if (selectedAddress == null && addresses.isNotEmpty) {
                          final defaultAddress = addresses.firstWhere(
                            (addr) => addr.isDefault,
                            orElse: () => addresses.first,
                          );
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            ref.read(selectedAddressProvider.notifier).state =
                                defaultAddress;
                          });
                        }

                        if (addresses.isEmpty) {
                          return _AddAddressCard(
                            onTap: () async {
                              await context.push('/add-address');
                              // Refresh addresses after adding
                              if (context.mounted) {
                                ref.invalidate(userAddressesProvider(user.id));
                              }
                            },
                          );
                        }
                        return Column(
                          children: [
                            ...addresses.map(
                              (address) => _AddressCard(
                                address: address,
                                isSelected: selectedAddress?.id == address.id,
                                onTap: () {
                                  ref
                                      .read(selectedAddressProvider.notifier)
                                      .state = address;
                                },
                              ),
                            ),
                            const SizedBox(height: 8),
                            _AddAddressCard(
                              onTap: () async {
                                await context.push('/add-address');
                                // Refresh addresses after adding
                                if (context.mounted) {
                                  ref.invalidate(
                                    userAddressesProvider(user.id),
                                  );
                                }
                              },
                            ),
                          ],
                        );
                      },
                      loading: () => const LoadingStateWidget(),
                      error:
                          (error, stack) => Text(
                            context.l10n.failedToLoadAddresses,
                            style: const TextStyle(color: AppColors.error),
                          ),
                    ),
                    const SizedBox(height: 24),
                    // Payment Method Section
                    _SectionTitle(title: context.l10n.paymentMethod),
                    const SizedBox(height: 12),
                    _PaymentMethodCard(
                      method: 'cash',
                      title: context.l10n.cashOnDelivery,
                      icon: Icons.money,
                      isSelected: _selectedPaymentMethod == 'cash',
                      onTap: () {
                        setState(() => _selectedPaymentMethod = 'cash');
                      },
                    ),
                    const SizedBox(height: 8),
                    _PaymentMethodCard(
                      method: 'card',
                      title: context.l10n.creditCard,
                      icon: Icons.credit_card,
                      isSelected: _selectedPaymentMethod == 'card',
                      onTap: () {
                        setState(() => _selectedPaymentMethod = 'card');
                      },
                    ),
                    const SizedBox(height: 24),
                    // Coupon Section
                    _SectionTitle(title: context.l10n.couponDiscount),
                    const SizedBox(height: 12),
                    _CouponSection(
                      couponCode: _couponCode,
                      discount: _discount,
                      onApplyCoupon: (code) {
                        setState(() {
                          _couponCode = code;
                          _discount =
                              10.0; // Mock discount - TODO: Validate via API
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              context.l10n.couponAppliedSuccessfully,
                            ),
                          ),
                        );
                      },
                      onRemoveCoupon: () {
                        setState(() {
                          _couponCode = null;
                          _discount = null;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    // Order Notes Section
                    _SectionTitle(title: context.l10n.orderNotes),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _notesController,
                      maxLines: 3,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: context.l10n.specialInstructions,
                        hintStyle: const TextStyle(
                          color: AppColors.textTertiary,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: AppColors.surface,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Order Summary Section
                    _SectionTitle(title: context.l10n.orderSummary),
                    const SizedBox(height: 12),
                    _OrderSummaryCard(
                      cart: cart,
                      total: total,
                      deliveryFee: deliveryFee,
                      discount: _discount,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
      bottomNavigationBar:
          cart.isEmpty
              ? null
              : Container(
                padding: const EdgeInsets.all(16),
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
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            context.l10n.total,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            CurrencyFormatter.formatPrice(
                              _calculateTotal(cart, deliveryFee, _discount),
                              context,
                            ),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              selectedAddress == null
                                  ? null
                                  : () {
                                    // TODO: Place order
                                    _placeOrder(context);
                                  },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.textPrimary,
                            disabledBackgroundColor: AppColors.border,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            context.l10n.placeOrder,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  double _calculateTotal(List cart, double deliveryFee, double? discount) {
    final subtotal = cart.fold<double>(0, (sum, item) => sum + item.totalPrice);
    final tax = subtotal * 0.15; // 15% VAT
    final discountAmount = discount ?? 0.0;
    final total = subtotal + deliveryFee + tax - discountAmount;
    return total > 0 ? total : 0;
  }

  Future<void> _placeOrder(BuildContext context) async {
    final cart = ref.read(cartProvider);
    final user = ref.read(currentUserProvider);
    final selectedAddress = ref.read(selectedAddressProvider);

    if (user == null || selectedAddress == null || cart.isEmpty) {
      return;
    }

    final restaurantId = cart.first.restaurantId;
    final restaurant = await ref.read(
      restaurantByIdProvider(restaurantId).future,
    );

    if (restaurant == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.restaurantNotFound)),
        );
      }
      return;
    }

    // Check if restaurant is online
    if (!restaurant.isOnline) {
      if (context.mounted) {
        _showRestaurantOfflineDialog(context);
      }
      return;
    }

    // Calculate subtotal
    final subtotal = cart.fold<double>(0, (sum, item) => sum + item.totalPrice);
    final deliveryFee = restaurant.deliveryFee;
    final tax = subtotal * 0.15; // 15% VAT
    final discountAmount = _discount ?? 0.0;
    final total = (subtotal + deliveryFee + tax - discountAmount).clamp(
      0.0,
      double.infinity,
    );

    try {
      final orderNotifier = ref.read(orderProvider.notifier);
      await orderNotifier.placeOrder(
        userId: user.id,
        restaurantId: restaurantId,
        restaurantName: restaurant.name,
        items: cart,
        deliveryAddress: selectedAddress,
        subtotal: subtotal,
        deliveryFee: deliveryFee,
        total: total,
        paymentMethod: _selectedPaymentMethod,
        discount: _discount,
        notes:
            _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
      );

      if (context.mounted) {
        // Clear cart
        ref.read(cartProvider.notifier).clearCart();
        // Navigate to order confirmation
        context.go('/order-confirmation');
      }
    } catch (e) {
      if (context.mounted) {
        // Check if error is restaurant offline
        if (e.toString().contains('RESTAURANT_OFFLINE')) {
          _showRestaurantOfflineDialog(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${context.l10n.failedToPlaceOrder}: $e')),
          );
        }
      }
    }
  }

  void _showRestaurantOfflineDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: Row(
          children: [
            Icon(
              Icons.store_outlined,
              color: AppColors.warning,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                context.l10n.restaurantNotActive,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.l10n.restaurantWillBeActiveSoon,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
            child: Text(
              context.l10n.ok,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLoginRegisterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: Text(
          context.l10n.loginOrRegisterToCheckout,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.l10n.pleaseRegisterToCheckout,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  context.push('/register?type=customer');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  context.l10n.register,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  context.push('/login?type=customer');
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppColors.primary, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  context.l10n.login,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              context.l10n.cancel,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
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

/// Address card widget
class _AddressCard extends StatelessWidget {
  const _AddressCard({
    required this.address,
    required this.isSelected,
    required this.onTap,
  });

  final AddressModel address;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Radio<AddressModel>(
              value: address,
              groupValue: isSelected ? address : null,
              onChanged: (_) => onTap(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    address.label,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    address.fullAddress,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            if (address.isDefault)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  context.l10n.defaultAddress,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.accent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Add address card widget
class _AddAddressCard extends StatelessWidget {
  const _AddAddressCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border, style: BorderStyle.solid),
        ),
        child: Row(
          children: [
            const Icon(Icons.add_location_alt, color: AppColors.primary),
            const SizedBox(width: 12),
            Text(
              context.l10n.addNewAddress,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Payment method card widget
class _PaymentMethodCard extends StatelessWidget {
  const _PaymentMethodCard({
    required this.method,
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String method;
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color:
                      isSelected
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                ),
              ),
            ),
            Radio<String>(
              value: method,
              groupValue: isSelected ? method : null,
              onChanged: (_) => onTap(),
            ),
          ],
        ),
      ),
    );
  }
}

/// Order summary card widget
class _OrderSummaryCard extends StatelessWidget {
  const _OrderSummaryCard({
    required this.cart,
    required this.total,
    required this.deliveryFee,
    this.discount,
  });

  final List cart;
  final double total;
  final double deliveryFee;
  final double? discount;

  @override
  Widget build(BuildContext context) {
    final subtotal = cart.fold<double>(0, (sum, item) => sum + item.totalPrice);
    final tax = subtotal * 0.15; // 15% VAT

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [AppColors.cardShadow],
      ),
      child: Column(
        children: [
          _SummaryRow(
            label: context.l10n.subtotal,
            value: CurrencyFormatter.formatPrice(subtotal, context),
          ),
          const SizedBox(height: 8),
          _SummaryRow(
            label: context.l10n.deliveryFee,
            value: CurrencyFormatter.formatPrice(deliveryFee, context),
          ),
          const SizedBox(height: 8),
          _SummaryRow(
            label: '${context.l10n.tax} (15%)',
            value: CurrencyFormatter.formatPrice(tax, context),
          ),
          if (discount != null && discount! > 0) ...[
            const SizedBox(height: 8),
            _SummaryRow(
              label: context.l10n.discount,
              value: '-${CurrencyFormatter.formatPrice(discount!, context)}',
              valueColor: AppColors.success,
            ),
          ],
          const Divider(height: 24),
          _SummaryRow(
            label: context.l10n.total,
            value: CurrencyFormatter.formatPrice(total, context),
            isTotal: true,
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
    this.valueColor,
  });

  final String label;
  final String value;
  final bool isTotal;
  final Color? valueColor;

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
            color:
                valueColor ??
                (isTotal ? AppColors.primary : AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}

/// Coupon section widget
class _CouponSection extends StatefulWidget {
  const _CouponSection({
    required this.couponCode,
    required this.discount,
    required this.onApplyCoupon,
    required this.onRemoveCoupon,
  });

  final String? couponCode;
  final double? discount;
  final Function(String) onApplyCoupon;
  final VoidCallback onRemoveCoupon;

  @override
  State<_CouponSection> createState() => _CouponSectionState();
}

class _CouponSectionState extends State<_CouponSection> {
  final TextEditingController _couponController = TextEditingController();

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.couponCode != null && widget.discount != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.success.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.success),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.success),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${context.l10n.couponApplied}: ${widget.couponCode}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                    ),
                  ),
                  Text(
                    '${context.l10n.discount}: ${CurrencyFormatter.formatPrice(widget.discount!, context)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: widget.onRemoveCoupon,
              color: AppColors.success,
            ),
          ],
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _couponController,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: context.l10n.enterCouponCode,
              hintStyle: const TextStyle(color: AppColors.textTertiary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: AppColors.surface,
            ),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () {
            final code = _couponController.text.trim();
            if (code.isNotEmpty) {
              widget.onApplyCoupon(code);
              _couponController.clear();
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
          child: Text(context.l10n.apply),
        ),
      ],
    );
  }
}
