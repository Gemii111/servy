import 'address_model.dart';

/// Order status enum
enum OrderStatus {
  pending,
  accepted,
  preparing,
  ready,
  outForDelivery,
  delivered,
  cancelled;

  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.accepted:
        return 'Accepted';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.ready:
        return 'Ready';
      case OrderStatus.outForDelivery:
        return 'Out for Delivery';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  static OrderStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return OrderStatus.pending;
      case 'accepted':
        return OrderStatus.accepted;
      case 'preparing':
        return OrderStatus.preparing;
      case 'ready':
        return OrderStatus.ready;
      case 'out_for_delivery':
      case 'outfordelivery':
        return OrderStatus.outForDelivery;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }
}

/// Order model
class OrderModel {
  final String id;
  final String userId;
  final String restaurantId;
  final String restaurantName;
  final OrderStatus status;
  final AddressModel deliveryAddress;
  final double subtotal;
  final double deliveryFee;
  final double? tax;
  final double? discount;
  final double total;
  final String paymentMethod;
  final DateTime createdAt;
  final DateTime? estimatedDeliveryTime;
  final String? notes;
  final List<OrderItemModel> items;
  final String? driverId;
  final String? driverName;
  final DateTime? deliveredAt;

  OrderModel({
    required this.id,
    required this.userId,
    required this.restaurantId,
    required this.restaurantName,
    required this.status,
    required this.deliveryAddress,
    required this.subtotal,
    required this.deliveryFee,
    this.tax,
    this.discount,
    required this.total,
    required this.paymentMethod,
    required this.createdAt,
    this.estimatedDeliveryTime,
    this.notes,
    this.items = const [],
    this.driverId,
    this.driverName,
    this.deliveredAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      restaurantId: json['restaurant_id'] as String,
      restaurantName: json['restaurant_name'] as String? ?? 'Restaurant',
      status: OrderStatus.fromString(json['status'] as String? ?? 'pending'),
      deliveryAddress: AddressModel.fromJson(
        json['delivery_address'] as Map<String, dynamic>,
      ),
      subtotal: (json['subtotal'] as num).toDouble(),
      deliveryFee: (json['delivery_fee'] as num).toDouble(),
      tax: (json['tax'] as num?)?.toDouble(),
      discount: (json['discount'] as num?)?.toDouble(),
      total: (json['total'] as num).toDouble(),
      paymentMethod: json['payment_method'] as String? ?? 'cash',
      createdAt: DateTime.parse(json['created_at'] as String),
      estimatedDeliveryTime: json['estimated_delivery_time'] != null
          ? DateTime.parse(json['estimated_delivery_time'] as String)
          : null,
      notes: json['notes'] as String?,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      driverId: json['driver_id'] as String?,
      driverName: json['driver_name'] as String?,
      deliveredAt: json['delivered_at'] != null
          ? DateTime.parse(json['delivered_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'restaurant_id': restaurantId,
      'restaurant_name': restaurantName,
      'status': status.name,
      'delivery_address': deliveryAddress.toJson(),
      'subtotal': subtotal,
      'delivery_fee': deliveryFee,
      'tax': tax,
      'discount': discount,
      'total': total,
      'payment_method': paymentMethod,
      'created_at': createdAt.toIso8601String(),
      'estimated_delivery_time': estimatedDeliveryTime?.toIso8601String(),
      'notes': notes,
      'items': items.map((e) => e.toJson()).toList(),
      'driver_id': driverId,
      'driver_name': driverName,
      'delivered_at': deliveredAt?.toIso8601String(),
    };
  }
}

/// Order item model (for order history)
class OrderItemModel {
  final String id;
  final String name;
  final double price;
  final int quantity;
  final List<String> extras;

  OrderItemModel({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    this.extras = const [],
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int,
      extras: (json['extras'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
      'extras': extras,
    };
  }
}

