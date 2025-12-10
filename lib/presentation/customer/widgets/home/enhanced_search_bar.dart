import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../logic/providers/restaurant_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';

/// Dark theme enhanced search bar with rounded design
class EnhancedSearchBar extends ConsumerStatefulWidget {
  const EnhancedSearchBar({super.key});

  @override
  ConsumerState<EnhancedSearchBar> createState() => _EnhancedSearchBarState();
}

class _EnhancedSearchBarState extends ConsumerState<EnhancedSearchBar> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      // Clear search and reload featured restaurants
      ref.read(restaurantsProvider.notifier).loadRestaurants(isFeatured: true);
      setState(() => _isSearching = false);
    } else {
      setState(() => _isSearching = true);
      _performSearch(query);
    }
  }

  void _performSearch(String query) async {
    final notifier = ref.read(restaurantsProvider.notifier);
    
    // Load restaurants first if empty
    if (notifier.allRestaurants.isEmpty) {
      await notifier.loadRestaurants(isFeatured: true);
    }
    
    // Use search method from notifier
    notifier.searchRestaurants(query);
  }

  void _clearSearch() {
    _searchController.clear();
    _focusNode.unfocus();
    ref.read(restaurantsProvider.notifier).clearSearch();
    setState(() => _isSearching = false);
  }

  void _navigateToSearchScreen() {
    // Navigate to dedicated search screen (future implementation)
    // For now, just focus the search bar
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isFocused = _focusNode.hasFocus;
    
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isFocused ? AppColors.primary : AppColors.border,
          width: isFocused ? 2 : 1,
        ),
        boxShadow: isFocused
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ]
            : null,
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _focusNode,
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: l10n?.searchHint ?? 'Search for restaurants or dishes...',
          hintStyle: const TextStyle(color: AppColors.textTertiary),
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.textSecondary,
          ),
          suffixIcon: _isSearching
              ? IconButton(
                  icon: const Icon(
                    Icons.clear,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: _clearSearch,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
        onChanged: _onSearchChanged,
        onTap: _navigateToSearchScreen,
        textInputAction: TextInputAction.search,
        onSubmitted: _performSearch,
      ),
    );
  }
}

