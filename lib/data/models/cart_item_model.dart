import 'menu_item_model.dart';
import 'menu_extra_model.dart';

/// Cart item model
class CartItemModel {
  final String id;
  final String restaurantId;
  final MenuItemModel menuItem;
  final int quantity;
  final List<MenuExtraModel> selectedExtras;
  final String? notes;

  CartItemModel({
    required this.id,
    required this.restaurantId,
    required this.menuItem,
    this.quantity = 1,
    this.selectedExtras = const [],
    this.notes,
  });

  /// Calculate total price including extras
  double get totalPrice {
    final extrasTotal = selectedExtras.fold<double>(
      0,
      (sum, extra) => sum + extra.price,
    );
    return (menuItem.price + extrasTotal) * quantity;
  }

  /// Create a copy with updated fields
  CartItemModel copyWith({
    String? id,
    String? restaurantId,
    MenuItemModel? menuItem,
    int? quantity,
    List<MenuExtraModel>? selectedExtras,
    String? notes,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      menuItem: menuItem ?? this.menuItem,
      quantity: quantity ?? this.quantity,
      selectedExtras: selectedExtras ?? this.selectedExtras,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurant_id': restaurantId,
      'menu_item': menuItem.toJson(),
      'quantity': quantity,
      'selected_extras': selectedExtras.map((e) => e.toJson()).toList(),
      'notes': notes,
    };
  }

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'] as String,
      restaurantId: json['restaurant_id'] as String,
      menuItem: MenuItemModel.fromJson(json['menu_item'] as Map<String, dynamic>),
      quantity: json['quantity'] as int? ?? 1,
      selectedExtras: (json['selected_extras'] as List<dynamic>?)
              ?.map((e) => MenuExtraModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      notes: json['notes'] as String?,
    );
  }
}

