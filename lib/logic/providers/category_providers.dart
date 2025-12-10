import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/category_model.dart';
import '../../data/repositories/category_repository.dart';

/// Category repository provider
final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository();
});

/// Categories state notifier
class CategoriesNotifier extends StateNotifier<AsyncValue<List<CategoryModel>>> {
  CategoriesNotifier(this._repository) : super(const AsyncValue.loading());

  final CategoryRepository _repository;
  List<CategoryModel> _allCategories = [];

  List<CategoryModel> get allCategories => _allCategories;

  /// Load categories
  Future<void> loadCategories() async {
    state = const AsyncValue.loading();
    try {
      final categories = await _repository.getCategories();
      _allCategories = categories;
      state = AsyncValue.data(categories);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Refresh categories
  Future<void> refresh() async {
    await loadCategories();
  }
}

/// Categories provider
final categoriesProvider =
    StateNotifierProvider<CategoriesNotifier, AsyncValue<List<CategoryModel>>>((ref) {
  final repository = ref.watch(categoryRepositoryProvider);
  return CategoriesNotifier(repository);
});

/// Category by ID provider
final categoryByIdProvider = FutureProvider.family<CategoryModel?, String>((ref, id) async {
  final repository = ref.watch(categoryRepositoryProvider);
  return await repository.getCategoryById(id);
});


