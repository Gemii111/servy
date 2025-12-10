import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../../core/utils/logger.dart';
import 'mock_api_service.dart';

/// Service for sending driver location updates to backend
class DriverLocationUpdateService {
  static final DriverLocationUpdateService instance =
      DriverLocationUpdateService._();
  DriverLocationUpdateService._();

  String? _currentDriverId;
  StreamSubscription<Position>? _positionSubscription;
  bool _isSendingUpdates = false;
  Position? _lastSentPosition;
  static const double _minDistanceToSend =
      50.0; // meters - send update every 50m

  /// Start sending location updates for a driver
  Future<void> startSendingUpdates({
    required String driverId,
    required Stream<Position> positionStream,
  }) async {
    if (_isSendingUpdates && _currentDriverId == driverId) {
      // Already sending updates for this driver
      return;
    }

    // Stop previous updates if any
    await stopSendingUpdates();

    _currentDriverId = driverId;
    _isSendingUpdates = true;
    _lastSentPosition = null;

    Logger.d(
      'DriverLocationUpdateService',
      'Starting to send location updates for driver: $driverId',
    );

    // Listen to position stream and send updates
    _positionSubscription = positionStream.listen(
      (position) => _sendLocationUpdate(driverId, position),
      onError: (error) {
        Logger.e(
          'DriverLocationUpdateService',
          'Error in position stream: $error',
        );
      },
      onDone: () {
        Logger.d(
          'DriverLocationUpdateService',
          'Position stream closed for driver: $driverId',
        );
        _isSendingUpdates = false;
      },
      cancelOnError: false,
    );
  }

  /// Stop sending location updates
  Future<void> stopSendingUpdates() async {
    if (!_isSendingUpdates) return;

    await _positionSubscription?.cancel();
    _positionSubscription = null;
    _isSendingUpdates = false;
    _currentDriverId = null;
    _lastSentPosition = null;

    Logger.d('DriverLocationUpdateService', 'Stopped sending location updates');
  }

  /// Send location update to backend
  Future<void> _sendLocationUpdate(String driverId, Position position) async {
    // Check if we should send this update (based on distance threshold)
    if (_lastSentPosition != null) {
      final distance = Geolocator.distanceBetween(
        _lastSentPosition!.latitude,
        _lastSentPosition!.longitude,
        position.latitude,
        position.longitude,
      );

      // Only send if moved more than minimum distance
      if (distance < _minDistanceToSend) {
        return;
      }
    }

    try {
      // Send to backend via MockApiService
      await MockApiService.instance.updateDriverLocation(
        driverId: driverId,
        latitude: position.latitude,
        longitude: position.longitude,
        heading: position.heading,
        speed: position.speed,
        timestamp: position.timestamp,
      );

      _lastSentPosition = position;

      Logger.d(
        'DriverLocationUpdateService',
        'Location update sent for driver $driverId: '
            '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}',
      );
    } catch (e) {
      Logger.e(
        'DriverLocationUpdateService',
        'Failed to send location update: $e',
      );
    }
  }

  /// Get current status
  bool get isSendingUpdates => _isSendingUpdates;
  String? get currentDriverId => _currentDriverId;

  /// Dispose resources
  Future<void> dispose() async {
    await stopSendingUpdates();
  }
}
