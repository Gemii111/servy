# 📝 دليل ربط Register Endpoint - خطوة بخطوة

## 🎯 الهدف
ربط Register Endpoint بالباك اند الحقيقي بدلاً من Mock API.

---

## ✅ الخطوة 1: جلب معلومات الباك اند

### ما تحتاجه من الباك اند:
1. **Base URL** - مثال: `https://api.servy.com` أو `http://localhost:8080`
2. **Register Endpoint** - مثال: `/api/v1/auth/register` أو `/auth/register`
3. **Request Format** - ما هي البيانات المطلوبة؟
4. **Response Format** - كيف يبدو الرد؟

### مثال:
```
Base URL: https://api.servy.com
Register Endpoint: /api/v1/auth/register
Full URL: https://api.servy.com/api/v1/auth/register
```

---

## ✅ الخطوة 2: تحديث Base URL

### افتح الملف:
📁 `lib/core/constants/api_constants.dart`

### غير هذا السطر:
```dart
// قبل:
static const String baseUrl = 'https://api.servy.app';

// بعد (ضع Base URL الخاص بك):
static const String baseUrl = 'https://api.servy.com'; // ← غير هنا
```

### مثال:
```dart
class ApiConstants {
  // غير هذا فقط:
  static const String baseUrl = 'https://your-backend-url.com';
  
  // باقي الكود موجود بالفعل:
  static const String apiVersion = 'v1';
  static const String authRegister = '/auth/register';
  // ...
}
```

---

## ✅ الخطوة 3: التحقق من Register Endpoint

### في نفس الملف (`api_constants.dart`):
تأكد من وجود هذا السطر:
```dart
static const String authRegister = '/auth/register';
```

**إذا كان Endpoint مختلف:**
```dart
// مثال: إذا كان Endpoint هو /api/v1/auth/signup
static const String authRegister = '/api/v1/auth/signup';
```

---

## ✅ الخطوة 4: تحديث AuthRepository

### افتح الملف:
📁 `lib/data/repositories/auth_repository.dart`

### 4.1: غير الـ Imports

**احذف هذا:**
```dart
import '../services/mock_api_service.dart';
```

**أضف هذا:**
```dart
import '../services/api_service.dart';
import '../../core/constants/api_constants.dart';
import '../../core/services/token_service.dart';
import '../../core/services/error_handler_service.dart';
```

### 4.2: احذف MockApiService

**احذف هذا:**
```dart
class AuthRepository {
  AuthRepository({
    MockApiService? mockApiService,
  }) : _mockApiService = mockApiService ?? MockApiService.instance;

  final MockApiService _mockApiService;
```

**استبدله بـ:**
```dart
class AuthRepository {
  // لا حاجة لـ MockApiService الآن
```

### 4.3: حدّث دالة register

**احذف الكود القديم:**
```dart
Future<AuthResponseModel> register({...}) async {
  // In production, use ApiService:
  // final response = await ApiService.instance.post('/auth/register', data: {
  //   'email': email,
  //   'password': password,
  //   'userType': userType,
  //   'name': name,
  //   'phone': phone,
  // });
  // return AuthResponseModel.fromJson(response.data);

  return await _mockApiService.register(...);
}
```

**استبدله بـ:**
```dart
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
    //     "refreshToken": "..."
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
      );
    }
  } catch (e) {
    // معالجة الأخطاء
    throw ErrorHandlerService.instance.handleException(e);
  }
}
```

---

## ✅ الخطوة 5: تحديث main.dart

### افتح الملف:
📁 `lib/main.dart`

### أضف هذا السطر بعد `WidgetsFlutterBinding.ensureInitialized();`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ أضف هذا السطر
  await TokenService.instance.init();

  // ✅ هذا موجود بالفعل - تأكد منه
  ApiService.instance.init(baseUrl: ApiConstants.baseUrl);

  // باقي الكود...
}
```

---

## ✅ الخطوة 6: اختبار

### 6.1: شغّل التطبيق
```bash
flutter run
```

### 6.2: اذهب إلى Register Screen
- افتح التطبيق
- اضغط على Register
- املأ البيانات:
  - Email: `test@example.com`
  - Password: `password123`
  - Name: `Test User`
  - Phone: `+966501234567`

### 6.3: راقب Console Logs

**إذا نجح:**
```
[ApiService] POST /api/v1/auth/register
[ApiService] Request: {
  "email": "test@example.com",
  "password": "password123",
  ...
}
[ApiService] Response: {
  "success": true,
  "data": {...}
}
[TokenService] Auth data saved successfully
```

**إذا فشل:**
```
[ApiService] POST /api/v1/auth/register
[ErrorHandlerService] API Error: Invalid email or password
```

---

## ⚠️ إذا كان Response Format مختلف

### مثال 1: Response بدون "success" field
```dart
// Response:
// {
//   "user": {...},
//   "accessToken": "...",
//   "refreshToken": "..."
// }

// الكود:
final data = response.data; // بدون ['data']
final authResponse = AuthResponseModel(
  user: UserModel.fromJson(data['user']),
  accessToken: data['accessToken'],
  refreshToken: data['refreshToken'],
  expiresAt: DateTime.parse(data['expiresAt']),
);
```

### مثال 2: Response مع nested structure مختلف
```dart
// Response:
// {
//   "result": {
//     "user": {...},
//     "tokens": {
//       "access": "...",
//       "refresh": "..."
//     }
//   }
// }

// الكود:
final result = response.data['result'];
final authResponse = AuthResponseModel(
  user: UserModel.fromJson(result['user']),
  accessToken: result['tokens']['access'],
  refreshToken: result['tokens']['refresh'],
  expiresAt: DateTime.parse(result['tokens']['expiresAt']),
);
```

---

## 🔍 Debugging - حل المشاكل

### مشكلة 1: Connection Error
```
Error: Connection timeout
```

**الحل:**
1. تأكد من Base URL صحيح
2. تأكد من الباك اند يعمل
3. جرب الـ URL في المتصفح: `https://api.servy.com/api/v1/auth/register`

### مشكلة 2: 404 Not Found
```
Error: Resource not found
```

**الحل:**
1. تحقق من Endpoint path في ApiConstants
2. تأكد من Base URL + Endpoint = Full URL الصحيح
3. جرب الـ URL في Postman

### مشكلة 3: 400 Bad Request
```
Error: Invalid request
```

**الحل:**
1. تحقق من Request Body - هل جميع الحقول موجودة؟
2. تحقق من تنسيق البيانات (Email format, etc.)
3. راجع API Documentation

### مشكلة 4: Response Parsing Error
```
Error: type 'Null' is not a subtype of type 'String'
```

**الحل:**
1. اطبع Response في Console:
   ```dart
   print('Response: ${response.data}');
   ```
2. حدّث Parsing حسب Response الفعلي
3. استخدم null checks:
   ```dart
   expiresAt: data['expiresAt'] != null 
       ? DateTime.parse(data['expiresAt']) 
       : DateTime.now().add(Duration(hours: 24)),
   ```

---

## 📋 Checklist النهائي

- [ ] ✅ غير Base URL في `api_constants.dart`
- [ ] ✅ تحقق من Register Endpoint موجود
- [ ] ✅ حدّث Imports في `auth_repository.dart`
- [ ] ✅ احذف MockApiService
- [ ] ✅ حدّث دالة `register()`
- [ ] ✅ أضف `TokenService.instance.init()` في `main()`
- [ ] ✅ شغّل التطبيق
- [ ] ✅ جرّب Register
- [ ] ✅ راقب Logs
- [ ] ✅ تحقق من Success/Error

---

## 🎯 مثال كامل - الكود النهائي

### `lib/core/constants/api_constants.dart`:
```dart
class ApiConstants {
  static const String baseUrl = 'https://api.servy.com'; // ← غير هنا
  static const String apiVersion = 'v1';
  static const String authRegister = '/auth/register'; // ← تأكد من هذا
}
```

### `lib/data/repositories/auth_repository.dart`:
```dart
import '../services/api_service.dart';
import '../../core/constants/api_constants.dart';
import '../../core/services/token_service.dart';
import '../../core/services/error_handler_service.dart';

class AuthRepository {
  Future<AuthResponseModel> register({...}) async {
    final response = await ApiService.instance.post(
      ApiConstants.authRegister,
      data: {...},
    );
    // Parse and save tokens
  }
}
```

### `lib/main.dart`:
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await TokenService.instance.init(); // ← أضف هذا
  ApiService.instance.init(baseUrl: ApiConstants.baseUrl);
  runApp(...);
}
```

---

## ✅ النتيجة المتوقعة

بعد إتمام جميع الخطوات:
1. ✅ Register يعمل من التطبيق
2. ✅ البيانات تُرسل للباك اند
3. ✅ Response يتم Parse بنجاح
4. ✅ Tokens يتم حفظها
5. ✅ User يتم تسجيله في التطبيق

---

## 🆘 إذا واجهت مشكلة

1. **اطبع Response:**
   ```dart
   print('Full Response: ${response.data}');
   ```

2. **راجع Logs في Console:**
   - Request URL
   - Request Body
   - Response Status
   - Response Data

3. **اختبر في Postman أولاً:**
   - تأكد من API يعمل
   - شاهد Response Format
   - ثم حدّث الكود

---

**هذا كل شيء! 🎉**

