/// Food category model
class CategoryModel {
  final String id;
  final String name;
  final String nameAr; // Arabic name
  final String iconUrl;
  final String color; // Hex color code

  CategoryModel({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.iconUrl,
    required this.color,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      nameAr: json['nameAr'] as String,
      iconUrl: json['iconUrl'] as String,
      color: json['color'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nameAr': nameAr,
      'iconUrl': iconUrl,
      'color': color,
    };
  }
}


