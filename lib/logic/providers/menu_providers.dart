import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/menu_model.dart';
import '../../data/models/menu_extra_model.dart';
import '../../data/repositories/restaurant_repository.dart';

/// Restaurant repository provider (reuse existing)
final restaurantRepositoryForMenuProvider = Provider<RestaurantRepository>((ref) {
  return RestaurantRepository();
});

/// Menu provider by restaurant ID
final menuProvider = FutureProvider.family<MenuModel, String>((ref, restaurantId) async {
  final repository = ref.watch(restaurantRepositoryForMenuProvider);
  return await repository.getRestaurantMenu(restaurantId);
});

/// Menu management notifier
class MenuManagementNotifier extends StateNotifier<AsyncValue<MenuModel>> {
  MenuManagementNotifier(this._repository, this._restaurantId)
      : super(const AsyncValue.loading()) {
    loadMenu();
  }

  final RestaurantRepository _repository;
  final String _restaurantId;

  Future<void> loadMenu() async {
    state = const AsyncValue.loading();
    try {
      final menu = await _repository.getRestaurantMenu(_restaurantId);
      state = AsyncValue.data(menu);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> refresh() async {
    await loadMenu();
  }

  Future<void> addCategory(String name) async {
    try {
      await _repository.addMenuCategory(
        restaurantId: _restaurantId,
        name: name,
      );
      await refresh();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  Future<void> updateCategory({
    required String categoryId,
    required String name,
  }) async {
    try {
      await _repository.updateMenuCategory(
        restaurantId: _restaurantId,
        categoryId: categoryId,
        name: name,
      );
      await refresh();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    try {
      await _repository.deleteMenuCategory(
        restaurantId: _restaurantId,
        categoryId: categoryId,
      );
      await refresh();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  Future<void> addItem({
    required String categoryId,
    required String name,
    required String description,
    required double price,
    String? imageUrl,
    bool isAvailable = true,
    List<MenuExtraModel> extras = const [],
  }) async {
    try {
      await _repository.addMenuItem(
        restaurantId: _restaurantId,
        categoryId: categoryId,
        name: name,
        description: description,
        price: price,
        imageUrl: imageUrl,
        isAvailable: isAvailable,
        extras: extras,
      );
      await refresh();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  Future<void> updateItem({
    required String categoryId,
    required String itemId,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    bool? isAvailable,
    List<MenuExtraModel>? extras,
  }) async {
    try {
      await _repository.updateMenuItem(
        restaurantId: _restaurantId,
        categoryId: categoryId,
        itemId: itemId,
        name: name,
        description: description,
        price: price,
        imageUrl: imageUrl,
        isAvailable: isAvailable,
        extras: extras,
      );
      await refresh();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  Future<void> deleteItem({
    required String categoryId,
    required String itemId,
  }) async {
    try {
      await _repository.deleteMenuItem(
        restaurantId: _restaurantId,
        categoryId: categoryId,
        itemId: itemId,
      );
      await refresh();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }
}

/// Menu management provider
final menuManagementProvider = StateNotifierProvider.family<
    MenuManagementNotifier,
    AsyncValue<MenuModel>,
    String>((ref, restaurantId) {
  final repository = ref.watch(restaurantRepositoryForMenuProvider);
  return MenuManagementNotifier(repository, restaurantId);
});

