# Step 0: Representative Code Snippet

## Best Practices Example

This demonstrates Clean Architecture patterns used in the project.

### Example 1: Constants (Core Layer)

```dart
// lib/core/constants/api_constants.dart

/// API Constants for Servy Customer App
class ApiConstants {
  ApiConstants._(); // Private constructor prevents instantiation

  // Base URL - Update this when connecting to real backend
  static const String baseUrl = 'http://localhost:8080';
  
  // API Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String restaurants = '/restaurants';
  
  // API Headers
  static const String contentType = 'Content-Type';
  static const String applicationJson = 'application/json';
  
  // API Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
```

**Best Practices:**
- ✅ Private constructor prevents instantiation
- ✅ All constants are static
- ✅ Clear documentation
- ✅ Organized by category

### Example 2: Utility Logger (Core Layer)

```dart
// lib/core/utils/logger.dart

import 'package:flutter/foundation.dart';

/// Simple logger utility for debugging
class Logger {
  Logger._(); // Private constructor

  static void d(String tag, dynamic message) {
    if (kDebugMode) {
      debugPrint('[$tag] $message');
    }
  }

  static void e(String tag, dynamic error, [StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('[$tag] ERROR: $error');
      if (stackTrace != null) {
        debugPrint('[$tag] StackTrace: $stackTrace');
      }
    }
  }
  
  // ... other methods
}
```

**Best Practices:**
- ✅ Conditional compilation (only in debug mode)
- ✅ Tagged logging for filtering
- ✅ Supports error tracking with stack traces
- ✅ Simple, reusable API

### Example 3: Mock Server Endpoint (Clean Separation)

```dart
// mock_server/lib/server.dart

router.post('/auth/login', (Request request) async {
  final body = await request.readAsString();
  final data = jsonDecode(body) as Map<String, dynamic>;
  final phone = data['phone'] as String?;
  final password = data['password'] as String?;

  // Mock validation
  if (phone == null || password == null) {
    return Response.badRequest(
      body: jsonEncode({'error': 'Phone and password are required'}),
      headers: {'Content-Type': 'application/json'},
    );
  }

  // Simulate API delay
  await Future.delayed(const Duration(milliseconds: 500));
  
  return Response.ok(
    jsonEncode({
      'success': true,
      'data': {
        'user': {
          'id': 'user_123',
          'name': 'John Doe',
          'phone': phone,
        },
        'token': 'mock_jwt_token_${DateTime.now().millisecondsSinceEpoch}',
      },
    }),
    headers: {'Content-Type': 'application/json'},
  );
});
```

**Best Practices:**
- ✅ Consistent response format (`success`, `data`, `error`)
- ✅ Proper error handling
- ✅ Realistic API delays
- ✅ Type-safe JSON handling

### Example 4: Unit Test (Testable Code)

```dart
// test/core/constants/app_constants_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:servy/core/constants/app_constants.dart';
import 'package:servy/core/constants/api_constants.dart';

void main() {
  group('AppConstants', () {
    test('should have correct default values', () {
      expect(AppConstants.defaultLatitude, equals(24.7136));
      expect(AppConstants.defaultLongitude, equals(46.6753));
      expect(AppConstants.defaultPageSize, equals(20));
    });
  });

  group('ApiConstants', () {
    test('should have correct base URL', () {
      expect(ApiConstants.baseUrl, equals('http://localhost:8080'));
    });
  });
}
```

**Best Practices:**
- ✅ Descriptive test names
- ✅ Grouped related tests
- ✅ Clear assertions
- ✅ Tests verify behavior, not implementation

## Architecture Principles Applied

1. **Separation of Concerns**: Core utilities separate from business logic
2. **Single Responsibility**: Each class has one clear purpose
3. **Testability**: All utilities are easily testable
4. **Maintainability**: Constants centralized, easy to update
5. **Documentation**: Clear comments explain purpose

## Next Steps

These patterns will be extended in:
- **Step 1**: Repository pattern implementation
- **Step 2**: Riverpod providers with AsyncValue
- **Step 3**: Domain entities and repository interfaces

