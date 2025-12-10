import '../models/auth_response_model.dart';
import '../models/user_model.dart';
import '../services/mock_api_service.dart';

/// Authentication repository
/// In production, this would use ApiService instead of MockApiService
class AuthRepository {
  AuthRepository({
    MockApiService? mockApiService,
  }) : _mockApiService = mockApiService ?? MockApiService.instance;

  final MockApiService _mockApiService;

  /// Login user
  Future<AuthResponseModel> login({
    required String email,
    required String password,
    required String userType,
  }) async {
    // In production, use ApiService:
    // final response = await ApiService.instance.post('/auth/login', data: {
    //   'email': email,
    //   'password': password,
    //   'userType': userType,
    // });
    // return AuthResponseModel.fromJson(response.data);

    // For now, use mock service
    return await _mockApiService.login(
      email: email,
      password: password,
      userType: userType,
    );
  }

  /// Register new user
  Future<AuthResponseModel> register({
    required String email,
    required String password,
    required String userType,
    String? name,
    String? phone,
  }) async {
    // In production, use ApiService:
    // final response = await ApiService.instance.post('/auth/register', data: {
    //   'email': email,
    //   'password': password,
    //   'userType': userType,
    //   'name': name,
    //   'phone': phone,
    // });
    // return AuthResponseModel.fromJson(response.data);

    return await _mockApiService.register(
      email: email,
      password: password,
      userType: userType,
      name: name,
      phone: phone,
    );
  }

  /// Refresh access token
  Future<AuthResponseModel> refreshToken({
    required String refreshToken,
  }) async {
    // Implementation for token refresh
    // final response = await ApiService.instance.post('/auth/refresh', data: {
    //   'refreshToken': refreshToken,
    // });
    // return AuthResponseModel.fromJson(response.data);
    throw UnimplementedError('Refresh token not implemented in mock');
  }

  /// Update user profile
  Future<UserModel> updateProfile({
    required String userId,
    String? name,
    String? phone,
    String? imageUrl,
    UserModel? currentUser,
  }) async {
    // In production, use ApiService:
    // final response = await ApiService.instance.put('/users/$userId', data: {
    //   'name': name,
    //   'phone': phone,
    //   'imageUrl': imageUrl,
    // });
    // return UserModel.fromJson(response.data);

    // For now, use mock service
    return await _mockApiService.updateProfile(
      userId: userId,
      name: name,
      phone: phone,
      imageUrl: imageUrl,
      currentUser: currentUser,
    );
  }

  /// Logout user
  Future<void> logout() async {
    // Call logout endpoint
    // await ApiService.instance.post('/auth/logout');
    await Future.delayed(const Duration(milliseconds: 300));
  }
}
