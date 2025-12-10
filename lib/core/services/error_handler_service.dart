import 'package:dio/dio.dart';
import '../utils/logger.dart';

/// Custom API Exception
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;
  final Map<String, dynamic>? errorData;

  ApiException({
    required this.message,
    this.statusCode,
    this.originalError,
    this.errorData,
  });

  @override
  String toString() => message;
}

/// Error Handler Service for API errors
/// يحول Dio errors و HTTP errors إلى ApiException
class ErrorHandlerService {
  ErrorHandlerService._();
  
  static final ErrorHandlerService instance = ErrorHandlerService._();

  /// Handle Dio error and convert to ApiException
  ApiException handleDioError(DioException error) {
    Logger.e('ErrorHandlerService', 'DioError: ${error.message}');

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          message: 'Connection timeout. Please check your internet connection.',
          statusCode: error.response?.statusCode,
          originalError: error,
        );

      case DioExceptionType.badResponse:
        return _handleResponseError(error.response!);

      case DioExceptionType.cancel:
        return ApiException(
          message: 'Request was cancelled',
          originalError: error,
        );

      case DioExceptionType.connectionError:
        return ApiException(
          message: 'No internet connection. Please check your network.',
          originalError: error,
        );

      default:
        return ApiException(
          message: 'An unexpected error occurred. Please try again.',
          originalError: error,
        );
    }
  }

  /// Handle HTTP response error
  ApiException _handleResponseError(Response response) {
    final statusCode = response.statusCode ?? 500;
    final data = response.data;

    // Try to extract error message from response
    String message = 'An error occurred';
    
    if (data is Map<String, dynamic>) {
      // Try common error message fields
      message = data['error'] ?? 
                data['message'] ?? 
                data['error_message'] ?? 
                data['msg'] ?? 
                message;
      
      // If error is in 'errors' array
      if (data['errors'] != null && data['errors'] is List) {
        final errors = data['errors'] as List;
        if (errors.isNotEmpty) {
          message = errors.first.toString();
        }
      }
    } else if (data is String) {
      message = data;
    }

    // Customize message based on status code
    switch (statusCode) {
      case 400:
        message = message.contains('Invalid') ? message : 'Invalid request. Please check your input.';
        break;
      case 401:
        message = message.contains('Invalid') || message.contains('Unauthorized') 
            ? message 
            : 'Authentication failed. Please login again.';
        break;
      case 403:
        message = 'Access denied. You don\'t have permission.';
        break;
      case 404:
        message = 'Resource not found.';
        break;
      case 422:
        message = message.contains('validation') ? message : 'Validation error. Please check your input.';
        break;
      case 429:
        message = 'Too many requests. Please try again later.';
        break;
      case 500:
        message = 'Server error. Please try again later.';
        break;
      case 502:
      case 503:
      case 504:
        message = 'Service unavailable. Please try again later.';
        break;
      default:
        break;
    }

    return ApiException(
      message: message,
      statusCode: statusCode,
      errorData: data is Map<String, dynamic> ? data : null,
    );
  }

  /// Handle generic exception
  ApiException handleException(dynamic error) {
    if (error is DioException) {
      return handleDioError(error);
    }
    
    if (error is ApiException) {
      return error;
    }

    Logger.e('ErrorHandlerService', 'Unknown error: $error');
    return ApiException(
      message: error.toString(),
      originalError: error,
    );
  }

  /// Get user-friendly error message
  String getUserFriendlyMessage(ApiException error) {
    return error.message;
  }
}

