import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../data/models/restaurant_model.dart';
import '../../../../logic/providers/restaurant_providers.dart';
import '../../../../logic/providers/rating_providers.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../widgets/ratings/review_card_widget.dart';
import '../../widgets/common/loading_state_widget.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/common/cart_app_bar_icon.dart';

/// Restaurant details screen
class RestaurantDetailsScreen extends ConsumerWidget {
  const RestaurantDetailsScreen({super.key, required this.restaurantId});

  final String restaurantId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restaurantAsync = ref.watch(restaurantByIdProvider(restaurantId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: restaurantAsync.when(
        data: (restaurant) {
          if (restaurant == null) {
            return _buildError(context, 'Restaurant not found');
          }
          return _buildContent(context, restaurant);
        },
        loading:
            () => const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
        error:
            (error, stack) => _buildError(context, 'Failed to load restaurant'),
      ),
    );
  }

  Widget _buildContent(BuildContext context, RestaurantModel restaurant) {
    return CustomScrollView(
      slivers: [
        // App Bar with image
        SliverAppBar(
          expandedHeight: 250,
          pinned: true,
          backgroundColor: AppColors.card,
          flexibleSpace: FlexibleSpaceBar(
            background: CachedNetworkImage(
              imageUrl: restaurant.imageUrl,
              fit: BoxFit.cover,
              placeholder:
                  (context, url) => Container(
                    color: AppColors.surface,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
              errorWidget:
                  (context, url, error) => Container(
                    color: AppColors.surface,
                    child: const Icon(Icons.error, color: AppColors.error),
                  ),
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/customer/home');
              }
            },
          ),
          actions: const [
            CartAppBarIcon(),
          ],
        ),
        // Restaurant Info
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name and Rating
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        restaurant.name,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.warning),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star,
                            color: AppColors.warning,
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            restaurant.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.warning,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Cuisine Type
                Text(
                  restaurant.cuisineType,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                // Description
                Text(
                  restaurant.description,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                // Info Cards
                Row(
                  children: [
                    Expanded(
                      child: _InfoCard(
                        icon: Icons.access_time,
                        title:
                            '${restaurant.deliveryTime.toInt()} ${context.l10n.min}',
                        subtitle: context.l10n.delivery,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _InfoCard(
                        icon: Icons.delivery_dining,
                        title: CurrencyFormatter.formatPrice(
                          restaurant.deliveryFee,
                          context,
                        ),
                        subtitle: context.l10n.deliveryFee,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _InfoCard(
                        icon: Icons.location_on,
                        title:
                            '${restaurant.distance.toStringAsFixed(1)} ${context.l10n.km}',
                        subtitle: context.l10n.distance,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color:
                        restaurant.isOpen
                            ? AppColors.success.withOpacity(0.2)
                            : AppColors.error.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color:
                          restaurant.isOpen
                              ? AppColors.success
                              : AppColors.error,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color:
                              restaurant.isOpen
                                  ? AppColors.success
                                  : AppColors.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        restaurant.isOpen
                            ? (context.l10n.open)
                            : (context.l10n.closed),
                        style: TextStyle(
                          color:
                              restaurant.isOpen
                                  ? AppColors.success
                                  : AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                // Closed Message
                if (!restaurant.isOpen) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.error.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.info_outline,
                            color: AppColors.error,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            context.l10n.restaurantClosedMessage,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                // View Menu Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: restaurant.isOpen
                        ? () {
                            context.push('/restaurant/$restaurantId/menu');
                          }
                        : null, // Disable button if closed
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textPrimary,
                      disabledBackgroundColor: AppColors.textSecondary.withOpacity(0.3),
                      disabledForegroundColor: AppColors.textSecondary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text(
                      'View Menu',
                      style: TextStyle(
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
        // Reviews Section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ReviewsSection(
                  restaurantId: restaurantId,
                  restaurantName: restaurant.name,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppColors.error),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // لو في شاشة جوه الـ stack نرجع لها
              if (context.canPop()) {
                context.pop();
              } else {
                // مؤقتاً: نرجّع المستخدم لشاشة اختيار نوع المستخدم
                context.go('/user-type-login');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textPrimary,
            ),
            child: Text(context.l10n.goBack),
          ),
        ],
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [AppColors.cardShadow],
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// Reviews Section Widget
class _ReviewsSection extends ConsumerWidget {
  const _ReviewsSection({
    required this.restaurantId,
    required this.restaurantName,
  });

  final String restaurantId;
  final String restaurantName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final ratingsSummaryAsync = ref.watch(
      restaurantRatingSummaryProvider(restaurantId),
    );
    final ratingsAsync = ref.watch(restaurantRatingsProvider(restaurantId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.ratingsAndReviews,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () {
                context.push(
                  '/restaurant/$restaurantId/reviews?name=${Uri.encodeComponent(restaurantName)}',
                );
              },
              child: Text(l10n.viewAll),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Rating Summary
        ratingsSummaryAsync.when(
          data: (summary) {
            if (summary.totalRatings == 0) {
              return EmptyStateWidget(
                icon: Icons.star_border,
                title: l10n.noReviewsYet,
                message: l10n.beTheFirstToReview,
              );
            }
            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [AppColors.cardShadow],
                  ),
                  child: Row(
                    children: [
                      // Average Rating
                      Column(
                        children: [
                          Text(
                            summary.averageRating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          Row(
                            children: List.generate(5, (index) {
                              return Icon(
                                index < summary.averageRating.round()
                                    ? Icons.star
                                    : Icons.star_border,
                                color: AppColors.warning,
                                size: 20,
                              );
                            }),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${summary.totalRatings} ${l10n.reviews.toLowerCase()}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 24),
                      // Rating Distribution
                      Expanded(
                        child: Column(
                          children:
                              [5, 4, 3, 2, 1].map((stars) {
                                final count =
                                    summary.ratingDistribution[stars] ?? 0;
                                final percentage =
                                    summary.totalRatings > 0
                                        ? (count / summary.totalRatings) * 100
                                        : 0.0;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 12,
                                        child: Text(
                                          '$stars',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ),
                                      const Icon(
                                        Icons.star,
                                        size: 16,
                                        color: AppColors.warning,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: LinearProgressIndicator(
                                          value: percentage / 100,
                                          backgroundColor: AppColors.border
                                              .withOpacity(0.2),
                                          valueColor:
                                              const AlwaysStoppedAnimation<
                                                Color
                                              >(AppColors.warning),
                                          minHeight: 8,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '$count',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Recent Reviews
                Text(
                  l10n.allReviews,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                ratingsAsync.when(
                  data: (ratings) {
                    if (ratings.isEmpty) {
                      return EmptyStateWidget(
                        icon: Icons.star_border,
                        title: l10n.noReviewsYet,
                        message: l10n.beTheFirstToReview,
                      );
                    }
                    // Show first 3 reviews
                    final recentReviews = ratings.take(3).toList();
                    return Column(
                      children:
                          recentReviews
                              .map(
                                (review) => ReviewCardWidget(
                                  review: review,
                                  showActions: false,
                                ),
                              )
                              .toList(),
                    );
                  },
                  loading: () => const LoadingStateWidget(),
                  error:
                      (error, stack) => Text(
                        '${l10n.failedToLoad}: ${error.toString()}',
                        style: const TextStyle(color: AppColors.error),
                      ),
                ),
              ],
            );
          },
          loading: () => const LoadingStateWidget(),
          error:
              (error, stack) => Text(
                '${l10n.failedToLoad}: ${error.toString()}',
                style: const TextStyle(color: AppColors.error),
              ),
        ),
      ],
    );
  }
}
