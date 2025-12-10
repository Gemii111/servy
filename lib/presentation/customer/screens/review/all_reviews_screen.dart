import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../logic/providers/rating_providers.dart';
import '../../widgets/ratings/review_card_widget.dart';
import '../../widgets/common/loading_state_widget.dart';
import '../../widgets/common/empty_state_widget.dart';

/// All Reviews Screen - Display all reviews for a restaurant
class AllReviewsScreen extends ConsumerStatefulWidget {
  const AllReviewsScreen({
    super.key,
    required this.restaurantId,
    this.restaurantName,
  });

  final String restaurantId;
  final String? restaurantName;

  @override
  ConsumerState<AllReviewsScreen> createState() => _AllReviewsScreenState();
}

class _AllReviewsScreenState extends ConsumerState<AllReviewsScreen> {
  String _selectedFilter = 'all'; // 'all', '5', '4', '3', '2', '1'
  String _sortBy = 'newest'; // 'newest', 'oldest', 'highest', 'lowest'

  List<dynamic> _filterAndSortReviews(List<dynamic> reviews) {
    var filtered = reviews;

    // Filter by rating
    if (_selectedFilter != 'all') {
      final rating = int.parse(_selectedFilter);
      filtered = filtered.where((r) => r.rating.round() == rating).toList();
    }

    // Sort reviews
    switch (_sortBy) {
      case 'newest':
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'oldest':
        filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case 'highest':
        filtered.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'lowest':
        filtered.sort((a, b) => a.rating.compareTo(b.rating));
        break;
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final ratingsSummaryAsync = ref.watch(
      restaurantRatingSummaryProvider(widget.restaurantId),
    );
    final ratingsAsync = ref.watch(
      restaurantRatingsProvider(widget.restaurantId),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.card,
        elevation: 0,
        title: Text(
          widget.restaurantName != null
              ? '${l10n.reviews} - ${widget.restaurantName}'
              : l10n.allReviews,
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: Column(
        children: [
          // Filters and Sort
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.card,
            child: Column(
              children: [
                // Rating Filter
                SizedBox(
                  height: 50,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _FilterChip(
                        label: l10n.all,
                        isSelected: _selectedFilter == 'all',
                        onTap: () => setState(() => _selectedFilter = 'all'),
                      ),
                      const SizedBox(width: 8),
                      ...List.generate(5, (index) {
                        final rating = 5 - index;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _FilterChip(
                            label: '$rating ⭐',
                            isSelected: _selectedFilter == '$rating',
                            onTap:
                                () =>
                                    setState(() => _selectedFilter = '$rating'),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Sort Options
                Row(
                  children: [
                    Text(
                      '${l10n.sortReviews}: ',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    Expanded(
                      child: DropdownButton<String>(
                        value: _sortBy,
                        isExpanded: true,
                        underline: const SizedBox(),
                        items: [
                          DropdownMenuItem(
                            value: 'newest',
                            child: Text(l10n.newestFirst),
                          ),
                          DropdownMenuItem(
                            value: 'oldest',
                            child: Text(l10n.oldestFirst),
                          ),
                          DropdownMenuItem(
                            value: 'highest',
                            child: Text(l10n.highestRated),
                          ),
                          DropdownMenuItem(
                            value: 'lowest',
                            child: Text(l10n.lowestRated),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _sortBy = value);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Reviews List
          Expanded(
            child: ratingsAsync.when(
              data: (ratings) {
                final filteredAndSorted = _filterAndSortReviews(ratings);

                if (filteredAndSorted.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.star_border,
                    title: l10n.noReviewsYet,
                    message:
                        _selectedFilter != 'all'
                            ? '${l10n.noReviewsYet} (${l10n.filterByRating})'
                            : l10n.beTheFirstToReview,
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredAndSorted.length,
                  itemBuilder: (context, index) {
                    final review = filteredAndSorted[index];
                    return ReviewCardWidget(
                      review: review,
                      showActions: true,
                      onHelpful: () {
                        // TODO: Implement helpful feature
                      },
                      onReport: () {
                        // TODO: Implement report feature
                      },
                    );
                  },
                );
              },
              loading: () => const LoadingStateWidget(),
              error:
                  (error, stack) => Center(
                    child: Text(
                      '${l10n.failedToLoad}: ${error.toString()}',
                      style: const TextStyle(color: AppColors.error),
                    ),
                  ),
            ),
          ),
          // Rating Summary Footer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.card,
              boxShadow: [
                BoxShadow(
                  color: AppColors.border.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: ratingsSummaryAsync.when(
              data: (summary) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          summary.averageRating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          l10n.averageRating,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Container(width: 1, height: 40, color: AppColors.border),
                    Column(
                      children: [
                        Text(
                          '${summary.totalRatings}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          l10n.totalReviews,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}

/// Filter Chip Widget
class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color:
              isSelected ? AppColors.primary.withOpacity(0.2) : AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
