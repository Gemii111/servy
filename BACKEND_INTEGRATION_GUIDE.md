# 📚 دليل تكامل الباك اند - Backend Integration Guide

## 📋 نظرة عامة

هذا الملف يحتوي على دليل شامل لتكامل التطبيق مع الباك اند. يشرح جميع الكلاسات والخدمات المطلوبة، ومتى وأين يتم استخدامها.

---

## 🏗️ البنية التحتية (Infrastructure)

### 1. 📍 ApiConstants (`lib/core/constants/api_constants.dart`)

**الوصف:** يحتوي على جميع الـ Endpoints والـ Constants الخاصة بالـ API.

**المحتويات:**
- Base URL و API Version
- جميع Authentication Endpoints
- جميع User Endpoints
- جميع Restaurant Endpoints
- جميع Order Endpoints
- جميع Driver Endpoints
- WebSocket URLs

**الاستخدام:**
```dart
// استخدام الـ Endpoints في Repository
final response = await ApiService.instance.get(
  ApiConstants.restaurants,
  queryParameters: {'isOpen': true},
);
```

**متى يتم تحديثه:**
- عند إضافة endpoint جديد في الباك اند
- عند تغيير Base URL
- عند تغيير API Version

---

### 2. 🔑 TokenService (`lib/core/services/token_service.dart`)

**الوصف:** يدير حفظ واسترجاع Access Token و Refresh Token من SharedPreferences.

**الوظائف الرئيسية:**
- `saveAccessToken()` - حفظ Access Token
- `getAccessToken()` - استرجاع Access Token
- `saveRefreshToken()` - حفظ Refresh Token
- `getRefreshToken()` - استرجاع Refresh Token
- `isTokenExpired()` - التحقق من انتهاء صلاحية Token
- `clearAllTokens()` - مسح جميع Tokens (عند Logout)

**الاستخدام:**
```dart
// في AuthRepository بعد Login
await TokenService.instance.saveAuthData(
  accessToken: authResponse.accessToken,
  refreshToken: authResponse.refreshToken,
  expiresAt: authResponse.expiresAt,
  userId: user.id,
);

// في ApiService (تلقائياً)
final token = TokenService.instance.getAccessToken();
```

**متى يتم استخدامه:**
- بعد Login/Register - لحفظ Tokens
- في ApiService Interceptor - لإضافة Token للـ Headers
- عند Logout - لمسح Tokens
- عند Refresh Token - لتحديث Tokens

**التهيئة (Initialization):**
```dart
// في main() قبل أي استخدام
await TokenService.instance.init();
```

---

### 3. ⚠️ ErrorHandlerService (`lib/core/services/error_handler_service.dart`)

**الوصف:** يحول Dio Errors و HTTP Errors إلى ApiException قابلة للاستخدام.

**الوظائف الرئيسية:**
- `handleDioError()` - تحويل DioException إلى ApiException
- `handleException()` - تحويل أي Exception إلى ApiException
- `getUserFriendlyMessage()` - الحصول على رسالة خطأ واضحة للمستخدم

**الاستخدام:**
```dart
// في ApiService (تلقائياً)
try {
  return await _dio.get(path);
} catch (e) {
  throw ErrorHandlerService.instance.handleException(e);
}

// في Repository أو Provider
try {
  final response = await apiService.get(path);
} on ApiException catch (e) {
  // معالجة الخطأ
  showError(e.message);
}
```

**أنواع الأخطاء المدعومة:**
- Connection Timeout
- Bad Response (400, 401, 403, 404, 422, 500, etc.)
- Request Cancelled
- No Internet Connection
- Generic Errors

---

### 4. 🌐 ApiService (`lib/data/services/api_service.dart`)

**الوصف:** خدمة HTTP الرئيسية للتواصل مع الباك اند. يستخدم Dio مع Token Management و Error Handling.

**الميزات:**
- ✅ Automatic Token Injection (إضافة Token تلقائياً للـ Headers)
- ✅ Automatic Token Refresh (تحديث Token تلقائياً عند انتهاء الصلاحية)
- ✅ Error Handling (معالجة الأخطاء)
- ✅ Request/Response Logging (في Debug Mode)

**الوظائف الرئيسية:**
- `init()` - تهيئة Service
- `get()` - GET Request
- `post()` - POST Request
- `put()` - PUT Request
- `delete()` - DELETE Request
- `patch()` - PATCH Request

**الاستخدام:**
```dart
// التهيئة في main()
ApiService.instance.init(
  baseUrl: 'https://api.servy.app', // اختياري، يستخدم ApiConstants.baseUrl افتراضياً
  enableLogging: true, // في Debug Mode فقط
);

// استخدام في Repository
final response = await ApiService.instance.post(
  ApiConstants.authLogin,
  data: {
    'email': email,
    'password': password,
    'userType': userType,
  },
);

// Parse Response
final data = response.data['data'];
final user = UserModel.fromJson(data['user']);
```

**Token Management:**
- يتم إضافة Token تلقائياً من TokenService
- عند 401 Unauthorized، يتم محاولة Refresh Token تلقائياً
- إذا فشل Refresh، يتم مسح Tokens وإرجاع Error

---

### 5. 🔔 NotificationService (`lib/core/services/notification_service.dart`)

**الوصف:** خدمة Push Notifications. حالياً Mock، جاهزة للتحويل إلى Firebase.

**الوظائف الرئيسية:**
- `initialize()` - تهيئة Service
- `requestPermission()` - طلب صلاحيات الإشعارات
- `subscribeToTopic()` - الاشتراك في Topic
- `unsubscribeFromTopic()` - إلغاء الاشتراك من Topic
- `registerTokenWithBackend()` - تسجيل FCM Token في Backend

**الاستخدام:**
```dart
// التهيئة في main()
await NotificationService.instance.initialize();

// بعد Login
final fcmToken = NotificationService.instance.fcmToken;
await NotificationService.instance.registerTokenWithBackend(userId);

// الاشتراك في Topics
await NotificationService.instance.subscribeToTopic('customer_$userId');
await NotificationService.instance.subscribeToTopic('driver_orders');

// الاستماع للإشعارات
NotificationService.instance.notificationStream?.listen((notification) {
  // معالجة الإشعار
  print('New notification: ${notification.title}');
  
  // Navigate based on notification type
  if (notification.type == 'order_update') {
    // Navigate to order details
  }
});
```

**للتحويل إلى Firebase:**
1. أضف في `pubspec.yaml`:
   ```yaml
   firebase_core: ^2.24.2
   firebase_messaging: ^14.7.10
   ```

2. ألغِ التعليق على كود Firebase في `NotificationService`

3. أضف `google-services.json` (Android) و `GoogleService-Info.plist` (iOS)

4. قم بتهيئة Firebase في `main()`:
   ```dart
   await Firebase.initializeApp();
   ```

**Topics المقترحة:**
- `customer_{userId}` - إشعارات خاصة بالعميل
- `driver_orders` - طلبات التوصيل المتاحة
- `restaurant_{restaurantId}_orders` - طلبات المطعم
- `order_{orderId}` - تحديثات طلب معين

---

## 📦 Repositories (طبقة البيانات)

### 1. AuthRepository (`lib/data/repositories/auth_repository.dart`)

**الوصف:** يتعامل مع جميع عمليات Authentication.

**الوظائف:**
- `login()` - تسجيل الدخول
- `register()` - التسجيل
- `refreshToken()` - تحديث Token
- `updateProfile()` - تحديث الملف الشخصي
- `logout()` - تسجيل الخروج

**مثال التحويل من Mock إلى Real API:**
```dart
// قبل (Mock)
Future<AuthResponseModel> login({...}) async {
  return await _mockApiService.login(...);
}

// بعد (Real API)
Future<AuthResponseModel> login({
  required String email,
  required String password,
  required String userType,
}) async {
  final response = await ApiService.instance.post(
    ApiConstants.authLogin,
    data: {
      'email': email,
      'password': password,
      'userType': userType,
    },
  );
  
  final data = response.data['data'];
  final authResponse = AuthResponseModel(
    user: UserModel.fromJson(data['user']),
    accessToken: data['accessToken'],
    refreshToken: data['refreshToken'],
    expiresAt: DateTime.parse(data['expiresAt']),
  );
  
  // حفظ Tokens
  await TokenService.instance.saveAuthData(
    accessToken: authResponse.accessToken,
    refreshToken: authResponse.refreshToken,
    expiresAt: authResponse.expiresAt,
    userId: authResponse.user.id,
  );
  
  return authResponse;
}
```

---

### 2. RestaurantRepository (`lib/data/repositories/restaurant_repository.dart`)

**مثال التحويل:**
```dart
// قبل (Mock)
Future<List<RestaurantModel>> getRestaurants({...}) async {
  return await _mockApiService.getRestaurants(...);
}

// بعد (Real API)
Future<List<RestaurantModel>> getRestaurants({
  String? categoryId,
  double? latitude,
  double? longitude,
  bool? isOpen,
}) async {
  final queryParams = <String, dynamic>{};
  if (categoryId != null) queryParams['categoryId'] = categoryId;
  if (latitude != null) queryParams['latitude'] = latitude;
  if (longitude != null) queryParams['longitude'] = longitude;
  if (isOpen != null) queryParams['isOpen'] = isOpen;
  
  final response = await ApiService.instance.get(
    ApiConstants.restaurants,
    queryParameters: queryParams,
  );
  
  final data = response.data['data'] as List;
  return data.map((json) => RestaurantModel.fromJson(json)).toList();
}
```

---

### 3. OrderRepository (`lib/data/repositories/order_repository.dart`)

**مثال التحويل:**
```dart
// قبل (Mock)
Future<OrderModel> placeOrder({...}) async {
  return await _mockApiService.placeOrder(...);
}

// بعد (Real API)
Future<OrderModel> placeOrder({
  required String restaurantId,
  required List<CartItemModel> items,
  required String deliveryAddressId,
  String? couponCode,
}) async {
  final response = await ApiService.instance.post(
    ApiConstants.ordersPlace,
    data: {
      'restaurantId': restaurantId,
      'items': items.map((item) => item.toJson()).toList(),
      'deliveryAddressId': deliveryAddressId,
      'couponCode': couponCode,
    },
  );
  
  final data = response.data['data'];
  return OrderModel.fromJson(data);
}
```

---

## 🔄 Workflow (سير العمل)

### 1. عند بدء التطبيق (App Startup)

```dart
// في main()
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Initialize TokenService
  await TokenService.instance.init();
  
  // 2. Initialize ApiService
  ApiService.instance.init();
  
  // 3. Initialize NotificationService
  await NotificationService.instance.initialize();
  
  // 4. Initialize ConnectivityService
  ConnectivityService.instance.init();
  
  runApp(const MyApp());
}
```

---

### 2. عند Login

```dart
// في AuthRepository أو AuthProvider
final authResponse = await authRepository.login(
  email: email,
  password: password,
  userType: userType,
);

// Tokens يتم حفظها تلقائياً في ApiService Interceptor
// لكن يمكن حفظها يدوياً أيضاً:
await TokenService.instance.saveAuthData(
  accessToken: authResponse.accessToken,
  refreshToken: authResponse.refreshToken,
  expiresAt: authResponse.expiresAt,
  userId: authResponse.user.id,
);

// تسجيل FCM Token في Backend
final fcmToken = NotificationService.instance.fcmToken;
if (fcmToken != null) {
  await NotificationService.instance.registerTokenWithBackend(authResponse.user.id);
  
  // الاشتراك في Topics
  await NotificationService.instance.subscribeToTopic('customer_${authResponse.user.id}');
}
```

---

### 3. عند Logout

```dart
// في AuthRepository أو AuthProvider
// 1. استدعاء Logout API
await authRepository.logout();

// 2. مسح Tokens
await TokenService.instance.clearAllTokens();

// 3. إلغاء الاشتراك من Topics
await NotificationService.instance.unsubscribeFromTopic('customer_$userId');

// 4. Clear User Data في Providers
ref.read(authProvider.notifier).logout();
```

---

### 4. عند تحديث Token

```dart
// يحدث تلقائياً في ApiService Interceptor
// عند 401 Unauthorized:
// 1. يتم محاولة Refresh Token
// 2. إذا نجح، يتم Retry الطلب الأصلي
// 3. إذا فشل، يتم مسح Tokens وإرجاع Error

// يمكن أيضاً تحديثه يدوياً:
final refreshToken = TokenService.instance.getRefreshToken();
if (refreshToken != null) {
  final response = await ApiService.instance.post(
    ApiConstants.authRefresh,
    data: {'refreshToken': refreshToken},
  );
  
  final data = response.data['data'];
  await TokenService.instance.saveAuthData(
    accessToken: data['accessToken'],
    refreshToken: data['refreshToken'] ?? refreshToken,
    expiresAt: DateTime.parse(data['expiresAt']),
  );
}
```

---

## 📝 Response Format (تنسيق الـ Response)

جميع الـ APIs يجب أن تعيد Response بهذا التنسيق:

```json
{
  "success": true,
  "data": {
    // البيانات الفعلية
  },
  "message": "Optional message"
}
```

**في حالة Error:**
```json
{
  "success": false,
  "error": "Error message",
  "errors": ["Optional array of errors"]
}
```

**في Code:**
```dart
final response = await ApiService.instance.get(ApiConstants.restaurants);
if (response.data['success'] == true) {
  final data = response.data['data'];
  // Process data
} else {
  final error = response.data['error'];
  // Handle error
}
```

---

## 🚀 خطوات التحويل من Mock إلى Real API

### الخطوة 1: تحديث ApiConstants
```dart
// تأكد من تحديث Base URL
static const String baseUrl = 'https://api.servy.app'; // أو URL الباك اند الحقيقي
```

### الخطوة 2: تحديث ApiService
```dart
// في main()
ApiService.instance.init(
  baseUrl: 'https://api.servy.app', // أو null لاستخدام ApiConstants.baseUrl
  enableLogging: true, // false في Production
);
```

### الخطوة 3: تحديث Repositories
- استبدل `MockApiService` بـ `ApiService.instance`
- استخدم `ApiConstants` للـ Endpoints
- Parse الـ Responses إلى Models

### الخطوة 4: اختبار
- تأكد من عمل Authentication
- تأكد من Token Management
- تأكد من Error Handling
- تأكد من جميع الـ Endpoints

---

## 📚 الملفات المرجعية

- **API_ENDPOINTS_SPECIFICATION.md** - مواصفات جميع الـ APIs
- **DATABASE_SCHEMA.md** - مواصفات قاعدة البيانات
- **API_STRUCTURE_EXPLANATION.md** - شرح بنية الـ APIs الحالية

---

## ✅ Checklist للباك اند

- [ ] Base URL جاهز
- [ ] جميع الـ Endpoints مُنفذة
- [ ] Authentication يعمل
- [ ] Token Refresh يعمل
- [ ] Error Handling صحيح
- [ ] Response Format متوافق
- [ ] WebSocket جاهز (للـ Real-time updates)
- [ ] Push Notifications جاهزة

---

## 🎯 الخلاصة

1. **ApiConstants**: جميع الـ Endpoints
2. **TokenService**: إدارة Tokens
3. **ErrorHandlerService**: معالجة الأخطاء
4. **ApiService**: HTTP Service مع Token Management
5. **NotificationService**: Push Notifications
6. **Repositories**: طبقة البيانات - تحتاج تحديث من Mock إلى Real API

**جميع الخدمات جاهزة للاستخدام!** فقط قم بتحديث Repositories لاستخدام ApiService بدلاً من MockApiService.

