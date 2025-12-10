import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/connectivity_service.dart';

/// Connectivity state notifier
class ConnectivityNotifier extends StateNotifier<AsyncValue<bool>> {
  ConnectivityNotifier(this._connectivityService) : super(const AsyncValue.data(true)) {
    _initialize();
  }

  final ConnectivityService _connectivityService;
  StreamSubscription<bool>? _connectivitySubscription;

  Future<void> _initialize() async {
    // Check initial connectivity
    final isConnected = await _connectivityService.checkConnectivity();
    state = AsyncValue.data(isConnected);

    // Listen to connectivity changes
    _connectivitySubscription = _connectivityService.connectivityStream.listen(
      (isConnected) {
        state = AsyncValue.data(isConnected);
      },
      onError: (error) {
        state = AsyncValue.error(error, StackTrace.current);
      },
    );

    // Start periodic checks
    _connectivityService.startPeriodicCheck();
  }

  /// Check connectivity manually
  Future<void> checkConnectivity() async {
    state = const AsyncValue.loading();
    try {
      final isConnected = await _connectivityService.checkConnectivity();
      state = AsyncValue.data(isConnected);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}

/// Connectivity provider
final connectivityProvider = StateNotifierProvider<ConnectivityNotifier, AsyncValue<bool>>((ref) {
  final connectivityService = ConnectivityService.instance;
  return ConnectivityNotifier(connectivityService);
});

/// Convenience provider for boolean connectivity status
final isConnectedProvider = Provider<bool>((ref) {
  final connectivityAsync = ref.watch(connectivityProvider);
  return connectivityAsync.when(
    data: (isConnected) => isConnected,
    loading: () => true, // Assume connected while loading
    error: (_, __) => false, // Assume disconnected on error
  );
});

