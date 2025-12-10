import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/services/driver_location_service.dart';
import '../../data/services/driver_location_update_service.dart';

/// Provider for DriverLocationService
final driverLocationServiceProvider = Provider<DriverLocationService>((ref) {
  // Dispose service when provider is disposed
  ref.onDispose(() {
    DriverLocationService.instance.dispose();
  });
  return DriverLocationService.instance;
});

/// Provider for current driver position (one-time)
final driverCurrentPositionProvider = FutureProvider<Position?>((ref) async {
  final service = ref.watch(driverLocationServiceProvider);
  return await service.getCurrentPosition();
});

/// Provider for real-time driver position stream
final driverPositionStreamProvider = StreamProvider<Position>((ref) {
  final service = ref.watch(driverLocationServiceProvider);

  // Auto-start tracking when provider is watched
  final stream = service.startLocationTracking(
    accuracy: LocationAccuracy.high,
    distanceFilter: 10, // Update every 10 meters
  );

  // Stop tracking when provider is disposed
  ref.onDispose(() {
    service.stopLocationTracking();
  });

  return stream;
});

/// Provider for checking if location tracking is active
final isDriverLocationTrackingProvider = Provider<bool>((ref) {
  final service = ref.watch(driverLocationServiceProvider);
  return service.isTracking;
});

/// Provider for last known driver position (cached)
final driverLastKnownPositionProvider = Provider<Position?>((ref) {
  final service = ref.watch(driverLocationServiceProvider);
  return service.lastKnownPosition;
});

/// Provider for location permission status
final driverLocationPermissionProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(driverLocationServiceProvider);
  return await service.requestPermission();
});

/// Provider for location service enabled status
final locationServiceEnabledProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(driverLocationServiceProvider);
  return await service.isLocationServiceEnabled();
});

/// Provider for DriverLocationUpdateService
final driverLocationUpdateServiceProvider =
    Provider<DriverLocationUpdateService>((ref) {
      // Dispose service when provider is disposed
      ref.onDispose(() {
        DriverLocationUpdateService.instance.dispose();
      });
      return DriverLocationUpdateService.instance;
    });
