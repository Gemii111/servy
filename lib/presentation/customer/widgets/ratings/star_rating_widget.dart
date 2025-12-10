import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Star Rating Widget - Display and interactive star ratings
class StarRatingWidget extends StatelessWidget {
  const StarRatingWidget({
    super.key,
    required this.rating,
    this.onRatingChanged,
    this.starSize = 24.0,
    this.allowHalfRating = false,
    this.readOnly = false,
    this.color = AppColors.warning,
  });

  final double rating; // 0.0 to 5.0
  final ValueChanged<double>? onRatingChanged;
  final double starSize;
  final bool allowHalfRating;
  final bool readOnly;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starValue = index + 1.0;
        final isFullStar = rating >= starValue;
        final isHalfStar = !isFullStar && rating >= starValue - 0.5;

        return GestureDetector(
          onTap: readOnly || onRatingChanged == null
              ? null
              : () {
                  if (allowHalfRating) {
                    // Toggle between full and half star
                    final newRating = isFullStar ? starValue - 0.5 : starValue;
                    onRatingChanged!(newRating);
                  } else {
                    onRatingChanged!(starValue);
                  }
                },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            child: Icon(
              isFullStar
                  ? Icons.star
                  : isHalfStar
                      ? Icons.star_half
                      : Icons.star_border,
              size: starSize,
              color: color,
            ),
          ),
        );
      }),
    );
  }
}

/// Star Rating Display Widget - Read-only display
class StarRatingDisplay extends StatelessWidget {
  const StarRatingDisplay({
    super.key,
    required this.rating,
    this.starSize = 18.0,
    this.showNumber = true,
    this.numberStyle,
    this.color = AppColors.warning,
  });

  final double rating; // 0.0 to 5.0
  final double starSize;
  final bool showNumber;
  final TextStyle? numberStyle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        StarRatingWidget(
          rating: rating,
          starSize: starSize,
          readOnly: true,
          color: color,
        ),
        if (showNumber) ...[
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: numberStyle ??
                TextStyle(
                  fontSize: starSize * 0.7,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
        ],
      ],
    );
  }
}

