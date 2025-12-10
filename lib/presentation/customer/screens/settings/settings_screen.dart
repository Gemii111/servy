import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../widgets/common/cart_app_bar_icon.dart';

/// Settings screen
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _locationEnabled = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          context.l10n.settings,
          style: TextStyle(color: colorScheme.onSurface),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        actions: const [
          CartAppBarIcon(),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Notifications Section
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(
                    theme.brightness == Brightness.dark ? 0.3 : 0.08,
                  ),
                  blurRadius: 20,
                  offset: Offset(
                    0,
                    theme.brightness == Brightness.dark ? 8 : 4,
                  ),
                ),
              ],
            ),
            child: ListTile(
              leading: Icon(
                Icons.notifications_outlined,
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
              title: Text(
                context.l10n.pushNotifications,
                style: TextStyle(color: colorScheme.onSurface),
              ),
              subtitle: Text(
                context.l10n.receiveOrderUpdates,
                style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
              ),
              trailing: Switch(
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() => _notificationsEnabled = value);
                },
                activeColor: colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Location Section
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(
                    theme.brightness == Brightness.dark ? 0.3 : 0.08,
                  ),
                  blurRadius: 20,
                  offset: Offset(
                    0,
                    theme.brightness == Brightness.dark ? 8 : 4,
                  ),
                ),
              ],
            ),
            child: ListTile(
              leading: Icon(
                Icons.location_on_outlined,
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
              title: Text(
                context.l10n.locationServices,
                style: TextStyle(color: colorScheme.onSurface),
              ),
              subtitle: Text(
                context.l10n.allowLocationAccess,
                style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
              ),
              trailing: Switch(
                value: _locationEnabled,
                onChanged: (value) {
                  setState(() => _locationEnabled = value);
                },
                activeColor: colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Language Section
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(
                    theme.brightness == Brightness.dark ? 0.3 : 0.08,
                  ),
                  blurRadius: 20,
                  offset: Offset(
                    0,
                    theme.brightness == Brightness.dark ? 8 : 4,
                  ),
                ),
              ],
            ),
            child: Consumer(
              builder: (context, ref, child) {
                final currentLocale = ref.watch(localeProvider);
                final currentLanguage =
                    currentLocale.languageCode == 'ar' ? 'العربية' : 'English';

                return ListTile(
                  leading: Icon(
                    Icons.language_outlined,
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                  title: Text(
                    context.l10n.language,
                    style: TextStyle(color: colorScheme.onSurface),
                  ),
                  subtitle: Text(
                    currentLanguage,
                    style: TextStyle(
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                  onTap: () {
                    context.push('/language-selection');
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          // About Section
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(
                    theme.brightness == Brightness.dark ? 0.3 : 0.08,
                  ),
                  blurRadius: 20,
                  offset: Offset(
                    0,
                    theme.brightness == Brightness.dark ? 8 : 4,
                  ),
                ),
              ],
            ),
            child: ListTile(
              leading: Icon(
                Icons.info_outlined,
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
              title: Text(
                context.l10n.about,
                style: TextStyle(color: colorScheme.onSurface),
              ),
              subtitle: Text(
                context.l10n.version,
                style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        backgroundColor: colorScheme.surface,
                        title: Text(
                          'Servy',
                          style: TextStyle(color: colorScheme.onSurface),
                        ),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.restaurant_menu,
                              size: 48,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Version 1.0.0',
                              style: TextStyle(
                                color: colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(
                              context.l10n.ok,
                              style: TextStyle(color: colorScheme.primary),
                            ),
                          ),
                        ],
                      ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          // Privacy Policy & Terms
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(
                    theme.brightness == Brightness.dark ? 0.3 : 0.08,
                  ),
                  blurRadius: 20,
                  offset: Offset(
                    0,
                    theme.brightness == Brightness.dark ? 8 : 4,
                  ),
                ),
              ],
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.privacy_tip_outlined,
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                  title: Text(
                    context.l10n.privacyPolicy,
                    style: TextStyle(color: colorScheme.onSurface),
                  ),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(context.l10n.privacyPolicyComingSoon),
                        backgroundColor: colorScheme.surface,
                      ),
                    );
                  },
                ),
                Divider(color: colorScheme.outline.withOpacity(0.2), height: 1),
                ListTile(
                  leading: Icon(
                    Icons.description_outlined,
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                  title: Text(
                    context.l10n.termsOfService,
                    style: TextStyle(color: colorScheme.onSurface),
                  ),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(context.l10n.termsComingSoon),
                        backgroundColor: colorScheme.surface,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
