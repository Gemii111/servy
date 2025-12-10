import '../models/auth_response_model.dart';
import '../models/user_model.dart';
import '../services/api_service.dart'; // ✅ للـ Register
import '../services/mock_api_service.dart'; // ⚠️ مؤقت للـ Login و UpdateProfile
import '../../core/constants/api_constants.dart';
import '../../core/services/token_service.dart';
import '../../core/services/error_handler_service.dart';

/// Authentication repository
/// Register يستخدم ApiService (الباك اند الحقيقي)
/// Login و UpdateProfile يستخدمان MockApiService (مؤقتاً)
class AuthRepository {
  final MockApiService _mockApiService = MockApiService.instance; // ⚠️ مؤقت

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

    // ⚠️ TODO: تحديث login ليستخدم ApiService (مثل register)
    // حالياً يستخدم MockApiService
    return await _mockApiService.login(
      email: email,
      password: password,
      userType: userType,
    );
  }

  /// Register new user
  /// 
  /// ⚠️ قبل الاستخدام:
  /// 1. تأكد من تحديث Base URL في ApiConstants
  /// 2. تأكد من تهيئة ApiService و TokenService في main()
  Future<AuthResponseModel> register({
    required String email,
    required String password,
    required String userType,
    String? name,
    String? phone,
  }) async {
    try {
      // 1. استدعاء API
      final response = await ApiService.instance.post(
        ApiConstants.authRegister, // '/auth/register'
        data: {
          'email': email,
          'password': password,
          'userType': userType,
          if (name != null) 'name': name,
          if (phone != null) 'phone': phone,
        },
      );

      // 2. فحص Response
      final responseData = response.data;
      
      // إذا كان Response بهذا التنسيق:
      // {
      //   "success": true,
      //   "data": {
      //     "user": {...},
      //     "accessToken": "...",
      //     "refreshToken": "...",
      //     "expiresAt": "2024-01-01T00:00:00Z"
      //   }
      // }
      
      if (responseData['success'] == true) {
        final data = responseData['data'];
        
        // 3. إنشاء AuthResponseModel
        final authResponse = AuthResponseModel(
          user: UserModel.fromJson(data['user']),
          accessToken: data['accessToken'],
          refreshToken: data['refreshToken'],
          expiresAt: data['expiresAt'] != null
              ? DateTime.parse(data['expiresAt'])
              : DateTime.now().add(const Duration(hours: 24)),
        );
        
        // 4. حفظ Tokens
        await TokenService.instance.saveAuthData(
          accessToken: authResponse.accessToken,
          refreshToken: authResponse.refreshToken,
          expiresAt: authResponse.expiresAt,
          userId: authResponse.user.id,
        );
        
        return authResponse;
      } else {
        // في حالة Error من الباك اند
        throw ApiException(
          message: responseData['error'] ?? 'Registration failed',
          statusCode: response.statusCode,
          errorData: responseData,
        );
      }
    } catch (e) {
      // معالجة الأخطاء
      throw ErrorHandlerService.instance.handleException(e);
    }
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

    // ⚠️ TODO: تحديث updateProfile ليستخدم ApiService
    // حالياً يستخدم MockApiService
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
