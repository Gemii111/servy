import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../logic/providers/auth_providers.dart';
import '../../../../logic/providers/rating_providers.dart';
import '../../../../logic/providers/order_providers.dart';
import '../../../../core/utils/haptic_feedback.dart';
import '../../widgets/ratings/star_rating_widget.dart';

/// Review Order Screen - Rate restaurant after order delivery
class ReviewOrderScreen extends ConsumerStatefulWidget {
  const ReviewOrderScreen({
    super.key,
    required this.orderId,
    this.restaurantId,
  });

  final String orderId;
  final String? restaurantId;

  @override
  ConsumerState<ReviewOrderScreen> createState() => _ReviewOrderScreenState();
}

class _ReviewOrderScreenState extends ConsumerState<ReviewOrderScreen> {
  double _rating = 0.0;
  final TextEditingController _commentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_rating == 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.pleaseSelectRating),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    HapticFeedbackUtil.mediumImpact();

    final user = ref.read(currentUserProvider);
    final orderAsync = ref.watch(orderByIdProvider(widget.orderId));

    await orderAsync.whenData((order) async {
      if (user == null || order == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.l10n.somethingWentWrong),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      try {
        await ref.read(ratingSubmissionProvider.notifier).submitRating(
              userId: user.id,
              userName: user.name ?? 'User',
              userImageUrl: user.imageUrl,
              restaurantId: order.restaurantId,
              orderId: widget.orderId,
              rating: _rating,
              comment: _commentController.text.trim().isEmpty
                  ? null
                  : _commentController.text.trim(),
              imageUrls: null, // TODO: Add image upload
            );

        // Refresh restaurant ratings
        ref.invalidate(restaurantRatingsProvider(order.restaurantId));
        ref.invalidate(restaurantRatingSummaryProvider(order.restaurantId));

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.reviewSubmittedSuccessfully),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 2),
          ),
        );

        // Navigate back after success
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            context.pop();
          }
        });
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final orderAsync = ref.watch(orderByIdProvider(widget.orderId));
    final l10n = context.l10n;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.rateYourOrder)),
        body: Center(child: Text(l10n.pleaseLoginFirst)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.card,
        elevation: 0,
        title: Text(
          l10n.rateYourOrder,
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: orderAsync.when(
        data: (order) {
          if (order == null) {
            return Center(child: Text(l10n.orderNotFound));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Restaurant Info Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [AppColors.cardShadow],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: AppColors.surface,
                          ),
                          child: const Icon(
                            Icons.restaurant,
                            size: 32,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order.restaurantName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l10n.howWasYourOrder,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 100.ms)
                      .slideY(begin: -0.1, end: 0),
                  const SizedBox(height: 32),

                  // Rating Section
                  Text(
                    l10n.yourRating,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 200.ms),
                  const SizedBox(height: 16),
                  Center(
                    child: StarRatingWidget(
                      rating: _rating,
                      starSize: 48,
                      onRatingChanged: (rating) {
                        setState(() {
                          _rating = rating;
                        });
                        HapticFeedbackUtil.lightImpact();
                      },
                      readOnly: false,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 300.ms)
                      .scale(),
                  if (_rating > 0) ...[
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        '${_rating.toStringAsFixed(1)} / 5.0',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(),
                  ],
                  const SizedBox(height: 32),

                  // Review Comment Section
                  Text(
                    l10n.reviewText,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 400.ms),
                  const SizedBox(height: 8),
                  Text(
                    l10n.optional,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 400.ms),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _commentController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: l10n.writeReview,
                      hintStyle: const TextStyle(color: AppColors.textSecondary),
                      filled: true,
                      fillColor: AppColors.card,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                    ),
                    style: const TextStyle(color: AppColors.textPrimary),
                  )
                      .animate()
                      .fadeIn(delay: 500.ms)
                      .slideY(begin: 0.1, end: 0),
                  const SizedBox(height: 24),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitReview,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        l10n.submitReview,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 600.ms)
                      .slideY(begin: 0.1, end: 0),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (error, stack) => Center(
          child: Text(
            l10n.failedToLoadOrder,
            style: const TextStyle(color: AppColors.error),
          ),
        ),
      ),
    );
  }
}

