import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../logic/providers/auth_providers.dart';
import '../../../../logic/providers/address_providers.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../location_picker/location_picker_screen.dart';
import '../../widgets/common/custom_text_field.dart';

/// Add address screen
class AddAddressScreen extends ConsumerStatefulWidget {
  const AddAddressScreen({super.key});

  @override
  ConsumerState<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends ConsumerState<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _labelController = TextEditingController();
  final _addressLineController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();
  
  String _selectedLabel = 'Home';
  bool _isDefault = false;
  bool _isLoading = false;

  // Default coordinates (Cairo)
  double _latitude = 30.0444;
  double _longitude = 31.2357;

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
        appBar: AppBar(title: Text(context.l10n.addAddress)),
        body: Center(child: Text(context.l10n.pleaseLoginFirst)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.card,
        title: Text(
          context.l10n.addNewAddressTitle,
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
              Text(
                'Label',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: ['Home', 'Work', 'Other'].map((label) {
                  return ChoiceChip(
                    label: Text(label),
                    selected: _selectedLabel == label,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedLabel = label);
                      }
                    },
                    backgroundColor: AppColors.card,
                    selectedColor: AppColors.primary.withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: _selectedLabel == label
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
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
              // Location Button
              OutlinedButton.icon(
                onPressed: () async {
                  try {
                    final position = await LocationService.instance.getCurrentPosition();
                    setState(() {
                      _latitude = position.latitude;
                      _longitude = position.longitude;
                    });
                    
                    // Get address from coordinates
                    final address = await LocationService.instance.getAddressFromCoordinates(
                      _latitude,
                      _longitude,
                    );
                    
                    // Update address fields
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
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Map Picker Button
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
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
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
                          await _saveAddress(user.id);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.textPrimary,
                      ),
                      )
                    : const Text(
                        'Save Address',
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

  Future<void> _saveAddress(String userId) async {
    setState(() => _isLoading = true);

    try {
      final repository = ref.read(addressRepositoryProvider);
      final label = _selectedLabel == 'Other'
          ? _labelController.text.trim()
          : _selectedLabel;

      await repository.createAddress(
        userId: userId,
        label: label,
        addressLine: _addressLineController.text.trim(),
        city: _cityController.text.trim(),
        postalCode: _postalCodeController.text.trim().isEmpty
            ? null
            : _postalCodeController.text.trim(),
        latitude: _latitude,
        longitude: _longitude,
        isDefault: _isDefault,
      );

      if (mounted) {
        // Invalidate addresses provider to refresh list
        ref.invalidate(userAddressesProvider(userId));
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.addressAdded),
            backgroundColor: Colors.green,
          ),
        );
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

