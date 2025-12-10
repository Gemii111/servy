/// Restaurant model for Customer and Restaurant apps
class RestaurantModel {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final String cuisineType;
  final double deliveryTime; // in minutes
  final double deliveryFee;
  final double? minOrderAmount;
  final bool isOpen;
  final bool isOnline; // Restaurant is online/active
  final double distance; // in km
  final String address;
  final double latitude;
  final double longitude;
  final List<String> images;
  final bool isFeatured;

  RestaurantModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    this.rating = 0.0,
    this.reviewCount = 0,
    required this.cuisineType,
    this.deliveryTime = 30.0,
    this.deliveryFee = 5.0,
    this.minOrderAmount,
    this.isOpen = true,
    this.isOnline = false,
    this.distance = 0.0,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.images = const [],
    this.isFeatured = false,
  });

  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    return RestaurantModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] as int? ?? 0,
      cuisineType: json['cuisineType'] as String,
      deliveryTime: (json['deliveryTime'] as num?)?.toDouble() ?? 30.0,
      deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 5.0,
      minOrderAmount: (json['minOrderAmount'] as num?)?.toDouble(),
      isOpen: json['isOpen'] as bool? ?? true,
      isOnline: json['isOnline'] as bool? ?? false,
      distance: (json['distance'] as num?)?.toDouble() ?? 0.0,
      address: json['address'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      images:
          (json['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      isFeatured: json['isFeatured'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'rating': rating,
      'reviewCount': reviewCount,
      'cuisineType': cuisineType,
      'deliveryTime': deliveryTime,
      'deliveryFee': deliveryFee,
      'minOrderAmount': minOrderAmount,
      'isOpen': isOpen,
      'isOnline': isOnline,
      'distance': distance,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'images': images,
      'isFeatured': isFeatured,
    };
  }

  RestaurantModel copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    double? rating,
    int? reviewCount,
    String? cuisineType,
    double? deliveryTime,
    double? deliveryFee,
    double? minOrderAmount,
    bool? isOpen,
    bool? isOnline,
    double? distance,
    String? address,
    double? latitude,
    double? longitude,
    List<String>? images,
    bool? isFeatured,
  }) {
    return RestaurantModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      cuisineType: cuisineType ?? this.cuisineType,
      deliveryTime: deliveryTime ?? this.deliveryTime,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      minOrderAmount: minOrderAmount ?? this.minOrderAmount,
      isOpen: isOpen ?? this.isOpen,
      isOnline: isOnline ?? this.isOnline,
      distance: distance ?? this.distance,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      images: images ?? this.images,
      isFeatured: isFeatured ?? this.isFeatured,
    );
  }
}
