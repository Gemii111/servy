import '../models/restaurant_model.dart';
import '../models/menu_model.dart';
import '../models/menu_category_model.dart';
import '../models/menu_item_model.dart';
import '../models/menu_extra_model.dart';
import '../services/mock_api_service.dart';

/// Restaurant repository
class RestaurantRepository {
  RestaurantRepository({MockApiService? mockApiService})
    : _mockApiService = mockApiService ?? MockApiService.instance;

  final MockApiService _mockApiService;

  /// Get all restaurants with optional filters
  Future<List<RestaurantModel>> getRestaurants({
    String? categoryId,
    double? latitude,
    double? longitude,
    bool? isOpen,
    bool? isFeatured,
  }) async {
    return await _mockApiService.getRestaurants(
      categoryId: categoryId,
      latitude: latitude,
      longitude: longitude,
      isOpen: isOpen,
      isFeatured: isFeatured,
    );
  }

  /// Get restaurant by ID
  Future<RestaurantModel?> getRestaurantById(String id) async {
    return await _mockApiService.getRestaurantById(id);
  }

  /// Get featured restaurants
  Future<List<RestaurantModel>> getFeaturedRestaurants({
    double? latitude,
    double? longitude,
  }) async {
    return await getRestaurants(
      isFeatured: true,
      latitude: latitude,
      longitude: longitude,
    );
  }

  /// Get nearby restaurants
  Future<List<RestaurantModel>> getNearbyRestaurants({
    required double latitude,
    required double longitude,
    double maxDistance = 10.0, // km
  }) async {
    final restaurants = await getRestaurants(
      latitude: latitude,
      longitude: longitude,
    );

    return restaurants.where((r) => r.distance <= maxDistance).toList();
  }

  /// Get restaurant menu
  Future<MenuModel> getRestaurantMenu(String restaurantId) async {
    return await _mockApiService.getRestaurantMenu(restaurantId);
  }

  /// Add menu category
  Future<MenuCategoryModel> addMenuCategory({
    required String restaurantId,
    required String name,
  }) async {
    return await _mockApiService.addMenuCategory(
      restaurantId: restaurantId,
      name: name,
    );
  }

  /// Update menu category
  Future<MenuCategoryModel> updateMenuCategory({
    required String restaurantId,
    required String categoryId,
    required String name,
  }) async {
    return await _mockApiService.updateMenuCategory(
      restaurantId: restaurantId,
      categoryId: categoryId,
      name: name,
    );
  }

  /// Delete menu category
  Future<void> deleteMenuCategory({
    required String restaurantId,
    required String categoryId,
  }) async {
    return await _mockApiService.deleteMenuCategory(
      restaurantId: restaurantId,
      categoryId: categoryId,
    );
  }

  /// Add menu item
  Future<MenuItemModel> addMenuItem({
    required String restaurantId,
    required String categoryId,
    required String name,
    required String description,
    required double price,
    String? imageUrl,
    bool isAvailable = true,
    List<MenuExtraModel> extras = const [],
  }) async {
    return await _mockApiService.addMenuItem(
      restaurantId: restaurantId,
      categoryId: categoryId,
      name: name,
      description: description,
      price: price,
      imageUrl: imageUrl,
      isAvailable: isAvailable,
      extras: extras,
    );
  }

  /// Update menu item
  Future<MenuItemModel> updateMenuItem({
    required String restaurantId,
    required String categoryId,
    required String itemId,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    bool? isAvailable,
    List<MenuExtraModel>? extras,
  }) async {
    return await _mockApiService.updateMenuItem(
      restaurantId: restaurantId,
      categoryId: categoryId,
      itemId: itemId,
      name: name,
      description: description,
      price: price,
      imageUrl: imageUrl,
      isAvailable: isAvailable,
      extras: extras,
    );
  }

  /// Delete menu item
  Future<void> deleteMenuItem({
    required String restaurantId,
    required String categoryId,
    required String itemId,
  }) async {
    return await _mockApiService.deleteMenuItem(
      restaurantId: restaurantId,
      categoryId: categoryId,
      itemId: itemId,
    );
  }

  /// Update restaurant status (open/closed)
  Future<void> updateRestaurantStatus({
    required String restaurantId,
    required bool isOpen,
  }) async {
    return await _mockApiService.updateRestaurantStatus(
      restaurantId: restaurantId,
      isOpen: isOpen,
    );
  }


  /// Update restaurant info
  Future<RestaurantModel> updateRestaurant({
    required String restaurantId,
    String? name,
    String? description,
    String? imageUrl,
    double? deliveryTime,
    double? deliveryFee,
    double? minOrderAmount,
    String? address,
    double? latitude,
    double? longitude,
  }) async {
    return await _mockApiService.updateRestaurant(
      restaurantId: restaurantId,
      name: name,
      description: description,
      imageUrl: imageUrl,
      deliveryTime: deliveryTime,
      deliveryFee: deliveryFee,
      minOrderAmount: minOrderAmount,
      address: address,
      latitude: latitude,
      longitude: longitude,
    );
  }
}
