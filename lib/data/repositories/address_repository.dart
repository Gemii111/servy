import '../models/address_model.dart';
import '../services/mock_api_service.dart';

/// Address repository
class AddressRepository {
  AddressRepository({
    MockApiService? mockApiService,
  }) : _mockApiService = mockApiService ?? MockApiService.instance;

  final MockApiService _mockApiService;

  /// Get user addresses
  Future<List<AddressModel>> getUserAddresses(String userId) async {
    return await _mockApiService.getUserAddresses(userId);
  }

  /// Create new address
  Future<AddressModel> createAddress({
    required String userId,
    required String label,
    required String addressLine,
    required String city,
    String? postalCode,
    required double latitude,
    required double longitude,
    bool isDefault = false,
  }) async {
    return await _mockApiService.createAddress(
      userId: userId,
      label: label,
      addressLine: addressLine,
      city: city,
      postalCode: postalCode,
      latitude: latitude,
      longitude: longitude,
      isDefault: isDefault,
    );
  }

  /// Update existing address
  Future<AddressModel> updateAddress({
    required String userId,
    required String addressId,
    String? label,
    String? addressLine,
    String? city,
    String? postalCode,
    double? latitude,
    double? longitude,
    bool? isDefault,
  }) async {
    return await _mockApiService.updateAddress(
      userId: userId,
      addressId: addressId,
      label: label,
      addressLine: addressLine,
      city: city,
      postalCode: postalCode,
      latitude: latitude,
      longitude: longitude,
      isDefault: isDefault,
    );
  }

  /// Delete address
  Future<void> deleteAddress({
    required String userId,
    required String addressId,
  }) async {
    await _mockApiService.deleteAddress(
      userId: userId,
      addressId: addressId,
    );
  }
}

