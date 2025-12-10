import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../logic/providers/auth_providers.dart';
import '../../../../logic/providers/order_providers.dart';
import '../../../../logic/providers/driver_location_providers.dart';
import '../../../../logic/providers/websocket_providers.dart';
import '../../../../logic/providers/notification_providers.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/haptic_feedback.dart';
import 'package:geolocator/geolocator.dart';
import '../../../customer/widgets/common/loading_state_widget.dart';

/// Home screen for Driver app with drawer navigation
class DriverHomeScreen extends ConsumerStatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  ConsumerState<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends ConsumerState<DriverHomeScreen> {
  bool _isOnline = false;

  @override
  void initState() {
    super.initState();
    // Request location permission on init
    _requestLocationPermission();
    // Connect to WebSocket for real-time updates
    // Initialize notifications
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _connectWebSocket();
      _initializeNotifications();
    });
  }

  Future<void> _connectWebSocket() async {
    final user = ref.read(currentUserProvider);
    if (user != null) {
      final wsService = ref.read(webSocketServiceProvider);
      await wsService.connect(
        userId: user.id,
        userType: AppConstants.appTypeDriver,
      );
    }
  }

  Future<void> _initializeNotifications() async {
    final notificationService = ref.read(notificationServiceProvider);
    await notificationService.initialize();
    await notificationService.requestPermission();

    // Subscribe to driver-specific topics
    await notificationService.subscribeToTopic('driver_orders');
    await notificationService.subscribeToTopic('driver_updates');
  }

  Future<void> _requestLocationPermission() async {
    final service = ref.read(driverLocationServiceProvider);
    await service.requestPermission();
  }

  Future<void> _handleOnlineStatusChange(bool value) async {
    setState(() {
      _isOnline = value;
    });
    HapticFeedbackUtil.lightImpact();

    if (value) {
      // Driver is going online - start location tracking
      try {
        final service = ref.read(driverLocationServiceProvider);
        final hasPermission = await service.requestPermission();

        if (hasPermission) {
          // Start location tracking by accessing the stream provider
          // The stream provider will automatically start tracking
          ref.read(driverPositionStreamProvider);

          // Start sending location updates to backend
          // Get the stream from the service directly
          final locationService = ref.read(driverLocationServiceProvider);
          final locationUpdateService = ref.read(
            driverLocationUpdateServiceProvider,
          );
          final driver = ref.read(currentUserProvider);

          if (driver != null) {
            // Get the position stream directly from the service
            final positionStream = locationService.startLocationTracking(
              accuracy: LocationAccuracy.high,
              distanceFilter: 10,
            );

            locationUpdateService.startSendingUpdates(
              driverId: driver.id,
              positionStream: positionStream,
            );
          }

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(context.l10n.locationTrackingStarted),
                backgroundColor: AppColors.success,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        } else {
          // Permission denied
          setState(() {
            _isOnline = false;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(context.l10n.locationPermissionRequired),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      } catch (e) {
        setState(() {
          _isOnline = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${context.l10n.failedToStartLocationTracking}: $e',
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } else {
      // Driver is going offline - stop location tracking
      final service = ref.read(driverLocationServiceProvider);
      await service.stopLocationTracking();

      // Stop sending location updates
      final locationUpdateService = ref.read(
        driverLocationUpdateServiceProvider,
      );
      await locationUpdateService.stopSendingUpdates();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.locationTrackingStopped),
            backgroundColor: AppColors.textSecondary,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final l10n = context.l10n;

    if (user == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Text(
            l10n.pleaseLoginFirst,
            style: const TextStyle(color: AppColors.textPrimary),
          ),
        ),
      );
    }

    final activeOrdersAsync =
        user.id.isNotEmpty
            ? ref.watch(driverActiveOrdersProvider(user.id))
            : const AsyncValue.data(<dynamic>[]);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          l10n.appName,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        actions: [
          // Online/Offline Toggle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Switch(
              value: _isOnline,
              onChanged: _handleOnlineStatusChange,
              activeColor: AppColors.success,
            ),
          ),
          // Notifications
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Navigate to notifications
            },
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: AppColors.surface,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(gradient: AppColors.primaryGradient),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.textPrimary,
                    child: Text(
                      user.name?.substring(0, 1).toUpperCase() ?? 'D',
                      style: const TextStyle(
                        fontSize: 24,
                        color: AppColors.background,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user.name ?? 'Driver',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    user.email,
                    style: TextStyle(
                      color: AppColors.textPrimary.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home, color: AppColors.primary),
              title: Text(
                l10n.home,
                style: const TextStyle(color: AppColors.textPrimary),
              ),
              selected: true,
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.delivery_dining,
                color: AppColors.primary,
              ),
              title: Text(
                l10n.deliveryRequests,
                style: const TextStyle(color: AppColors.textPrimary),
              ),
              onTap: () {
                Navigator.pop(context);
                context.push('/driver/delivery-requests');
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.local_shipping,
                color: AppColors.primary,
              ),
              title: Text(
                l10n.activeOrders,
                style: const TextStyle(color: AppColors.textPrimary),
              ),
              onTap: () {
                Navigator.pop(context);
                // Navigate to active orders
              },
            ),
            ListTile(
              leading: const Icon(Icons.history, color: AppColors.primary),
              title: Text(
                l10n.driverOrderHistory,
                style: const TextStyle(color: AppColors.textPrimary),
              ),
              onTap: () {
                Navigator.pop(context);
                context.push('/driver/order-history');
              },
            ),
            ListTile(
              leading: const Icon(Icons.analytics, color: AppColors.primary),
              title: Text(
                l10n.earnings,
                style: const TextStyle(color: AppColors.textPrimary),
              ),
              onTap: () {
                Navigator.pop(context);
                context.push('/driver/earnings');
              },
            ),
            const Divider(color: AppColors.border),
            ListTile(
              leading: const Icon(
                Icons.person_outline,
                color: AppColors.primary,
              ),
              title: Text(
                l10n.profile,
                style: const TextStyle(color: AppColors.textPrimary),
              ),
              onTap: () {
                Navigator.pop(context);
                context.push('/driver/profile');
              },
            ),
            const Divider(color: AppColors.border),
            ListTile(
              leading: const Icon(
                Icons.settings,
                color: AppColors.textSecondary,
              ),
              title: Text(
                l10n.settings,
                style: const TextStyle(color: AppColors.textPrimary),
              ),
              onTap: () {
                Navigator.pop(context);
                context.push('/driver/settings');
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.error),
              title: Text(
                l10n.logout,
                style: const TextStyle(color: AppColors.error),
              ),
              onTap: () async {
                Navigator.pop(context);
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) {
                  context.go('/driver/login');
                }
              },
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        onRefresh: () async {
          if (user.id.isNotEmpty) {
            ref.invalidate(driverActiveOrdersProvider(user.id));
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Welcome Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [AppColors.cardShadow],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${l10n.welcomeBack}, ${user.name ?? 'Driver'}!',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isOnline
                          ? l10n.youAreOnlineAndReady
                          : l10n.turnOnToStartReceiving,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          _isOnline ? Icons.circle : Icons.circle_outlined,
                          color:
                              _isOnline
                                  ? AppColors.success
                                  : AppColors.textSecondary,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isOnline ? l10n.online : l10n.offline,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color:
                                _isOnline
                                    ? AppColors.success
                                    : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.1, end: 0),
              const SizedBox(height: 24),

              // Quick Actions
              Text(
                l10n.quickActions,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _ActionCard(
                      icon: Icons.delivery_dining,
                      title: l10n.deliveryRequests,
                      subtitle: l10n.viewAvailableOrders,
                      color: AppColors.primary,
                      onTap: () {
                        context.push('/driver/delivery-requests');
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _ActionCard(
                      icon: Icons.local_shipping,
                      title: l10n.activeOrders,
                      subtitle: l10n.trackDeliveries,
                      color: AppColors.accent,
                      onTap: () {
                        // Navigate to active orders
                      },
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.1, end: 0),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _ActionCard(
                      icon: Icons.history,
                      title: l10n.driverOrderHistory,
                      subtitle: l10n.pastDeliveries,
                      color: AppColors.secondary,
                      onTap: () {
                        context.push('/driver/order-history');
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _ActionCard(
                      icon: Icons.analytics,
                      title: l10n.earnings,
                      subtitle: l10n.viewEarnings,
                      color: AppColors.success,
                      onTap: () {
                        context.push('/driver/earnings');
                      },
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.1, end: 0),
              const SizedBox(height: 32),

              // Active Orders Section
              Text(
                l10n.activeOrders,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ).animate().fadeIn(delay: 500.ms),
              const SizedBox(height: 16),

              activeOrdersAsync.when(
                data: (orders) {
                  if (orders.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.local_shipping_outlined,
                            size: 48,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.noActiveOrders,
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children:
                        orders.map<Widget>((order) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppColors.primary.withOpacity(
                                  0.2,
                                ),
                                child: const Icon(
                                  Icons.shopping_bag,
                                  color: AppColors.primary,
                                ),
                              ),
                              title: Text(
                                'Order #${order.id.substring(0, 8)}',
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                order.restaurantName,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              trailing: const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: AppColors.textSecondary,
                              ),
                              onTap: () {
                                context.push(
                                  '/driver/order-details/${order.id}',
                                );
                              },
                            ),
                          );
                        }).toList(),
                  );
                },
                loading: () => const LoadingStateWidget(),
                error:
                    (error, stack) => Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.error),
                      ),
                      child: Text(
                        'Error loading orders',
                        style: const TextStyle(color: AppColors.error),
                      ),
                    ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton:
          _isOnline
              ? FloatingActionButton.extended(
                onPressed: () {
                  context.push('/driver/delivery-requests');
                },
                backgroundColor: AppColors.primary,
                icon: const Icon(Icons.delivery_dining),
                label: Text(l10n.deliveryRequests),
              )
              : null,
    );
  }
}

/// Action card widget for quick actions
class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
