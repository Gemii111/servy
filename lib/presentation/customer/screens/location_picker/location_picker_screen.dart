import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/localization/app_localizations.dart';

/// Location picker screen using Google Maps
class LocationPickerScreen extends ConsumerStatefulWidget {
  const LocationPickerScreen({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
    this.onLocationSelected,
  });

  final double? initialLatitude;
  final double? initialLongitude;
  final Function(double latitude, double longitude, String address)? onLocationSelected;

  @override
  ConsumerState<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends ConsumerState<LocationPickerScreen> {
  GoogleMapController? _mapController;
  LatLng? _selectedLocation;
  String _selectedAddress = '';
  bool _isLoading = false;
  bool _isLoadingAddress = false;
  // Removed _mapsSupported flag - will use try-catch instead

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    setState(() => _isLoading = true);

    try {
      if (widget.initialLatitude != null && widget.initialLongitude != null) {
        // Use provided initial location
        _selectedLocation = LatLng(widget.initialLatitude!, widget.initialLongitude!);
        await _updateAddress(_selectedLocation!);
      } else {
        // Get current location
        final position = await LocationService.instance.getCurrentPosition();
        _selectedLocation = LatLng(position.latitude, position.longitude);
        await _updateAddress(_selectedLocation!);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${context.l10n.failedToGetLocation}: $e'),
            backgroundColor: Colors.red,
          ),
        );
        // Use default location (Cairo)
        _selectedLocation = const LatLng(30.0444, 31.2357);
        await _updateAddress(_selectedLocation!);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateAddress(LatLng location) async {
    setState(() => _isLoadingAddress = true);
    try {
      final address = await LocationService.instance.getAddressFromCoordinates(
        location.latitude,
        location.longitude,
      );
      setState(() {
        _selectedAddress = address;
        _isLoadingAddress = false;
      });
    } catch (e) {
      // Fallback to coordinates if geocoding fails
      setState(() {
        _selectedAddress = '${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}';
        _isLoadingAddress = false;
      });
    }
  }

  void _onMapTap(LatLng location) {
    setState(() {
      _selectedLocation = location;
    });
    _updateAddress(location);
  }

  void _onCurrentLocationTap() async {
    try {
      final position = await LocationService.instance.getCurrentPosition();
      final location = LatLng(position.latitude, position.longitude);
      
      setState(() {
        _selectedLocation = location;
      });
      
      await _updateAddress(location);
      
      // Move camera to current location if map is available
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(location, 15),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${context.l10n.failedToGetLocation}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onConfirm() {
    if (_selectedLocation != null) {
      if (widget.onLocationSelected != null) {
        widget.onLocationSelected!(
          _selectedLocation!.latitude,
          _selectedLocation!.longitude,
          _selectedAddress,
        );
      } else {
        // Return result via Navigator.pop
        Navigator.of(context).pop({
          'latitude': _selectedLocation!.latitude,
          'longitude': _selectedLocation!.longitude,
          'address': _selectedAddress,
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.selectLocation),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _onCurrentLocationTap,
            tooltip: l10n.useCurrentLocation,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _selectedLocation == null
              ? const Center(child: CircularProgressIndicator())
              : _buildMapOrFallback(),
    );
  }

  Widget _buildMapOrFallback() {
    // Wrap GoogleMap in error boundary to catch platform view errors
    return Stack(
      children: [
        // Try to show Google Maps, with fallback for older devices
        Builder(
          builder: (context) {
            try {
              return GoogleMap(
                key: const Key('google_map'),
                initialCameraPosition: CameraPosition(
                  target: _selectedLocation!,
                  zoom: 15,
                ),
                onMapCreated: (controller) {
                  _mapController = controller;
                },
                onTap: _onMapTap,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                mapType: MapType.normal,
                markers: {
                  Marker(
                    markerId: const MarkerId('selected_location'),
                    position: _selectedLocation!,
                    draggable: true,
                    onDragEnd: (newPosition) {
                      setState(() {
                        _selectedLocation = newPosition;
                      });
                      _updateAddress(newPosition);
                    },
                  ),
                },
                onCameraMove: (position) {
                  // Optional: Update location on camera move
                },
                onCameraIdle: () {
                  // Optional: Update address when camera stops
                },
              );
            } catch (e) {
              // If Google Maps fails, show fallback
              return _buildFallbackUI();
            }
          },
        ),
        // Address display card
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _isLoadingAddress
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(
                                _selectedAddress,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _onConfirm,
                      icon: const Icon(Icons.check),
                      label: Text(context.l10n.confirmLocation),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFallbackUI() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.map_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'Map Not Available',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Your device doesn\'t support Google Maps. Please use "Use Current Location" button to select your location.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            if (_selectedAddress.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selected Location',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _selectedAddress,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
            ElevatedButton.icon(
              onPressed: _onCurrentLocationTap,
              icon: const Icon(Icons.my_location),
              label: Text(context.l10n.useCurrentLocation),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
