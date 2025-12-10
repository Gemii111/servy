import 'dart:async';
import 'package:dio/dio.dart';

/// Connectivity service to check internet connection
class ConnectivityService {
  ConnectivityService._();
  
  static final ConnectivityService instance = ConnectivityService._();

  bool _isConnected = true;
  final StreamController<bool> _connectivityController = StreamController<bool>.broadcast();

  /// Current connectivity status
  bool get isConnected => _isConnected;

  /// Connectivity status stream
  Stream<bool> get connectivityStream => _connectivityController.stream;

  /// Check internet connectivity
  Future<bool> checkConnectivity() async {
    try {
      final dio = Dio();
      dio.options.connectTimeout = const Duration(seconds: 5);
      dio.options.receiveTimeout = const Duration(seconds: 5);

      // Try to connect to a reliable server
      final response = await dio.get(
        'https://www.google.com',
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      final connected = response.statusCode != null && response.statusCode! < 500;
      _updateConnectivityStatus(connected);
      return connected;
    } catch (e) {
      _updateConnectivityStatus(false);
      return false;
    }
  }

  /// Update connectivity status and notify listeners
  void _updateConnectivityStatus(bool isConnected) {
    if (_isConnected != isConnected) {
      _isConnected = isConnected;
      _connectivityController.add(isConnected);
    }
  }

  /// Start periodic connectivity checks
  Timer? _checkTimer;
  void startPeriodicCheck({Duration interval = const Duration(seconds: 10)}) {
    stopPeriodicCheck();
    _checkTimer = Timer.periodic(interval, (_) async {
      await checkConnectivity();
    });
  }

  /// Stop periodic connectivity checks
  void stopPeriodicCheck() {
    _checkTimer?.cancel();
    _checkTimer = null;
  }

  /// Dispose resources
  void dispose() {
    stopPeriodicCheck();
    _connectivityController.close();
  }
}

