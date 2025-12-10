import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/restaurant_statistics_model.dart';
import '../../data/models/restaurant_model.dart';
import '../../data/services/mock_api_service.dart';
import '../../data/repositories/restaurant_repository.dart';

/// Restaurant repository provider
final restaurantRepositoryProvider = Provider<RestaurantRepository>((ref) {
  return RestaurantRepository();
});

/// Restaurants state notifier
class RestaurantsNotifier
    extends StateNotifier<AsyncValue<List<RestaurantModel>>> {
  RestaurantsNotifier(this._repository) : super(const AsyncValue.loading());

  final RestaurantRepository _repository;
  List<RestaurantModel> _allRestaurants = [];

  List<RestaurantModel> get allRestaurants => _allRestaurants;

  /// Load restaurants with optional filters
  Future<void> loadRestaurants({
    String? categoryId,
    double? latitude,
    double? longitude,
    bool? isOpen,
    bool? isFeatured,
  }) async {
    state = const AsyncValue.loading();
    try {
      final restaurants = await _repository.getRestaurants(
        categoryId: categoryId,
        latitude: latitude,
        longitude: longitude,
        isOpen: isOpen,
        isFeatured: isFeatured,
      );
      _allRestaurants = restaurants;
      state = AsyncValue.data(restaurants);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Refresh restaurants
  Future<void> refresh({
    String? categoryId,
    double? latitude,
    double? longitude,
    bool? isOpen,
    bool? isFeatured,
  }) async {
    await loadRestaurants(
      categoryId: categoryId,
      latitude: latitude,
      longitude: longitude,
      isOpen: isOpen,
      isFeatured: isFeatured,
    );
  }

  /// Clear search/filter
  void clearSearch() {
    // Reset to show all restaurants if we have them
    if (_allRestaurants.isNotEmpty) {
      state = AsyncValue.data(_allRestaurants);
    } else {
      loadRestaurants(isFeatured: true);
    }
  }

  /// Search restaurants by query
  void searchRestaurants(String query) {
    if (query.isEmpty) {
      state = AsyncValue.data(_allRestaurants);
      return;
    }

    final queryLower = query.toLowerCase();
    final filtered =
        _allRestaurants.where((restaurant) {
          return restaurant.name.toLowerCase().contains(queryLower) ||
              restaurant.description.toLowerCase().contains(queryLower) ||
              restaurant.cuisineType.toLowerCase().contains(queryLower);
        }).toList();

    state = AsyncValue.data(filtered);
  }

  /// Apply filters and sorting to restaurants
  List<RestaurantModel> applyFiltersAndSort({
    List<RestaurantModel>? restaurants,
    String? sortBy,
    bool openOnly = false,
    String? cuisineType,
    double? maxDeliveryFee,
    double? maxDeliveryTime,
    double? minRating,
  }) {
    final list = restaurants ?? _allRestaurants;
    var filtered = List<RestaurantModel>.from(list);

    // Apply filters
    if (openOnly) {
      filtered = filtered.where((r) => r.isOpen).toList();
    }

    if (cuisineType != null && cuisineType.isNotEmpty) {
      filtered = filtered.where((r) => r.cuisineType == cuisineType).toList();
    }

    if (maxDeliveryFee != null) {
      filtered =
          filtered.where((r) => r.deliveryFee <= maxDeliveryFee).toList();
    }

    if (maxDeliveryTime != null) {
      filtered =
          filtered.where((r) => r.deliveryTime <= maxDeliveryTime).toList();
    }

    if (minRating != null) {
      filtered = filtered.where((r) => r.rating >= minRating).toList();
    }

    // Apply sorting
    if (sortBy != null) {
      switch (sortBy) {
        case 'distance':
          filtered.sort((a, b) => a.distance.compareTo(b.distance));
          break;
        case 'rating':
          filtered.sort((a, b) => b.rating.compareTo(a.rating));
          break;
        case 'delivery_time':
          filtered.sort((a, b) => a.deliveryTime.compareTo(b.deliveryTime));
          break;
        case 'price':
          filtered.sort((a, b) => a.deliveryFee.compareTo(b.deliveryFee));
          break;
      }
    }

    return filtered;
  }
}

/// Restaurants provider
final restaurantsProvider = StateNotifierProvider<
  RestaurantsNotifier,
  AsyncValue<List<RestaurantModel>>
>((ref) {
  final repository = ref.watch(restaurantRepositoryProvider);
  return RestaurantsNotifier(repository);
});

/// Restaurant by ID provider
final restaurantByIdProvider = FutureProvider.family<RestaurantModel?, String>((
  ref,
  id,
) async {
  final repository = ref.watch(restaurantRepositoryProvider);
  return await repository.getRestaurantById(id);
});

/// Restaurant statistics provider
final restaurantStatisticsProvider =
    FutureProvider.family<RestaurantStatisticsModel, String>((
      ref,
      restaurantId,
    ) async {
      final stats = await MockApiService.instance.getRestaurantStatistics(
        restaurantId,
      );
      return RestaurantStatisticsModel.fromJson(stats);
    });
