# 🧪 دليل اختبار APIs - API Testing Guide

## 📝 خطوات إضافة واختبار API جديد

### مثال: Sign Up Endpoint

---

## الخطوة 1: تحديث Base URL في ApiConstants

```dart
// lib/core/constants/api_constants.dart
class ApiConstants {
  // غير Base URL هنا
  static const String baseUrl = 'https://your-backend-url.com'; // Base URL الجديد
  
  // الـ endpoint موجود بالفعل:
  static const String authRegister = '/auth/register';
}
```

---

## الخطوة 2: تحديث Repository ليستخدم ApiService

```dart
// lib/data/repositories/auth_repository.dart
import '../services/api_service.dart'; // ✅ استبدل mock_api_service
import '../../core/constants/api_constants.dart';
import '../../core/services/token_service.dart';
import '../../core/services/error_handler_service.dart';

class AuthRepository {
  // ❌ احذف هذا:
  // final MockApiService _mockApiService;
  
  // ✅ لا حاجة لـ MockApiService الآن

  /// Register new user
  Future<AuthResponseModel> register({
    required String email,
    required String password,
    required String userType,
    String? name,
    String? phone,
  }) async {
    try {
      // ✅ استخدم ApiService بدلاً من MockApiService
      final response = await ApiService.instance.post(
        ApiConstants.authRegister, // استخدم الـ constant
        data: {
          'email': email,
          'password': password,
          'userType': userType,
          'name': name,
          'phone': phone,
        },
      );
      
      // Parse Response
      // حسب تنسيق Response من الباك اند:
      final responseData = response.data;
      
      // إذا كان Response بهذا التنسيق:
      // {
      //   "success": true,
      //   "data": {
      //     "user": {...},
      //     "accessToken": "...",
      //     "refreshToken": "..."
      //   }
      // }
      
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
        // Handle error from response
        throw ApiException(
          message: responseData['error'] ?? 'Registration failed',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      // DioException يتم تحويله تلقائياً في ApiService
      // لكن يمكنك معالجته هنا أيضاً
      throw ErrorHandlerService.instance.handleDioError(e);
    } catch (e) {
      // أي Exception آخر
      throw ErrorHandlerService.instance.handleException(e);
    }
  }
}
```

---

## الخطوة 3: التأكد من تهيئة ApiService في main()

```dart
// lib/main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ تأكد من تهيئة ApiService
  ApiService.instance.init(
    baseUrl: 'https://your-backend-url.com', // أو null لاستخدام ApiConstants.baseUrl
    enableLogging: true, // true في Development
  );
  
  // ✅ تأكد من تهيئة TokenService
  await TokenService.instance.init();

  runApp(const ProviderScope(child: ServyApp()));
}
```

---

## الخطوة 4: الاختبار

### أ) الاختبار في التطبيق (UI)

1. شغّل التطبيق
2. اذهب إلى شاشة Register
3. املأ البيانات واضغط Register
4. راقب الـ Logs في Console:
   ```
   [ApiService] POST /api/v1/auth/register
   [ApiService] Request: {...}
   [ApiService] Response: {...}
   ```

### ب) الاختبار بـ Try-Catch في Provider/Screen

```dart
// في Provider أو Screen
try {
  final authResponse = await authRepository.register(
    email: 'test@example.com',
    password: 'password123',
    userType: 'customer',
    name: 'Test User',
    phone: '+966501234567',
  );
  
  // Success
  print('Registration successful!');
  print('User: ${authResponse.user.name}');
  print('Token: ${authResponse.accessToken}');
  
} on ApiException catch (e) {
  // Handle API Error
  print('API Error: ${e.message}');
  print('Status Code: ${e.statusCode}');
  
  // Show error to user
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(e.message)),
  );
  
} catch (e) {
  // Handle other errors
  print('Error: $e');
}
```

### ج) اختبار مباشر من Terminal (Postman/curl)

```bash
# Test using curl
curl -X POST https://your-backend-url.com/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123",
    "userType": "customer",
    "name": "Test User",
    "phone": "+966501234567"
  }'
```

---

## 🔍 Debugging Tips

### 1. تفعيل Logging في ApiService

```dart
ApiService.instance.init(
  enableLogging: true, // ✅ true في Development
);
```

### 2. فحص Response في Debugger

```dart
final response = await ApiService.instance.post(...);

// اضغط Breakpoint هنا وافحص response.data
print('Response Status: ${response.statusCode}');
print('Response Data: ${response.data}');
```

### 3. فحص Headers

```dart
// ApiService يضيف Headers تلقائياً:
// - Content-Type: application/json
// - Authorization: Bearer {token} (إذا كان موجود)
```

### 4. فحص Network Tab

في Flutter DevTools → Network:
- شاهد جميع Requests
- فحص Request Headers
- فحص Request Body
- فحص Response

---

## ⚠️ الأخطاء الشائعة

### 1. Connection Error
```
Error: Connection timeout / No internet connection
```
**الحل:** تأكد من:
- Base URL صحيح
- الباك اند يعمل
- الإنترنت متصل

### 2. 401 Unauthorized
```
Error: Authentication failed
```
**الحل:** 
- Sign Up لا يحتاج Token (عادة)
- تأكد من الـ Request Body صحيح

### 3. 400 Bad Request
```
Error: Invalid request
```
**الحل:**
- تأكد من جميع الحقول المطلوبة موجودة
- تأكد من تنسيق البيانات صحيح
- راجع API Documentation

### 4. 422 Validation Error
```
Error: Validation error
```
**الحل:**
- راجع رسالة الخطأ في Response
- تأكد من صحة البيانات (Email format, Password strength, etc.)

### 5. 500 Server Error
```
Error: Server error
```
**الحل:**
- المشكلة من الباك اند
- تحقق من Server Logs

---

## 📋 Checklist للاختبار

- [ ] Base URL محدث في ApiConstants
- [ ] Endpoint موجود في ApiConstants
- [ ] Repository محدث ليستخدم ApiService
- [ ] ApiService مُهيأ في main()
- [ ] TokenService مُهيأ في main()
- [ ] Error Handling موجود (try-catch)
- [ ] Response Parsing صحيح
- [ ] Tokens يتم حفظها بعد Register
- [ ] UI يعرض Success/Error messages
- [ ] Logs تظهر في Console

---

## 🎯 مثال كامل: Register Endpoint

### 1. ApiConstants (موجود بالفعل)
```dart
static const String authRegister = '/auth/register';
```

### 2. AuthRepository (تحديث)
```dart
Future<AuthResponseModel> register({...}) async {
  final response = await ApiService.instance.post(
    ApiConstants.authRegister,
    data: {...},
  );
  // Parse and return
}
```

### 3. main.dart (تحديث)
```dart
ApiService.instance.init(
  baseUrl: 'https://your-backend-url.com',
  enableLogging: true,
);
await TokenService.instance.init();
```

### 4. الاختبار
- شغّل التطبيق
- جرب Register من UI
- راقب Logs
- تحقق من Success/Error

---

## 📚 نصائح إضافية

1. **ابدأ بـ endpoint واحد:** جرب Register أولاً قبل باقي الـ APIs
2. **استخدم Postman:** اختبر الـ API من Postman قبل التطبيق
3. **راقب Logs:** ApiService يسجل كل Request/Response
4. **اختبر Error Cases:** جرب بيانات خاطئة لرؤية Error Handling
5. **تحقق من Response Format:** تأكد من تنسيق Response كما هو متوقع

---

## ✅ النتيجة المتوقعة

بعد إتمام الخطوات:
- ✅ Register يعمل من التطبيق
- ✅ Response يتم Parse بنجاح
- ✅ Tokens يتم حفظها
- ✅ User يتم تسجيله في التطبيق
- ✅ يمكن Login بنجاح

---

## 🔄 نفس الخطوات لأي Endpoint آخر

1. تأكد من Endpoint موجود في ApiConstants
2. حدّث Repository ليستخدم ApiService
3. Parse Response حسب تنسيق الباك اند
4. اختبر من UI أو Provider
5. راقب Logs

**هذا كل شيء! 🎉**

