import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Restaurant filter state
class RestaurantFilters {
  final String? sortBy; // 'distance', 'rating', 'delivery_time', 'price'
  final bool openOnly;
  final String? cuisineType;
  final double? maxDeliveryFee;
  final double? maxDeliveryTime;
  final double? minRating;

  const RestaurantFilters({
    this.sortBy,
    this.openOnly = false,
    this.cuisineType,
    this.maxDeliveryFee,
    this.maxDeliveryTime,
    this.minRating,
  });

  RestaurantFilters copyWith({
    String? sortBy,
    bool? openOnly,
    String? cuisineType,
    double? maxDeliveryFee,
    double? maxDeliveryTime,
    double? minRating,
  }) {
    return RestaurantFilters(
      sortBy: sortBy ?? this.sortBy,
      openOnly: openOnly ?? this.openOnly,
      cuisineType: cuisineType ?? this.cuisineType,
      maxDeliveryFee: maxDeliveryFee ?? this.maxDeliveryFee,
      maxDeliveryTime: maxDeliveryTime ?? this.maxDeliveryTime,
      minRating: minRating ?? this.minRating,
    );
  }

  int get activeFiltersCount {
    int count = 0;
    if (sortBy != null) count++;
    if (openOnly) count++;
    if (cuisineType != null) count++;
    if (maxDeliveryFee != null) count++;
    if (maxDeliveryTime != null) count++;
    if (minRating != null) count++;
    return count;
  }

  bool get hasActiveFilters => activeFiltersCount > 0;

  RestaurantFilters clear() {
    return const RestaurantFilters();
  }
}

/// Restaurant filters notifier
class RestaurantFiltersNotifier extends StateNotifier<RestaurantFilters> {
  RestaurantFiltersNotifier() : super(const RestaurantFilters());

  void setSortBy(String? sortBy) {
    state = state.copyWith(sortBy: sortBy);
  }

  void setOpenOnly(bool openOnly) {
    state = state.copyWith(openOnly: openOnly);
  }

  void setCuisineType(String? cuisineType) {
    state = state.copyWith(cuisineType: cuisineType);
  }

  void setMaxDeliveryFee(double? maxDeliveryFee) {
    state = state.copyWith(maxDeliveryFee: maxDeliveryFee);
  }

  void setMaxDeliveryTime(double? maxDeliveryTime) {
    state = state.copyWith(maxDeliveryTime: maxDeliveryTime);
  }

  void setMinRating(double? minRating) {
    state = state.copyWith(minRating: minRating);
  }

  void clearFilters() {
    state = state.clear();
  }

  void applyFilters(RestaurantFilters filters) {
    state = filters;
  }
}

/// Restaurant filters provider
final restaurantFiltersProvider =
    StateNotifierProvider<RestaurantFiltersNotifier, RestaurantFilters>(
      (ref) => RestaurantFiltersNotifier(),
    );
