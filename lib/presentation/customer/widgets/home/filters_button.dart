import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../logic/providers/restaurant_filters_providers.dart';

/// Filters button widget showing active filters count
class FiltersButton extends ConsumerWidget {
  const FiltersButton({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeFiltersCount =
        ref.watch(restaurantFiltersProvider).activeFiltersCount;

    return InkWell(
      onTap: onTap ?? () => _showFiltersDialog(context, ref),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color:
              activeFiltersCount > 0
                  ? AppColors.primary.withOpacity(0.2)
                  : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                activeFiltersCount > 0 ? AppColors.primary : AppColors.border,
            width: activeFiltersCount > 0 ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.tune,
              size: 18,
              color:
                  activeFiltersCount > 0
                      ? AppColors.primary
                      : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              context.l10n.filters,
              style: TextStyle(
                fontSize: 14,
                fontWeight:
                    activeFiltersCount > 0 ? FontWeight.w600 : FontWeight.w500,
                color:
                    activeFiltersCount > 0
                        ? AppColors.primary
                        : AppColors.textSecondary,
              ),
            ),
            if (activeFiltersCount > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$activeFiltersCount',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showFiltersDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => _FiltersBottomSheet(ref: ref),
    );
  }
}

/// Filters bottom sheet content
class _FiltersBottomSheet extends ConsumerStatefulWidget {
  const _FiltersBottomSheet({required this.ref});

  final WidgetRef ref;

  @override
  ConsumerState<_FiltersBottomSheet> createState() =>
      _FiltersBottomSheetState();
}

class _FiltersBottomSheetState extends ConsumerState<_FiltersBottomSheet> {
  late RestaurantFilters _filters;

  @override
  void initState() {
    super.initState();
    _filters = widget.ref.read(restaurantFiltersProvider);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.l10n.filters,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _filters = _filters.clear();
                  });
                  widget.ref
                      .read(restaurantFiltersProvider.notifier)
                      .clearFilters();
                },
                child: Text(
                  context.l10n.reset,
                  style: const TextStyle(color: AppColors.error),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Sort By
          Text(
            context.l10n?.sortBy ?? 'Sort By',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              _FilterChip(
                label: context.l10n.distance,
                isSelected: _filters.sortBy == 'distance',
                onTap: () {
                  setState(() {
                    _filters = _filters.copyWith(
                      sortBy: _filters.sortBy == 'distance' ? null : 'distance',
                    );
                  });
                },
              ),
              _FilterChip(
                label: context.l10n.rating,
                isSelected: _filters.sortBy == 'rating',
                onTap: () {
                  setState(() {
                    _filters = _filters.copyWith(
                      sortBy: _filters.sortBy == 'rating' ? null : 'rating',
                    );
                  });
                },
              ),
              _FilterChip(
                label: context.l10n.deliveryTime,
                isSelected: _filters.sortBy == 'delivery_time',
                onTap: () {
                  setState(() {
                    _filters = _filters.copyWith(
                      sortBy:
                          _filters.sortBy == 'delivery_time'
                              ? null
                              : 'delivery_time',
                    );
                  });
                },
              ),
              _FilterChip(
                label: context.l10n.price,
                isSelected: _filters.sortBy == 'price',
                onTap: () {
                  setState(() {
                    _filters = _filters.copyWith(
                      sortBy: _filters.sortBy == 'price' ? null : 'price',
                    );
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Open Only
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.l10n.openRestaurantsOnly,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Switch(
                value: _filters.openOnly,
                onChanged: (value) {
                  setState(() {
                    _filters = _filters.copyWith(openOnly: value);
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Apply Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Apply filters
                widget.ref
                    .read(restaurantFiltersProvider.notifier)
                    .applyFilters(_filters);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(context.l10n.applyFilters),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

/// Filter chip widget
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
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
        ),
      ),
      selected: isSelected,
      onSelected: (_) => onTap(),
      backgroundColor: AppColors.card,
      selectedColor: AppColors.primary.withOpacity(0.2),
      checkmarkColor: AppColors.primary,
      side: BorderSide(
        color: isSelected ? AppColors.primary : AppColors.border,
        width: isSelected ? 2 : 1,
      ),
    );
  }
}
