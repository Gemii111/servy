import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/order_model.dart';
import '../../data/models/cart_item_model.dart';
import '../../data/models/address_model.dart';
import '../../data/models/driver_location_model.dart';
import '../../data/repositories/order_repository.dart';

/// Order repository provider
final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepository();
});

/// Order state notifier
class OrderNotifier extends StateNotifier<AsyncValue<OrderModel?>> {
  OrderNotifier(this._repository) : super(const AsyncValue.data(null));

  final OrderRepository _repository;

  /// Place order
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
    state = const AsyncValue.loading();
    try {
      final order = await _repository.placeOrder(
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

      state = AsyncValue.data(order);
      return order;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }
}

/// Order provider
final orderProvider =
    StateNotifierProvider<OrderNotifier, AsyncValue<OrderModel?>>((ref) {
      final repository = ref.watch(orderRepositoryProvider);
      return OrderNotifier(repository);
    });

/// User orders provider
final userOrdersProvider = FutureProvider.family<List<OrderModel>, String>((
  ref,
  userId,
) async {
  final repository = ref.watch(orderRepositoryProvider);
  return await repository.getUserOrders(userId);
});

/// Available delivery requests provider for drivers
final availableDeliveryRequestsProvider = FutureProvider<List<OrderModel>>((
  ref,
) async {
  final repository = ref.watch(orderRepositoryProvider);
  // TODO: Get driver's current location
  return await repository.getAvailableDeliveryRequests();
});

/// Driver active orders provider
final driverActiveOrdersProvider =
    FutureProvider.family<List<OrderModel>, String>((ref, driverId) async {
      final repository = ref.watch(orderRepositoryProvider);
      return await repository.getDriverActiveOrders(driverId);
    });

/// Driver order history provider
final driverOrderHistoryProvider =
    FutureProvider.family<List<OrderModel>, String>((ref, driverId) async {
      final repository = ref.watch(orderRepositoryProvider);
      return await repository.getDriverOrderHistory(driverId);
    });

/// Order by ID provider
final orderByIdProvider = FutureProvider.family<OrderModel?, String>((
  ref,
  orderId,
) async {
  final repository = ref.watch(orderRepositoryProvider);
  return await repository.getOrderById(orderId);
});

/// Driver location for order provider (with polling for real-time updates)
/// Polls every 10 seconds to get driver location updates
/// This is more battery-efficient than 3 seconds while still providing good UX
final driverLocationForOrderProvider =
    StreamProvider.family<DriverLocationData?, String>((ref, orderId) async* {
      final repository = ref.watch(orderRepositoryProvider);

      // Poll for driver location updates every 10 seconds
      // This balances real-time updates with battery/data consumption
      await for (final _ in Stream.periodic(const Duration(seconds: 10))) {
        try {
          final location = await repository.getDriverLocationForOrder(orderId);
          yield location;
        } catch (e) {
          yield null;
        }
      }
    });

/// Restaurant orders provider
final restaurantOrdersProvider =
    FutureProvider.family<List<OrderModel>, String>((ref, restaurantId) async {
      final repository = ref.watch(orderRepositoryProvider);
      return await repository.getRestaurantOrders(restaurantId);
    });
