import '../models/driver_earnings_model.dart';
import '../services/mock_api_service.dart';

/// Driver repository
class DriverRepository {
  DriverRepository({MockApiService? mockApiService})
      : _mockApiService = mockApiService ?? MockApiService.instance;

  final MockApiService _mockApiService;

  /// Get driver earnings
  Future<DriverEarningsModel> getDriverEarnings(String driverId) async {
    return await _mockApiService.getDriverEarnings(driverId);
  }
}

