import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../logic/providers/favorites_providers.dart';
import '../../widgets/home/restaurant_card.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/common/loading_state_widget.dart';
import '../../widgets/common/error_state_widget.dart';
import '../../widgets/common/cart_app_bar_icon.dart';

/// All Favorites Screen - Display all favorite restaurants
class AllFavoritesScreen extends ConsumerWidget {
  const AllFavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final favoritesAsync = ref.watch(favoriteRestaurantsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.card,
        elevation: 0,
        title: Text(
          l10n.favoriteRestaurants,
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
      body: favoritesAsync.when(
        data: (favoriteRestaurants) {
          if (favoriteRestaurants.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.favorite_border,
              title: l10n.noFavoritesYet,
              message: 'Start adding restaurants to your favorites!',
            );
          }

          return RefreshIndicator(
            color: AppColors.primary,
            backgroundColor: AppColors.surface,
            onRefresh: () async {
              // Invalidate and wait for refresh
              ref.invalidate(favoriteRestaurantsProvider);
              // Wait for the provider to refresh
              await ref.read(favoriteRestaurantsProvider.future);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: favoriteRestaurants.length,
              itemBuilder: (context, index) {
                final restaurant = favoriteRestaurants[index];
                return RestaurantCard(
                  restaurant: restaurant,
                  onTap: () {
                    context.push('/restaurant/${restaurant.id}');
                  },
                )
                    .animate()
                    .fadeIn(delay: (50 * index).ms)
                    .slideY(begin: 0.1, end: 0);
              },
            ),
          );
        },
        loading: () => const LoadingStateWidget(),
        error: (error, stack) => ErrorStateWidget(
          message: l10n.failedToLoad,
          error: error.toString(),
          onRetry: () {
            ref.invalidate(favoriteRestaurantsProvider);
          },
        ),
      ),
    );
  }
}

