// ⚠️ هذا ملف مثال - Example File
// نسخ الكود إلى auth_repository.dart بعد التأكد من Base URL

import '../models/auth_response_model.dart';
import '../models/user_model.dart';
import '../services/api_service.dart'; // ✅ استبدل mock_api_service
import '../../core/constants/api_constants.dart';
import '../../core/services/token_service.dart';
import '../../core/services/error_handler_service.dart';

/// Authentication repository - Real API Implementation
/// 
/// ⚠️ قبل الاستخدام:
/// 1. تأكد من تحديث Base URL في ApiConstants
/// 2. تأكد من تهيئة ApiService في main()
/// 3. تأكد من تهيئة TokenService في main()
/// 
/// 📝 مثال الاستخدام:
/// ```dart
/// final authRepo = AuthRepository();
/// try {
///   final response = await authRepo.register(
///     email: 'test@example.com',
///     password: 'password123',
///     userType: 'customer',
///     name: 'Test User',
///     phone: '+966501234567',
///   );
///   // Success - User registered
/// } on ApiException catch (e) {
///   // Handle error
/// }
/// ```
class AuthRepository {
  // ❌ لا حاجة لـ MockApiService الآن
  // final MockApiService _mockApiService;

  /// Register new user
  /// 
  /// Response Format المتوقع:
  /// {
  ///   "success": true,
  ///   "data": {
  ///     "user": {...},
  ///     "accessToken": "...",
  ///     "refreshToken": "...",
  ///     "expiresAt": "2024-01-01T00:00:00Z"
  ///   }
  /// }
  Future<AuthResponseModel> register({
    required String email,
    required String password,
    required String userType,
    String? name,
    String? phone,
  }) async {
    try {
      // ✅ استخدم ApiService
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

      // Parse Response
      final responseData = response.data;

      // Check if success
      if (responseData['success'] == true) {
        final data = responseData['data'];

        // Create AuthResponseModel
        final authResponse = AuthResponseModel(
          user: UserModel.fromJson(data['user']),
          accessToken: data['accessToken'],
          refreshToken: data['refreshToken'],
          expiresAt: data['expiresAt'] != null
              ? DateTime.parse(data['expiresAt'])
              : DateTime.now().add(const Duration(hours: 24)),
        );

        // حفظ Tokens في TokenService
        await TokenService.instance.saveAuthData(
          accessToken: authResponse.accessToken,
          refreshToken: authResponse.refreshToken,
          expiresAt: authResponse.expiresAt,
          userId: authResponse.user.id,
        );

        return authResponse;
      } else {
        // Handle error from response
        throw ApiException(
          message: responseData['error'] ?? 'Registration failed',
          statusCode: response.statusCode,
          errorData: responseData,
        );
      }
    } on DioException catch (e) {
      // DioException يتم تحويله تلقائياً في ApiService
      // لكن يمكنك معالجته هنا أيضاً للتحكم أكثر
      throw ErrorHandlerService.instance.handleDioError(e);
    } catch (e) {
      // أي Exception آخر
      throw ErrorHandlerService.instance.handleException(e);
    }
  }

  /// Login user
  /// 
  /// نفس طريقة Register
  Future<AuthResponseModel> login({
    required String email,
    required String password,
    required String userType,
  }) async {
    try {
      final response = await ApiService.instance.post(
        ApiConstants.authLogin, // '/auth/login'
        data: {
          'email': email,
          'password': password,
          'userType': userType,
        },
      );

      final responseData = response.data;

      if (responseData['success'] == true) {
        final data = responseData['data'];

        final authResponse = AuthResponseModel(
          user: UserModel.fromJson(data['user']),
          accessToken: data['accessToken'],
          refreshToken: data['refreshToken'],
          expiresAt: data['expiresAt'] != null
              ? DateTime.parse(data['expiresAt'])
              : DateTime.now().add(const Duration(hours: 24)),
        );

        // حفظ Tokens
        await TokenService.instance.saveAuthData(
          accessToken: authResponse.accessToken,
          refreshToken: authResponse.refreshToken,
          expiresAt: authResponse.expiresAt,
          userId: authResponse.user.id,
        );

        return authResponse;
      } else {
        throw ApiException(
          message: responseData['error'] ?? 'Login failed',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ErrorHandlerService.instance.handleDioError(e);
    } catch (e) {
      throw ErrorHandlerService.instance.handleException(e);
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      await ApiService.instance.post(
        ApiConstants.authLogout, // '/auth/logout'
      );

      // مسح Tokens
      await TokenService.instance.clearAllTokens();
    } catch (e) {
      // حتى لو فشل Logout API، امسح Tokens محلياً
      await TokenService.instance.clearAllTokens();
      throw ErrorHandlerService.instance.handleException(e);
    }
  }
}

