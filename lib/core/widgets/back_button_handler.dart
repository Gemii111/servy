import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/app_localizations.dart';

/// Widget to handle back button press
/// Shows exit confirmation dialog when trying to exit from main screens
class BackButtonHandler extends StatelessWidget {
  const BackButtonHandler({
    super.key,
    required this.child,
    this.onBackPressed,
    this.showExitDialog = false,
  });

  final Widget child;
  final VoidCallback? onBackPressed;
  final bool showExitDialog;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;

        if (onBackPressed != null) {
          onBackPressed!();
          return;
        }

        if (showExitDialog) {
          final shouldExit = await _showExitDialog(context);
          if (shouldExit) {
            // Exit app
            SystemNavigator.pop();
          }
        } else {
          // Allow normal back navigation
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: child,
    );
  }

  Future<bool> _showExitDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.card,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            title: Text(
              l10n?.exitApp ?? 'Exit App',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              l10n?.exitAppConfirm ?? 'Are you sure you want to exit?',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  l10n?.cancel ?? 'Cancel',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: AppColors.textPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(l10n?.exit ?? 'Exit'),
              ),
            ],
          ),
        ) ??
        false;
  }
}

