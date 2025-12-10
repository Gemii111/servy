import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import '../../data/models/restaurant_model.dart';
import '../../data/datasources/local_storage_service.dart';
import 'restaurant_providers.dart';

/// Favorites state notifier
class FavoritesNotifier extends StateNotifier<List<String>> {
  FavoritesNotifier() : super([]) {
    _loadFavorites();
  }

  static const String _favoritesKey = 'favorite_restaurants';

  /// Load favorites from storage
  Future<void> _loadFavorites() async {
    try {
      final storage = LocalStorageService.instance;
      final favoritesJson = storage.get<String>(_favoritesKey);
      if (favoritesJson != null) {
        final List<dynamic> decoded = jsonDecode(favoritesJson);
        state = decoded.map((id) => id as String).toList();
      }
    } catch (e) {
      state = [];
    }
  }

  /// Save favorites to storage
  Future<void> _saveFavorites() async {
    try {
      final storage = LocalStorageService.instance;
      final favoritesJson = jsonEncode(state);
      await storage.save(_favoritesKey, favoritesJson);
    } catch (e) {
      // Handle error
    }
  }

  /// Add restaurant to favorites
  Future<void> addFavorite(String restaurantId) async {
    if (!state.contains(restaurantId)) {
      state = [...state, restaurantId];
      await _saveFavorites();
    }
  }

  /// Remove restaurant from favorites
  Future<void> removeFavorite(String restaurantId) async {
    state = state.where((id) => id != restaurantId).toList();
    await _saveFavorites();
  }

  /// Toggle favorite status
  Future<void> toggleFavorite(String restaurantId) async {
    if (state.contains(restaurantId)) {
      await removeFavorite(restaurantId);
    } else {
      await addFavorite(restaurantId);
    }
  }

  /// Check if restaurant is favorite
  bool isFavorite(String restaurantId) {
    return state.contains(restaurantId);
  }

  /// Clear all favorites
  Future<void> clearFavorites() async {
    state = [];
    await _saveFavorites();
  }

  /// Get favorites count
  int get count => state.length;
}

/// Favorites provider
final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, List<String>>((ref) {
  return FavoritesNotifier();
});

/// Check if restaurant is favorite
final isRestaurantFavoriteProvider = Provider.family<bool, String>((ref, restaurantId) {
  final favorites = ref.watch(favoritesProvider);
  return favorites.contains(restaurantId);
});

/// Favorite restaurants list provider
final favoriteRestaurantsProvider = FutureProvider<List<RestaurantModel>>((ref) async {
  final favorites = ref.watch(favoritesProvider);
  if (favorites.isEmpty) {
    return [];
  }

  // Get restaurant repository
  final restaurantRepository = ref.watch(restaurantRepositoryProvider);
  
  // Fetch favorite restaurants
  final allRestaurants = await restaurantRepository.getRestaurants();
  
  // Filter to only include favorites
  return allRestaurants
      .where((restaurant) => favorites.contains(restaurant.id))
      .toList();
});

