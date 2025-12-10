import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import '../../data/models/cart_item_model.dart';
import '../../data/models/menu_item_model.dart';
import '../../data/models/menu_extra_model.dart';
import '../../data/datasources/local_storage_service.dart';

/// Cart state notifier
class CartNotifier extends StateNotifier<List<CartItemModel>> {
  CartNotifier() : super([]) {
    _loadCart();
  }

  static const String _cartKey = 'cart_items';

  /// Load cart from storage
  Future<void> _loadCart() async {
    try {
      final storage = LocalStorageService.instance;
      final cartJson = storage.get<String>(_cartKey);
      if (cartJson != null) {
        final List<dynamic> decoded = jsonDecode(cartJson);
        state = decoded
            .map((item) => CartItemModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      state = [];
    }
  }

  /// Save cart to storage
  Future<void> _saveCart() async {
    try {
      final storage = LocalStorageService.instance;
      final cartJson = jsonEncode(state.map((item) => item.toJson()).toList());
      await storage.save(_cartKey, cartJson);
    } catch (e) {
      // Handle error
    }
  }

  /// Add item to cart
  Future<void> addItem({
    required String restaurantId,
    required MenuItemModel menuItem,
    List<MenuExtraModel> extras = const [],
    String? notes,
  }) async {
    // Check if item already exists
    final existingIndex = state.indexWhere(
      (item) =>
          item.restaurantId == restaurantId &&
          item.menuItem.id == menuItem.id &&
          _extrasMatch(item.selectedExtras, extras),
    );

    if (existingIndex >= 0) {
      // Update quantity
      final existing = state[existingIndex];
      final updated = existing.copyWith(quantity: existing.quantity + 1);
      state = [
        ...state.sublist(0, existingIndex),
        updated,
        ...state.sublist(existingIndex + 1),
      ];
    } else {
      // Add new item
      final newItem = CartItemModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        restaurantId: restaurantId,
        menuItem: menuItem,
        quantity: 1,
        selectedExtras: extras,
        notes: notes,
      );
      state = [...state, newItem];
    }

    await _saveCart();
  }

  /// Remove item from cart
  Future<void> removeItem(String itemId) async {
    state = state.where((item) => item.id != itemId).toList();
    await _saveCart();
  }

  /// Update item quantity
  Future<void> updateQuantity(String itemId, int quantity) async {
    if (quantity <= 0) {
      await removeItem(itemId);
      return;
    }

    final index = state.indexWhere((item) => item.id == itemId);
    if (index >= 0) {
      final item = state[index];
      final updated = item.copyWith(quantity: quantity);
      state = [
        ...state.sublist(0, index),
        updated,
        ...state.sublist(index + 1),
      ];
      await _saveCart();
    }
  }

  /// Clear cart
  Future<void> clearCart() async {
    state = [];
    await _saveCart();
  }

  /// Get total price
  double get totalPrice {
    return state.fold<double>(0, (sum, item) => sum + item.totalPrice);
  }

  /// Get item count
  int get itemCount {
    return state.fold<int>(0, (sum, item) => sum + item.quantity);
  }

  /// Check if cart has items from same restaurant
  bool hasItemsFromRestaurant(String restaurantId) {
    return state.any((item) => item.restaurantId == restaurantId);
  }

  /// Check if cart is empty
  bool get isEmpty => state.isEmpty;

  /// Check extras match
  bool _extrasMatch(List<MenuExtraModel> a, List<MenuExtraModel> b) {
    if (a.length != b.length) return false;
    final aIds = a.map((e) => e.id).toSet();
    final bIds = b.map((e) => e.id).toSet();
    return aIds.length == bIds.length && 
           aIds.every((id) => bIds.contains(id));
  }
}

/// Cart provider
final cartProvider = StateNotifierProvider<CartNotifier, List<CartItemModel>>((ref) {
  return CartNotifier();
});

/// Cart total price provider
final cartTotalProvider = Provider<double>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold<double>(0, (sum, item) => sum + item.totalPrice);
});

/// Cart item count provider
final cartItemCountProvider = Provider<int>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold<int>(0, (sum, item) => sum + item.quantity);
});

