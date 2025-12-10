import '../models/category_model.dart';
import '../services/mock_api_service.dart';

/// Category repository
class CategoryRepository {
  CategoryRepository({
    MockApiService? mockApiService,
  }) : _mockApiService = mockApiService ?? MockApiService.instance;

  final MockApiService _mockApiService;

  /// Get all categories
  Future<List<CategoryModel>> getCategories() async {
    return await _mockApiService.getCategories();
  }

  /// Get category by ID
  Future<CategoryModel?> getCategoryById(String id) async {
    final categories = await getCategories();
    try {
      return categories.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }
}


