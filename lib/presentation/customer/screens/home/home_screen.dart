import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/widgets/back_button_handler.dart';
import '../../../../logic/providers/category_providers.dart';
import '../../../../logic/providers/restaurant_providers.dart';
import '../../../../logic/providers/auth_providers.dart';
import '../../../../logic/providers/websocket_providers.dart';
import '../../../../logic/providers/notification_providers.dart';
import '../../../../logic/providers/order_providers.dart';
import '../../../../core/services/websocket_service.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../widgets/home/dark_header_widget.dart';
import '../../widgets/home/dark_banner_widget.dart';
import '../../widgets/home/enhanced_search_bar.dart';
import '../../widgets/home/category_item.dart';
import '../../widgets/home/restaurant_card.dart';
import '../../widgets/home/hot_deals_section.dart';
import '../../widgets/common/bottom_nav_bar.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/common/error_state_widget.dart';
import '../../widgets/common/skeleton_loaders.dart';
import '../../widgets/cart/cart_bottom_sheet.dart';
import '../../../../logic/providers/cart_providers.dart';
import '../../../../logic/providers/favorites_providers.dart';
import '../../../../logic/providers/filtered_restaurants_provider.dart';
import '../../widgets/home/filters_button.dart';
import '../../widgets/common/connectivity_banner.dart';
import 'favorites_section_widget.dart';

/// Home screen for Customer app with dark theme design
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    // Load categories and restaurants on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(categoriesProvider.notifier).loadCategories();
      ref.read(restaurantsProvider.notifier).loadRestaurants(isFeatured: true);
      // Connect to WebSocket for real-time updates
      _connectWebSocket();
      // Initialize notifications
      _initializeNotifications();
      // Listen to WebSocket messages
      _listenToWebSocketMessages();
    });
  }

  void _listenToWebSocketMessages() {
    final wsService = ref.read(webSocketServiceProvider);
    final stream = wsService.messagesStream;
    if (stream != null) {
      stream.listen((message) {
        if (message.type == WebSocketMessageType.orderUpdate) {
          final orderData = message.data;
          final orderStatus = orderData['status'] as String?;
          final orderId = orderData['id'] as String?;
          final userId = orderData['user_id'] as String?;
          
          // Check if this order belongs to current user
          final currentUser = ref.read(currentUserProvider);
          if (currentUser != null && userId == currentUser.id) {
            // Refresh user orders
            ref.invalidate(userOrdersProvider(currentUser.id));
            
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
                      context.push('/order-details/$orderId');
                    },
                  ),
                ),
              );
            }
          }
        }
      });
    }
  }

  Future<void> _connectWebSocket() async {
    final user = ref.read(currentUserProvider);
    if (user != null) {
      final wsService = ref.read(webSocketServiceProvider);
      await wsService.connect(
        userId: user.id,
        userType: AppConstants.appTypeCustomer,
      );
    }
  }

  Future<void> _initializeNotifications() async {
    final notificationService = ref.read(notificationServiceProvider);
    await notificationService.initialize();
    await notificationService.requestPermission();

    // Subscribe to customer-specific topics
    await notificationService.subscribeToTopic('customer_orders');
    await notificationService.subscribeToTopic('customer_promotions');
  }

  void _onCategorySelected(String categoryId, String categoryName) {
    setState(() {
      _selectedCategoryId = categoryId;
    });
    ref
        .read(restaurantsProvider.notifier)
        .loadRestaurants(categoryId: categoryId);
  }

  void _clearCategoryFilter() {
    setState(() {
      _selectedCategoryId = null;
    });
    ref.read(restaurantsProvider.notifier).loadRestaurants(isFeatured: true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoriesState = ref.watch(categoriesProvider);
    final restaurantsState = ref.watch(filteredRestaurantsProvider);
    final user = ref.watch(currentUserProvider);

    return BackButtonHandler(
      showExitDialog: true,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              const ConnectivityBanner(),
              Expanded(
                child: RefreshIndicator(
            onRefresh: () async {
              try {
                // Clear any active search first
                final restaurantsNotifier = ref.read(
                  restaurantsProvider.notifier,
                );
                restaurantsNotifier.clearSearch();

                // Clear category filter
                setState(() {
                  _selectedCategoryId = null;
                });

                // Refresh categories and restaurants
                await Future.wait([
                  ref.read(categoriesProvider.notifier).refresh(),
                  restaurantsNotifier.refresh(isFeatured: true),
                ]);

                // Refresh favorites provider
                ref.invalidate(favoriteRestaurantsProvider);
              } catch (e) {
                // Error handling - state will show error if needed
                rethrow;
              }
            },
            color: AppColors.primary,
            backgroundColor: AppColors.surface,
            child: CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: DarkHeaderWidget(
                    userName: user?.name,
                    userImageUrl: user?.imageUrl,
                    onNotificationTap: () {
                      // Navigate to notifications
                    },
                  ),
                ),
                // Search Bar with Filters
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      children: [
                        Expanded(child: const EnhancedSearchBar()),
                        const SizedBox(width: 12),
                        FiltersButton(),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 20)),
                // Banner
                SliverToBoxAdapter(
                  child: DarkBannerWidget(
                    title: context.l10n.specialOffer,
                    subtitle: context.l10n.get50OffFirstOrder,
                    onOrderNowTap: () {
                      // Navigate to restaurants
                    },
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
                // Categories Section
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text(
                          context.l10n.categories,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      categoriesState.when(
                        data:
                            (categories) => SizedBox(
                              height: 120,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                itemCount: categories.length,
                                itemBuilder: (context, index) {
                                  final isSelected =
                                      _selectedCategoryId ==
                                      categories[index].id;
                                  return CategoryItem(
                                        category: categories[index],
                                        isSelected: isSelected,
                                        onTap: () {
                                          if (isSelected) {
                                            _clearCategoryFilter();
                                          } else {
                                            _onCategorySelected(
                                              categories[index].id,
                                              categories[index].name,
                                            );
                                          }
                                        },
                                      )
                                      .animate()
                                      .fadeIn(delay: (50 * index).ms)
                                      .slideX();
                                },
                              ),
                            ),
                        loading:
                            () => const SizedBox(
                              height: 120,
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                        error:
                            (error, stack) => SizedBox(
                              height: 120,
                              child: Center(
                                child: Text(
                                  context.l10n.failedToLoad,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                      ),
                    ],
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
                // Hot Deals Section
                SliverToBoxAdapter(
                  child: HotDealsSection(
                    onSeeAllTap: () {
                      context.push('/customer/hot-deals');
                    },
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
                // Favorites Section (if user has favorites)
                SliverToBoxAdapter(child: const FavoritesSectionWidget()),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
                // Featured Restaurants Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          context.l10n.featuredRestaurants,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // Navigate to all restaurants
                          },
                          child: Text(
                            context.l10n.seeAll,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Restaurants List
                restaurantsState.when(
                  data: (restaurants) {
                    if (restaurants.isEmpty) {
                      return SliverFillRemaining(
                        hasScrollBody: false,
                        child: EmptyStateWidget(
                          icon: Icons.restaurant_outlined,
                          title: context.l10n.noRestaurantsFound,
                          message: 'Try searching for your favorite restaurant',
                        ),
                      );
                    }

                    return SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          return RestaurantCard(
                                restaurant: restaurants[index],
                                onTap: () {
                                  context.push(
                                    '/restaurant/${restaurants[index].id}',
                                  );
                                },
                              )
                              .animate()
                              .fadeIn(delay: (50 * index).ms)
                              .slideY(begin: 0.1, end: 0);
                        }, childCount: restaurants.length),
                      ),
                    );
                  },
                  loading:
                      () => SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => const RestaurantCardSkeleton(),
                            childCount: 3,
                          ),
                        ),
                      ),
                  error:
                      (error, stack) => SliverFillRemaining(
                        hasScrollBody: false,
                        child: ErrorStateWidget(
                          message: context.l10n.failedToLoad,
                          error: error.toString(),
                          onRetry: () {
                            ref
                                .read(restaurantsProvider.notifier)
                                .refresh(isFeatured: true);
                          },
                        ),
                      ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 20)),
              ],
            ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: const CustomerBottomNavBar(currentIndex: 0),
        floatingActionButton: Consumer(
          builder: (context, ref, child) {
            final cartCount = ref.watch(cartItemCountProvider);
            if (cartCount == 0) return const SizedBox.shrink();
            return FloatingActionButton.extended(
              onPressed: () {
                showCartBottomSheet(context);
              },
              backgroundColor: AppColors.primary,
              icon: Badge(
                label: Text('$cartCount'),
                isLabelVisible: cartCount > 0,
                child: const Icon(Icons.shopping_cart),
              ),
              label: Text(
                context.l10n.viewCart,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            );
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}
