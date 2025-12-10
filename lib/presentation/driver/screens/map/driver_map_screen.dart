import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/order_model.dart';
import '../../../../logic/providers/restaurant_providers.dart';
import '../../../../core/utils/haptic_feedback.dart';
import '../../../../logic/providers/order_providers.dart';
import '../../../../logic/providers/driver_location_providers.dart';
import '../../../../core/services/driver_location_service.dart';
import 'package:geolocator/geolocator.dart';
import '../../../customer/widgets/common/loading_state_widget.dart';
import '../../../customer/widgets/common/error_state_widget.dart';

/// Driver Map Screen - Shows restaurant and customer locations on map
class DriverMapScreen extends ConsumerWidget {
  const DriverMapScreen({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderByIdProvider(orderId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          context.l10n.map,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: orderAsync.when(
        data: (order) {
          if (order == null) {
            return ErrorStateWidget(
              message: context.l10n.orderNotFound,
              onRetry: () {
                ref.invalidate(orderByIdProvider(orderId));
              },
            );
          }
          return _MapContent(order: order);
        },
        loading: () => const LoadingStateWidget(),
        error:
            (error, stack) => ErrorStateWidget(
              message: context.l10n.failedToLoadOrder,
              error: error.toString(),
              onRetry: () {
                ref.invalidate(orderByIdProvider(orderId));
              },
            ),
      ),
    );
  }
}

/// Map Content Widget
class _MapContent extends ConsumerStatefulWidget {
  const _MapContent({required this.order});

  final OrderModel order;

  @override
  ConsumerState<_MapContent> createState() => _MapContentState();
}

class _MapContentState extends ConsumerState<_MapContent> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  bool _isLoading = true;
  Position? _driverPosition;
  double? _distanceToRestaurant;
  double? _distanceToCustomer;

  @override
  void initState() {
    super.initState();
    _loadMapData();
    _startDriverLocationTracking();
  }

  void _startDriverLocationTracking() {
    // Watch driver position stream for real-time updates
    ref.listenManual(driverPositionStreamProvider, (previous, next) {
      next.whenData((position) {
        if (mounted) {
          setState(() {
            _driverPosition = position;
          });
          _updateDriverMarker();
          _calculateDistances();
        }
      });
    });

    // Also get current position immediately
    _getCurrentDriverPosition();
  }

  Future<void> _getCurrentDriverPosition() async {
    final positionAsync = ref.read(driverCurrentPositionProvider);
    positionAsync.whenData((position) {
      if (position != null && mounted) {
        setState(() {
          _driverPosition = position;
        });
        _updateDriverMarker();
        _calculateDistances();
      }
    });
  }

  void _updateDriverMarker() {
    if (_driverPosition == null) return;

    final newMarkers = Set<Marker>.from(_markers);

    // Remove existing driver marker if any
    newMarkers.removeWhere((m) => m.markerId.value == 'driver');

    // Add driver marker
    newMarkers.add(
      Marker(
        markerId: const MarkerId('driver'),
        position: LatLng(_driverPosition!.latitude, _driverPosition!.longitude),
        infoWindow: InfoWindow(
          title: context.l10n.yourLocation,
          snippet: context.l10n.driverLocation,
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

  void _calculateDistances() {
    if (_driverPosition == null) return;

    // Calculate distance to restaurant
    final restaurantMarker = _markers.firstWhere(
      (m) => m.markerId.value == 'restaurant',
      orElse: () => _markers.first,
    );
    if (restaurantMarker.markerId.value == 'restaurant') {
      _distanceToRestaurant = DriverLocationService.calculateDistance(
        _driverPosition!.latitude,
        _driverPosition!.longitude,
        restaurantMarker.position.latitude,
        restaurantMarker.position.longitude,
      );
    }

    // Calculate distance to customer
    final customerMarker = _markers.firstWhere(
      (m) => m.markerId.value == 'customer',
      orElse: () => _markers.first,
    );
    if (customerMarker.markerId.value == 'customer') {
      _distanceToCustomer = DriverLocationService.calculateDistance(
        _driverPosition!.latitude,
        _driverPosition!.longitude,
        customerMarker.position.latitude,
        customerMarker.position.longitude,
      );
    }

    if (mounted) {
      setState(() {});
    }
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
              title: context.l10n.deliverTo,
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

        // Add driver marker if available and calculate distances
        _updateDriverMarker();
        _calculateDistances();

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
              title: context.l10n.deliverTo,
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
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

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (_isLoading) {
      return const LoadingStateWidget();
    }

    // Default center (Cairo, Egypt)
    final defaultCenter = const LatLng(30.0444, 31.2357);

    return Stack(
      children: [
        // Google Map
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target:
                _markers.isNotEmpty ? _markers.first.position : defaultCenter,
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
          onTap: (LatLng position) {
            // Hide keyboard or other UI elements if needed
          },
        ),
        // Info Cards at bottom
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Restaurant Info Card
                _LocationInfoCard(
                  icon: Icons.restaurant,
                  iconColor: AppColors.primary,
                  title: l10n.pickupFrom,
                  name: widget.order.restaurantName,
                  distance: _distanceToRestaurant,
                  onTap: () {
                    HapticFeedbackUtil.mediumImpact();
                    _mapController?.animateCamera(
                      CameraUpdate.newLatLngZoom(
                        _markers
                            .firstWhere(
                              (m) => m.markerId.value == 'restaurant',
                              orElse: () => _markers.first,
                            )
                            .position,
                        16.0,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                // Customer Info Card
                _LocationInfoCard(
                  icon: Icons.location_on,
                  iconColor: AppColors.accent,
                  title: l10n.deliverTo,
                  name: widget.order.deliveryAddress.fullAddress,
                  distance: _distanceToCustomer,
                  onTap: () {
                    HapticFeedbackUtil.mediumImpact();
                    _mapController?.animateCamera(
                      CameraUpdate.newLatLngZoom(
                        _markers
                            .firstWhere(
                              (m) => m.markerId.value == 'customer',
                              orElse: () => _markers.first,
                            )
                            .position,
                        16.0,
                      ),
                    );
                  },
                ),
                if (_driverPosition != null) ...[
                  const SizedBox(height: 12),
                  // Driver Location Card
                  _LocationInfoCard(
                    icon: Icons.local_shipping,
                    iconColor: Colors.blue,
                    title: l10n.yourLocation,
                    name: l10n.driverLocation,
                    onTap: () {
                      HapticFeedbackUtil.mediumImpact();
                      _mapController?.animateCamera(
                        CameraUpdate.newLatLngZoom(
                          LatLng(
                            _driverPosition!.latitude,
                            _driverPosition!.longitude,
                          ),
                          16.0,
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}

/// Location Info Card Widget
class _LocationInfoCard extends StatelessWidget {
  const _LocationInfoCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.name,
    required this.onTap,
    this.distance,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String name;
  final VoidCallback onTap;
  final double? distance;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [AppColors.cardShadow],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (distance != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.straighten,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${distance!.toStringAsFixed(1)} ${context.l10n.km}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
