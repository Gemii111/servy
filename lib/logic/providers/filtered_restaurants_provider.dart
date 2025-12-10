import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/restaurant_model.dart';
import 'restaurant_providers.dart';
import 'restaurant_filters_providers.dart';

/// Provider that combines restaurants with filters
final filteredRestaurantsProvider = Provider<AsyncValue<List<RestaurantModel>>>((ref) {
  final restaurantsAsync = ref.watch(restaurantsProvider);
  final filters = ref.watch(restaurantFiltersProvider);

  return restaurantsAsync.when(
    data: (restaurants) {
      // Get the notifier to use applyFiltersAndSort
      final notifier = ref.read(restaurantsProvider.notifier);
      
      // Apply filters and sorting
      final filtered = notifier.applyFiltersAndSort(
        restaurants: restaurants,
        sortBy: filters.sortBy,
        openOnly: filters.openOnly,
        cuisineType: filters.cuisineType,
        maxDeliveryFee: filters.maxDeliveryFee,
        maxDeliveryTime: filters.maxDeliveryTime,
        minRating: filters.minRating,
      );
      
      return AsyncValue.data(filtered);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
  );
});

