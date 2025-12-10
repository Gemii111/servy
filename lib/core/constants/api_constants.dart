/// API Constants for Servy Food Delivery System
/// جميع الـ Endpoints والـ Constants المطلوبة للـ Backend
class ApiConstants {
  ApiConstants._();

  // ==================== Base Configuration ====================
  
  /// Base URL - تحديث هذا عند الاتصال بالـ Backend الحقيقي
  /// Development: 'http://localhost:8080'
  /// Production: 'https://api.servy.app'
  static const String baseUrl = 'https://api.servy.app';
  
  /// API Version
  static const String apiVersion = 'v1';
  
  /// Full API Base URL
  static String get apiBaseUrl => '$baseUrl/api/$apiVersion';

  // ==================== API Timeouts ====================
  
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // ==================== API Headers ====================
  
  static const String contentType = 'Content-Type';
  static const String applicationJson = 'application/json';
  static const String authorization = 'Authorization';
  static const String bearer = 'Bearer';
  static const String accept = 'Accept';

  // ==================== Authentication Endpoints ====================
  
  static const String authLogin = '/auth/login';
  static const String authRegister = '/auth/register';
  static const String authRefresh = '/auth/refresh';
  static const String authLogout = '/auth/logout';
  static const String authVerifyEmail = '/auth/verify-email';
  static const String authResetPassword = '/auth/reset-password';
  static const String authForgotPassword = '/auth/forgot-password';

  // ==================== User Endpoints ====================
  
  static const String usersMe = '/users/me';
  static const String usersUpdateProfile = '/users/me';
  static const String usersChangePassword = '/users/me/password';
  static const String usersUploadAvatar = '/users/me/avatar';
  static const String usersAddresses = '/users/me/addresses';
  static String userAddressById(String addressId) => '/users/me/addresses/$addressId';
  static const String usersFavorites = '/users/me/favorites';
  static String userFavoriteById(String restaurantId) => '/users/me/favorites/$restaurantId';

  // ==================== Restaurant Endpoints ====================
  
  static const String restaurants = '/restaurants';
  static String restaurantById(String id) => '/restaurants/$id';
  static String restaurantMenu(String id) => '/restaurants/$id/menu';
  static String restaurantReviews(String id) => '/restaurants/$id/reviews';
  static String restaurantStatistics(String id) => '/restaurants/$id/statistics';
  static String restaurantOrders(String id) => '/restaurants/$id/orders';
  static String restaurantUpdateStatus(String id) => '/restaurants/$id/status';
  static String restaurantUpdateOnlineStatus(String id) => '/restaurants/$id/online-status';
  static const String restaurantsFeatured = '/restaurants/featured';
  static const String restaurantsNearby = '/restaurants/nearby';
  static const String restaurantsSearch = '/restaurants/search';

  // ==================== Menu Endpoints ====================
  
  static String menuCategories(String restaurantId) => '/restaurants/$restaurantId/menu/categories';
  static String menuCategoryById(String restaurantId, String categoryId) => '/restaurants/$restaurantId/menu/categories/$categoryId';
  static String menuItems(String restaurantId) => '/restaurants/$restaurantId/menu/items';
  static String menuItemById(String restaurantId, String itemId) => '/restaurants/$restaurantId/menu/items/$itemId';

  // ==================== Order Endpoints ====================
  
  static const String orders = '/orders';
  static String orderById(String id) => '/orders/$id';
  static String orderTrack(String id) => '/orders/$id/track';
  static String orderCancel(String id) => '/orders/$id/cancel';
  static String orderUpdateStatus(String id) => '/orders/$id/status';
  static String orderRate(String id) => '/orders/$id/rate';
  static const String ordersActive = '/orders/active';
  static const String ordersHistory = '/orders/history';
  static const String ordersPlace = '/orders/place';

  // ==================== Driver Endpoints ====================
  
  static const String driversActiveOrders = '/drivers/orders/active';
  static const String driversEarnings = '/drivers/earnings';
  static const String driversDeliveryRequests = '/drivers/delivery-requests';
  static String driverAcceptOrder(String orderId) => '/drivers/orders/$orderId/accept';
  static String driverRejectOrder(String orderId) => '/drivers/orders/$orderId/reject';
  static String driverUpdateLocation = '/drivers/location';
  static String driverUpdateStatus = '/drivers/status';

  // ==================== Restaurant Management Endpoints ====================
  
  static const String restaurantManagementOrders = '/restaurant/orders';
  static String restaurantManagementOrderById(String orderId) => '/restaurant/orders/$orderId';
  static String restaurantManagementOrderUpdateStatus(String orderId) => '/restaurant/orders/$orderId/status';
  static const String restaurantManagementStatistics = '/restaurant/statistics';
  static const String restaurantManagementMenu = '/restaurant/menu';

  // ==================== Category Endpoints ====================
  
  static const String categories = '/categories';
  static String categoryById(String id) => '/categories/$id';

  // ==================== Coupon Endpoints ====================
  
  static const String couponsValidate = '/coupons/validate';
  static const String coupons = '/coupons';

  // ==================== Rating & Review Endpoints ====================
  
  static const String reviews = '/reviews';
  static String reviewById(String id) => '/reviews/$id';
  static String restaurantReviewsList(String restaurantId) => '/restaurants/$restaurantId/reviews';

  // ==================== Notification Endpoints ====================
  
  static const String notifications = '/notifications';
  static String notificationById(String id) => '/notifications/$id';
  static const String notificationsMarkAllRead = '/notifications/read-all';
  static String notificationMarkRead(String id) => '/notifications/$id/read';
  static const String notificationsRegisterToken = '/notifications/register-token';

  // ==================== WebSocket Endpoints ====================
  
  /// WebSocket URL for real-time updates
  /// Development: 'ws://localhost:8080/ws'
  /// Production: 'wss://api.servy.app/ws'
  static const String websocketUrl = 'wss://api.servy.app/ws';
  
  static const String wsOrders = '/ws/orders';
  static const String wsDriverLocation = '/ws/driver-location';
  static const String wsRestaurantOrders = '/ws/restaurant/orders';
}
