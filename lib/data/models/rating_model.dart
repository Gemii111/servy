/// Rating model for restaurant and order reviews
class RatingModel {
  final String id;
  final String userId;
  final String userName;
  final String? userImageUrl;
  final String restaurantId;
  final String? orderId; // Optional - if rating is for specific order
  final double rating; // 1.0 to 5.0
  final String? comment; // Optional review text
  final List<String>? imageUrls; // Optional review photos
  final DateTime createdAt;
  final DateTime? updatedAt;

  RatingModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.userImageUrl,
    required this.restaurantId,
    this.orderId,
    required this.rating,
    this.comment,
    this.imageUrls,
    required this.createdAt,
    this.updatedAt,
  });

  factory RatingModel.fromJson(Map<String, dynamic> json) {
    return RatingModel(
      id: json['id'] as String,
      userId: json['user_id'] as String? ?? json['userId'] as String,
      userName: json['user_name'] as String? ?? json['userName'] as String,
      userImageUrl: json['user_image_url'] as String? ?? json['userImageUrl'] as String?,
      restaurantId: json['restaurant_id'] as String? ?? json['restaurantId'] as String,
      orderId: json['order_id'] as String? ?? json['orderId'] as String?,
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'] as String?,
      imageUrls: json['image_urls'] != null
          ? (json['image_urls'] as List<dynamic>).map((e) => e as String).toList()
          : json['imageUrls'] != null
              ? (json['imageUrls'] as List<dynamic>).map((e) => e as String).toList()
              : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : json['createdAt'] != null
              ? DateTime.parse(json['createdAt'] as String)
              : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : json['updatedAt'] != null
              ? json['updatedAt'] != null
                  ? DateTime.parse(json['updatedAt'] as String)
                  : null
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'user_image_url': userImageUrl,
      'restaurant_id': restaurantId,
      'order_id': orderId,
      'rating': rating,
      'comment': comment,
      'image_urls': imageUrls,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  RatingModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userImageUrl,
    String? restaurantId,
    String? orderId,
    double? rating,
    String? comment,
    List<String>? imageUrls,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RatingModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userImageUrl: userImageUrl ?? this.userImageUrl,
      restaurantId: restaurantId ?? this.restaurantId,
      orderId: orderId ?? this.orderId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      imageUrls: imageUrls ?? this.imageUrls,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Restaurant rating summary
class RestaurantRatingSummary {
  final double averageRating;
  final int totalRatings;
  final Map<int, int> ratingDistribution; // {5: 10, 4: 5, 3: 2, 2: 1, 1: 0}
  final List<RatingModel> recentReviews; // Latest 5-10 reviews

  RestaurantRatingSummary({
    required this.averageRating,
    required this.totalRatings,
    required this.ratingDistribution,
    required this.recentReviews,
  });

  factory RestaurantRatingSummary.fromRatings(List<RatingModel> ratings) {
    if (ratings.isEmpty) {
      return RestaurantRatingSummary(
        averageRating: 0.0,
        totalRatings: 0,
        ratingDistribution: {5: 0, 4: 0, 3: 0, 2: 0, 1: 0},
        recentReviews: [],
      );
    }

    final total = ratings.length;
    final sum = ratings.fold<double>(0.0, (sum, rating) => sum + rating.rating);
    final average = sum / total;

    final distribution = <int, int>{5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    for (final rating in ratings) {
      final stars = rating.rating.round();
      distribution[stars] = (distribution[stars] ?? 0) + 1;
    }

    final sortedReviews = List<RatingModel>.from(ratings)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return RestaurantRatingSummary(
      averageRating: double.parse(average.toStringAsFixed(1)),
      totalRatings: total,
      ratingDistribution: distribution,
      recentReviews: sortedReviews.take(10).toList(),
    );
  }
}

