import 'dart:math';
import '../models/user_model.dart';
import '../models/auth_response_model.dart';
import '../models/restaurant_model.dart';
import '../models/category_model.dart';
import '../models/menu_model.dart';
import '../models/menu_category_model.dart';
import '../models/menu_item_model.dart';
import '../models/menu_extra_model.dart';
import '../models/address_model.dart';
import '../models/order_model.dart';
import '../models/cart_item_model.dart';
import '../models/driver_earnings_model.dart';
import '../models/driver_location_model.dart';
import '../models/rating_model.dart';
import '../../core/utils/logger.dart';
import '../../core/services/websocket_service.dart';

/// Mock API Service for development and testing
/// This simulates backend API responses with dummy data
class MockApiService {
  MockApiService._() {
    _initializeMockRatings();
  }

  static final MockApiService instance = MockApiService._();
  final Random _random = Random();
  
  // Store pending orders to notify restaurants when they connect
  final Map<String, List<OrderModel>> _pendingOrderNotifications = {};

  // Simulate network delay
  Future<void> _delay([int milliseconds = 500]) async {
    await Future.delayed(Duration(milliseconds: milliseconds));
  }

  // Mock users database
  final List<Map<String, dynamic>> _users = [
    {
      'email': 'customer@servy.com',
      'password': '123456',
      'userType': 'customer',
    },
    {'email': 'driver@servy.com', 'password': '123456', 'userType': 'driver'},
    {
      'email': 'restaurant@servy.com',
      'password': '123456',
      'userType': 'restaurant',
    },
  ];

  /// Mock login
  Future<AuthResponseModel> login({
    required String email,
    required String password,
    required String userType,
  }) async {
    Logger.d('MockApiService', 'Login attempt: $email');
    await _delay(800);

    // Simulate finding user (email + password + userType must match)
    final existingUser = _users.firstWhere(
      (u) =>
          u['email'] == email &&
          u['password'] == password &&
          u['userType'] == userType,
      orElse: () => throw Exception('Invalid credentials'),
    );

    // Always rely on stored userType to avoid أى لخبطة فى الأنواع
    final effectiveUserType = existingUser['userType'] as String;

    // Generate mock user
    final userId = _generateId();
    final userModel = UserModel(
      id: userId,
      email: email,
      name: email
          .split('@')[0]
          .split('.')
          .map((s) => s[0].toUpperCase() + s.substring(1))
          .join(' '),
      phone: '+966501234567',
      userType: effectiveUserType,
      isEmailVerified: true,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    );

    // Save user profile for updates
    _userProfiles[userId] = userModel;

    return AuthResponseModel(
      user: userModel,
      accessToken: 'mock_access_token_${_generateId()}',
      refreshToken: 'mock_refresh_token_${_generateId()}',
      expiresAt: DateTime.now().add(const Duration(hours: 24)),
    );
  }

  /// Mock register
  Future<AuthResponseModel> register({
    required String email,
    required String password,
    required String userType,
    String? name,
    String? phone,
  }) async {
    Logger.d('MockApiService', 'Register attempt: $email');
    await _delay(1000);

    // Check if user exists for the SAME userType
    if (_users.any((u) => u['email'] == email && u['userType'] == userType)) {
      throw Exception('Email already exists');
    }

    // Add new user
    _users.add({'email': email, 'password': password, 'userType': userType});

    final userId = _generateId();
    final userModel = UserModel(
      id: userId,
      email: email,
      name: name ?? email.split('@')[0],
      phone: phone,
      userType: userType,
      isEmailVerified: false,
      createdAt: DateTime.now(),
    );

    // Save user profile for updates
    _userProfiles[userId] = userModel;

    return AuthResponseModel(
      user: userModel,
      accessToken: 'mock_access_token_${_generateId()}',
      refreshToken: 'mock_refresh_token_${_generateId()}',
      expiresAt: DateTime.now().add(const Duration(hours: 24)),
    );
  }

  // Store users for profile updates
  final Map<String, UserModel> _userProfiles = {};

  /// Mock update user profile
  Future<UserModel> updateProfile({
    required String userId,
    String? name,
    String? phone,
    String? imageUrl,
    UserModel? currentUser, // Pass current user as fallback
  }) async {
    await _delay(400);

    // Get existing user from storage or use currentUser as fallback
    UserModel? existingUser = _userProfiles[userId];

    // If not found in _userProfiles, use currentUser as fallback
    if (existingUser == null) {
      if (currentUser != null && currentUser.id == userId) {
        // Use currentUser and save it for future updates
        existingUser = currentUser;
        _userProfiles[userId] = currentUser;
      } else {
        // Try to get from login/register stored users
        // If still not found, create a basic user from currentUser data
        if (currentUser != null) {
          existingUser = currentUser;
          _userProfiles[userId] = currentUser;
        } else {
          throw Exception('User not found. Please login again.');
        }
      }
    }

    // Update only provided fields (if value is provided, use it; otherwise keep existing)
    final updatedUser = existingUser.copyWith(
      name: name != null ? (name.isEmpty ? null : name) : existingUser.name,
      phone:
          phone != null ? (phone.isEmpty ? null : phone) : existingUser.phone,
      imageUrl: imageUrl ?? existingUser.imageUrl,
    );

    _userProfiles[userId] = updatedUser;
    return updatedUser;
  }

  /// Save user profile (public method for external use)
  void saveUserProfile(UserModel user) {
    _userProfiles[user.id] = user;
  }

  /// Get user profile
  UserModel? getUserProfile(String userId) {
    return _userProfiles[userId];
  }

  /// Mock get categories
  Future<List<CategoryModel>> getCategories() async {
    await _delay(400);
    return _mockCategories;
  }

  /// Mock get restaurants
  Future<List<RestaurantModel>> getRestaurants({
    String? categoryId,
    double? latitude,
    double? longitude,
    bool? isOpen,
    bool? isFeatured,
  }) async {
    await _delay(600);

    List<RestaurantModel> restaurants = _mockRestaurants;

    // Apply filters
    if (categoryId != null) {
      restaurants =
          restaurants.where((r) => r.cuisineType == categoryId).toList();
    }
    if (isOpen != null) {
      restaurants = restaurants.where((r) => r.isOpen == isOpen).toList();
    }
    if (isFeatured != null && isFeatured) {
      restaurants = restaurants.where((r) => r.isFeatured).toList();
    }

    // Calculate distance if coordinates provided
    if (latitude != null && longitude != null) {
      restaurants =
          restaurants.map((r) {
              final distance = _calculateDistance(
                latitude,
                longitude,
                r.latitude,
                r.longitude,
              );
              return RestaurantModel(
                id: r.id,
                name: r.name,
                description: r.description,
                imageUrl: r.imageUrl,
                rating: r.rating,
                reviewCount: r.reviewCount,
                cuisineType: r.cuisineType,
                deliveryTime: r.deliveryTime,
                deliveryFee: r.deliveryFee,
                minOrderAmount: r.minOrderAmount,
                isOpen: r.isOpen,
                isOnline: r.isOnline,
                distance: distance,
                address: r.address,
                latitude: r.latitude,
                longitude: r.longitude,
                images: r.images,
                isFeatured: r.isFeatured,
              );
            }).toList()
            ..sort((a, b) => a.distance.compareTo(b.distance));
    }

    return restaurants;
  }

  /// Mock get restaurant menu - Egyptian menus
  Future<MenuModel> getRestaurantMenu(String restaurantId) async {
    await _delay(400);

    // Mock menu data based on restaurant - Egyptian menus
    List<MenuCategoryModel> categories = [];

    if (restaurantId == '1') {
      // Koshary Abou Tarek
      categories = [
        MenuCategoryModel(
          id: 'cat_1',
          name: 'Koshary',
          items: [
            MenuItemModel(
              id: 'item_1',
              name: 'Koshary Regular',
              description: 'كشري عادي - أرز وعدس ومكرونة وصلصة',
              price: 25.0,
              imageUrl:
                  'https://images.unsplash.com/photo-1571091718767-18b5b1457add?w=400',
              isAvailable: true,
              extras: [
                MenuExtraModel(id: 'extra_1', name: 'Extra Sauce', price: 3.0),
                MenuExtraModel(id: 'extra_2', name: 'Extra Garlic', price: 2.0),
              ],
            ),
            MenuItemModel(
              id: 'item_2',
              name: 'Koshary Large',
              description: 'كشري كبير - حصة مضاعفة',
              price: 40.0,
              imageUrl:
                  'https://images.unsplash.com/photo-1571091718767-18b5b1457add?w=400',
              isAvailable: true,
            ),
            MenuItemModel(
              id: 'item_3',
              name: 'Koshary with Chickpeas',
              description: 'كشري بالحمص',
              price: 30.0,
              imageUrl:
                  'https://images.unsplash.com/photo-1571091718767-18b5b1457add?w=400',
              isAvailable: true,
            ),
          ],
        ),
        MenuCategoryModel(
          id: 'cat_2',
          name: 'Drinks',
          items: [
            MenuItemModel(
              id: 'item_4',
              name: 'Lemon Juice',
              description: 'عصير ليمون طبيعي',
              price: 12.0,
              isAvailable: true,
            ),
            MenuItemModel(
              id: 'item_5',
              name: 'Orange Juice',
              description: 'عصير برتقال طبيعي',
              price: 15.0,
              isAvailable: true,
            ),
          ],
        ),
      ];
    } else if (restaurantId == '2') {
      // El Shabrawy - Grilled
      categories = [
        MenuCategoryModel(
          id: 'cat_1',
          name: 'Grilled Meats',
          items: [
            MenuItemModel(
              id: 'item_1',
              name: 'Kofta',
              description: 'كفتة مشوية - نصف كيلو',
              price: 120.0,
              imageUrl:
                  'https://images.unsplash.com/photo-1544025162-d76694265947?w=400',
              isAvailable: true,
              extras: [
                MenuExtraModel(id: 'extra_1', name: 'Extra Bread', price: 5.0),
                MenuExtraModel(id: 'extra_2', name: 'Tahini', price: 8.0),
              ],
            ),
            MenuItemModel(
              id: 'item_2',
              name: 'Kebab',
              description: 'كباب مشوي - نصف كيلو',
              price: 150.0,
              imageUrl:
                  'https://images.unsplash.com/photo-1544025162-d76694265947?w=400',
              isAvailable: true,
            ),
            MenuItemModel(
              id: 'item_3',
              name: 'Chicken Shawarma',
              description: 'شاورما دجاج',
              price: 80.0,
              imageUrl:
                  'https://images.unsplash.com/photo-1544025162-d76694265947?w=400',
              isAvailable: true,
            ),
          ],
        ),
      ];
    } else if (restaurantId == '3') {
      // Fish Market - Seafood
      categories = [
        MenuCategoryModel(
          id: 'cat_1',
          name: 'Fresh Fish',
          items: [
            MenuItemModel(
              id: 'item_1',
              name: 'Grilled Sea Bass',
              description: 'قشر مشوي - طازج من البحر',
              price: 180.0,
              imageUrl:
                  'https://images.unsplash.com/photo-1559339352-11d035aa65de?w=400',
              isAvailable: true,
              extras: [
                MenuExtraModel(id: 'extra_1', name: 'Extra Lemon', price: 3.0),
                MenuExtraModel(
                  id: 'extra_2',
                  name: 'Tahini Sauce',
                  price: 10.0,
                ),
              ],
            ),
            MenuItemModel(
              id: 'item_2',
              name: 'Fried Shrimp',
              description: 'جمبري مقلي',
              price: 200.0,
              imageUrl:
                  'https://images.unsplash.com/photo-1559339352-11d035aa65de?w=400',
              isAvailable: true,
            ),
          ],
        ),
      ];
    } else if (restaurantId == '4') {
      // El Abd Pastry - Desserts
      categories = [
        MenuCategoryModel(
          id: 'cat_1',
          name: 'Oriental Sweets',
          items: [
            MenuItemModel(
              id: 'item_1',
              name: 'Basbousa',
              description: 'بسبوسة - قطعة واحدة',
              price: 15.0,
              imageUrl:
                  'https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=400',
              isAvailable: true,
            ),
            MenuItemModel(
              id: 'item_2',
              name: 'Kunafa',
              description: 'كنافة - قطعة واحدة',
              price: 25.0,
              imageUrl:
                  'https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=400',
              isAvailable: true,
            ),
            MenuItemModel(
              id: 'item_3',
              name: 'Baklava',
              description: 'بقلاوة - قطعة واحدة',
              price: 20.0,
              imageUrl:
                  'https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=400',
              isAvailable: true,
            ),
          ],
        ),
      ];
    } else if (restaurantId == '5') {
      // Fresh Juice
      categories = [
        MenuCategoryModel(
          id: 'cat_1',
          name: 'Fresh Juices',
          items: [
            MenuItemModel(
              id: 'item_1',
              name: 'Mango Juice',
              description: 'عصير مانجو طبيعي',
              price: 25.0,
              imageUrl:
                  'https://images.unsplash.com/photo-1600271886742-f049cd451bba?w=400',
              isAvailable: true,
            ),
            MenuItemModel(
              id: 'item_2',
              name: 'Strawberry Juice',
              description: 'عصير فراولة طبيعي',
              price: 22.0,
              imageUrl:
                  'https://images.unsplash.com/photo-1600271886742-f049cd451bba?w=400',
              isAvailable: true,
            ),
            MenuItemModel(
              id: 'item_3',
              name: 'Orange Juice',
              description: 'عصير برتقال طبيعي',
              price: 18.0,
              imageUrl:
                  'https://images.unsplash.com/photo-1600271886742-f049cd451bba?w=400',
              isAvailable: true,
            ),
          ],
        ),
      ];
    } else if (restaurantId == '6') {
      // Mo'men - Fast Food
      categories = [
        MenuCategoryModel(
          id: 'cat_1',
          name: 'Burgers',
          items: [
            MenuItemModel(
              id: 'item_1',
              name: 'Classic Burger',
              description: 'برجر كلاسيك - لحم طازج',
              price: 65.0,
              imageUrl:
                  'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400',
              isAvailable: true,
              extras: [
                MenuExtraModel(id: 'extra_1', name: 'Extra Cheese', price: 8.0),
                MenuExtraModel(
                  id: 'extra_2',
                  name: 'Extra Pickles',
                  price: 3.0,
                ),
              ],
            ),
            MenuItemModel(
              id: 'item_2',
              name: 'Chicken Burger',
              description: 'برجر دجاج',
              price: 55.0,
              imageUrl:
                  'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400',
              isAvailable: true,
            ),
          ],
        ),
        MenuCategoryModel(
          id: 'cat_2',
          name: 'Fried Chicken',
          items: [
            MenuItemModel(
              id: 'item_3',
              name: 'Fried Chicken Box',
              description: 'صندوق فراي تشيكن - 4 قطع',
              price: 90.0,
              imageUrl:
                  'https://images.unsplash.com/photo-1562967914-608f82629710?w=400',
              isAvailable: true,
            ),
          ],
        ),
      ];
    } else {
      // Felfela - Egyptian Food (default)
      categories = [
        MenuCategoryModel(
          id: 'cat_1',
          name: 'Traditional',
          items: [
            MenuItemModel(
              id: 'item_1',
              name: 'Ful Medames',
              description: 'فول مصري - طبق واحد',
              price: 20.0,
              imageUrl:
                  'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=400',
              isAvailable: true,
              extras: [
                MenuExtraModel(id: 'extra_1', name: 'Extra Oil', price: 2.0),
                MenuExtraModel(id: 'extra_2', name: 'Lemon', price: 1.0),
              ],
            ),
            MenuItemModel(
              id: 'item_2',
              name: 'Taameya',
              description: 'طعمية - 5 قطع',
              price: 15.0,
              imageUrl:
                  'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=400',
              isAvailable: true,
            ),
            MenuItemModel(
              id: 'item_3',
              name: 'Falafel',
              description: 'فلافل - 5 قطع',
              price: 18.0,
              imageUrl:
                  'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=400',
              isAvailable: true,
            ),
          ],
        ),
      ];
    }

    final menu = MenuModel(restaurantId: restaurantId, categories: categories);

    // If menu not already stored, save it
    if (!_restaurantMenus.containsKey(restaurantId)) {
      _restaurantMenus[restaurantId] = menu;
    } else {
      // Return stored menu (for updates)
      return _restaurantMenus[restaurantId]!;
    }

    return menu;
  }

  /// Mock add menu category
  Future<MenuCategoryModel> addMenuCategory({
    required String restaurantId,
    required String name,
  }) async {
    await _delay(400);

    // Get or create menu
    MenuModel menu =
        _restaurantMenus[restaurantId] ?? await getRestaurantMenu(restaurantId);

    final category = MenuCategoryModel(
      id: 'cat_${_generateId()}',
      name: name,
      items: [],
    );

    final updatedCategories = [...menu.categories, category];
    _restaurantMenus[restaurantId] = MenuModel(
      restaurantId: restaurantId,
      categories: updatedCategories,
    );

    Logger.d('MockApiService', 'Added category: ${category.name}');
    return category;
  }

  /// Mock update menu category
  Future<MenuCategoryModel> updateMenuCategory({
    required String restaurantId,
    required String categoryId,
    required String name,
  }) async {
    await _delay(400);

    MenuModel menu =
        _restaurantMenus[restaurantId] ?? await getRestaurantMenu(restaurantId);

    final categoryIndex = menu.categories.indexWhere((c) => c.id == categoryId);
    if (categoryIndex == -1) {
      throw Exception('Category not found');
    }

    final updatedCategory = MenuCategoryModel(
      id: categoryId,
      name: name,
      items: menu.categories[categoryIndex].items,
    );

    final updatedCategories = [...menu.categories];
    updatedCategories[categoryIndex] = updatedCategory;

    _restaurantMenus[restaurantId] = MenuModel(
      restaurantId: restaurantId,
      categories: updatedCategories,
    );

    Logger.d('MockApiService', 'Updated category: $name');
    return updatedCategory;
  }

  /// Mock delete menu category
  Future<void> deleteMenuCategory({
    required String restaurantId,
    required String categoryId,
  }) async {
    await _delay(400);

    MenuModel menu =
        _restaurantMenus[restaurantId] ?? await getRestaurantMenu(restaurantId);

    final updatedCategories =
        menu.categories.where((c) => c.id != categoryId).toList();

    _restaurantMenus[restaurantId] = MenuModel(
      restaurantId: restaurantId,
      categories: updatedCategories,
    );

    Logger.d('MockApiService', 'Deleted category: $categoryId');
  }

  /// Mock add menu item
  Future<MenuItemModel> addMenuItem({
    required String restaurantId,
    required String categoryId,
    required String name,
    required String description,
    required double price,
    String? imageUrl,
    bool isAvailable = true,
    List<MenuExtraModel> extras = const [],
  }) async {
    await _delay(400);

    MenuModel menu =
        _restaurantMenus[restaurantId] ?? await getRestaurantMenu(restaurantId);

    final categoryIndex = menu.categories.indexWhere((c) => c.id == categoryId);
    if (categoryIndex == -1) {
      throw Exception('Category not found');
    }

    final item = MenuItemModel(
      id: 'item_${_generateId()}',
      name: name,
      description: description,
      price: price,
      imageUrl: imageUrl,
      isAvailable: isAvailable,
      extras: extras,
    );

    final category = menu.categories[categoryIndex];
    final updatedCategory = MenuCategoryModel(
      id: categoryId,
      name: category.name,
      items: [...category.items, item],
    );

    final updatedCategories = [...menu.categories];
    updatedCategories[categoryIndex] = updatedCategory;

    _restaurantMenus[restaurantId] = MenuModel(
      restaurantId: restaurantId,
      categories: updatedCategories,
    );

    Logger.d('MockApiService', 'Added item: $name');
    return item;
  }

  /// Mock update menu item
  Future<MenuItemModel> updateMenuItem({
    required String restaurantId,
    required String categoryId,
    required String itemId,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    bool? isAvailable,
    List<MenuExtraModel>? extras,
  }) async {
    await _delay(400);

    MenuModel menu =
        _restaurantMenus[restaurantId] ?? await getRestaurantMenu(restaurantId);

    final categoryIndex = menu.categories.indexWhere((c) => c.id == categoryId);
    if (categoryIndex == -1) {
      throw Exception('Category not found');
    }

    final category = menu.categories[categoryIndex];
    final itemIndex = category.items.indexWhere((i) => i.id == itemId);
    if (itemIndex == -1) {
      throw Exception('Item not found');
    }

    final oldItem = category.items[itemIndex];
    final updatedItem = MenuItemModel(
      id: itemId,
      name: name ?? oldItem.name,
      description: description ?? oldItem.description,
      price: price ?? oldItem.price,
      imageUrl: imageUrl ?? oldItem.imageUrl,
      isAvailable: isAvailable ?? oldItem.isAvailable,
      extras: extras ?? oldItem.extras,
    );

    final updatedItems = [...category.items];
    updatedItems[itemIndex] = updatedItem;

    final updatedCategory = MenuCategoryModel(
      id: categoryId,
      name: category.name,
      items: updatedItems,
    );

    final updatedCategories = [...menu.categories];
    updatedCategories[categoryIndex] = updatedCategory;

    _restaurantMenus[restaurantId] = MenuModel(
      restaurantId: restaurantId,
      categories: updatedCategories,
    );

    Logger.d('MockApiService', 'Updated item: ${updatedItem.name}');
    return updatedItem;
  }

  /// Mock delete menu item
  Future<void> deleteMenuItem({
    required String restaurantId,
    required String categoryId,
    required String itemId,
  }) async {
    await _delay(400);

    MenuModel menu =
        _restaurantMenus[restaurantId] ?? await getRestaurantMenu(restaurantId);

    final categoryIndex = menu.categories.indexWhere((c) => c.id == categoryId);
    if (categoryIndex == -1) {
      throw Exception('Category not found');
    }

    final category = menu.categories[categoryIndex];
    final updatedItems = category.items.where((i) => i.id != itemId).toList();

    final updatedCategory = MenuCategoryModel(
      id: categoryId,
      name: category.name,
      items: updatedItems,
    );

    final updatedCategories = [...menu.categories];
    updatedCategories[categoryIndex] = updatedCategory;

    _restaurantMenus[restaurantId] = MenuModel(
      restaurantId: restaurantId,
      categories: updatedCategories,
    );

    Logger.d('MockApiService', 'Deleted item: $itemId');
  }

  // Mock data - Egyptian Categories
  static final List<CategoryModel> _mockCategories = [
    CategoryModel(
      id: '1',
      name: 'Egyptian Food',
      nameAr: 'أكل مصري',
      iconUrl: '🍽️',
      color: '#9D4EDD',
    ),
    CategoryModel(
      id: '2',
      name: 'Grilled',
      nameAr: 'مشويات',
      iconUrl: '🍖',
      color: '#C77DFF',
    ),
    CategoryModel(
      id: '3',
      name: 'Seafood',
      nameAr: 'مأكولات بحرية',
      iconUrl: '🐟',
      color: '#E0AAFF',
    ),
    CategoryModel(
      id: '4',
      name: 'Desserts',
      nameAr: 'حلويات',
      iconUrl: '🍰',
      color: '#F5E6FF',
    ),
    CategoryModel(
      id: '5',
      name: 'Juices',
      nameAr: 'عصائر',
      iconUrl: '🥤',
      color: '#D8B4FE',
    ),
    CategoryModel(
      id: '6',
      name: 'Fast Food',
      nameAr: 'وجبات سريعة',
      iconUrl: '🍔',
      color: '#C084FC',
    ),
  ];

  static final List<RestaurantModel> _mockRestaurants = [
    RestaurantModel(
      id: '1',
      name: 'Koshary Abou Tarek',
      description: 'أشهر كشري في مصر - طعم أصيل ومميز',
      imageUrl:
          'https://images.unsplash.com/photo-1571091718767-18b5b1457add?w=400',
      rating: 4.8,
      reviewCount: 3421,
      cuisineType: '1', // Egyptian Food
      deliveryTime: 20.0,
      deliveryFee: 15.0,
      minOrderAmount: 50.0,
      isOpen: true,
      isOnline: true, // Online
      address: 'شارع ماري جرجس، الزمالك، القاهرة',
      latitude: 30.0626,
      longitude: 31.2197,
      images: [
        'https://images.unsplash.com/photo-1571091718767-18b5b1457add?w=400',
      ],
      isFeatured: true,
    ),
    RestaurantModel(
      id: '2',
      name: 'El Shabrawy',
      description: 'مشويات طازجة ومشهورة - طعم لا يقاوم',
      imageUrl:
          'https://images.unsplash.com/photo-1544025162-d76694265947?w=400',
      rating: 4.6,
      reviewCount: 2156,
      cuisineType: '2', // Grilled
      deliveryTime: 25.0,
      deliveryFee: 20.0,
      minOrderAmount: 80.0,
      isOpen: true,
      isOnline: true, // Online
      address: 'شارع التحرير، وسط البلد، القاهرة',
      latitude: 30.0444,
      longitude: 31.2357,
      images: [
        'https://images.unsplash.com/photo-1544025162-d76694265947?w=400',
      ],
      isFeatured: true,
    ),
    RestaurantModel(
      id: '3',
      name: 'Fish Market',
      description: 'مأكولات بحرية طازجة يومياً من البحر مباشرة',
      imageUrl:
          'https://images.unsplash.com/photo-1559339352-11d035aa65de?w=400',
      rating: 4.7,
      reviewCount: 1890,
      cuisineType: '3', // Seafood
      deliveryTime: 30.0,
      deliveryFee: 25.0,
      minOrderAmount: 120.0,
      isOpen: true,
      isOnline: false, // Offline
      address: 'كورنيش النيل، المعادي، القاهرة',
      latitude: 29.9606,
      longitude: 31.2764,
      images: [
        'https://images.unsplash.com/photo-1559339352-11d035aa65de?w=400',
      ],
      isFeatured: true,
    ),
    RestaurantModel(
      id: '4',
      name: 'El Abd Pastry',
      description: 'حلويات شرقية وغربية - أشهر محل حلويات في مصر',
      imageUrl:
          'https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=400',
      rating: 4.9,
      reviewCount: 4567,
      cuisineType: '4', // Desserts
      deliveryTime: 15.0,
      deliveryFee: 10.0,
      minOrderAmount: 40.0,
      isOpen: true,
      isOnline: true, // Online
      address: 'شارع طلعت حرب، وسط البلد، القاهرة',
      latitude: 30.0444,
      longitude: 31.2357,
      images: [
        'https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=400',
      ],
      isFeatured: true,
    ),
    RestaurantModel(
      id: '5',
      name: 'Fresh Juice',
      description: 'عصائر طبيعية 100% - فواكه طازجة يومياً',
      imageUrl:
          'https://images.unsplash.com/photo-1600271886742-f049cd451bba?w=400',
      rating: 4.5,
      reviewCount: 1234,
      cuisineType: '5', // Juices
      deliveryTime: 12.0,
      deliveryFee: 8.0,
      minOrderAmount: 30.0,
      isOpen: true,
      isOnline: false, // Offline
      address: 'شارع النصر، مدينة نصر، القاهرة',
      latitude: 30.0626,
      longitude: 31.3197,
      images: [
        'https://images.unsplash.com/photo-1600271886742-f049cd451bba?w=400',
      ],
      isFeatured: false,
    ),
    RestaurantModel(
      id: '6',
      name: 'Mo\'men',
      description: 'وجبات سريعة مصرية - برجر وفراي تشيكن طازج',
      imageUrl:
          'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400',
      rating: 4.4,
      reviewCount: 3456,
      cuisineType: '6', // Fast Food
      deliveryTime: 18.0,
      deliveryFee: 12.0,
      minOrderAmount: 60.0,
      isOpen: true,
      isOnline: true, // Online
      address: 'شارع العروبة، مصر الجديدة، القاهرة',
      latitude: 30.0826,
      longitude: 31.3197,
      images: [
        'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400',
      ],
      isFeatured: false,
    ),
    RestaurantModel(
      id: '7',
      name: 'Felfela',
      description: 'أكل مصري أصيل - فول وطعمية وفلافل شهية',
      imageUrl:
          'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=400',
      rating: 4.6,
      reviewCount: 2789,
      cuisineType: '1', // Egyptian Food
      deliveryTime: 22.0,
      deliveryFee: 15.0,
      minOrderAmount: 45.0,
      isOpen: true,
      isOnline: true, // Online
      address: 'شارع هدى شعراوي، وسط البلد، القاهرة',
      latitude: 30.0444,
      longitude: 31.2357,
      images: [
        'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=400',
      ],
      isFeatured: false,
    ),
  ];

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() +
        _random.nextInt(1000).toString();
  }

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    // Haversine formula for calculating distance between two points
    const double earthRadius = 6371; // km
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);
    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  // Store addresses per user
  final Map<String, List<AddressModel>> _userAddresses = {};

  // Store menus per restaurant for management
  final Map<String, MenuModel> _restaurantMenus = {};

  /// Mock get user addresses
  Future<List<AddressModel>> getUserAddresses(String userId) async {
    await _delay(300);

    // If user has saved addresses, return them
    if (_userAddresses.containsKey(userId) &&
        _userAddresses[userId]!.isNotEmpty) {
      return _userAddresses[userId]!;
    }

    // Otherwise, return default addresses (first time) - Cairo addresses
    final defaultAddresses = [
      AddressModel(
        id: 'addr_1',
        userId: userId,
        label: 'Home',
        addressLine: '123 شارع التحرير',
        city: 'القاهرة',
        postalCode: '11511',
        latitude: 30.0444,
        longitude: 31.2357,
        isDefault: true,
      ),
      AddressModel(
        id: 'addr_2',
        userId: userId,
        label: 'Work',
        addressLine: '456 شارع النصر',
        city: 'مدينة نصر',
        postalCode: '11765',
        latitude: 30.0626,
        longitude: 31.3197,
        isDefault: false,
      ),
    ];

    // Save default addresses for this user
    _userAddresses[userId] = defaultAddresses;

    return defaultAddresses;
  }

  /// Mock create address
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
    await _delay(300);

    // If setting as default, remove default from other addresses
    if (isDefault && _userAddresses.containsKey(userId)) {
      _userAddresses[userId] =
          _userAddresses[userId]!.map((addr) {
            return addr.copyWith(isDefault: false);
          }).toList();
    }

    final newAddress = AddressModel(
      id: 'addr_${_generateId()}',
      userId: userId,
      label: label,
      addressLine: addressLine,
      city: city,
      postalCode: postalCode,
      latitude: latitude,
      longitude: longitude,
      isDefault: isDefault,
    );

    // Save address for this user
    if (!_userAddresses.containsKey(userId)) {
      _userAddresses[userId] = [];
    }
    _userAddresses[userId]!.add(newAddress);

    return newAddress;
  }

  /// Mock update address
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
    await _delay(300);

    if (!_userAddresses.containsKey(userId)) {
      throw Exception('User not found');
    }

    final userAddresses = _userAddresses[userId]!;
    final index = userAddresses.indexWhere((addr) => addr.id == addressId);

    if (index == -1) {
      throw Exception('Address not found');
    }

    // If setting as default, remove default from other addresses
    if (isDefault == true) {
      _userAddresses[userId] =
          userAddresses.map((addr) {
            return addr.copyWith(isDefault: false);
          }).toList();
    }

    final existingAddress = userAddresses[index];
    final updatedAddress = existingAddress.copyWith(
      label: label,
      addressLine: addressLine,
      city: city,
      postalCode: postalCode,
      latitude: latitude,
      longitude: longitude,
      isDefault: isDefault,
    );

    userAddresses[index] = updatedAddress;
    return updatedAddress;
  }

  /// Mock delete address
  Future<void> deleteAddress({
    required String userId,
    required String addressId,
  }) async {
    await _delay(300);

    if (_userAddresses.containsKey(userId)) {
      _userAddresses[userId]!.removeWhere((addr) => addr.id == addressId);
    }
  }

  /// Mock place order
  Future<OrderModel> placeOrder({
    required String userId,
    required String restaurantId,
    required String restaurantName,
    required List<CartItemModel> items,
    required AddressModel deliveryAddress,
    required double subtotal,
    required double deliveryFee,
    required double total,
    required String paymentMethod,
    String? notes,
    double? discount,
  }) async {
    await _delay(500);

    // Check if restaurant is online BEFORE creating order
    final restaurant = await getRestaurantById(restaurantId);
    if (restaurant == null) {
      throw Exception('Restaurant not found');
    }

    if (!restaurant.isOpen) {
      throw Exception('RESTAURANT_OFFLINE');
    }

    final orderId = 'order_${_generateId()}';
    final estimatedDeliveryTime = DateTime.now().add(
      const Duration(minutes: 25),
    );

    // Convert cart items to order items
    final orderItems =
        items.map((cartItem) {
          return OrderItemModel(
            id: cartItem.menuItem.id,
            name: cartItem.menuItem.name,
            price: cartItem.menuItem.price,
            quantity: cartItem.quantity,
            extras: cartItem.selectedExtras.map((e) => e.name).toList(),
          );
        }).toList();

    final order = OrderModel(
      id: orderId,
      userId: userId,
      restaurantId: restaurantId,
      restaurantName: restaurantName,
      status: OrderStatus.pending, // Start as pending, restaurant will accept
      deliveryAddress: deliveryAddress,
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      tax: subtotal * 0.15, // 15% VAT
      discount: discount,
      total: total,
      paymentMethod: paymentMethod,
      createdAt: DateTime.now(),
      estimatedDeliveryTime: estimatedDeliveryTime,
      notes: notes,
      items: orderItems,
    );

    // Save order to mock storage
    _saveOrder(order);
    _saveOrderToAll(order);

    // Store order for notification (will be sent when restaurant connects)
    if (!_pendingOrderNotifications.containsKey(restaurantId)) {
      _pendingOrderNotifications[restaurantId] = [];
    }
    _pendingOrderNotifications[restaurantId]!.add(order);

    // Send WebSocket notification to restaurant immediately if connected
    // In real app, this would be sent via WebSocket server
    try {
      final wsService = WebSocketService.instance;
      // Always emit message - WebSocketService will handle it
      wsService.emitMockMessage(
        WebSocketMessage(
          type: WebSocketMessageType.newOrder,
          data: order.toJson(),
        ),
      );
      Logger.d('MockApiService', 'Order notification sent to restaurant: $restaurantId');
    } catch (e) {
      // WebSocket not available, but order is still placed
      Logger.d('MockApiService', 'WebSocket notification failed: $e');
    }

    return order;
  }

  // Store orders for mock data
  final Map<String, List<OrderModel>> _userOrders = {};

  /// Save order to mock storage (called after placeOrder)
  void _saveOrder(OrderModel order) {
    if (!_userOrders.containsKey(order.userId)) {
      _userOrders[order.userId] = [];
    }
    _userOrders[order.userId]!.add(order);
  }

  /// Mock get user orders
  Future<List<OrderModel>> getUserOrders(String userId) async {
    await _delay(400);

    // If user has no orders, return empty list
    if (!_userOrders.containsKey(userId) || _userOrders[userId]!.isEmpty) {
      return [];
    }

    // Return sorted by date (newest first)
    final orders = _userOrders[userId]!;
    orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return orders;
  }

  // Store all orders (not just per user) for driver access
  final List<OrderModel> _allOrders = [];

  /// Save order to all orders list (called after placeOrder)
  void _saveOrderToAll(OrderModel order) {
    _allOrders.add(order);
  }

  /// Mock get available delivery requests for drivers
  Future<List<OrderModel>> getAvailableDeliveryRequests({
    double? latitude,
    double? longitude,
  }) async {
    await _delay(600);

    // Return orders that are ready for delivery (status: ready or accepted)
    final availableOrders =
        _allOrders.where((order) {
          return order.status == OrderStatus.ready ||
              order.status == OrderStatus.accepted;
        }).toList();

    // Sort by creation date (oldest first - prioritize older orders)
    availableOrders.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    // Simulate some mock orders if none exist
    if (availableOrders.isEmpty) {
      return _generateMockDeliveryRequests();
    }

    return availableOrders;
  }

  /// Generate mock delivery requests for testing
  List<OrderModel> _generateMockDeliveryRequests() {
    final mockOrders = <OrderModel>[];

    // Get mock restaurants
    final restaurants = _mockRestaurants.take(3).toList();

    for (int i = 0; i < 3; i++) {
      final restaurant = restaurants[i];
      final order = OrderModel(
        id: 'driver_order_${_generateId()}',
        userId: 'customer_${_generateId()}',
        restaurantId: restaurant.id,
        restaurantName: restaurant.name,
        status: OrderStatus.ready,
        deliveryAddress: AddressModel(
          id: 'addr_${_generateId()}',
          userId: 'customer_${_generateId()}',
          label: 'Customer Address',
          addressLine: '${i + 1} شارع النصر، مدينة نصر',
          city: 'القاهرة',
          postalCode: '11765',
          latitude: 30.0626 + (i * 0.01),
          longitude: 31.3197 + (i * 0.01),
          isDefault: true,
        ),
        subtotal: 100.0 + (i * 50),
        deliveryFee: restaurant.deliveryFee,
        tax: (100.0 + (i * 50)) * 0.15,
        total:
            (100.0 + (i * 50)) +
            restaurant.deliveryFee +
            ((100.0 + (i * 50)) * 0.15),
        paymentMethod: 'cash',
        createdAt: DateTime.now().subtract(Duration(minutes: i * 5)),
        estimatedDeliveryTime: DateTime.now().add(
          Duration(minutes: 25 + (i * 5)),
        ),
        items: [
          OrderItemModel(
            id: 'item_$i',
            name: 'Order Item ${i + 1}',
            price: 50.0 + (i * 25),
            quantity: 1 + i,
            extras: [],
          ),
        ],
      );
      mockOrders.add(order);
      _allOrders.add(order);
    }

    return mockOrders;
  }

  /// Mock accept delivery request
  Future<OrderModel> acceptDeliveryRequest({
    required String driverId,
    required String orderId,
  }) async {
    await _delay(500);

    final orderIndex = _allOrders.indexWhere((o) => o.id == orderId);
    if (orderIndex == -1) {
      throw Exception('Order not found');
    }

    final order = _allOrders[orderIndex];
    if (order.status != OrderStatus.ready &&
        order.status != OrderStatus.accepted) {
      throw Exception('Order is not available for delivery');
    }

    // Update order status to outForDelivery and assign driver
    final updatedOrder = OrderModel(
      id: order.id,
      userId: order.userId,
      restaurantId: order.restaurantId,
      restaurantName: order.restaurantName,
      status: OrderStatus.outForDelivery,
      deliveryAddress: order.deliveryAddress,
      subtotal: order.subtotal,
      deliveryFee: order.deliveryFee,
      tax: order.tax,
      discount: order.discount,
      total: order.total,
      paymentMethod: order.paymentMethod,
      createdAt: order.createdAt,
      estimatedDeliveryTime: order.estimatedDeliveryTime,
      notes: order.notes,
      items: order.items,
      driverId: driverId,
      driverName: null, // Can be fetched from user data if needed
    );

    _allOrders[orderIndex] = updatedOrder;

    // Also update in user orders if exists
    if (_userOrders.containsKey(order.userId)) {
      final userOrderIndex = _userOrders[order.userId]!.indexWhere(
        (o) => o.id == orderId,
      );
      if (userOrderIndex != -1) {
        _userOrders[order.userId]![userOrderIndex] = updatedOrder;
      }
    }

    return updatedOrder;
  }

  /// Mock reject delivery request
  Future<void> rejectDeliveryRequest({
    required String driverId,
    required String orderId,
  }) async {
    await _delay(300);
    // Just simulate rejection - order remains available for other drivers
    Logger.d('MockApiService', 'Driver $driverId rejected order $orderId');
  }

  /// Mock update order status
  Future<OrderModel> updateOrderStatus({
    required String orderId,
    required OrderStatus status,
    String? driverId,
    String? driverName,
  }) async {
    await _delay(400);

    final orderIndex = _allOrders.indexWhere((o) => o.id == orderId);
    if (orderIndex == -1) {
      throw Exception('Order not found');
    }

    final order = _allOrders[orderIndex];

    // If marking as delivered, set deliveredAt timestamp
    final deliveredAt =
        status == OrderStatus.delivered ? DateTime.now() : order.deliveredAt;

    // Preserve driver info if already set, or use new driver info
    final finalDriverId = driverId ?? order.driverId;
    final finalDriverName = driverName ?? order.driverName;

    final updatedOrder = OrderModel(
      id: order.id,
      userId: order.userId,
      restaurantId: order.restaurantId,
      restaurantName: order.restaurantName,
      status: status,
      deliveryAddress: order.deliveryAddress,
      subtotal: order.subtotal,
      deliveryFee: order.deliveryFee,
      tax: order.tax,
      discount: order.discount,
      total: order.total,
      paymentMethod: order.paymentMethod,
      createdAt: order.createdAt,
      estimatedDeliveryTime: order.estimatedDeliveryTime,
      notes: order.notes,
      items: order.items,
      driverId: finalDriverId,
      driverName: finalDriverName,
      deliveredAt: deliveredAt,
    );

    _allOrders[orderIndex] = updatedOrder;

    // Also update in user orders if exists
    if (_userOrders.containsKey(order.userId)) {
      final userOrderIndex = _userOrders[order.userId]!.indexWhere(
        (o) => o.id == orderId,
      );
      if (userOrderIndex != -1) {
        _userOrders[order.userId]![userOrderIndex] = updatedOrder;
      }
    }

    // Send WebSocket notification to restaurant and customer when order status changes
    try {
      final wsService = WebSocketService.instance;
      // Send orderUpdate message to notify restaurant and customer
      wsService.emitMockMessage(
        WebSocketMessage(
          type: WebSocketMessageType.orderUpdate,
          data: updatedOrder.toJson(),
        ),
      );
      Logger.d('MockApiService', 'Order status update notification sent - Order ID: $orderId, Status: $status');
      
      // Special notification for delivered status
      if (status == OrderStatus.delivered) {
        Logger.d('MockApiService', 'Order delivered notification sent - Order ID: $orderId');
      }
    } catch (e) {
      Logger.d('MockApiService', 'WebSocket notification failed: $e');
    }

    return updatedOrder;
  }

  /// Mock get driver active orders
  Future<List<OrderModel>> getDriverActiveOrders(String driverId) async {
    await _delay(400);

    // Return orders that are out for delivery (assigned to this driver)
    return _allOrders.where((order) {
      return (order.status == OrderStatus.outForDelivery ||
              order.status == OrderStatus.accepted) &&
          order.driverId == driverId;
    }).toList();
  }

  /// Mock get driver order history
  Future<List<OrderModel>> getDriverOrderHistory(String driverId) async {
    await _delay(400);

    // Return delivered orders for this specific driver
    final history =
        _allOrders.where((order) {
          return order.status == OrderStatus.delivered &&
              order.driverId == driverId;
        }).toList();

    history.sort((a, b) {
      final aDate = a.deliveredAt ?? a.createdAt;
      final bDate = b.deliveredAt ?? b.createdAt;
      return bDate.compareTo(aDate);
    });
    return history;
  }

  /// Mock get order by ID
  Future<OrderModel?> getOrderById(String orderId) async {
    await _delay(300);

    // Search in all orders first
    try {
      final order = _allOrders.firstWhere((order) => order.id == orderId);
      return order;
    } catch (e) {
      // If not found in _allOrders, search in user orders
      for (final ordersList in _userOrders.values) {
        try {
          final order = ordersList.firstWhere((order) => order.id == orderId);
          return order;
        } catch (e) {
          continue;
        }
      }
      // Order not found in any list
      return null;
    }
  }

  /// Mock get driver earnings
  Future<DriverEarningsModel> getDriverEarnings(String driverId) async {
    await _delay(500);

    // Get all delivered orders for this specific driver
    final deliveredOrders =
        _allOrders.where((order) {
          return order.status == OrderStatus.delivered &&
              order.driverId == driverId;
        }).toList();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekStart = today.subtract(Duration(days: now.weekday - 1));
    final monthStart = DateTime(now.year, now.month, 1);

    // Calculate today's earnings
    final todayOrders =
        deliveredOrders.where((order) {
          final orderDate = order.deliveredAt ?? order.createdAt;
          return orderDate.isAfter(today);
        }).toList();
    final todayEarnings = todayOrders.fold<double>(
      0.0,
      (sum, order) => sum + order.deliveryFee,
    );

    // Calculate week's earnings
    final weekOrders =
        deliveredOrders.where((order) {
          final orderDate = order.deliveredAt ?? order.createdAt;
          return orderDate.isAfter(weekStart);
        }).toList();
    final weekEarnings = weekOrders.fold<double>(
      0.0,
      (sum, order) => sum + order.deliveryFee,
    );

    // Calculate month's earnings
    final monthOrders =
        deliveredOrders.where((order) {
          final orderDate = order.deliveredAt ?? order.createdAt;
          return orderDate.isAfter(monthStart);
        }).toList();
    final monthEarnings = monthOrders.fold<double>(
      0.0,
      (sum, order) => sum + order.deliveryFee,
    );

    // Calculate total earnings
    final totalEarnings = deliveredOrders.fold<double>(
      0.0,
      (sum, order) => sum + order.deliveryFee,
    );

    // Calculate deliveries count
    final todayDeliveries = todayOrders.length;
    final weekDeliveries = weekOrders.length;
    final monthDeliveries = monthOrders.length;
    final totalDeliveries = deliveredOrders.length;

    // Calculate average
    final averageEarningPerDelivery =
        totalDeliveries > 0 ? totalEarnings / totalDeliveries : 0.0;

    // Generate weekly earnings data (last 7 days)
    final weeklyEarnings = <EarningsDayModel>[];
    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final dayStart = DateTime(date.year, date.month, date.day);
      final dayEnd = dayStart.add(const Duration(days: 1));

      final dayOrders =
          deliveredOrders.where((order) {
            // Use deliveredAt if available, otherwise use createdAt
            final orderDate = order.deliveredAt ?? order.createdAt;
            return orderDate.isAfter(dayStart) && orderDate.isBefore(dayEnd);
          }).toList();

      final dayEarnings = dayOrders.fold<double>(
        0.0,
        (sum, order) => sum + order.deliveryFee,
      );

      weeklyEarnings.add(
        EarningsDayModel(
          date: date,
          earnings: dayEarnings,
          deliveries: dayOrders.length,
        ),
      );
    }

    return DriverEarningsModel(
      todayEarnings: todayEarnings,
      weekEarnings: weekEarnings,
      monthEarnings: monthEarnings,
      totalEarnings: totalEarnings,
      todayDeliveries: todayDeliveries,
      weekDeliveries: weekDeliveries,
      monthDeliveries: monthDeliveries,
      totalDeliveries: totalDeliveries,
      averageEarningPerDelivery: averageEarningPerDelivery,
      weeklyEarnings: weeklyEarnings,
    );
  }

  // Store driver locations (driverId -> latest location)
  final Map<String, DriverLocationData> _driverLocations = {};

  /// Mock update driver location
  Future<void> updateDriverLocation({
    required String driverId,
    required double latitude,
    required double longitude,
    double? heading,
    double? speed,
    DateTime? timestamp,
  }) async {
    await _delay(100); // Simulate network delay

    _driverLocations[driverId] = DriverLocationData(
      driverId: driverId,
      latitude: latitude,
      longitude: longitude,
      heading: heading,
      speed: speed,
      timestamp: timestamp ?? DateTime.now(),
    );

    Logger.d(
      'MockApiService',
      'Updated location for driver $driverId: $latitude, $longitude',
    );
  }

  /// Mock get driver location
  Future<DriverLocationData?> getDriverLocation(String driverId) async {
    await _delay(200);
    return _driverLocations[driverId];
  }

  /// Mock get driver location for order (by order ID)
  Future<DriverLocationData?> getDriverLocationForOrder(String orderId) async {
    await _delay(200);

    // Find order to get driver ID
    final order = _allOrders.firstWhere(
      (o) => o.id == orderId,
      orElse: () => throw Exception('Order not found'),
    );

    if (order.driverId == null) {
      return null;
    }

    return _driverLocations[order.driverId];
  }

  /// Mock get restaurant orders
  Future<List<OrderModel>> getRestaurantOrders(String restaurantId) async {
    await _delay(400);
    return _allOrders
        .where((order) => order.restaurantId == restaurantId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Mock get restaurant by ID
  Future<RestaurantModel?> getRestaurantById(String id) async {
    await _delay(300);
    try {
      return _mockRestaurants.firstWhere((r) => r.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Mock update restaurant status (open/closed)
  Future<void> updateRestaurantStatus({
    required String restaurantId,
    required bool isOpen,
  }) async {
    await _delay(300);
    final index = _mockRestaurants.indexWhere((r) => r.id == restaurantId);
    if (index == -1) {
      throw Exception('Restaurant not found');
    }
    final restaurant = _mockRestaurants[index];
    _mockRestaurants[index] = RestaurantModel(
      id: restaurant.id,
      name: restaurant.name,
      description: restaurant.description,
      imageUrl: restaurant.imageUrl,
      rating: restaurant.rating,
      reviewCount: restaurant.reviewCount,
      cuisineType: restaurant.cuisineType,
      deliveryTime: restaurant.deliveryTime,
      deliveryFee: restaurant.deliveryFee,
      minOrderAmount: restaurant.minOrderAmount,
      isOpen: isOpen,
      isOnline: isOpen, // When restaurant is open, it's also online
      distance: restaurant.distance,
      address: restaurant.address,
      latitude: restaurant.latitude,
      longitude: restaurant.longitude,
      images: restaurant.images,
      isFeatured: restaurant.isFeatured,
    );
    Logger.d('MockApiService', 'Updated restaurant status: $isOpen');
  }


  /// Mock update restaurant info
  Future<RestaurantModel> updateRestaurant({
    required String restaurantId,
    String? name,
    String? description,
    String? imageUrl,
    double? deliveryTime,
    double? deliveryFee,
    double? minOrderAmount,
    String? address,
    double? latitude,
    double? longitude,
  }) async {
    await _delay(400);
    final index = _mockRestaurants.indexWhere((r) => r.id == restaurantId);
    if (index == -1) {
      throw Exception('Restaurant not found');
    }
    final restaurant = _mockRestaurants[index];
    final updatedRestaurant = RestaurantModel(
      id: restaurant.id,
      name: name ?? restaurant.name,
      description: description ?? restaurant.description,
      imageUrl: imageUrl ?? restaurant.imageUrl,
      rating: restaurant.rating,
      reviewCount: restaurant.reviewCount,
      cuisineType: restaurant.cuisineType,
      deliveryTime: deliveryTime ?? restaurant.deliveryTime,
      deliveryFee: deliveryFee ?? restaurant.deliveryFee,
      minOrderAmount: minOrderAmount ?? restaurant.minOrderAmount,
      isOpen: restaurant.isOpen,
      isOnline: restaurant.isOpen, // isOnline follows isOpen
      distance: restaurant.distance,
      address: address ?? restaurant.address,
      latitude: latitude ?? restaurant.latitude,
      longitude: longitude ?? restaurant.longitude,
      images: restaurant.images,
      isFeatured: restaurant.isFeatured,
    );
    _mockRestaurants[index] = updatedRestaurant;
    Logger.d('MockApiService', 'Updated restaurant: ${updatedRestaurant.name}');
    return updatedRestaurant;
  }

  /// Mock get restaurant statistics
  Future<Map<String, dynamic>> getRestaurantStatistics(
    String restaurantId,
  ) async {
    await _delay(500);

    final restaurantOrders =
        _allOrders
            .where((order) => order.restaurantId == restaurantId)
            .toList();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekStart = today.subtract(Duration(days: now.weekday - 1));
    final monthStart = DateTime(now.year, now.month, 1);

    // Today's orders and revenue
    final todayOrders =
        restaurantOrders
            .where((order) => order.createdAt.isAfter(today))
            .toList();
    final todayRevenue = todayOrders.fold<double>(
      0.0,
      (sum, order) => sum + order.total,
    );

    // Pending orders
    final pendingOrders =
        restaurantOrders
            .where((order) => order.status == OrderStatus.pending)
            .length;

    // Active orders (not delivered/cancelled)
    final activeOrders =
        restaurantOrders
            .where(
              (order) =>
                  order.status != OrderStatus.delivered &&
                  order.status != OrderStatus.cancelled,
            )
            .length;

    // Average order value
    final averageOrderValue =
        restaurantOrders.isNotEmpty
            ? restaurantOrders.fold<double>(
                  0.0,
                  (sum, order) => sum + order.total,
                ) /
                restaurantOrders.length
            : 0.0;

    // Weekly orders and revenue
    final weeklyOrders =
        restaurantOrders
            .where((order) => order.createdAt.isAfter(weekStart))
            .toList();
    final weeklyRevenue = weeklyOrders.fold<double>(
      0.0,
      (sum, order) => sum + order.total,
    );

    // Monthly orders and revenue
    final monthlyOrders =
        restaurantOrders
            .where((order) => order.createdAt.isAfter(monthStart))
            .toList();
    final monthlyRevenue = monthlyOrders.fold<double>(
      0.0,
      (sum, order) => sum + order.total,
    );

    return {
      'today_orders': todayOrders.length,
      'today_revenue': todayRevenue,
      'pending_orders': pendingOrders,
      'active_orders': activeOrders,
      'average_order_value': averageOrderValue,
      'weekly_orders': weeklyOrders.length,
      'weekly_revenue': weeklyRevenue,
      'monthly_orders': monthlyOrders.length,
      'monthly_revenue': monthlyRevenue,
    };
  }

  // Mock ratings database
  final List<RatingModel> _ratings = [];

  /// Mock get restaurant ratings
  Future<List<RatingModel>> getRestaurantRatings(String restaurantId) async {
    await _delay(300);
    return _ratings.where((r) => r.restaurantId == restaurantId).toList();
  }

  /// Mock get rating by ID
  Future<RatingModel?> getRatingById(String ratingId) async {
    await _delay(200);
    try {
      return _ratings.firstWhere((r) => r.id == ratingId);
    } catch (e) {
      return null;
    }
  }

  /// Mock submit rating/review
  Future<RatingModel> submitRating({
    required String userId,
    required String userName,
    String? userImageUrl,
    required String restaurantId,
    String? orderId,
    required double rating,
    String? comment,
    List<String>? imageUrls,
  }) async {
    await _delay(500);

    final ratingModel = RatingModel(
      id: _generateId(),
      userId: userId,
      userName: userName,
      userImageUrl: userImageUrl,
      restaurantId: restaurantId,
      orderId: orderId,
      rating: rating,
      comment: comment,
      imageUrls: imageUrls,
      createdAt: DateTime.now(),
    );

    // Check if user already rated this restaurant/order
    final existingIndex = _ratings.indexWhere(
      (r) =>
          r.userId == userId &&
          r.restaurantId == restaurantId &&
          (orderId == null || r.orderId == orderId),
    );

    if (existingIndex != -1) {
      // Update existing rating
      _ratings[existingIndex] = ratingModel.copyWith(
        id: _ratings[existingIndex].id,
        updatedAt: DateTime.now(),
      );
      Logger.d('MockApiService', 'Rating updated: ${ratingModel.id}');
      return _ratings[existingIndex];
    } else {
      // Add new rating
      _ratings.add(ratingModel);
      Logger.d('MockApiService', 'Rating submitted: ${ratingModel.id}');

      // Update restaurant rating automatically
      _updateRestaurantRating(restaurantId);

      return ratingModel;
    }
  }

  /// Update restaurant rating based on all ratings
  void _updateRestaurantRating(String restaurantId) {
    final restaurantRatings =
        _ratings.where((r) => r.restaurantId == restaurantId).toList();

    if (restaurantRatings.isEmpty) {
      return;
    }

    final averageRating =
        restaurantRatings.fold<double>(
          0.0,
          (sum, rating) => sum + rating.rating,
        ) /
        restaurantRatings.length;

    // Update restaurant in mock data
    final index = _mockRestaurants.indexWhere((r) => r.id == restaurantId);
    if (index != -1) {
      _mockRestaurants[index] = _mockRestaurants[index].copyWith(
        rating: double.parse(averageRating.toStringAsFixed(1)),
        reviewCount: restaurantRatings.length,
      );
      Logger.d(
        'MockApiService',
        'Restaurant $restaurantId rating updated to ${averageRating.toStringAsFixed(1)}',
      );
    }
  }

  /// Mock update rating
  Future<RatingModel> updateRating({
    required String ratingId,
    double? rating,
    String? comment,
    List<String>? imageUrls,
  }) async {
    await _delay(400);

    final index = _ratings.indexWhere((r) => r.id == ratingId);
    if (index == -1) {
      throw Exception('Rating not found');
    }

    final updatedRating = _ratings[index].copyWith(
      rating: rating ?? _ratings[index].rating,
      comment: comment ?? _ratings[index].comment,
      imageUrls: imageUrls ?? _ratings[index].imageUrls,
      updatedAt: DateTime.now(),
    );

    _ratings[index] = updatedRating;
    Logger.d('MockApiService', 'Rating updated: $ratingId');
    return updatedRating;
  }

  /// Mock delete rating
  Future<void> deleteRating(String ratingId) async {
    await _delay(300);
    _ratings.removeWhere((r) => r.id == ratingId);
    Logger.d('MockApiService', 'Rating deleted: $ratingId');
  }

  /// Mock get user ratings
  Future<List<RatingModel>> getUserRatings(String userId) async {
    await _delay(300);
    return _ratings.where((r) => r.userId == userId).toList();
  }

  /// Generate some mock ratings for testing
  void _initializeMockRatings() {
    if (_ratings.isNotEmpty) return; // Already initialized

    // Mock ratings for restaurant 1
    _ratings.addAll([
      RatingModel(
        id: _generateId(),
        userId: 'customer_1',
        userName: 'Ahmed Mohamed',
        restaurantId: '1',
        rating: 5.0,
        comment: 'أفضل كشري في مصر! طعم أصيل ومميز. التوصيل سريع جداً.',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      RatingModel(
        id: _generateId(),
        userId: 'customer_2',
        userName: 'Sara Ali',
        restaurantId: '1',
        rating: 4.5,
        comment: 'Very good food and fast delivery. Highly recommended!',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      RatingModel(
        id: _generateId(),
        userId: 'customer_3',
        userName: 'Mohamed Hassan',
        restaurantId: '1',
        rating: 4.0,
        comment: 'جيد جداً لكن التوصيل تأخر شوية',
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
      RatingModel(
        id: _generateId(),
        userId: 'customer_4',
        userName: 'Fatma Ibrahim',
        restaurantId: '2',
        rating: 5.0,
        comment: 'مشويات رائعة! طازجة ومشهورة.',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      RatingModel(
        id: _generateId(),
        userId: 'customer_5',
        userName: 'Omar Tarek',
        restaurantId: '2',
        rating: 4.0,
        comment: 'Good grilled meat, nice flavor.',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ]);
  }
}
