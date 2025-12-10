import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/customer/screens/splash/splash_screen.dart';
import '../../presentation/customer/screens/onboarding/onboarding_screen.dart';
import '../../presentation/customer/screens/auth/login_screen.dart';
import '../../presentation/customer/screens/auth/register_screen.dart';
import '../../presentation/customer/screens/auth/user_type_selection_screen.dart';
import '../../presentation/customer/screens/auth/user_type_login_screen.dart';
import '../../presentation/customer/screens/home/home_screen.dart';
import '../../presentation/customer/screens/orders/orders_screen.dart';
import '../../presentation/customer/screens/profile/profile_screen.dart';
import '../../presentation/customer/screens/restaurant_details/restaurant_details_screen.dart';
import '../../presentation/customer/screens/menu/menu_screen.dart';
import '../../presentation/customer/screens/checkout/checkout_screen.dart';
import '../../presentation/customer/screens/order_confirmation/order_confirmation_screen.dart';
import '../../presentation/customer/screens/order_details/order_details_screen.dart';
import '../../presentation/customer/screens/order_tracking/order_tracking_screen.dart';
import '../../presentation/customer/screens/review/review_order_screen.dart';
import '../../presentation/customer/screens/review/all_reviews_screen.dart';
import '../../presentation/customer/screens/favorites/all_favorites_screen.dart';
import '../../presentation/customer/screens/hot_deals/all_hot_deals_screen.dart';
import '../../presentation/customer/screens/profile/edit_profile_screen.dart';
import '../../presentation/customer/screens/addresses/addresses_screen.dart';
import '../../presentation/customer/screens/settings/settings_screen.dart';
import '../../presentation/customer/screens/payment_methods/payment_methods_screen.dart';
import '../../presentation/customer/screens/addresses/add_address_screen.dart';
import '../../presentation/customer/screens/addresses/edit_address_screen.dart';
import '../../presentation/customer/screens/settings/language_selection_screen.dart';
import '../../presentation/customer/screens/payment_methods/add_payment_method_screen.dart';
import '../../presentation/driver/screens/splash/driver_splash_screen.dart';
import '../../presentation/driver/screens/onboarding/driver_onboarding_screen.dart';
import '../../presentation/driver/screens/home/driver_home_screen.dart';
import '../../presentation/driver/screens/orders/delivery_requests_screen.dart';
import '../../presentation/driver/screens/orders/driver_order_details_screen.dart';
import '../../presentation/driver/screens/map/driver_map_screen.dart';
import '../../presentation/driver/screens/orders/driver_order_history_screen.dart';
import '../../presentation/driver/screens/earnings/earnings_dashboard_screen.dart';
import '../../presentation/driver/screens/profile/driver_profile_screen.dart';
import '../../presentation/driver/screens/settings/driver_settings_screen.dart';
import '../../presentation/restaurant/screens/splash/restaurant_splash_screen.dart';
import '../../presentation/restaurant/screens/home/restaurant_home_screen.dart';
import '../../presentation/restaurant/screens/orders/restaurant_orders_screen.dart';
import '../../presentation/restaurant/screens/orders/restaurant_order_details_screen.dart';
import '../../presentation/restaurant/screens/menu/restaurant_menu_management_screen.dart';
import '../../presentation/restaurant/screens/profile/restaurant_profile_screen.dart';
import '../../presentation/restaurant/screens/profile/edit_restaurant_profile_screen.dart';
import '../../presentation/restaurant/screens/settings/restaurant_settings_screen.dart';
import '../../presentation/restaurant/screens/analytics/restaurant_analytics_screen.dart';
import '../constants/app_constants.dart';

/// Main app router configuration
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    routes: [
      // Root/Splash
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // User Type Selection (Before Auth)
      GoRoute(
        path: '/user-type-selection',
        builder: (context, state) => const UserTypeSelectionScreen(),
      ),
      GoRoute(
        path: '/user-type-login',
        builder: (context, state) => const UserTypeLoginScreen(),
      ),

      // Customer App Routes
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) {
          final type =
              state.uri.queryParameters['type'] ?? AppConstants.appTypeCustomer;
          return LoginScreen(userType: type);
        },
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) {
          final type =
              state.uri.queryParameters['type'] ?? AppConstants.appTypeCustomer;
          return RegisterScreen(userType: type);
        },
      ),
      GoRoute(
        path: '/customer/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/customer/orders',
        builder: (context, state) => const OrdersScreen(),
      ),
      GoRoute(
        path: '/customer/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/edit-profile',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/addresses',
        builder: (context, state) => const AddressesScreen(),
      ),
      GoRoute(
        path: '/add-address',
        builder: (context, state) => const AddAddressScreen(),
      ),
      GoRoute(
        path: '/edit-address/:id',
        builder: (context, state) {
          final addressId = state.pathParameters['id']!;
          return EditAddressScreen(addressId: addressId);
        },
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/language-selection',
        builder: (context, state) => const LanguageSelectionScreen(),
      ),
      GoRoute(
        path: '/payment-methods',
        builder: (context, state) => const PaymentMethodsScreen(),
      ),
      GoRoute(
        path: '/add-payment-method',
        builder: (context, state) => const AddPaymentMethodScreen(),
      ),
      GoRoute(
        path: '/checkout',
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: '/order-confirmation',
        builder: (context, state) => const OrderConfirmationScreen(),
      ),
      GoRoute(
        path: '/order-details/:id',
        builder: (context, state) {
          final orderId = state.pathParameters['id']!;
          return OrderDetailsScreen(orderId: orderId);
        },
      ),
      GoRoute(
        path: '/order-tracking/:id',
        builder: (context, state) {
          final orderId = state.pathParameters['id']!;
          return OrderTrackingScreen(orderId: orderId);
        },
      ),
      GoRoute(
        path: '/review-order/:id',
        builder: (context, state) {
          final orderId = state.pathParameters['id']!;
          return ReviewOrderScreen(orderId: orderId);
        },
      ),
      GoRoute(
        path: '/restaurant/:id/reviews',
        builder: (context, state) {
          final restaurantId = state.pathParameters['id']!;
          final restaurantName = state.uri.queryParameters['name'];
          return AllReviewsScreen(
            restaurantId: restaurantId,
            restaurantName: restaurantName,
          );
        },
      ),
      GoRoute(
        path: '/customer/favorites',
        builder: (context, state) => const AllFavoritesScreen(),
      ),
      GoRoute(
        path: '/customer/hot-deals',
        builder: (context, state) => const AllHotDealsScreen(),
      ),

      // Driver App Routes
      GoRoute(
        path: '/driver/splash',
        builder: (context, state) => const DriverSplashScreen(),
      ),
      GoRoute(
        path: '/driver/onboarding',
        builder: (context, state) => const DriverOnboardingScreen(),
      ),
      GoRoute(
        path: '/driver/login',
        builder:
            (context, state) =>
                LoginScreen(userType: AppConstants.appTypeDriver),
      ),
      GoRoute(
        path: '/driver/register',
        builder:
            (context, state) =>
                RegisterScreen(userType: AppConstants.appTypeDriver),
      ),
      GoRoute(
        path: '/driver/home',
        builder: (context, state) => const DriverHomeScreen(),
      ),
      GoRoute(
        path: '/driver/delivery-requests',
        builder: (context, state) => const DeliveryRequestsScreen(),
      ),
      GoRoute(
        path: '/driver/order-details/:id',
        builder: (context, state) {
          final orderId = state.pathParameters['id']!;
          return DriverOrderDetailsScreen(orderId: orderId);
        },
      ),
      GoRoute(
        path: '/driver/map/:id',
        builder: (context, state) {
          final orderId = state.pathParameters['id']!;
          return DriverMapScreen(orderId: orderId);
        },
      ),
      GoRoute(
        path: '/driver/earnings',
        builder: (context, state) => const EarningsDashboardScreen(),
      ),
      GoRoute(
        path: '/driver/order-history',
        builder: (context, state) => const DriverOrderHistoryScreen(),
      ),
      GoRoute(
        path: '/driver/profile',
        builder: (context, state) => const DriverProfileScreen(),
      ),
      GoRoute(
        path: '/driver/edit-profile',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/driver/settings',
        builder: (context, state) => const DriverSettingsScreen(),
      ),
      GoRoute(
        path: '/driver/language-selection',
        builder: (context, state) => const LanguageSelectionScreen(),
      ),

      // Restaurant App Routes
      GoRoute(
        path: '/restaurant/splash',
        builder: (context, state) => const RestaurantSplashScreen(),
      ),
      GoRoute(
        path: '/restaurant/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/restaurant/login',
        builder:
            (context, state) =>
                LoginScreen(userType: AppConstants.appTypeRestaurant),
      ),
      GoRoute(
        path: '/restaurant/register',
        builder:
            (context, state) =>
                RegisterScreen(userType: AppConstants.appTypeRestaurant),
      ),
      GoRoute(
        path: '/restaurant/home',
        builder: (context, state) => const RestaurantHomeScreen(),
      ),
      GoRoute(
        path: '/restaurant/orders',
        builder: (context, state) => const RestaurantOrdersScreen(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) {
              final orderId = state.pathParameters['id']!;
              return RestaurantOrderDetailsScreen(orderId: orderId);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/restaurant/menu',
        builder: (context, state) => const RestaurantMenuManagementScreen(),
      ),
      GoRoute(
        path: '/restaurant/profile',
        builder: (context, state) => const RestaurantProfileScreen(),
      ),
      GoRoute(
        path: '/restaurant/edit-profile',
        builder: (context, state) => const EditRestaurantProfileScreen(),
      ),
      GoRoute(
        path: '/restaurant/settings',
        builder: (context, state) => const RestaurantSettingsScreen(),
      ),
      GoRoute(
        path: '/restaurant/analytics',
        builder: (context, state) => const RestaurantAnalyticsScreen(),
      ),

      // Restaurant Details Route (MUST be after /restaurant/home and other specific routes)
      GoRoute(
        path: '/restaurant/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return RestaurantDetailsScreen(restaurantId: id);
        },
        routes: [
          GoRoute(
            path: 'menu',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return MenuScreen(restaurantId: id);
            },
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) {
      // Import AppColors for error page
      return Scaffold(
        backgroundColor: const Color(0xFF121212), // AppColors.background
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color(
                      0xFFFF4C4C,
                    ).withOpacity(0.2), // AppColors.error
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF4C4C).withOpacity(0.3),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.error_outline,
                    size: 60,
                    color: Color(0xFFFF4C4C), // AppColors.error
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Page Not Found',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: const Color(0xFFFFFFFF), // AppColors.textPrimary
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  state.uri.toString(),
                  style: const TextStyle(
                    color: Color(0xFFCCCCCC), // AppColors.textSecondary
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () => context.go('/'),
                  icon: const Icon(Icons.home, size: 20),
                  label: const Text('Go Home'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(
                      0xFFD22EF2,
                    ), // AppColors.primary
                    foregroundColor: const Color(
                      0xFFFFFFFF,
                    ), // AppColors.textPrimary
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
