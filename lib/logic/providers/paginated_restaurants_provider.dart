import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/restaurant_model.dart';
import '../../data/repositories/restaurant_repository.dart';
import 'restaurant_providers.dart';

/// Paginated restaurants state
class PaginatedRestaurantsState {
  final List<RestaurantModel> restaurants;
  final int currentPage;
  final bool isLoading;
  final bool hasMore;
  final String? error;

  const PaginatedRestaurantsState({
    this.restaurants = const [],
    this.currentPage = 1,
    this.isLoading = false,
    this.hasMore = true,
    this.error,
  });

  PaginatedRestaurantsState copyWith({
    List<RestaurantModel>? restaurants,
    int? currentPage,
    bool? isLoading,
    bool? hasMore,
    String? error,
  }) {
    return PaginatedRestaurantsState(
      restaurants: restaurants ?? this.restaurants,
      currentPage: currentPage ?? this.currentPage,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      error: error,
    );
  }
}

/// Paginated restaurants notifier
class PaginatedRestaurantsNotifier extends StateNotifier<PaginatedRestaurantsState> {
  PaginatedRestaurantsNotifier(this._repository) : super(const PaginatedRestaurantsState());

  final RestaurantRepository _repository;
  static const int _pageSize = 10;

  /// Load initial restaurants
  Future<void> loadInitial({
    String? categoryId,
    bool? isFeatured,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final restaurants = await _repository.getRestaurants(
        categoryId: categoryId,
        isFeatured: isFeatured,
      );

      // Simulate pagination - take first page
      final paginatedItems = restaurants.take(_pageSize).toList();
      final hasMore = restaurants.length > _pageSize;

      state = state.copyWith(
        restaurants: paginatedItems,
        currentPage: 1,
        isLoading: false,
        hasMore: hasMore,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Load more restaurants (next page)
  Future<void> loadMore({
    String? categoryId,
    bool? isFeatured,
  }) async {
    if (!state.hasMore || state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final allRestaurants = await _repository.getRestaurants(
        categoryId: categoryId,
        isFeatured: isFeatured,
      );

      final nextPage = state.currentPage + 1;
      final startIndex = state.restaurants.length;
      final endIndex = startIndex + _pageSize;
      
      if (startIndex >= allRestaurants.length) {
        state = state.copyWith(
          isLoading: false,
          hasMore: false,
        );
        return;
      }

      final newItems = allRestaurants
          .skip(startIndex)
          .take(_pageSize)
          .toList();

      state = state.copyWith(
        restaurants: [...state.restaurants, ...newItems],
        currentPage: nextPage,
        isLoading: false,
        hasMore: endIndex < allRestaurants.length,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Reset pagination
  void reset() {
    state = const PaginatedRestaurantsState();
  }
}

/// Paginated restaurants provider
final paginatedRestaurantsProvider =
    StateNotifierProvider<PaginatedRestaurantsNotifier, PaginatedRestaurantsState>(
  (ref) {
    final repository = ref.watch(restaurantRepositoryProvider);
    return PaginatedRestaurantsNotifier(repository);
  },
);

