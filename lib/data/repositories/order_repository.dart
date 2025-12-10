import '../models/order_model.dart';
import '../models/cart_item_model.dart';
import '../models/address_model.dart';
import '../models/driver_location_model.dart';
import '../services/mock_api_service.dart';

/// Order repository
class OrderRepository {
  OrderRepository({MockApiService? mockApiService})
    : _mockApiService = mockApiService ?? MockApiService.instance;

  final MockApiService _mockApiService;

  /// Place new order
  Future<OrderModel> placeOrder({
    required String userId,
    required String restaurantId,
    required String restaurantName,
    required List<CartItemModel> items,
    required AddressModel deliveryAddress,
    required double subtotal,
    required double deliveryFee,
    required double total,
    required String paymentMethod,
    String? notes,
    double? discount,
  }) async {
    return await _mockApiService.placeOrder(
      userId: userId,
      restaurantId: restaurantId,
      restaurantName: restaurantName,
      items: items,
      deliveryAddress: deliveryAddress,
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      total: total,
      paymentMethod: paymentMethod,
      notes: notes,
      discount: discount,
    );
  }

  /// Get user orders
  Future<List<OrderModel>> getUserOrders(String userId) async {
    return await _mockApiService.getUserOrders(userId);
  }

  /// Get available delivery requests for drivers
  Future<List<OrderModel>> getAvailableDeliveryRequests({
    double? latitude,
    double? longitude,
  }) async {
    return await _mockApiService.getAvailableDeliveryRequests(
      latitude: latitude,
      longitude: longitude,
    );
  }

  /// Accept delivery request
  Future<OrderModel> acceptDeliveryRequest({
    required String driverId,
    required String orderId,
  }) async {
    return await _mockApiService.acceptDeliveryRequest(
      driverId: driverId,
      orderId: orderId,
    );
  }

  /// Reject delivery request
  Future<void> rejectDeliveryRequest({
    required String driverId,
    required String orderId,
  }) async {
    return await _mockApiService.rejectDeliveryRequest(
      driverId: driverId,
      orderId: orderId,
    );
  }

  /// Update order status (for driver)
  Future<OrderModel> updateOrderStatus({
    required String orderId,
    required OrderStatus status,
    String? driverId,
    String? driverName,
  }) async {
    return await _mockApiService.updateOrderStatus(
      orderId: orderId,
      status: status,
      driverId: driverId,
      driverName: driverName,
    );
  }

  /// Get driver active orders
  Future<List<OrderModel>> getDriverActiveOrders(String driverId) async {
    return await _mockApiService.getDriverActiveOrders(driverId);
  }

  /// Get driver order history
  Future<List<OrderModel>> getDriverOrderHistory(String driverId) async {
    return await _mockApiService.getDriverOrderHistory(driverId);
  }

  /// Get order by ID
  Future<OrderModel?> getOrderById(String orderId) async {
    return await _mockApiService.getOrderById(orderId);
  }

  /// Get driver location for order
  Future<DriverLocationData?> getDriverLocationForOrder(String orderId) async {
    return await _mockApiService.getDriverLocationForOrder(orderId);
  }

  /// Get restaurant orders
  Future<List<OrderModel>> getRestaurantOrders(String restaurantId) async {
    return await _mockApiService.getRestaurantOrders(restaurantId);
  }
}
