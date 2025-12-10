import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:async';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../logic/providers/auth_providers.dart';
import '../../../../logic/providers/restaurant_providers.dart';
import '../../../../logic/providers/order_providers.dart';
import '../../../../logic/providers/websocket_providers.dart';
import '../../../../logic/providers/notification_providers.dart';
import '../../../../core/services/websocket_service.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/haptic_feedback.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/logger.dart';
import '../../../../data/datasources/local_storage_service.dart';
import '../../../../data/models/order_model.dart';
import '../../../customer/widgets/common/loading_state_widget.dart';
import '../../../customer/widgets/common/error_state_widget.dart';

/// Home screen for Restaurant app with Dashboard
class RestaurantHomeScreen extends ConsumerStatefulWidget {
  const RestaurantHomeScreen({super.key});

  @override
  ConsumerState<RestaurantHomeScreen> createState() =>
      _RestaurantHomeScreenState();
}

class _RestaurantHomeScreenState extends ConsumerState<RestaurantHomeScreen> {
  static const String _autoAcceptKey = 'restaurant_auto_accept_orders';
  final Map<String, Timer> _autoAcceptTimers = {};

  @override
  void initState() {
    super.initState();
    // Connect to WebSocket for real-time updates
    // Initialize notifications
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _connectWebSocket();
      _initializeNotifications();
      _listenToWebSocketMessages();
      _listenToNotifications();
      // Check for pending orders after connection
      Future.delayed(const Duration(milliseconds: 500), () {
        _checkForPendingOrders();
      });
    });
  }

  void _checkForPendingOrders() {
    final restaurantId = '1'; // Mock restaurant ID
    // Refresh orders to show any pending orders
    ref.invalidate(restaurantOrdersProvider(restaurantId));
    ref.invalidate(restaurantStatisticsProvider(restaurantId));
  }

  @override
  void dispose() {
    // Cancel all auto-accept timers
    for (var timer in _autoAcceptTimers.values) {
      timer.cancel();
    }
    _autoAcceptTimers.clear();
    // Disconnect WebSocket when screen is disposed
    ref.read(webSocketServiceProvider).disconnect();
    super.dispose();
  }

  Future<void> _connectWebSocket() async {
    final user = ref.read(currentUserProvider);
    if (user != null) {
      final wsService = ref.read(webSocketServiceProvider);
      await wsService.connect(
        userId: user.id,
        userType: AppConstants.appTypeRestaurant,
      );
      Logger.d('RestaurantHomeScreen', 'WebSocket connected for restaurant: ${user.id}');
    }
  }

  Future<void> _initializeNotifications() async {
    final notificationService = ref.read(notificationServiceProvider);
    await notificationService.initialize();
    await notificationService.requestPermission();

    // Subscribe to restaurant-specific topics
    await notificationService.subscribeToTopic('restaurant_orders');
    await notificationService.subscribeToTopic('restaurant_updates');
  }

  void _listenToWebSocketMessages() {
    final restaurantId = '1'; // Mock restaurant ID

    // Listen to stream for future messages
    final wsService = ref.read(webSocketServiceProvider);
    final stream = wsService.messagesStream;
    if (stream != null) {
      Logger.d('RestaurantHomeScreen', 'Listening to WebSocket messages for restaurant: $restaurantId');
      stream.listen((message) {
        Logger.d('RestaurantHomeScreen', 'Received WebSocket message: ${message.type}');
        if (message.type == WebSocketMessageType.newOrder) {
          // Get order data from message
          final orderData = message.data;
          final orderRestaurantId = orderData['restaurant_id'] as String?;
          
          Logger.d('RestaurantHomeScreen', 'New order message - Order restaurant ID: $orderRestaurantId, This restaurant ID: $restaurantId');
          
          // Only process if this order is for this restaurant
          if (orderRestaurantId != null && orderRestaurantId != restaurantId) {
            Logger.d('RestaurantHomeScreen', 'Order is for different restaurant, ignoring');
            return;
          }
          
          // Get order ID from message data
          final orderId =
              orderData['id'] as String? ??
              orderData['orderId'] as String?;

          Logger.d('RestaurantHomeScreen', 'Processing new order: $orderId');

          if (orderId != null) {
            // Cancel any existing timer for this order
            _autoAcceptTimers[orderId]?.cancel();

            // Refresh orders and statistics
            ref.invalidate(restaurantOrdersProvider(restaurantId));
            ref.invalidate(restaurantStatisticsProvider(restaurantId));

            // Check if auto-accept is enabled and restaurant is open
            final autoAcceptEnabled =
                LocalStorageService.instance.get<bool>(_autoAcceptKey) ?? false;
            final restaurantAsync = ref.read(
              restaurantByIdProvider(restaurantId),
            );

            restaurantAsync.whenData((restaurant) {
              if (autoAcceptEnabled && restaurant?.isOpen == true && mounted) {
                // Start auto-accept timer (30 seconds)
                _startAutoAcceptTimer(orderId, restaurantId);

                // Show notification with countdown
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${context.l10n.newOrderReceived}\n${context.l10n.orderWillBeAcceptedIn} 30 ${context.l10n.seconds}',
                      ),
                      backgroundColor: AppColors.accent,
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 30),
                      action: SnackBarAction(
                        label: context.l10n.view,
                        textColor: AppColors.textPrimary,
                        onPressed: () {
                          context.push('/restaurant/orders');
                        },
                      ),
                    ),
                  );
                }
              } else {
                // Manual acceptance required
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(context.l10n.newOrderReceived),
                      backgroundColor: AppColors.primary,
                      behavior: SnackBarBehavior.floating,
                      action: SnackBarAction(
                        label: context.l10n.view,
                        textColor: AppColors.textPrimary,
                        onPressed: () {
                          context.push('/restaurant/orders');
                        },
                      ),
                    ),
                  );
                }
              }
            });
          }
        } else if (message.type == WebSocketMessageType.orderUpdate) {
          // Order status updated - refresh orders
          final orderData = message.data;
          final orderStatus = orderData['status'] as String?;
          final orderId =
              orderData['id'] as String? ??
              orderData['orderId'] as String?;
          
          // Check if order is for this restaurant
          final orderRestaurantId = orderData['restaurant_id'] as String?;
          if (orderRestaurantId != null && orderRestaurantId != restaurantId) {
            return; // This order is for a different restaurant
          }
          
          ref.invalidate(restaurantOrdersProvider(restaurantId));
          ref.invalidate(restaurantStatisticsProvider(restaurantId));

          // Cancel auto-accept timer if order was already accepted/cancelled
          if (orderId != null) {
            _autoAcceptTimers[orderId]?.cancel();
            _autoAcceptTimers.remove(orderId);
          }

          // Show notification if order is delivered
          if (orderStatus == 'delivered' && orderId != null && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${context.l10n.orderDelivered} - Order #${orderId.substring(orderId.length - 6)}'),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 3),
                action: SnackBarAction(
                  label: context.l10n.view,
                  textColor: AppColors.textPrimary,
                  onPressed: () {
                    context.push('/restaurant/orders/$orderId');
                  },
                ),
              ),
            );
          }
        }
      });
    }
  }

  void _startAutoAcceptTimer(String orderId, String restaurantId) {
    int remainingSeconds = 30;

    // Cancel existing timer if any
    _autoAcceptTimers[orderId]?.cancel();

    // Create new timer
    final timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      remainingSeconds--;

      if (remainingSeconds <= 0) {
        // Accept order automatically
        timer.cancel();
        _autoAcceptTimers.remove(orderId);
        _acceptOrderAutomatically(orderId, restaurantId);
      }
    });

    _autoAcceptTimers[orderId] = timer;
  }

  Future<void> _acceptOrderAutomatically(
    String orderId,
    String restaurantId,
  ) async {
    try {
      final repository = ref.read(orderRepositoryProvider);
      await repository.updateOrderStatus(
        orderId: orderId,
        status: OrderStatus.accepted,
      );

      // Refresh orders and statistics
      ref.invalidate(restaurantOrdersProvider(restaurantId));
      ref.invalidate(restaurantStatisticsProvider(restaurantId));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.autoAcceptedOrder),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // Handle error silently or show notification
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${context.l10n.failedToLoad}: ${e.toString()}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  void _listenToNotifications() {
    // Listen to notification service stream directly
    final notificationService = ref.read(notificationServiceProvider);
    final stream = notificationService.notificationStream;
    if (stream != null) {
      stream.listen((notificationData) {
        // Handle notification
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(notificationData.title),
              backgroundColor: AppColors.primary,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      });
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

    // For now, use first restaurant ID from mock data
    // In real app, this would come from user's restaurant
    final restaurantId = '1'; // Mock restaurant ID

    // Load restaurant status
    final restaurantAsync = ref.watch(restaurantByIdProvider(restaurantId));
    final statisticsAsync = ref.watch(
      restaurantStatisticsProvider(restaurantId),
    );
    final ordersAsync = ref.watch(restaurantOrdersProvider(restaurantId));

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
          // Open/Closed Toggle (Main status control)
          restaurantAsync.when(
            data:
                (restaurant) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Switch(
                    value: restaurant?.isOpen ?? false,
                    onChanged:
                        (value) => _handleOpenStatusChange(restaurantId, value),
                    activeColor: AppColors.success,
                  ),
                ),
            loading:
                () => const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: SizedBox(
                    width: 48,
                    height: 24,
                    child: Center(
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ),
            error: (_, __) => const SizedBox.shrink(),
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
      drawer: _buildDrawer(context, user, l10n),
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        onRefresh: () async {
          ref.invalidate(restaurantStatisticsProvider(restaurantId));
          ref.invalidate(restaurantOrdersProvider(restaurantId));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Welcome Card with Open/Closed Status
              restaurantAsync.when(
                data:
                    (restaurant) => _buildWelcomeCard(
                      user,
                      l10n,
                      restaurant?.isOpen ?? false,
                    ),
                loading: () => const LoadingStateWidget(),
                error: (_, __) => _buildWelcomeCard(user, l10n, false),
              ),
              const SizedBox(height: 24),

              // Statistics Cards
              statisticsAsync.when(
                data: (stats) => _StatisticsCards(stats: stats),
                loading: () => const LoadingStateWidget(),
                error:
                    (error, stack) => ErrorStateWidget(
                      message: l10n.failedToLoad,
                      error: error.toString(),
                      onRetry: () {
                        ref.invalidate(
                          restaurantStatisticsProvider(restaurantId),
                        );
                      },
                    ),
              ),
              const SizedBox(height: 24),

              // Quick Actions
              _buildQuickActions(context, l10n),
              const SizedBox(height: 24),

              // Recent Orders
              Text(
                l10n.recentOrders,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ).animate().fadeIn(delay: 300.ms),
              const SizedBox(height: 16),
              ordersAsync.when(
                data: (orders) {
                  final recentOrders = orders.take(5).toList();
                  if (recentOrders.isEmpty) {
                    return _buildEmptyOrders(l10n);
                  }
                  return _RecentOrdersList(orders: recentOrders);
                },
                loading: () => const LoadingStateWidget(),
                error:
                    (error, stack) => ErrorStateWidget(
                      message: l10n.failedToLoadOrders,
                      error: error.toString(),
                      onRetry: () {
                        ref.invalidate(restaurantOrdersProvider(restaurantId));
                      },
                    ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(user, l10n, bool isOpen) {
    return Container(
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
            '${l10n.welcomeBack}, ${user.name ?? l10n.restaurant}!',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                isOpen ? Icons.check_circle : Icons.cancel,
                color: isOpen ? AppColors.success : AppColors.error,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                isOpen ? l10n.restaurantIsOpen : l10n.restaurantIsClosed,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textPrimary.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: -0.1, end: 0);
  }

  Widget _buildQuickActions(BuildContext context, l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.quickActions,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                icon: Icons.receipt_long,
                title: l10n.orders,
                color: AppColors.primary,
                onTap: () {
                  HapticFeedbackUtil.lightImpact();
                  context.push('/restaurant/orders');
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.restaurant_menu,
                title: l10n.manageMenu,
                color: AppColors.accent,
                onTap: () {
                  HapticFeedbackUtil.lightImpact();
                  context.push('/restaurant/menu');
                },
              ),
            ),
          ],
        ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.1, end: 0),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                icon: Icons.analytics,
                title: l10n.viewAnalytics,
                color: AppColors.secondary,
                onTap: () {
                  HapticFeedbackUtil.lightImpact();
                  context.push('/restaurant/analytics');
                },
              ),
            ),
          ],
        ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.1, end: 0),
      ],
    );
  }

  Widget _buildEmptyOrders(l10n) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noRestaurantOrders,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, user, l10n) {
    return Drawer(
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
                    user.name?.substring(0, 1).toUpperCase() ?? 'R',
                    style: const TextStyle(
                      fontSize: 24,
                      color: AppColors.background,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  user.name ?? l10n.restaurant,
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
            leading: const Icon(Icons.dashboard, color: AppColors.primary),
            title: Text(
              l10n.dashboard,
              style: const TextStyle(color: AppColors.textPrimary),
            ),
            selected: true,
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long, color: AppColors.primary),
            title: Text(
              l10n.orders,
              style: const TextStyle(color: AppColors.textPrimary),
            ),
            onTap: () {
              Navigator.pop(context);
              context.push('/restaurant/orders');
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.restaurant_menu,
              color: AppColors.primary,
            ),
            title: Text(
              l10n.manageMenu,
              style: const TextStyle(color: AppColors.textPrimary),
            ),
            onTap: () {
              Navigator.pop(context);
              context.push('/restaurant/menu');
            },
          ),
          ListTile(
            leading: const Icon(Icons.analytics, color: AppColors.primary),
            title: Text(
              l10n.viewAnalytics,
              style: const TextStyle(color: AppColors.textPrimary),
            ),
            onTap: () {
              Navigator.pop(context);
              context.push('/restaurant/analytics');
            },
          ),
          const Divider(color: AppColors.border),
          ListTile(
            leading: const Icon(Icons.person_outline, color: AppColors.primary),
            title: Text(
              l10n.profile,
              style: const TextStyle(color: AppColors.textPrimary),
            ),
            onTap: () {
              Navigator.pop(context);
              context.push('/restaurant/profile');
            },
          ),
          const Divider(color: AppColors.border),
          ListTile(
            leading: const Icon(Icons.settings, color: AppColors.textSecondary),
            title: Text(
              l10n.settings,
              style: const TextStyle(color: AppColors.textPrimary),
            ),
            onTap: () {
              Navigator.pop(context);
              context.push('/restaurant/settings');
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
                context.go('/restaurant/login');
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _handleOpenStatusChange(String restaurantId, bool value) async {
    HapticFeedbackUtil.mediumImpact();

    try {
      final repository = ref.read(restaurantRepositoryProvider);
      await repository.updateRestaurantStatus(
        restaurantId: restaurantId,
        isOpen: value,
      );

      // Refresh restaurant data and statistics
      ref.invalidate(restaurantByIdProvider(restaurantId));
      ref.invalidate(restaurantStatisticsProvider(restaurantId));

      if (mounted) {
        final l10n = context.l10n;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              value ? l10n.restaurantIsOpen : l10n.restaurantIsClosed,
            ),
            backgroundColor:
                value ? AppColors.success : AppColors.textSecondary,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${context.l10n.failedToLoad}: ${e.toString()}'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }
}

/// Statistics Cards Widget
class _StatisticsCards extends StatelessWidget {
  const _StatisticsCards({required this.stats});

  final dynamic stats;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.receipt_long,
                title: l10n.todaysOrders,
                value: '${stats.todayOrders}',
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.attach_money,
                title: l10n.todaysRevenue,
                value: CurrencyFormatter.formatPrice(
                  stats.todayRevenue,
                  context,
                ),
                color: AppColors.accent,
              ),
            ),
          ],
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.pending,
                title: l10n.pendingOrders,
                value: '${stats.pendingOrders}',
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.local_shipping,
                title: l10n.activeOrdersCount,
                value: '${stats.activeOrders}',
                color: AppColors.success,
              ),
            ),
          ],
        ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0),
      ],
    );
  }
}

/// Statistics Card Widget
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [AppColors.cardShadow],
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
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Quick Action Card Widget
class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
          boxShadow: [AppColors.cardShadow],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Recent Orders List Widget
class _RecentOrdersList extends StatelessWidget {
  const _RecentOrdersList({required this.orders});

  final List<dynamic> orders;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [...orders.map((order) => _OrderCard(order: order)).toList()],
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0);
  }
}

/// Order Card Widget
class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final dynamic order;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [AppColors.cardShadow],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.receipt_long,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${l10n.orderNumber}${order.id.substring(0, 8)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  CurrencyFormatter.formatPrice(order.total, context),
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getStatusColor(order.status).withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              order.status.displayName,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _getStatusColor(order.status),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(status) {
    switch (status.toString().split('.').last) {
      case 'pending':
        return AppColors.secondary;
      case 'accepted':
      case 'preparing':
        return AppColors.accent;
      case 'ready':
        return AppColors.success;
      default:
        return AppColors.textSecondary;
    }
  }
}
