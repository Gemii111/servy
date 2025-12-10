import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../logic/providers/favorites_providers.dart';
import '../../widgets/home/restaurant_card.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Favorites Section Widget for Home Screen
class FavoritesSectionWidget extends ConsumerWidget {
  const FavoritesSectionWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);
    final favoritesAsync = ref.watch(favoriteRestaurantsProvider);

    // Hide section if no favorites
    if (favorites.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.l10n.favoriteRestaurants,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  context.push('/customer/favorites');
                },
                child: Text(
                  context.l10n.seeAll,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        favoritesAsync.when(
          data: (favoriteRestaurants) {
            if (favoriteRestaurants.isEmpty) {
              return const SizedBox.shrink();
            }

            // Show first 3 favorites horizontally
            final displayFavorites = favoriteRestaurants.take(3).toList();

            return SizedBox(
              height: 380, // Increased to accommodate card content
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: displayFavorites.length,
                itemBuilder: (context, index) {
                  final restaurant = displayFavorites[index];
                  return Container(
                    width: 280,
                    margin: const EdgeInsets.only(right: 16),
                    child: RestaurantCard(
                      restaurant: restaurant,
                      onTap: () {
                        context.push('/restaurant/${restaurant.id}');
                      },
                    ),
                  ).animate().fadeIn(delay: (50 * index).ms).slideX();
                },
              ),
            );
          },
          loading:
              () => const SizedBox(
                height: 200,
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
          error:
              (error, stack) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Center(
                  child: Text(
                    context.l10n.failedToLoad,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ),
        ),
      ],
    );
  }
}
