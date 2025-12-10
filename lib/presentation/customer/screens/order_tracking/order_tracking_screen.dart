import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../data/models/order_model.dart';
import '../../../../logic/providers/order_providers.dart';
import '../../../../logic/providers/auth_providers.dart';
import '../../../../logic/providers/restaurant_providers.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/driver_location_model.dart';
import '../../widgets/common/loading_state_widget.dart';
import '../../widgets/common/error_state_widget.dart';

/// Order tracking screen with live updates
class OrderTrackingScreen extends ConsumerStatefulWidget {
  const OrderTrackingScreen({super.key, required this.orderId});

  final String orderId;

  @override
  ConsumerState<OrderTrackingScreen> createState() =>
      _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends ConsumerState<OrderTrackingScreen> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text(context.l10n.trackOrder)),
        body: Center(child: Text(context.l10n.pleaseLoginFirst)),
      );
    }

    final ordersAsync = ref.watch(userOrdersProvider(user.id));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.card,
        title: Text(
          context.l10n.trackOrder,
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: ordersAsync.when(
        data: (orders) {
          final order = orders.firstWhere(
            (o) => o.id == widget.orderId,
            orElse: () => throw Exception('Order not found'),
          );
          return _buildTrackingContent(context, order);
        },
        loading: () => const LoadingStateWidget(),
        error:
            (error, stack) => ErrorStateWidget(
              message: context.l10n.failedToLoadOrder,
              error: error.toString(),
              showGoBack: true,
            ),
      ),
    );
  }

  Widget _buildTrackingContent(BuildContext context, OrderModel order) {
    final statusSteps = _getStatusSteps(order.status);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Restaurant Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.border),
              boxShadow: [AppColors.cardShadow],
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.restaurant,
                    size: 30,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.restaurantName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Order #${order.id.substring(order.id.length - 6)}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Status Timeline
          Text(
            'Order Status',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...statusSteps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            final isLast = index == statusSteps.length - 1;
            return _StatusStep(
              step: step,
              isCompleted: step['isCompleted'] as bool,
              isCurrent: step['isCurrent'] as bool,
              isLast: isLast,
            );
          }),
          const SizedBox(height: 32),
          // Delivery Address
          Text(
            context.l10n.deliveryAddress,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.border),
              boxShadow: [AppColors.cardShadow],
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.deliveryAddress.label,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order.deliveryAddress.fullAddress,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Estimated Time
          if (order.estimatedDeliveryTime != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.accent),
                boxShadow: [AppColors.cardShadow],
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time, color: AppColors.accent),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Estimated Delivery Time',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.accent,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatEstimatedTime(order.estimatedDeliveryTime!),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),
          // Map Section (if order is out for delivery or delivered and has driver)
          if ((order.status == OrderStatus.outForDelivery ||
                  order.status == OrderStatus.delivered) &&
              order.driverId != null)
            _DriverLocationMap(order: order),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getStatusSteps(OrderStatus currentStatus) {
    final allSteps = [
      {'name': 'Order Placed', 'status': OrderStatus.pending},
      {'name': 'Order Accepted', 'status': OrderStatus.accepted},
      {'name': 'Preparing', 'status': OrderStatus.preparing},
      {'name': 'Ready', 'status': OrderStatus.ready},
      {'name': 'Out for Delivery', 'status': OrderStatus.outForDelivery},
      {'name': 'Delivered', 'status': OrderStatus.delivered},
    ];

    final currentStatusIndex = allSteps.indexWhere(
      (step) => step['status'] == currentStatus,
    );

    return allSteps.map((step) {
      final stepIndex = allSteps.indexOf(step);
      final isCompleted = stepIndex < currentStatusIndex;
      final isCurrent = stepIndex == currentStatusIndex;

      return {
        'name': step['name'] as String,
        'isCompleted': isCompleted,
        'isCurrent': isCurrent,
      };
    }).toList();
  }

  String _formatEstimatedTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);

    if (difference.inMinutes <= 0) {
      return 'Delivered';
    } else if (difference.inMinutes < 60) {
      return 'In ${difference.inMinutes} minutes';
    } else {
      final hours = difference.inHours;
      final minutes = difference.inMinutes % 60;
      return 'In $hours hour${hours > 1 ? 's' : ''} ${minutes > 0 ? '$minutes min' : ''}';
    }
  }
}

/// Status step widget
class _StatusStep extends StatelessWidget {
  const _StatusStep({
    required this.step,
    required this.isCompleted,
    required this.isCurrent,
    required this.isLast,
  });

  final Map<String, dynamic> step;
  final bool isCompleted;
  final bool isCurrent;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final color =
        isCompleted || isCurrent ? AppColors.primary : AppColors.border;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon/Circle
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color),
              child:
                  isCompleted
                      ? const Icon(Icons.check, color: Colors.white, size: 20)
                      : isCurrent
                      ? Center(
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                        ),
                      )
                      : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: isCompleted ? color : AppColors.border,
              ),
          ],
        ),
        const SizedBox(width: 16),
        // Text
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: isCurrent ? 4 : 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step['name'] as String,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                    color:
                        isCompleted || isCurrent
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                  ),
                ),
                if (isCurrent) ...[
                  const SizedBox(height: 4),
                  Text(
                    'In progress',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Driver location map widget for customer order tracking
class _DriverLocationMap extends ConsumerStatefulWidget {
  const _DriverLocationMap({required this.order});

  final OrderModel order;

  @override
  ConsumerState<_DriverLocationMap> createState() => _DriverLocationMapState();
}

class _DriverLocationMapState extends ConsumerState<_DriverLocationMap> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  bool _isLoading = true;
  DriverLocationData? _driverLocation;

  @override
  void initState() {
    super.initState();
    _loadMapData();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _loadMapData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get restaurant location
      final restaurant = await ref.read(
        restaurantByIdProvider(widget.order.restaurantId).future,
      );

      if (restaurant != null) {
        // Create markers
        final markers = <Marker>{
          // Restaurant marker
          Marker(
            markerId: const MarkerId('restaurant'),
            position: LatLng(restaurant.latitude, restaurant.longitude),
            infoWindow: InfoWindow(
              title: widget.order.restaurantName,
              snippet: restaurant.address,
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueRed,
            ),
          ),
          // Customer delivery address marker
          Marker(
            markerId: const MarkerId('customer'),
            position: LatLng(
              widget.order.deliveryAddress.latitude,
              widget.order.deliveryAddress.longitude,
            ),
            infoWindow: InfoWindow(
              title: 'Delivery Address',
              snippet: widget.order.deliveryAddress.fullAddress,
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueGreen,
            ),
          ),
        };

        setState(() {
          _markers = markers;
          _isLoading = false;
        });

        // Fit bounds to show all markers
        if (_mapController != null) {
          await _fitBounds();
        }
      } else {
        // If restaurant not found, show only customer location
        final markers = <Marker>{
          Marker(
            markerId: const MarkerId('customer'),
            position: LatLng(
              widget.order.deliveryAddress.latitude,
              widget.order.deliveryAddress.longitude,
            ),
            infoWindow: InfoWindow(
              title: 'Delivery Address',
              snippet: widget.order.deliveryAddress.fullAddress,
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueGreen,
            ),
          ),
        };

        setState(() {
          _markers = markers;
          _isLoading = false;
        });

        if (_mapController != null) {
          await _mapController!.animateCamera(
            CameraUpdate.newLatLngZoom(
              LatLng(
                widget.order.deliveryAddress.latitude,
                widget.order.deliveryAddress.longitude,
              ),
              15.0,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _updateDriverMarker() {
    if (_driverLocation == null) return;

    final newMarkers = Set<Marker>.from(_markers);

    // Remove existing driver marker if any
    newMarkers.removeWhere((m) => m.markerId.value == 'driver');

    // Add driver marker
    newMarkers.add(
      Marker(
        markerId: const MarkerId('driver'),
        position: LatLng(_driverLocation!.latitude, _driverLocation!.longitude),
        infoWindow: const InfoWindow(
          title: 'Driver Location',
          snippet: 'Your order is on the way',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueAzure, // Blue color for driver
        ),
      ),
    );

    if (mounted) {
      setState(() {
        _markers = newMarkers;
      });
      _fitBounds();
    }
  }

  Future<void> _fitBounds() async {
    if (_markers.isEmpty || _mapController == null) return;

    final bounds = _calculateBounds();
    if (bounds != null) {
      await _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 100.0),
      );
    }
  }

  LatLngBounds? _calculateBounds() {
    if (_markers.isEmpty) return null;

    double minLat = double.infinity;
    double maxLat = -double.infinity;
    double minLng = double.infinity;
    double maxLng = -double.infinity;

    for (final marker in _markers) {
      final lat = marker.position.latitude;
      final lng = marker.position.longitude;

      if (lat < minLat) minLat = lat;
      if (lat > maxLat) maxLat = lat;
      if (lng < minLng) minLng = lng;
      if (lng > maxLng) maxLng = lng;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  String _formatTimeSince(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch driver location updates
    final driverLocationAsync = ref.watch(
      driverLocationForOrderProvider(widget.order.id),
    );

    driverLocationAsync.whenData((location) {
      if (location != _driverLocation) {
        setState(() {
          _driverLocation = location;
        });
        _updateDriverMarker();
      }
    });

    if (_isLoading) {
      return Container(
        height: 250,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border),
        ),
        child: const Center(child: LoadingStateWidget()),
      );
    }

    // Default center (Cairo, Egypt)
    final defaultCenter = const LatLng(30.0444, 31.2357);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Track Your Order',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 300,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target:
                    _markers.isNotEmpty
                        ? _markers.first.position
                        : defaultCenter,
                zoom: 12.0,
              ),
              markers: _markers,
              mapType: MapType.normal,
              myLocationButtonEnabled: true,
              myLocationEnabled: true,
              zoomControlsEnabled: true,
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
                // Fit bounds after map is created
                Future.delayed(const Duration(milliseconds: 500), () {
                  _fitBounds();
                });
              },
            ),
          ),
        ),
        if (_driverLocation != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.accent),
            ),
            child: Row(
              children: [
                const Icon(Icons.local_shipping, color: AppColors.accent),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Driver is on the way',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Location updated ${_formatTimeSince(_driverLocation!.timestamp)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
