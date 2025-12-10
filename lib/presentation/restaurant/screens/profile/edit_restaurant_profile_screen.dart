import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../logic/providers/auth_providers.dart';
import '../../../../logic/providers/restaurant_providers.dart';
import '../../../../core/utils/haptic_feedback.dart';
import '../../../customer/widgets/common/loading_state_widget.dart';

/// Edit Restaurant Profile Screen
class EditRestaurantProfileScreen extends ConsumerStatefulWidget {
  const EditRestaurantProfileScreen({super.key});

  @override
  ConsumerState<EditRestaurantProfileScreen> createState() =>
      _EditRestaurantProfileScreenState();
}

class _EditRestaurantProfileScreenState
    extends ConsumerState<EditRestaurantProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _deliveryTimeController;
  late TextEditingController _deliveryFeeController;
  late TextEditingController _minOrderAmountController;
  late TextEditingController _addressController;
  String? _restaurantId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRestaurantData();
    });
  }

  Future<void> _loadRestaurantData() async {
    final user = ref.read(currentUserProvider);
    if (user != null) {
      final restaurantId = '1'; // Mock restaurant ID
      setState(() {
        _restaurantId = restaurantId;
      });

      final restaurantAsync = ref.read(restaurantByIdProvider(restaurantId));
      restaurantAsync.whenData((restaurant) {
        if (restaurant != null && mounted) {
          setState(() {
            _nameController = TextEditingController(text: restaurant.name);
            _descriptionController =
                TextEditingController(text: restaurant.description);
            _deliveryTimeController =
                TextEditingController(text: restaurant.deliveryTime.toInt().toString());
            _deliveryFeeController =
                TextEditingController(text: restaurant.deliveryFee.toString());
            _minOrderAmountController = TextEditingController(
                text: restaurant.minOrderAmount?.toString() ?? '');
            _addressController = TextEditingController(text: restaurant.address);
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _deliveryTimeController.dispose();
    _deliveryFeeController.dispose();
    _minOrderAmountController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_restaurantId == null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    HapticFeedbackUtil.mediumImpact();

    try {
      final repository = ref.read(restaurantRepositoryProvider);
      await repository.updateRestaurant(
        restaurantId: _restaurantId!,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        deliveryTime: double.tryParse(_deliveryTimeController.text.trim()),
        deliveryFee: double.tryParse(_deliveryFeeController.text.trim()),
        minOrderAmount: _minOrderAmountController.text.trim().isEmpty
            ? null
            : double.tryParse(_minOrderAmountController.text.trim()),
        address: _addressController.text.trim(),
      );

      // Refresh restaurant data
      ref.invalidate(restaurantByIdProvider(_restaurantId!));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.restaurantInfoUpdated),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

      // Navigate back
      context.pop();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final l10n = context.l10n;

    if (user == null || _restaurantId == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          title: Text(
            l10n.editRestaurantInfo,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          iconTheme: const IconThemeData(color: AppColors.textPrimary),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final restaurantAsync = ref.watch(restaurantByIdProvider(_restaurantId!));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          l10n.editRestaurantInfo,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
            )
          else
            TextButton(
              onPressed: _saveChanges,
              child: Text(
                l10n.save,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: restaurantAsync.when(
        data: (restaurant) {
          if (restaurant == null) {
            return Center(
              child: Text(
                l10n.restaurantNotFound,
                style: const TextStyle(color: AppColors.textPrimary),
              ),
            );
          }

          // Initialize controllers if not already initialized
          if (!_nameController.text.isNotEmpty) {
            _nameController = TextEditingController(text: restaurant.name);
            _descriptionController =
                TextEditingController(text: restaurant.description);
            _deliveryTimeController =
                TextEditingController(text: restaurant.deliveryTime.toInt().toString());
            _deliveryFeeController =
                TextEditingController(text: restaurant.deliveryFee.toString());
            _minOrderAmountController = TextEditingController(
                text: restaurant.minOrderAmount?.toString() ?? '');
            _addressController = TextEditingController(text: restaurant.address);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Restaurant Image
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            image: DecorationImage(
                              image: NetworkImage(restaurant.imageUrl),
                              fit: BoxFit.cover,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.background,
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: AppColors.textPrimary,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Restaurant Name
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: l10n.restaurantName,
                      prefixIcon: const Icon(Icons.restaurant),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: AppColors.card,
                    ),
                    style: const TextStyle(color: AppColors.textPrimary),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.restaurantNameRequired;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Description
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: l10n.restaurantDescriptionDetail,
                      prefixIcon: const Icon(Icons.description_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: AppColors.card,
                    ),
                    style: const TextStyle(color: AppColors.textPrimary),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.restaurantDescriptionRequired;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Delivery Time
                  TextFormField(
                    controller: _deliveryTimeController,
                    decoration: InputDecoration(
                      labelText: l10n.deliveryTimeMinutes,
                      prefixIcon: const Icon(Icons.access_time),
                      suffixText: l10n.minutes,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: AppColors.card,
                    ),
                    style: const TextStyle(color: AppColors.textPrimary),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '${l10n.deliveryTimeMinutes} ${l10n.isRequired}';
                      }
                      final time = double.tryParse(value.trim());
                      if (time == null || time <= 0) {
                        return l10n.invalidPrice;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Delivery Fee
                  TextFormField(
                    controller: _deliveryFeeController,
                    decoration: InputDecoration(
                      labelText: l10n.deliveryFeeAmount,
                      prefixIcon: const Icon(Icons.delivery_dining),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: AppColors.card,
                    ),
                    style: const TextStyle(color: AppColors.textPrimary),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '${l10n.deliveryFeeAmount} ${l10n.isRequired}';
                      }
                      final fee = double.tryParse(value.trim());
                      if (fee == null || fee < 0) {
                        return l10n.invalidPrice;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Minimum Order Amount
                  TextFormField(
                    controller: _minOrderAmountController,
                    decoration: InputDecoration(
                      labelText: l10n.minimumOrderAmount,
                      prefixIcon: const Icon(Icons.shopping_bag_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: AppColors.card,
                    ),
                    style: const TextStyle(color: AppColors.textPrimary),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value != null && value.trim().isNotEmpty) {
                        final amount = double.tryParse(value.trim());
                        if (amount == null || amount < 0) {
                          return l10n.invalidPrice;
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Address
                  TextFormField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      labelText: l10n.restaurantAddress,
                      prefixIcon: const Icon(Icons.location_on),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: AppColors.card,
                    ),
                    style: const TextStyle(color: AppColors.textPrimary),
                    maxLines: 2,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '${l10n.restaurantAddress} ${l10n.isRequired}';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  // Save Button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.textPrimary,
                            ),
                          )
                        : Text(
                            l10n.save,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
        loading: () => const LoadingStateWidget(),
        error: (error, stack) => Center(
          child: Text(
            error.toString(),
            style: const TextStyle(color: AppColors.error),
          ),
        ),
      ),
    );
  }
}

