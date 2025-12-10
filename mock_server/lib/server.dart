import 'dart:io';
import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';

/// Mock API Server for Servy Food Delivery App
/// This server provides mock REST endpoints for development and testing

void main(List<String> args) async {
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await io.serve(
    Pipeline()
        .addMiddleware(logRequests())
        .addMiddleware(corsHeaders())
        .addHandler(createRouter().call),
    InternetAddress.anyIPv4,
    port,
  );

  print('🚀 Mock API Server running on http://${server.address.host}:${server.port}');
  print('📋 Available endpoints:');
  print('   POST   /auth/login');
  print('   POST   /auth/register');
  print('   GET    /restaurants');
  print('   GET    /restaurants/:id');
  print('   GET    /restaurants/:id/menu');
  print('   GET    /users/:id/addresses');
  print('   POST   /users/:id/addresses');
  print('   POST   /orders');
  print('   GET    /orders/:id/track');
  print('   POST   /coupons/validate');
}

Router createRouter() {
  final router = Router();

  // ============ AUTH ENDPOINTS ============

  router.post('/auth/login', (Request request) async {
    final body = await request.readAsString();
    final data = jsonDecode(body) as Map<String, dynamic>;
    final phone = data['phone'] as String?;
    final password = data['password'] as String?;

    // Mock validation
    if (phone == null || password == null) {
      return Response.badRequest(
        body: jsonEncode({'error': 'Phone and password are required'}),
        headers: {'Content-Type': 'application/json'},
      );
    }

    // Mock successful login
    await Future.delayed(const Duration(milliseconds: 500));
    return Response.ok(
      jsonEncode({
        'success': true,
        'data': {
          'user': {
            'id': 'user_123',
            'name': 'John Doe',
            'phone': phone,
            'email': 'user@example.com',
          },
          'token': 'mock_jwt_token_${DateTime.now().millisecondsSinceEpoch}',
          'refresh_token': 'mock_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
        },
      }),
      headers: {'Content-Type': 'application/json'},
    );
  });

  router.post('/auth/register', (Request request) async {
    final body = await request.readAsString();
    final data = jsonDecode(body) as Map<String, dynamic>;
    final name = data['name'] as String?;
    final phone = data['phone'] as String?;
    final password = data['password'] as String?;

    if (name == null || phone == null || password == null) {
      return Response.badRequest(
        body: jsonEncode({'error': 'Name, phone, and password are required'}),
        headers: {'Content-Type': 'application/json'},
      );
    }

    await Future.delayed(const Duration(milliseconds: 500));
    return Response.ok(
      jsonEncode({
        'success': true,
        'data': {
          'user': {
            'id': 'user_${DateTime.now().millisecondsSinceEpoch}',
            'name': name,
            'phone': phone,
            'email': 'user@example.com',
          },
          'token': 'mock_jwt_token_${DateTime.now().millisecondsSinceEpoch}',
          'refresh_token': 'mock_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
        },
      }),
      headers: {'Content-Type': 'application/json'},
    );
  });

  // ============ RESTAURANTS ENDPOINTS ============

  router.get('/restaurants', (Request request) async {
    final lat = request.url.queryParameters['lat'] ?? '24.7136';
    final lng = request.url.queryParameters['lng'] ?? '46.6753';

    await Future.delayed(const Duration(milliseconds: 300));

    final restaurants = [
      {
        'id': 'rest_1',
        'name': 'Pizza Palace',
        'description': 'The best pizza in town',
        'image_url': 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=400',
        'rating': 4.5,
        'review_count': 234,
        'cuisine_type': 'Italian',
        'delivery_time': 25,
        'delivery_fee': 5.0,
        'min_order': 30.0,
        'is_open': true,
        'distance': 2.5,
        'latitude': double.parse(lat) + 0.01,
        'longitude': double.parse(lng) + 0.01,
      },
      {
        'id': 'rest_2',
        'name': 'Burger King',
        'description': 'Fresh burgers made with premium ingredients',
        'image_url': 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400',
        'rating': 4.3,
        'review_count': 189,
        'cuisine_type': 'Fast Food',
        'delivery_time': 20,
        'delivery_fee': 4.0,
        'min_order': 25.0,
        'is_open': true,
        'distance': 1.8,
        'latitude': double.parse(lat) + 0.008,
        'longitude': double.parse(lng) + 0.008,
      },
      {
        'id': 'rest_3',
        'name': 'Sushi Master',
        'description': 'Authentic Japanese sushi and sashimi',
        'image_url': 'https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?w=400',
        'rating': 4.7,
        'review_count': 156,
        'cuisine_type': 'Japanese',
        'delivery_time': 35,
        'delivery_fee': 7.0,
        'min_order': 50.0,
        'is_open': true,
        'distance': 3.2,
        'latitude': double.parse(lat) + 0.012,
        'longitude': double.parse(lng) + 0.012,
      },
    ];

    return Response.ok(
      jsonEncode({
        'success': true,
        'data': restaurants,
        'pagination': {
          'page': 1,
          'per_page': 20,
          'total': restaurants.length,
        },
      }),
      headers: {'Content-Type': 'application/json'},
    );
  });

  router.get('/restaurants/<id>', (Request request, String id) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final restaurant = {
      'id': id,
      'name': 'Pizza Palace',
      'description': 'The best pizza in town with authentic Italian flavors',
      'image_url': 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=400',
      'rating': 4.5,
      'review_count': 234,
      'cuisine_type': 'Italian',
      'delivery_time': 25,
      'delivery_fee': 5.0,
      'min_order': 30.0,
      'is_open': true,
      'distance': 2.5,
      'latitude': 24.7136,
      'longitude': 46.6753,
      'address': 'King Fahd Road, Riyadh',
      'phone': '+966501234567',
      'opening_hours': {
        'monday': '09:00 - 23:00',
        'tuesday': '09:00 - 23:00',
        'wednesday': '09:00 - 23:00',
        'thursday': '09:00 - 23:00',
        'friday': '14:00 - 23:00',
        'saturday': '09:00 - 23:00',
        'sunday': '09:00 - 23:00',
      },
    };

    return Response.ok(
      jsonEncode({
        'success': true,
        'data': restaurant,
      }),
      headers: {'Content-Type': 'application/json'},
    );
  });

  router.get('/restaurants/<id>/menu', (Request request, String id) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final menu = {
      'restaurant_id': id,
      'categories': [
        {
          'id': 'cat_1',
          'name': 'Pizzas',
          'items': [
            {
              'id': 'item_1',
              'name': 'Margherita Pizza',
              'description': 'Classic tomato and mozzarella',
              'price': 35.0,
              'image_url': 'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=400',
              'is_available': true,
              'extras': [
                {
                  'id': 'extra_1',
                  'name': 'Extra Cheese',
                  'price': 5.0,
                },
                {
                  'id': 'extra_2',
                  'name': 'Extra Toppings',
                  'price': 8.0,
                },
              ],
            },
            {
              'id': 'item_2',
              'name': 'Pepperoni Pizza',
              'description': 'Pepperoni with mozzarella',
              'price': 42.0,
              'image_url': 'https://images.unsplash.com/photo-1628840042765-356cda07504e?w=400',
              'is_available': true,
              'extras': [],
            },
          ],
        },
        {
          'id': 'cat_2',
          'name': 'Drinks',
          'items': [
            {
              'id': 'item_3',
              'name': 'Coca Cola',
              'description': '500ml',
              'price': 8.0,
              'image_url': null,
              'is_available': true,
              'extras': [],
            },
          ],
        },
      ],
    };

    return Response.ok(
      jsonEncode({
        'success': true,
        'data': menu,
      }),
      headers: {'Content-Type': 'application/json'},
    );
  });

  // ============ ADDRESSES ENDPOINTS ============

  router.get('/users/<id>/addresses', (Request request, String id) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final addresses = [
      {
        'id': 'addr_1',
        'user_id': id,
        'label': 'Home',
        'address_line': '123 King Fahd Road',
        'city': 'Riyadh',
        'postal_code': '12345',
        'latitude': 24.7136,
        'longitude': 46.6753,
        'is_default': true,
      },
      {
        'id': 'addr_2',
        'user_id': id,
        'label': 'Work',
        'address_line': '456 Olaya Street',
        'city': 'Riyadh',
        'postal_code': '12346',
        'latitude': 24.7000,
        'longitude': 46.6800,
        'is_default': false,
      },
    ];

    return Response.ok(
      jsonEncode({
        'success': true,
        'data': addresses,
      }),
      headers: {'Content-Type': 'application/json'},
    );
  });

  router.post('/users/<id>/addresses', (Request request, String id) async {
    final body = await request.readAsString();
    final data = jsonDecode(body) as Map<String, dynamic>;

    await Future.delayed(const Duration(milliseconds: 300));

    final newAddress = {
      'id': 'addr_${DateTime.now().millisecondsSinceEpoch}',
      'user_id': id,
      'label': data['label'] ?? 'Address',
      'address_line': data['address_line'],
      'city': data['city'] ?? 'Riyadh',
      'postal_code': data['postal_code'] ?? '',
      'latitude': data['latitude'],
      'longitude': data['longitude'],
      'is_default': data['is_default'] ?? false,
    };

    return Response.ok(
      jsonEncode({
        'success': true,
        'data': newAddress,
      }),
      headers: {'Content-Type': 'application/json'},
    );
  });

  // ============ ORDERS ENDPOINTS ============

  router.post('/orders', (Request request) async {
    final body = await request.readAsString();
    final data = jsonDecode(body) as Map<String, dynamic>;

    await Future.delayed(const Duration(milliseconds: 500));

    final orderId = 'order_${DateTime.now().millisecondsSinceEpoch}';
    final order = {
      'id': orderId,
      'user_id': data['user_id'],
      'restaurant_id': data['restaurant_id'],
      'status': 'accepted',
      'total_amount': data['total_amount'],
      'delivery_fee': data['delivery_fee'] ?? 5.0,
      'estimated_time': 25,
      'created_at': DateTime.now().toIso8601String(),
      'items': data['items'],
      'address': data['address'],
    };

    return Response.ok(
      jsonEncode({
        'success': true,
        'data': order,
      }),
      headers: {'Content-Type': 'application/json'},
    );
  });

  router.get('/orders/<id>/track', (Request request, String id) async {
    // WebSocket placeholder - return current order status
    await Future.delayed(const Duration(milliseconds: 300));

    final tracking = {
      'order_id': id,
      'status': 'preparing',
      'estimated_time': 20,
      'driver': null,
      'timeline': [
        {
          'status': 'accepted',
          'timestamp': DateTime.now().subtract(const Duration(minutes: 5)).toIso8601String(),
        },
        {
          'status': 'preparing',
          'timestamp': DateTime.now().toIso8601String(),
        },
      ],
    };

    return Response.ok(
      jsonEncode({
        'success': true,
        'data': tracking,
      }),
      headers: {'Content-Type': 'application/json'},
    );
  });

  // ============ COUPONS ENDPOINT ============

  router.post('/coupons/validate', (Request request) async {
    final body = await request.readAsString();
    final data = jsonDecode(body) as Map<String, dynamic>;
    final code = data['code'] as String?;

    await Future.delayed(const Duration(milliseconds: 300));

    if (code == null || code.isEmpty) {
      return Response.badRequest(
        body: jsonEncode({'error': 'Coupon code is required'}),
        headers: {'Content-Type': 'application/json'},
      );
    }

    // Mock validation
    final validCodes = ['WELCOME10', 'SAVE20', 'FREEDELIVERY'];
    final isValid = validCodes.contains(code.toUpperCase());

    if (isValid) {
      return Response.ok(
        jsonEncode({
          'success': true,
          'data': {
            'code': code.toUpperCase(),
            'discount_type': code.toUpperCase() == 'FREEDELIVERY' ? 'delivery' : 'percentage',
            'discount_value': code.toUpperCase() == 'WELCOME10' ? 10 : 20,
            'valid': true,
          },
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } else {
      return Response.ok(
        jsonEncode({
          'success': false,
          'error': 'Invalid coupon code',
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  });

  // 404 handler
  router.all('/<path|.*>', (Request request) {
    return Response.notFound(
      jsonEncode({
        'success': false,
        'error': 'Endpoint not found: ${request.url.path}',
      }),
      headers: {'Content-Type': 'application/json'},
    );
  });

  return router;
}

