import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/rating_model.dart';
import '../../data/repositories/rating_repository.dart';

/// Rating repository provider
final ratingRepositoryProvider = Provider<RatingRepository>((ref) {
  return RatingRepository();
});

/// Restaurant ratings provider
final restaurantRatingsProvider =
    FutureProvider.family<List<RatingModel>, String>((ref, restaurantId) async {
  final repository = ref.watch(ratingRepositoryProvider);
  return await repository.getRestaurantRatings(restaurantId);
});

/// Restaurant rating summary provider
final restaurantRatingSummaryProvider =
    FutureProvider.family<RestaurantRatingSummary, String>((ref, restaurantId) async {
  final ratings = await ref.watch(restaurantRatingsProvider(restaurantId).future);
  return RestaurantRatingSummary.fromRatings(ratings);
});

/// Rating by ID provider
final ratingByIdProvider =
    FutureProvider.family<RatingModel?, String>((ref, ratingId) async {
  final repository = ref.watch(ratingRepositoryProvider);
  return await repository.getRatingById(ratingId);
});

/// User ratings provider
final userRatingsProvider =
    FutureProvider.family<List<RatingModel>, String>((ref, userId) async {
  final repository = ref.watch(ratingRepositoryProvider);
  return await repository.getUserRatings(userId);
});

/// Rating submission notifier
class RatingSubmissionNotifier extends StateNotifier<AsyncValue<RatingModel?>> {
  RatingSubmissionNotifier(this._repository) : super(const AsyncValue.data(null));

  final RatingRepository _repository;

  Future<void> submitRating({
    required String userId,
    required String userName,
    String? userImageUrl,
    required String restaurantId,
    String? orderId,
    required double rating,
    String? comment,
    List<String>? imageUrls,
  }) async {
    state = const AsyncValue.loading();
    try {
      final result = await _repository.submitRating(
        userId: userId,
        userName: userName,
        userImageUrl: userImageUrl,
        restaurantId: restaurantId,
        orderId: orderId,
        rating: rating,
        comment: comment,
        imageUrls: imageUrls,
      );
      state = AsyncValue.data(result);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> updateRating({
    required String ratingId,
    double? rating,
    String? comment,
    List<String>? imageUrls,
  }) async {
    state = const AsyncValue.loading();
    try {
      final result = await _repository.updateRating(
        ratingId: ratingId,
        rating: rating,
        comment: comment,
        imageUrls: imageUrls,
      );
      state = AsyncValue.data(result);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> deleteRating(String ratingId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteRating(ratingId);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

/// Rating submission provider
final ratingSubmissionProvider =
    StateNotifierProvider<RatingSubmissionNotifier, AsyncValue<RatingModel?>>((ref) {
  final repository = ref.watch(ratingRepositoryProvider);
  return RatingSubmissionNotifier(repository);
});

