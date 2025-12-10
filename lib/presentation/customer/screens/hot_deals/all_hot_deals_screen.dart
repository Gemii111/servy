import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../logic/providers/restaurant_providers.dart';
import '../../widgets/home/hot_deal_card_full_width.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/common/loading_state_widget.dart';
import '../../widgets/common/error_state_widget.dart';
import '../../widgets/common/cart_app_bar_icon.dart';

/// All Hot Deals Screen - Display all hot deals/offers
class AllHotDealsScreen extends ConsumerWidget {
  const AllHotDealsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final restaurantsAsync = ref.watch(restaurantsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.card,
        elevation: 0,
        title: Text(
          l10n.hotDeals,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        actions: const [
          CartAppBarIcon(),
        ],
      ),
      body: restaurantsAsync.when(
        data: (restaurants) {
          if (restaurants.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.local_offer_outlined,
              title: l10n.noHotDeals,
              message: 'No hot deals available at the moment',
            );
          }

          // Generate discount percentages for each restaurant
          final hotDeals =
              restaurants.asMap().entries.map((entry) {
                final index = entry.key;
                final restaurant = entry.value;
                final discountPercent =
                    (index % 5 + 1) * 10; // 10%, 20%, 30%, 40%, 50%
                return {'restaurant': restaurant, 'discount': discountPercent};
              }).toList();

          return RefreshIndicator(
            color: AppColors.primary,
            backgroundColor: AppColors.surface,
            onRefresh: () async {
              try {
                // Clear any active search first
                final restaurantsNotifier = ref.read(restaurantsProvider.notifier);
                restaurantsNotifier.clearSearch();
                
                // Refresh restaurants
                await restaurantsNotifier.refresh(isFeatured: true);
              } catch (e) {
                // Error handling - state will show error if needed
                rethrow;
              }
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: hotDeals.length,
              itemBuilder: (context, index) {
                final deal = hotDeals[index];
                final restaurant = deal['restaurant'] as dynamic;
                final discount = deal['discount'] as int;

                return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: HotDealCardFullWidth(
                        restaurant: restaurant,
                        discountPercent: discount,
                      ),
                    )
                    .animate()
                    .fadeIn(delay: (50 * index).ms)
                    .slideY(begin: 0.1, end: 0);
              },
            ),
          );
        },
        loading: () => const LoadingStateWidget(),
        error:
            (error, stack) => ErrorStateWidget(
              message: l10n.failedToLoad,
              error: error.toString(),
              onRetry: () {
                ref.invalidate(restaurantsProvider);
              },
            ),
      ),
    );
  }
}
