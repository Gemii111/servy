/// Application-wide constants
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Servy';
  
  // App Types
  static const String appTypeCustomer = 'customer';
  static const String appTypeDriver = 'driver';
  static const String appTypeRestaurant = 'restaurant';
  
  // Storage Keys
  static const String hiveBoxName = 'servy_customer_box';
  static const String authTokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';
  static const String onboardingCompletedKey = 'onboarding_completed';
  
  // Default Values (Cairo, Egypt)
  static const double defaultLatitude = 30.0444; // Cairo
  static const double defaultLongitude = 31.2357;
  static const int defaultDeliveryTime = 25; // minutes
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);
}
