import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../logic/providers/address_providers.dart';
import '../../../../logic/providers/auth_providers.dart';
import '../../../../data/models/address_model.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/common/loading_state_widget.dart';
import '../../widgets/common/error_state_widget.dart';
import '../../widgets/common/cart_app_bar_icon.dart';

/// Addresses management screen
class AddressesScreen extends ConsumerWidget {
  const AddressesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text(context.l10n.addresses)),
        body: Center(child: Text(context.l10n.pleaseLoginFirst)),
      );
    }

    final addressesAsync = ref.watch(userAddressesProvider(user.id));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.card,
        title: Text(
          context.l10n.myAddresses,
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        actions: [
          const CartAppBarIcon(),
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.textPrimary),
            onPressed: () {
              context.push('/add-address');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(userAddressesProvider(user.id));
        },
        child: addressesAsync.when(
          data: (addresses) {
            if (addresses.isEmpty) {
              return EmptyStateWidget(
                icon: Icons.location_off,
                title: context.l10n.noAddressesYet,
                message: context.l10n.addFirstAddress,
                actionLabel: context.l10n.addAddress,
                onAction: () {
                  context.push('/add-address');
                },
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: addresses.length,
              cacheExtent: 500, // Preload items for smoother scrolling
              itemBuilder: (context, index) {
                final address = addresses[index];
                return _AddressCard(
                  address: address,
                  onEdit: () async {
                    await context.push('/edit-address/${address.id}');
                    // Refresh addresses after editing
                    if (context.mounted) {
                      ref.invalidate(userAddressesProvider(user.id));
                    }
                  },
                  onDelete: () {
                    _showDeleteDialog(context, ref, address, user.id);
                  },
                  onSetDefault: () {
                    // TODO: Implement set default
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(context.l10n.setDefaultComingSoon)),
                    );
                  },
                );
              },
            );
          },
          loading: () => const LoadingStateWidget(),
          error: (error, stack) => ErrorStateWidget(
            message: context.l10n.failedToLoadAddresses,
            error: error.toString(),
            onRetry: () {
              ref.invalidate(userAddressesProvider(user.id));
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/add-address');
        },
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textPrimary,
        icon: const Icon(Icons.add_location_alt),
        label: Text(context.l10n.addAddress),
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    AddressModel address,
    String userId,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text(
          context.l10n.deleteAddress,
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          '${context.l10n.deleteAddressConfirm} "${address.label}"?',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              context.l10n.cancel,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                final repository = ref.read(addressRepositoryProvider);
                await repository.deleteAddress(
                  userId: userId,
                  addressId: address.id,
                );
                // Refresh addresses list
                ref.invalidate(userAddressesProvider(userId));
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(context.l10n.addressDeleted),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${context.l10n.failedToLoadAddresses}: $e'),
                      backgroundColor: AppColors.error,
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

/// Address card widget
class _AddressCard extends StatelessWidget {
  const _AddressCard({
    required this.address,
    required this.onEdit,
    required this.onDelete,
    required this.onSetDefault,
  });

  final AddressModel address;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSetDefault;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: [AppColors.cardShadow],
      ),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.location_on,
            color: AppColors.primary,
          ),
        ),
        title: Row(
          children: [
            Text(
              address.label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            if (address.isDefault) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Default',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.accent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Text(
          address.fullAddress,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              child: Row(
                children: [
                  const Icon(Icons.edit, size: 20),
                  const SizedBox(width: 8),
                  Text(context.l10n.edit),
                ],
              ),
              onTap: () => Future.delayed(
                const Duration(milliseconds: 100),
                onEdit,
              ),
            ),
            if (!address.isDefault)
              PopupMenuItem(
                child: Row(
                  children: [
                    const Icon(Icons.star_outline, size: 20),
                    const SizedBox(width: 8),
                    Text(context.l10n.setAsDefault),
                  ],
                ),
                onTap: () => Future.delayed(
                  const Duration(milliseconds: 100),
                  onSetDefault,
                ),
              ),
            PopupMenuItem(
              child: Row(
                children: [
                  const Icon(Icons.delete, size: 20, color: AppColors.error),
                  const SizedBox(width: 8),
                  Text(
                    context.l10n.delete,
                    style: const TextStyle(color: AppColors.error),
                  ),
                ],
              ),
              onTap: () => Future.delayed(
                const Duration(milliseconds: 100),
                onDelete,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

