/// API Constants for Servy Customer App
class ApiConstants {
  ApiConstants._();

  // Base URL - Update this when connecting to real backend
  static const String baseUrl = 'http://localhost:8080';
  
  // API Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String restaurants = '/restaurants';
  static const String restaurantDetails = '/restaurants';
  static const String restaurantMenu = '/restaurants';
  static const String userAddresses = '/users';
  static const String createAddress = '/users';
  static const String orders = '/orders';
  static const String orderTrack = '/orders';
  static const String validateCoupon = '/coupons/validate';

  // API Headers
  static const String contentType = 'Content-Type';
  static const String applicationJson = 'application/json';
  static const String authorization = 'Authorization';
  static const String bearer = 'Bearer';

  // API Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}

