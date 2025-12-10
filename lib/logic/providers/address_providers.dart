import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/address_model.dart';
import '../../data/repositories/address_repository.dart';

/// Address repository provider
final addressRepositoryProvider = Provider<AddressRepository>((ref) {
  return AddressRepository();
});

/// User addresses provider
final userAddressesProvider = FutureProvider.family<List<AddressModel>, String>((ref, userId) async {
  final repository = ref.watch(addressRepositoryProvider);
  return await repository.getUserAddresses(userId);
});

/// Selected address provider (for checkout)
final selectedAddressProvider = StateProvider<AddressModel?>((ref) => null);

