import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/driver_earnings_model.dart';
import '../../data/repositories/driver_repository.dart';

/// Driver repository provider
final driverRepositoryProvider = Provider<DriverRepository>((ref) {
  return DriverRepository();
});

/// Driver earnings provider
final driverEarningsProvider =
    FutureProvider.family<DriverEarningsModel, String>((ref, driverId) async {
  final repository = ref.watch(driverRepositoryProvider);
  return await repository.getDriverEarnings(driverId);
});

