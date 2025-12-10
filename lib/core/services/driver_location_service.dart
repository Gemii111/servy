import 'dart:async';
import 'package:geolocator/geolocator.dart';

/// Service for tracking driver location in real-time
class DriverLocationService {
  static final DriverLocationService instance = DriverLocationService._();
  DriverLocationService._();

  StreamSubscription<Position>? _positionStreamSubscription;
  Position? _currentPosition;
  bool _isTracking = false;

  /// Get current position (one-time)
  Future<Position?> getCurrentPosition() async {
    try {
      final hasPermission = await _checkPermission();
      if (!hasPermission) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      return null;
    }
  }

  /// Start tracking driver location in real-time
  /// Returns a stream that yields positions as they are updated
  Stream<Position> startLocationTracking({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilter = 10, // meters
    Duration? timeLimit,
  }) async* {
    // Stop existing tracking if any
    if (_isTracking && _positionStreamSubscription != null) {
      await stopLocationTracking();
    }

    // Check permission first
    final hasPermission = await _checkPermission();
    if (!hasPermission) {
      throw Exception('Location permission denied');
    }

    final locationSettings = LocationSettings(
      accuracy: accuracy,
      distanceFilter: distanceFilter,
    );

    // Create a stream controller
    final streamController = StreamController<Position>.broadcast();

    // Get position stream from Geolocator
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      (Position position) {
        _currentPosition = position;
        streamController.add(position);
      },
      onError: (error) {
        streamController.addError(error);
        _isTracking = false;
      },
      onDone: () {
        streamController.close();
        _isTracking = false;
      },
      cancelOnError: false,
    );

    _isTracking = true;

    // Yield positions from the controller stream
    yield* streamController.stream;
  }

  /// Stop tracking location
  Future<void> stopLocationTracking() async {
    await _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
    _isTracking = false;
  }

  /// Get last known position (cached)
  Position? get lastKnownPosition => _currentPosition;

  /// Check if currently tracking
  bool get isTracking => _isTracking;

  /// Check and request location permissions
  Future<bool> _checkPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are disabled
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever
      return false;
    }

    // Permissions are granted
    return true;
  }

  /// Request location permissions explicitly
  Future<bool> requestPermission() async {
    return await _checkPermission();
  }

  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Calculate distance between two points in kilometers
  static double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
          startLatitude,
          startLongitude,
          endLatitude,
          endLongitude,
        ) /
        1000; // Convert meters to kilometers
  }

  /// Calculate bearing between two points
  static double calculateBearing(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.bearingBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// Dispose resources
  Future<void> dispose() async {
    await stopLocationTracking();
  }
}
