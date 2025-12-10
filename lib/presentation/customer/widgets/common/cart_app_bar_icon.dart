import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../logic/providers/cart_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../cart/cart_bottom_sheet.dart';

/// Cart icon button for AppBar
/// Shows cart badge with item count
/// Opens cart bottom sheet when tapped
class CartAppBarIcon extends ConsumerWidget {
  const CartAppBarIcon({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartCount = ref.watch(cartItemCountProvider);

    // Don't show if cart is empty
    if (cartCount == 0) {
      return const SizedBox.shrink();
    }

    return IconButton(
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(
            Icons.shopping_cart_outlined,
            color: AppColors.textPrimary,
          ),
          Positioned(
            right: -8,
            top: -8,
            child: Container(
              padding: cartCount > 99
                  ? const EdgeInsets.symmetric(horizontal: 4, vertical: 2)
                  : const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: cartCount > 99
                    ? BoxShape.rectangle
                    : BoxShape.circle,
                borderRadius: cartCount > 99
                    ? BorderRadius.circular(8)
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.5),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              constraints: const BoxConstraints(
                minWidth: 20,
                minHeight: 20,
              ),
              child: Center(
                child: Text(
                  cartCount > 99 ? '99+' : '$cartCount',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
      onPressed: () {
        showCartBottomSheet(context);
      },
      tooltip: 'View Cart',
    );
  }
}

