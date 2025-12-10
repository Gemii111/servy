import 'package:flutter/material.dart';
import '../../../../data/datasources/local_storage_service.dart';
import '../../screens/location_picker/location_picker_screen.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';

/// Location display widget showing current address
class LocationDisplayWidget extends StatefulWidget {
  const LocationDisplayWidget({
    super.key,
    this.onLocationTap,
  });

  final VoidCallback? onLocationTap;

  @override
  State<LocationDisplayWidget> createState() => _LocationDisplayWidgetState();
}

class _LocationDisplayWidgetState extends State<LocationDisplayWidget> {
  String _currentAddress = 'القاهرة، مصر';

  @override
  void initState() {
    super.initState();
    _loadSavedAddress();
  }

  Future<void> _loadSavedAddress() async {
    final storage = LocalStorageService.instance;
    final savedAddress = storage.get<String>('current_address');
    if (savedAddress != null) {
      setState(() {
        _currentAddress = savedAddress;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onLocationTap ?? _showLocationPicker,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.border,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.location_on,
              size: 16,
              color: AppColors.primary,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                _currentAddress,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(
              Icons.arrow_drop_down,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  void _showLocationPicker() async {
    if (!mounted) return;
    
    try {
      final result = await Navigator.of(context).push<Map<String, dynamic>>(
        MaterialPageRoute(
          builder: (context) => const LocationPickerScreen(),
          fullscreenDialog: true, // Use fullscreen dialog for better UX
        ),
      );

      if (result != null && mounted) {
        final address = result['address'] as String? ?? '';
        final storage = LocalStorageService.instance;
        await storage.save('current_address', address);
        
        setState(() {
          _currentAddress = address;
        });
      }
    } catch (e) {
      // Handle any navigation errors
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${context.l10n.failedToOpenLocationPicker}: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

