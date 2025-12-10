import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/haptic_feedback.dart';

/// Driver Settings screen with driver-specific settings
class DriverSettingsScreen extends ConsumerStatefulWidget {
  const DriverSettingsScreen({super.key});

  @override
  ConsumerState<DriverSettingsScreen> createState() => _DriverSettingsScreenState();
}

class _DriverSettingsScreenState extends ConsumerState<DriverSettingsScreen> {
  bool _notificationsEnabled = true;
  bool _locationEnabled = true;
  bool _autoAcceptOrders = false;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          l10n.settings,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Driver-Specific Settings
          Text(
            'Driver Settings',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
              letterSpacing: 1.2,
            ),
          )
              .animate()
              .fadeIn(delay: 100.ms, duration: 400.ms),
          const SizedBox(height: 12),

          // Auto Accept Orders
          Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.border),
              boxShadow: [AppColors.cardShadow],
            ),
            child: ListTile(
              leading: const Icon(
                Icons.auto_mode,
                color: AppColors.primary,
              ),
              title: const Text(
                'Auto Accept Orders',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              subtitle: const Text(
                'Automatically accept orders when available',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              trailing: Switch(
                value: _autoAcceptOrders,
                onChanged: (value) {
                  HapticFeedbackUtil.lightImpact();
                  setState(() => _autoAcceptOrders = value);
                },
                activeColor: AppColors.primary,
              ),
            ),
          )
              .animate()
              .fadeIn(delay: 200.ms, duration: 400.ms)
              .slideX(begin: -0.2, end: 0),
          const SizedBox(height: 12),

          // Notifications Section
          Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.border),
              boxShadow: [AppColors.cardShadow],
            ),
            child: ListTile(
              leading: const Icon(
                Icons.notifications_outlined,
                color: AppColors.accent,
              ),
              title: Text(
                l10n.pushNotifications,
                style: const TextStyle(color: AppColors.textPrimary),
              ),
              subtitle: Text(
                l10n.receiveOrderUpdates,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              trailing: Switch(
                value: _notificationsEnabled,
                onChanged: (value) {
                  HapticFeedbackUtil.lightImpact();
                  setState(() => _notificationsEnabled = value);
                },
                activeColor: AppColors.primary,
              ),
            ),
          )
              .animate()
              .fadeIn(delay: 300.ms, duration: 400.ms)
              .slideX(begin: -0.2, end: 0),
          const SizedBox(height: 12),

          // Sound & Vibration
          Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.border),
              boxShadow: [AppColors.cardShadow],
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.volume_up_outlined,
                    color: AppColors.accent,
                  ),
                  title: const Text(
                    'Sound',
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                  subtitle: const Text(
                    'Play sound for new orders',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                  trailing: Switch(
                    value: _soundEnabled,
                    onChanged: (value) {
                      HapticFeedbackUtil.lightImpact();
                      setState(() => _soundEnabled = value);
                    },
                    activeColor: AppColors.primary,
                  ),
                ),
                Divider(color: AppColors.border, height: 1),
                ListTile(
                  leading: const Icon(
                    Icons.vibration_outlined,
                    color: AppColors.accent,
                  ),
                  title: const Text(
                    'Vibration',
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                  subtitle: const Text(
                    'Vibrate for new orders',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                  trailing: Switch(
                    value: _vibrationEnabled,
                    onChanged: (value) {
                      HapticFeedbackUtil.lightImpact();
                      setState(() => _vibrationEnabled = value);
                    },
                    activeColor: AppColors.primary,
                  ),
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(delay: 400.ms, duration: 400.ms)
              .slideX(begin: -0.2, end: 0),

          const SizedBox(height: 24),

          // General Settings
          Text(
            'General Settings',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
              letterSpacing: 1.2,
            ),
          )
              .animate()
              .fadeIn(delay: 500.ms, duration: 400.ms),
          const SizedBox(height: 12),

          // Location Section
          Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.border),
              boxShadow: [AppColors.cardShadow],
            ),
            child: ListTile(
              leading: const Icon(
                Icons.location_on_outlined,
                color: AppColors.accent,
              ),
              title: Text(
                l10n.locationServices,
                style: const TextStyle(color: AppColors.textPrimary),
              ),
              subtitle: Text(
                l10n.allowLocationAccess,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              trailing: Switch(
                value: _locationEnabled,
                onChanged: (value) {
                  HapticFeedbackUtil.lightImpact();
                  setState(() => _locationEnabled = value);
                },
                activeColor: AppColors.primary,
              ),
            ),
          )
              .animate()
              .fadeIn(delay: 600.ms, duration: 400.ms)
              .slideX(begin: -0.2, end: 0),
          const SizedBox(height: 12),

          // Language Section
          Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.border),
              boxShadow: [AppColors.cardShadow],
            ),
            child: Consumer(
              builder: (context, ref, child) {
                final currentLocale = ref.watch(localeProvider);
                final currentLanguage =
                    currentLocale.languageCode == 'ar' ? 'العربية' : 'English';

                return ListTile(
                  leading: const Icon(
                    Icons.language_outlined,
                    color: AppColors.accent,
                  ),
                  title: Text(
                    l10n.language,
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                  subtitle: Text(
                    currentLanguage,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: AppColors.textSecondary,
                  ),
                  onTap: () {
                    HapticFeedbackUtil.lightImpact();
                    context.push('/driver/language-selection');
                  },
                );
              },
            ),
          )
              .animate()
              .fadeIn(delay: 700.ms, duration: 400.ms)
              .slideX(begin: -0.2, end: 0),

          const SizedBox(height: 24),

          // About & Legal
          Text(
            'About & Legal',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
              letterSpacing: 1.2,
            ),
          )
              .animate()
              .fadeIn(delay: 800.ms, duration: 400.ms),
          const SizedBox(height: 12),

          // About Section
          Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.border),
              boxShadow: [AppColors.cardShadow],
            ),
            child: ListTile(
              leading: const Icon(
                Icons.info_outlined,
                color: AppColors.accent,
              ),
              title: Text(
                l10n.about,
                style: const TextStyle(color: AppColors.textPrimary),
              ),
              subtitle: Text(
                l10n.version,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              trailing: const Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
              ),
              onTap: () {
                HapticFeedbackUtil.lightImpact();
                _showAboutDialog(context);
              },
            ),
          )
              .animate()
              .fadeIn(delay: 900.ms, duration: 400.ms)
              .slideX(begin: -0.2, end: 0),
          const SizedBox(height: 12),

          // Privacy Policy & Terms
          Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.border),
              boxShadow: [AppColors.cardShadow],
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.privacy_tip_outlined,
                    color: AppColors.accent,
                  ),
                  title: Text(
                    l10n.privacyPolicy,
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: AppColors.textSecondary,
                  ),
                  onTap: () {
                    HapticFeedbackUtil.lightImpact();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.privacyPolicyComingSoon),
                        backgroundColor: AppColors.surface,
                      ),
                    );
                  },
                ),
                Divider(color: AppColors.border, height: 1),
                ListTile(
                  leading: const Icon(
                    Icons.description_outlined,
                    color: AppColors.accent,
                  ),
                  title: Text(
                    l10n.termsOfService,
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: AppColors.textSecondary,
                  ),
                  onTap: () {
                    HapticFeedbackUtil.lightImpact();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.termsComingSoon),
                        backgroundColor: AppColors.surface,
                      ),
                    );
                  },
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(delay: 1000.ms, duration: 400.ms)
              .slideX(begin: -0.2, end: 0),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.restaurant_menu,
                color: AppColors.textPrimary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Servy Driver',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Text(
              'Version 1.0.0',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Food Delivery Driver App',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              l10n.ok,
              style: const TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}


