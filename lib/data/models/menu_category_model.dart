import 'menu_item_model.dart';

/// Menu category model (contains menu items)
class MenuCategoryModel {
  final String id;
  final String name;
  final List<MenuItemModel> items;

  MenuCategoryModel({
    required this.id,
    required this.name,
    this.items = const [],
  });

  factory MenuCategoryModel.fromJson(Map<String, dynamic> json) {
    return MenuCategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => MenuItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'items': items.map((e) => e.toJson()).toList(),
    };
  }
}

