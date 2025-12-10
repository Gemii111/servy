import 'package:flutter/material.dart';
import '../../../../data/models/category_model.dart';
import '../../../../core/theme/app_colors.dart';

/// Dark theme category item widget with circular design
class CategoryItem extends StatelessWidget {
  const CategoryItem({
    super.key,
    required this.category,
    required this.onTap,
    this.isSelected = false,
  });

  final CategoryModel category;
  final VoidCallback onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 90,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surface : AppColors.card,
          borderRadius: BorderRadius.circular(24),
          border: isSelected
              ? Border.all(
                  color: AppColors.primary,
                  width: 2,
                )
              : Border.all(
                  color: AppColors.border,
                  width: 1,
                ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ]
              : [AppColors.cardShadow],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: isSelected
                    ? AppColors.primaryGradient
                    : LinearGradient(
                        colors: [
                          _colorFromHex(category.color).withOpacity(0.2),
                          _colorFromHex(category.color).withOpacity(0.1),
                        ],
                      ),
                shape: BoxShape.circle,
                border: isSelected
                    ? Border.all(
                        color: AppColors.primary,
                        width: 2,
                      )
                    : null,
              ),
              child: Center(
                child: Text(
                  category.iconUrl,
                  style: TextStyle(
                    fontSize: 28,
                    color: isSelected
                        ? AppColors.textPrimary
                        : _colorFromHex(category.color),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              category.name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Color _colorFromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) {
      buffer.write('ff');
    }
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
