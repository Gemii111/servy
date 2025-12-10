# ⚡ دليل البدء السريع - Quick Start Guide

## ✅ ما تم إنجازه

تم تجهيز جميع المتطلبات للباك اند بشكل كامل:

### 1. ✅ ApiConstants - جميع الـ Endpoints
- 📁 `lib/core/constants/api_constants.dart`
- يحتوي على جميع الـ Endpoints المطلوبة
- Base URL و API Version

### 2. ✅ TokenService - إدارة Tokens
- 📁 `lib/core/services/token_service.dart`
- حفظ واسترجاع Access Token و Refresh Token
- التحقق من انتهاء الصلاحية
- مسح Tokens عند Logout

### 3. ✅ ErrorHandlerService - معالجة الأخطاء
- 📁 `lib/core/services/error_handler_service.dart`
- تحويل Dio Errors إلى ApiException
- رسائل خطأ واضحة للمستخدم

### 4. ✅ ApiService - HTTP Service
- 📁 `lib/data/services/api_service.dart`
- ✅ Automatic Token Injection
- ✅ Automatic Token Refresh
- ✅ Error Handling
- ✅ Request/Response Logging

### 5. ✅ NotificationService - Push Notifications
- 📁 `lib/core/services/notification_service.dart`
- جاهز للتحويل إلى Firebase
- Mock Implementation حالياً

### 6. ✅ Backend Integration Guide
- 📁 `BACKEND_INTEGRATION_GUIDE.md`
- دليل شامل لكيفية استخدام كل شيء

---

## 🚀 البدء السريع

### الخطوة 1: التهيئة في main()

```dart
// lib/main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Initialize TokenService
  await TokenService.instance.init();
  
  // 2. Initialize ApiService
  ApiService.instance.init(
    baseUrl: 'https://api.servy.app', // أو null لاستخدام ApiConstants.baseUrl
    enableLogging: true, // false في Production
  );
  
  // 3. Initialize NotificationService
  await NotificationService.instance.initialize();
  
  // 4. Initialize ConnectivityService (موجود بالفعل)
  ConnectivityService.instance.init();
  ConnectivityService.instance.startPeriodicCheck();
  
  runApp(const ProviderScope(child: MyApp()));
}
```

---

### الخطوة 2: تحديث AuthRepository

```dart
// lib/data/repositories/auth_repository.dart
import '../services/api_service.dart'; // بدلاً من mock_api_service.dart
import '../../core/constants/api_constants.dart';
import '../../core/services/token_service.dart';

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

### الخطوة 3: تحديث باقي Repositories

نفس الطريقة:
1. استبدل `MockApiService` بـ `ApiService.instance`
2. استخدم `ApiConstants` للـ Endpoints
3. Parse الـ Responses

**مثال: RestaurantRepository**
```dart
Future<List<RestaurantModel>> getRestaurants({...}) async {
  final response = await ApiService.instance.get(
    ApiConstants.restaurants,
    queryParameters: {...},
  );
  
  final data = response.data['data'] as List;
  return data.map((json) => RestaurantModel.fromJson(json)).toList();
}
```

---

### الخطوة 4: استخدام Notifications

```dart
// بعد Login
final fcmToken = NotificationService.instance.fcmToken;
if (fcmToken != null) {
  await NotificationService.instance.registerTokenWithBackend(userId);
  await NotificationService.instance.subscribeToTopic('customer_$userId');
}

// الاستماع للإشعارات
NotificationService.instance.notificationStream?.listen((notification) {
  // Handle notification
  if (notification.type == 'order_update') {
    // Navigate to order details
  }
});
```

---

## 📍 أماكن الاستخدام

### ApiConstants
- **يستخدم في:** جميع Repositories
- **متى:** عند استدعاء أي API endpoint

### TokenService
- **يستخدم في:**
  - ApiService (تلقائياً) - لإضافة Token للـ Headers
  - AuthRepository - لحفظ Tokens بعد Login
- **متى:** تلقائياً في ApiService، يدوياً في AuthRepository

### ErrorHandlerService
- **يستخدم في:** ApiService (تلقائياً)
- **متى:** عند حدوث أي خطأ في API call

### ApiService
- **يستخدم في:** جميع Repositories
- **متى:** عند استدعاء أي API

### NotificationService
- **يستخدم في:**
  - main() - للتهيئة
  - بعد Login - لتسجيل Token
  - في أي مكان - للاستماع للإشعارات
- **متى:** عند بدء التطبيق وبعد Login

---

## 🔄 التحويل من Mock إلى Real API

### 1. تحديث Base URL
```dart
// lib/core/constants/api_constants.dart
static const String baseUrl = 'https://api.servy.app'; // URL الباك اند الحقيقي
```

### 2. تحديث ApiService.init() في main()
```dart
ApiService.instance.init(
  baseUrl: 'https://api.servy.app', // أو null
  enableLogging: false, // في Production
);
```

### 3. تحديث جميع Repositories
- استبدل `MockApiService` بـ `ApiService.instance`
- استخدم `ApiConstants` للـ Endpoints
- Parse الـ Responses

---

## 📚 الملفات المرجعية

1. **BACKEND_INTEGRATION_GUIDE.md** - دليل شامل ومفصل
2. **API_ENDPOINTS_SPECIFICATION.md** - مواصفات جميع الـ APIs
3. **DATABASE_SCHEMA.md** - مواصفات قاعدة البيانات

---

## ✅ Checklist

- [x] ApiConstants - جميع Endpoints جاهزة
- [x] TokenService - إدارة Tokens جاهزة
- [x] ErrorHandlerService - معالجة الأخطاء جاهزة
- [x] ApiService - HTTP Service جاهز
- [x] NotificationService - Push Notifications جاهز
- [x] التوثيق الشامل - جاهز
- [ ] تحديث Repositories (يجب فعله عند الاتصال بالباك اند)
- [ ] اختبار جميع APIs
- [ ] إعداد Firebase للـ Push Notifications

---

## 🎯 الخلاصة

**جميع الخدمات جاهزة!** 🎉

فقط قم بـ:
1. تحديث Base URL في ApiConstants
2. تحديث Repositories لاستخدام ApiService بدلاً من MockApiService
3. اختبار جميع APIs

**للمزيد من التفاصيل:** راجع `BACKEND_INTEGRATION_GUIDE.md`

