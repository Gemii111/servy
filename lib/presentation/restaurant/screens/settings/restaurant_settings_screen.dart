import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/utils/haptic_feedback.dart';
import '../../../../data/datasources/local_storage_service.dart';

/// Restaurant Settings Screen
class RestaurantSettingsScreen extends ConsumerStatefulWidget {
  const RestaurantSettingsScreen({super.key});

  @override
  ConsumerState<RestaurantSettingsScreen> createState() => _RestaurantSettingsScreenState();
}

class _RestaurantSettingsScreenState extends ConsumerState<RestaurantSettingsScreen> {
  static const String _autoAcceptKey = 'restaurant_auto_accept_orders';

  bool _getAutoAcceptSetting(WidgetRef ref) {
    return LocalStorageService.instance.get<bool>(_autoAcceptKey) ?? false;
  }

  void _setAutoAcceptSetting(WidgetRef ref, bool value) {
    LocalStorageService.instance.save(_autoAcceptKey, value);
    setState(() {}); // Update UI
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = ref.watch(localeProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          l10n.restaurantSettings,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Order Management Settings
            _SettingsSection(
              title: 'Order Management',
              children: [
                SwitchListTile(
                  value: _getAutoAcceptSetting(ref),
                  onChanged: (value) {
                    HapticFeedbackUtil.lightImpact();
                    _setAutoAcceptSetting(ref, value);
                  },
                  title: Text(
                    l10n.autoAcceptOrders,
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                  subtitle: Text(
                    l10n.autoAcceptOrdersDescription,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                  activeColor: AppColors.primary,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Notifications Settings
            _SettingsSection(
              title: l10n.notifications,
              children: [
                SwitchListTile(
                  value: true, // Mock - should be from provider
                  onChanged: (value) {
                    HapticFeedbackUtil.lightImpact();
                    // Handle notification toggle
                  },
                  title: Text(
                    l10n.enableNotifications,
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                  subtitle: Text(
                    l10n.receiveOrderUpdates,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  activeColor: AppColors.primary,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Language Settings
            _SettingsSection(
              title: l10n.language,
              children: [
                ListTile(
                  leading: const Icon(Icons.language, color: AppColors.primary),
                  title: Text(
                    locale.languageCode == 'ar' ? 'العربية' : 'English',
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                  trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                  onTap: () {
                    HapticFeedbackUtil.lightImpact();
                    ref.read(localeProvider.notifier).toggleLocale();
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Support & Info
            _SettingsSection(
              title: l10n.support,
              children: [
                ListTile(
                  leading: const Icon(Icons.help_outline, color: AppColors.textSecondary),
                  title: Text(
                    l10n.helpSupport,
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                  trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                  onTap: () {
                    HapticFeedbackUtil.lightImpact();
                    // Navigate to help
                  },
                ),
                const Divider(color: AppColors.border, height: 1),
                ListTile(
                  leading: const Icon(Icons.info_outline, color: AppColors.textSecondary),
                  title: Text(
                    l10n.aboutUs,
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                  trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                  onTap: () {
                    HapticFeedbackUtil.lightImpact();
                    // Show about dialog
                  },
                ),
                const Divider(color: AppColors.border, height: 1),
                ListTile(
                  leading: const Icon(Icons.phone_outlined, color: AppColors.textSecondary),
                  title: Text(
                    l10n.contactSupport,
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                  trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                  onTap: () {
                    HapticFeedbackUtil.lightImpact();
                    // Navigate to contact support
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Legal
            _SettingsSection(
              title: l10n.legal,
              children: [
                ListTile(
                  leading: const Icon(Icons.description_outlined, color: AppColors.textSecondary),
                  title: Text(
                    l10n.termsAndConditions,
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                  trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                  onTap: () {
                    HapticFeedbackUtil.lightImpact();
                    // Navigate to terms
                  },
                ),
                const Divider(color: AppColors.border, height: 1),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined, color: AppColors.textSecondary),
                  title: Text(
                    l10n.privacyPolicy,
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                  trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                  onTap: () {
                    HapticFeedbackUtil.lightImpact();
                    // Navigate to privacy policy
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // App Version
            Text(
              '${l10n.version} 1.0.0',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

/// Settings Section Widget
class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [AppColors.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

