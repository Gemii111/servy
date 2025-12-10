import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../logic/providers/menu_providers.dart';
import '../../../../logic/providers/restaurant_providers.dart';
import '../../../../logic/providers/cart_providers.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/common/loading_state_widget.dart';
import '../../widgets/common/error_state_widget.dart';
import '../../widgets/common/skeleton_loaders.dart';
import '../../widgets/common/cart_app_bar_icon.dart';

/// Menu screen showing restaurant menu
class MenuScreen extends ConsumerWidget {
  const MenuScreen({
    super.key,
    required this.restaurantId,
  });

  final String restaurantId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuAsync = ref.watch(menuProvider(restaurantId));
    final restaurantAsync = ref.watch(restaurantByIdProvider(restaurantId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: restaurantAsync.when(
          data: (restaurant) => Text(
            restaurant?.name ?? context.l10n.menu,
            style: const TextStyle(color: AppColors.textPrimary),
          ),
          loading: () => Text(
            context.l10n.menu,
            style: const TextStyle(color: AppColors.textPrimary),
          ),
          error: (_, __) => Text(
            context.l10n.menu,
            style: const TextStyle(color: AppColors.textPrimary),
          ),
        ),
        actions: const [
          CartAppBarIcon(),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        onRefresh: () async {
          ref.invalidate(menuProvider(restaurantId));
        },
        child: menuAsync.when(
          data: (menu) {
            if (menu.categories.isEmpty) {
              return EmptyStateWidget(
                icon: Icons.restaurant_menu_outlined,
                title: context.l10n.noMenuItemsAvailable,
                message: 'No menu items available at this time',
              );
            }
            return _buildMenuContent(context, ref, menu);
          },
        loading: () => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: 5,
          itemBuilder: (context, index) => const MenuItemSkeleton(),
        ),
          error: (error, stack) => ErrorStateWidget(
            message: context.l10n.failedToLoadMenu,
            error: error.toString(),
            showGoBack: true,
          ),
        ),
      ),
    );
  }

  Widget _buildMenuContent(BuildContext context, WidgetRef ref, menu) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: menu.categories.length,
      cacheExtent: 500, // Preload items for smoother scrolling
      itemBuilder: (context, index) {
        final category = menu.categories[index];
        return _MenuCategorySection(
          category: category,
          restaurantId: restaurantId,
          onItemTap: (item) {
            _showAddToCartDialog(context, ref, item, restaurantId);
          },
        );
      },
    );
  }

  void _showAddToCartDialog(BuildContext context, WidgetRef ref, item, String restaurantId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        title: Text(
          item.name,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.description.isNotEmpty) ...[
              Text(
                item.description,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
            ],
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Price:',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    CurrencyFormatter.formatPrice(item.price, context),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
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
          ElevatedButton(
            onPressed: () async {
              await ref.read(cartProvider.notifier).addItem(
                    restaurantId: restaurantId,
                    menuItem: item,
                  );
              if (dialogContext.mounted) {
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(
                    content: Text(context.l10n.itemAddedToCart),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(context.l10n.addToCart),
          ),
        ],
      ),
    );
  }
}

/// Menu category section widget
class _MenuCategorySection extends StatelessWidget {
  const _MenuCategorySection({
    required this.category,
    required this.restaurantId,
    required this.onItemTap,
  });

  final category;
  final String restaurantId;
  final Function(dynamic) onItemTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            category.name,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
          ),
        ),
        ...category.items.map((item) => _MenuItemCard(
              item: item,
              onTap: () => onItemTap(item),
            )),
        const SizedBox(height: 24),
      ],
    );
  }
}

/// Menu item card widget
class _MenuItemCard extends StatelessWidget {
  const _MenuItemCard({
    required this.item,
    required this.onTap,
  });

  final item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
          boxShadow: [AppColors.cardShadow],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            if (item.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: item.imageUrl!,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 80,
                    height: 80,
                    color: AppColors.surface,
                    child: const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 80,
                    height: 80,
                    color: AppColors.surface,
                    child: const Icon(
                      Icons.image_not_supported,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            if (item.imageUrl != null) const SizedBox(width: 12),
            // Content
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
                  if (item.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        CurrencyFormatter.formatPrice(item.price, context),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      if (!item.isAvailable) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            context.l10n.outOfStock,
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.error,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // Add button
            if (item.isAvailable)
              Container(
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.add_circle),
                  color: AppColors.primary,
                  onPressed: onTap,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

