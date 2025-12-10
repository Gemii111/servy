import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../../core/constants/api_constants.dart';
import '../../core/services/token_service.dart';
import '../../core/services/error_handler_service.dart';
import '../../core/utils/logger.dart';

/// API Service for making HTTP requests using Dio
/// يدعم Token Management و Error Handling و Automatic Token Refresh
class ApiService {
  ApiService._();

  static final ApiService instance = ApiService._();
  late Dio _dio;
  bool _isInitialized = false;

  /// Initialize Dio with configuration
  /// يجب استدعاءها في main() قبل استخدام أي API calls
  void init({
    String? baseUrl,
    Map<String, dynamic>? headers,
    bool enableLogging = true,
  }) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? ApiConstants.apiBaseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        sendTimeout: ApiConstants.sendTimeout,
        headers: {
          ApiConstants.contentType: ApiConstants.applicationJson,
          ApiConstants.accept: ApiConstants.applicationJson,
          ...?headers,
        },
      ),
    );

    // Add logging interceptor (only in debug mode)
    if (enableLogging) {
      _dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
          maxWidth: 90,
        ),
      );
    }

    // Add auth interceptor for automatic token injection
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          _addAuthToken(options);
          handler.next(options);
        },
        onError: (error, handler) async {
          // Handle 401 Unauthorized - try to refresh token
          if (error.response?.statusCode == 401) {
            try {
              final refreshed = await _refreshToken();
              if (refreshed) {
                // Retry the original request with new token
                _addAuthToken(error.requestOptions);
                final response = await _dio.fetch(error.requestOptions);
                handler.resolve(response);
                return;
              }
            } catch (e) {
              Logger.e('ApiService', 'Token refresh failed: $e');
              // If refresh fails, clear tokens and let error propagate
              await TokenService.instance.clearAllTokens();
            }
          }
          
          // Handle other errors
          final apiException = ErrorHandlerService.instance.handleDioError(error);
          Logger.e('ApiService', 'API Error: ${apiException.message}');
          handler.next(error);
        },
      ),
    );

    _isInitialized = true;
    Logger.d('ApiService', 'ApiService initialized with baseUrl: ${ApiConstants.apiBaseUrl}');
  }

  /// Add authentication token to request headers
  void _addAuthToken(RequestOptions options) {
    final token = TokenService.instance.getAccessToken();
    if (token != null && !options.headers.containsKey(ApiConstants.authorization)) {
      options.headers[ApiConstants.authorization] = '${ApiConstants.bearer} $token';
    }
  }

  /// Refresh access token using refresh token
  Future<bool> _refreshToken() async {
    try {
      final refreshToken = TokenService.instance.getRefreshToken();
      if (refreshToken == null) {
        Logger.e('ApiService', 'No refresh token available');
        return false;
      }

      // Create a new Dio instance without interceptors to avoid infinite loop
      final refreshDio = Dio(
        BaseOptions(
          baseUrl: ApiConstants.apiBaseUrl,
          headers: {
            ApiConstants.contentType: ApiConstants.applicationJson,
          },
        ),
      );

      final response = await refreshDio.post(
        ApiConstants.authRefresh,
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'] ?? response.data;
        final accessToken = data['accessToken'] as String?;
        final newRefreshToken = data['refreshToken'] as String?;
        final expiresAt = data['expiresAt'] != null
            ? DateTime.parse(data['expiresAt'] as String)
            : null;

        if (accessToken != null) {
          await TokenService.instance.saveAuthData(
            accessToken: accessToken,
            refreshToken: newRefreshToken ?? refreshToken,
            expiresAt: expiresAt,
          );
          Logger.d('ApiService', 'Token refreshed successfully');
          return true;
        }
      }

      return false;
    } catch (e) {
      Logger.e('ApiService', 'Token refresh error: $e');
      return false;
    }
  }

  /// Check if service is initialized
  bool get isInitialized => _isInitialized;

  // ==================== HTTP Methods ====================

  /// GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    _ensureInitialized();
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      throw ErrorHandlerService.instance.handleException(e);
    }
  }

  /// POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    _ensureInitialized();
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      throw ErrorHandlerService.instance.handleException(e);
    }
  }

  /// PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    _ensureInitialized();
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      throw ErrorHandlerService.instance.handleException(e);
    }
  }

  /// DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    _ensureInitialized();
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      throw ErrorHandlerService.instance.handleException(e);
    }
  }

  /// PATCH request
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    _ensureInitialized();
    try {
      return await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      throw ErrorHandlerService.instance.handleException(e);
    }
  }

  /// Ensure service is initialized
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError(
        'ApiService not initialized. Call ApiService.instance.init() first.',
      );
    }
  }

  /// Clear all interceptors and reset (useful for testing)
  void reset() {
    _dio.interceptors.clear();
    _isInitialized = false;
  }
}
