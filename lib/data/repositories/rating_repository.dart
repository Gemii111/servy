import '../models/rating_model.dart';
import '../services/mock_api_service.dart';

/// Rating repository
class RatingRepository {
  RatingRepository({MockApiService? mockApiService})
      : _mockApiService = mockApiService ?? MockApiService.instance;

  final MockApiService _mockApiService;

  /// Get restaurant ratings
  Future<List<RatingModel>> getRestaurantRatings(String restaurantId) async {
    return await _mockApiService.getRestaurantRatings(restaurantId);
  }

  /// Get rating by ID
  Future<RatingModel?> getRatingById(String ratingId) async {
    return await _mockApiService.getRatingById(ratingId);
  }

  /// Submit rating/review
  Future<RatingModel> submitRating({
    required String userId,
    required String userName,
    String? userImageUrl,
    required String restaurantId,
    String? orderId,
    required double rating,
    String? comment,
    List<String>? imageUrls,
  }) async {
    return await _mockApiService.submitRating(
      userId: userId,
      userName: userName,
      userImageUrl: userImageUrl,
      restaurantId: restaurantId,
      orderId: orderId,
      rating: rating,
      comment: comment,
      imageUrls: imageUrls,
    );
  }

  /// Update rating
  Future<RatingModel> updateRating({
    required String ratingId,
    double? rating,
    String? comment,
    List<String>? imageUrls,
  }) async {
    return await _mockApiService.updateRating(
      ratingId: ratingId,
      rating: rating,
      comment: comment,
      imageUrls: imageUrls,
    );
  }

  /// Delete rating
  Future<void> deleteRating(String ratingId) async {
    return await _mockApiService.deleteRating(ratingId);
  }

  /// Get user ratings
  Future<List<RatingModel>> getUserRatings(String userId) async {
    return await _mockApiService.getUserRatings(userId);
  }
}

