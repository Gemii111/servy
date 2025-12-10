import 'menu_category_model.dart';
import 'menu_item_model.dart';

/// Restaurant menu model
class MenuModel {
  final String restaurantId;
  final List<MenuCategoryModel> categories;

  MenuModel({
    required this.restaurantId,
    this.categories = const [],
  });

  factory MenuModel.fromJson(Map<String, dynamic> json) {
    return MenuModel(
      restaurantId: json['restaurant_id'] as String,
      categories: (json['categories'] as List<dynamic>?)
              ?.map((e) => MenuCategoryModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'restaurant_id': restaurantId,
      'categories': categories.map((e) => e.toJson()).toList(),
    };
  }

  /// Get all items from all categories
  List<MenuItemModel> get allItems {
    return categories.expand((category) => category.items).toList();
  }
}

