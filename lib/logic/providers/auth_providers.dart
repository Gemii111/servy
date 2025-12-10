import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/datasources/local_storage_service.dart';
import '../../data/services/mock_api_service.dart';
import '../../core/constants/app_constants.dart';
import 'dart:convert';

/// Auth repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

/// Authentication state notifier
class AuthNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  AuthNotifier(this._authRepository) : super(const AsyncValue.loading());

  final AuthRepository _authRepository;

  UserModel? _currentUser;
  String? _accessToken;
  String? _refreshToken;

  UserModel? get currentUser => _currentUser;
  String? get accessToken => _accessToken;
  bool get isAuthenticated => _currentUser != null;

  /// Initialize auth state (check for existing session)
  Future<void> initialize() async {
    state = const AsyncValue.loading();
    
    try {
      final storage = LocalStorageService.instance;
      
      // Check for stored tokens
      final accessToken = storage.get<String>(AppConstants.authTokenKey);
      final refreshToken = storage.get<String>(AppConstants.refreshTokenKey);
      final userJson = storage.get<String>('user_data');
      
      if (accessToken != null && userJson != null) {
        // Restore user from stored data
        try {
          final userMap = jsonDecode(userJson) as Map<String, dynamic>;
          _currentUser = UserModel.fromJson(userMap);
          _accessToken = accessToken;
          _refreshToken = refreshToken;
          
          // Save user in MockApiService for profile updates
          _saveUserInMockService(_currentUser!);
          
          state = AsyncValue.data(_currentUser);
          return;
        } catch (e) {
          // If user data is corrupted, clear and continue
          await _clearStoredAuth();
        }
      }
      
      state = AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.data(null);
    }
  }

  /// Save user in MockApiService for profile updates
  void _saveUserInMockService(UserModel user) {
    MockApiService.instance.saveUserProfile(user);
  }

  /// Clear stored authentication data
  Future<void> _clearStoredAuth() async {
    final storage = LocalStorageService.instance;
    await storage.remove(AppConstants.authTokenKey);
    await storage.remove(AppConstants.refreshTokenKey);
    await storage.remove(AppConstants.userIdKey);
    await storage.remove('user_data');
  }

  /// Login
  Future<void> login({
    required String email,
    required String password,
    required String userType,
  }) async {
    state = const AsyncValue.loading();
    try {
      final response = await _authRepository.login(
        email: email,
        password: password,
        userType: userType,
      );

      _currentUser = response.user;
      _accessToken = response.accessToken;
      _refreshToken = response.refreshToken;

      // Store tokens and user data in Hive
      final storage = LocalStorageService.instance;
      await storage.save(AppConstants.authTokenKey, _accessToken);
      await storage.save(AppConstants.refreshTokenKey, _refreshToken);
      await storage.save(AppConstants.userIdKey, response.user.id);
      await storage.save('user_data', jsonEncode(response.user.toJson()));

      // Save user in MockApiService for profile updates
      _saveUserInMockService(response.user);

      state = AsyncValue.data(_currentUser);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  /// Register
  Future<void> register({
    required String email,
    required String password,
    required String userType,
    String? name,
    String? phone,
  }) async {
    state = const AsyncValue.loading();
    try {
      final response = await _authRepository.register(
        email: email,
        password: password,
        userType: userType,
        name: name,
        phone: phone,
      );

      _currentUser = response.user;
      _accessToken = response.accessToken;
      _refreshToken = response.refreshToken;

      // Store tokens and user data in Hive
      final storage = LocalStorageService.instance;
      await storage.save(AppConstants.authTokenKey, _accessToken);
      await storage.save(AppConstants.refreshTokenKey, _refreshToken);
      await storage.save(AppConstants.userIdKey, response.user.id);
      await storage.save('user_data', jsonEncode(response.user.toJson()));

      // Save user in MockApiService for profile updates
      _saveUserInMockService(response.user);

      state = AsyncValue.data(_currentUser);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  /// Update user profile
  Future<void> updateProfile({
    String? name,
    String? phone,
    String? imageUrl,
  }) async {
    if (_currentUser == null) return;

    try {
      final updatedUser = await _authRepository.updateProfile(
        userId: _currentUser!.id,
        name: name,
        phone: phone,
        imageUrl: imageUrl,
        currentUser: _currentUser, // Pass current user as fallback
      );

      _currentUser = updatedUser;

      // Update stored user data
      final storage = LocalStorageService.instance;
      await storage.save('user_data', jsonEncode(_currentUser!.toJson()));

      state = AsyncValue.data(_currentUser);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  /// Logout
  Future<void> logout() async {
    state = const AsyncValue.loading();
    try {
      await _authRepository.logout();

      _currentUser = null;
      _accessToken = null;
      _refreshToken = null;

      // Clear stored tokens
      await _clearStoredAuth();

      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }
}

/// Auth state provider
final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<UserModel?>>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthNotifier(authRepository);
});

/// Current user provider (nullable)
final currentUserProvider = Provider<UserModel?>((ref) {
  final authState = ref.watch(authProvider);
  return authState.value;
});

/// Is authenticated provider
final isAuthenticatedProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user != null;
});
