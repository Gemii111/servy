/// Menu item extra/addon model
class MenuExtraModel {
  final String id;
  final String name;
  final double price;

  MenuExtraModel({
    required this.id,
    required this.name,
    required this.price,
  });

  factory MenuExtraModel.fromJson(Map<String, dynamic> json) {
    return MenuExtraModel(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
    };
  }
}

