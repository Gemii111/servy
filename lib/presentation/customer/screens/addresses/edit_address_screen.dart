import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../logic/providers/auth_providers.dart';
import '../../../../logic/providers/address_providers.dart';
import '../../../../data/models/address_model.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../widgets/common/loading_state_widget.dart';
import '../location_picker/location_picker_screen.dart';

/// Edit address screen
class EditAddressScreen extends ConsumerStatefulWidget {
  const EditAddressScreen({
    super.key,
    required this.addressId,
  });

  final String addressId;

  @override
  ConsumerState<EditAddressScreen> createState() => _EditAddressScreenState();
}

class _EditAddressScreenState extends ConsumerState<EditAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _labelController;
  late TextEditingController _addressLineController;
  late TextEditingController _cityController;
  late TextEditingController _postalCodeController;
  
  String? _selectedLabel;
  bool _isDefault = false;
  bool _isLoading = false;
  AddressModel? _address;
  double? _latitude;
  double? _longitude;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController();
    _addressLineController = TextEditingController();
    _cityController = TextEditingController();
    _postalCodeController = TextEditingController();
    _loadAddress();
  }

  void _loadAddress() {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final addressesAsync = ref.read(userAddressesProvider(user.id));
    addressesAsync.whenData((addresses) {
      final address = addresses.firstWhere(
        (a) => a.id == widget.addressId,
        orElse: () => throw Exception('Address not found'),
      );
      
      setState(() {
        _address = address;
        _selectedLabel = address.label;
        _labelController.text = address.label;
        _addressLineController.text = address.addressLine;
        _cityController.text = address.city;
        _postalCodeController.text = address.postalCode ?? '';
        _isDefault = address.isDefault;
        _latitude = address.latitude;
        _longitude = address.longitude;
      });
    });
  }

  @override
  void dispose() {
    _labelController.dispose();
    _addressLineController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text(context.l10n.editAddress)),
        body: Center(child: Text(context.l10n.pleaseLoginFirst)),
      );
    }

    if (_address == null) {
      return Scaffold(
        appBar: AppBar(title: Text(context.l10n.editAddress)),
        body: const LoadingStateWidget(),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.card,
        title: Text(
          context.l10n.editAddress,
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Label Selection
              const Text(
                'Label',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: ['Home', 'Work', 'Other'].map((label) {
                  final isSelected = _selectedLabel == label;
                  return ChoiceChip(
                    label: Text(label),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedLabel = label);
                        if (label != 'Other') {
                          _labelController.text = label;
                        } else {
                          _labelController.clear();
                        }
                      }
                    },
                  );
                }).toList(),
              ),
              if (_selectedLabel == 'Other') ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _labelController,
                  decoration: const InputDecoration(
                    labelText: 'Custom Label',
                    hintText: 'e.g., Grandma\'s House',
                    prefixIcon: Icon(Icons.label_outline),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a label';
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 24),
              // Address Line
              TextFormField(
                controller: _addressLineController,
                decoration: const InputDecoration(
                  labelText: 'Address Line *',
                  hintText: 'Street name and building number',
                  prefixIcon: Icon(Icons.location_on_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Address is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // City
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(
                  labelText: 'City *',
                  hintText: 'مثلاً: القاهرة',
                  prefixIcon: Icon(Icons.location_city_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'City is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Postal Code
              TextFormField(
                controller: _postalCodeController,
                decoration: const InputDecoration(
                  labelText: 'Postal Code',
                  hintText: 'Optional',
                  prefixIcon: Icon(Icons.markunread_mailbox_outlined),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              // Location Buttons
              OutlinedButton.icon(
                onPressed: () async {
                  try {
                    final position = await LocationService.instance.getCurrentPosition();
                    setState(() {
                      _latitude = position.latitude;
                      _longitude = position.longitude;
                    });
                    
                    final address = await LocationService.instance.getAddressFromCoordinates(
                      _latitude!,
                      _longitude!,
                    );
                    
                    final parts = address.split(',');
                    if (parts.isNotEmpty) {
                      _addressLineController.text = parts[0].trim();
                    }
                    if (parts.length > 1) {
                      _cityController.text = parts[1].trim();
                    }
                    
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${context.l10n.useCurrentLocation}: $address'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to get location: $e'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.my_location),
                label: Text(context.l10n.useCurrentLocation),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () async {
                  final result = await Navigator.of(context).push<Map<String, dynamic>>(
                    MaterialPageRoute(
                      builder: (context) => LocationPickerScreen(
                        initialLatitude: _latitude,
                        initialLongitude: _longitude,
                        onLocationSelected: (lat, lng, address) {
                          Navigator.of(context).pop({
                            'latitude': lat,
                            'longitude': lng,
                            'address': address,
                          });
                        },
                      ),
                    ),
                  );
                  
                  if (result != null) {
                    setState(() {
                      _latitude = result['latitude'] as double;
                      _longitude = result['longitude'] as double;
                    });
                    
                    final address = result['address'] as String;
                    final parts = address.split(',');
                    if (parts.isNotEmpty) {
                      _addressLineController.text = parts[0].trim();
                    }
                    if (parts.length > 1) {
                      _cityController.text = parts[1].trim();
                    }
                  }
                },
                icon: const Icon(Icons.map),
                label: Text(context.l10n.selectLocation),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 24),
              // Set as Default
              SwitchListTile(
                title: Text(context.l10n.setAsDefault),
                subtitle: Text(context.l10n.useThisAddressByDefault),
                value: _isDefault,
                onChanged: (value) {
                  setState(() => _isDefault = value);
                },
              ),
              const SizedBox(height: 32),
              // Save Button
              ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate()) {
                          await _updateAddress(user.id);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Save Changes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(height: 16),
              // Delete Button
              OutlinedButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        _showDeleteDialog(context, user.id);
                      },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Delete Address',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateAddress(String userId) async {
    if (_formKey.currentState!.validate() && _address != null && _latitude != null && _longitude != null) {
      setState(() => _isLoading = true);

      try {
        final repository = ref.read(addressRepositoryProvider);
        await repository.updateAddress(
          userId: userId,
          addressId: widget.addressId,
          label: _selectedLabel == 'Other' ? _labelController.text.trim() : _selectedLabel,
          addressLine: _addressLineController.text.trim(),
          city: _cityController.text.trim(),
          postalCode: _postalCodeController.text.trim().isEmpty ? null : _postalCodeController.text.trim(),
          latitude: _latitude!,
          longitude: _longitude!,
          isDefault: _isDefault,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.l10n.changesSaved),
              backgroundColor: Colors.green,
            ),
          );
          ref.invalidate(userAddressesProvider(userId));
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${context.l10n.failedToLoadAddresses}: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  void _showDeleteDialog(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.deleteAddress),
        content: Text('${context.l10n.deleteAddressConfirm} "${_address?.label}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                final repository = ref.read(addressRepositoryProvider);
                await repository.deleteAddress(
                  userId: userId,
                  addressId: widget.addressId,
                );
                if (context.mounted) {
                  ref.invalidate(userAddressesProvider(userId));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(context.l10n.addressDeleted),
                      backgroundColor: Colors.green,
                    ),
                  );
                  context.pop();
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${context.l10n.failedToLoadAddresses}: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(context.l10n.delete),
          ),
        ],
      ),
    );
  }
}

