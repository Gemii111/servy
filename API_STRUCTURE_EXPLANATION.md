# 📋 بنية APIs الحالية - شرح شامل

## 🎯 الوضع الحالي

### ✅ ما هو موجود وجاهز:

1. **API Service Layer** ✅
   - 📁 `lib/data/services/api_service.dart`
   - يستخدم Dio للـ HTTP requests
   - جاهز للاستخدام مع APIs الحقيقية
   - يحتوي على: GET, POST, PUT, DELETE, PATCH

2. **Repository Pattern** ✅
   - 📁 `lib/data/repositories/`
   - كل repository منفصل (Auth, Restaurant, Order, etc.)
   - جاهزة للتحويل من Mock إلى Real API

3. **State Management** ✅
   - 📁 `lib/logic/providers/`
   - يستخدم **Riverpod** (StateNotifier)
   - Providers جاهزة للعمل مع APIs

---

## ⚠️ ملاحظة مهمة: Cubit vs Riverpod

### الوضع الحالي:
- ❌ **لا** يستخدم Cubit
- ✅ يستخدم **Riverpod** (StateNotifier)

### إذا كنت تريد استخدام Cubit:

1. **يحتاج إعادة هيكلة كبيرة:**
   - إزالة Riverpod من `pubspec.yaml`
   - إضافة `flutter_bloc` package
   - تحويل جميع Providers إلى Cubits
   - تحديث جميع الشاشات لاستخدام BlocBuilder/BlocProvider

2. **الوقت المتوقع:** 4-6 ساعات عمل

---

## 🔄 كيفية التحويل من Mock إلى Real APIs

### الخطوة 1: تحديث Repository

**مثال: AuthRepository**

```dart
// حالياً (Mock):
class AuthRepository {
  final MockApiService _mockApiService;
  
  Future<AuthResponseModel> login(...) async {
    return await _mockApiService.login(...); // Mock
  }
}

// بعد التحويل (Real API):
class AuthRepository {
  final ApiService _apiService; // تغيير هنا
  
  Future<AuthResponseModel> login({
    required String email,
    required String password,
    required String userType,
  }) async {
    final response = await ApiService.instance.post(
      ApiConstants.login, // '/auth/login'
      data: {
        'email': email,
        'password': password,
        'userType': userType,
      },
    );
    return AuthResponseModel.fromJson(response.data);
  }
}
```

### الخطوة 2: تحديث ApiConstants

```dart
// lib/core/constants/api_constants.dart
class ApiConstants {
  static const String baseUrl = 'https://your-api.com'; // تغيير هنا
  
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  // ... باقي endpoints
}
```

### الخطوة 3: إضافة Auth Token Interceptor

```dart
// في ApiService.init()
_dio.interceptors.add(
  InterceptorsWrapper(
    onRequest: (options, handler) {
      final token = AuthService.getToken(); // جلب الـ token
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      handler.next(options);
    },
  ),
);
```

---

## 📊 هيكل المشروع الحالي

```
lib/
├── data/
│   ├── services/
│   │   ├── api_service.dart          ✅ جاهز للـ APIs الحقيقية
│   │   └── mock_api_service.dart     ⚠️ يستخدم حالياً
│   │
│   ├── repositories/                 ✅ جاهزة للتحويل
│   │   ├── auth_repository.dart
│   │   ├── restaurant_repository.dart
│   │   ├── order_repository.dart
│   │   └── ...
│   │
│   └── models/                       ✅ جاهزة
│
├── logic/
│   └── providers/                    ✅ Riverpod (StateNotifier)
│       ├── auth_providers.dart
│       ├── restaurant_providers.dart
│       └── ...
│
└── core/
    ├── constants/
    │   └── api_constants.dart        ✅ جاهز
    └── services/
        └── api_service.dart          ✅ جاهز
```

---

## 🎯 الخطوات المقترحة

### الخيار 1: البقاء على Riverpod (الأسهل) ✅

**المميزات:**
- ✅ الكود موجود بالفعل
- ✅ جاهز للاستخدام
- ✅ لا يحتاج إعادة هيكلة

**التعديلات المطلوبة:**
1. تحديث Repositories لاستخدام `ApiService` بدلاً من `MockApiService`
2. تحديث `ApiConstants.baseUrl` إلى الـ URL الحقيقي
3. إضافة Auth Token Interceptor

**الوقت:** 1-2 ساعة

---

### الخيار 2: التحويل إلى Cubit (إعادة هيكلة)

**المطلوب:**
1. إزالة `flutter_riverpod` من `pubspec.yaml`
2. إضافة `flutter_bloc` package
3. تحويل جميع Providers إلى Cubits
4. تحديث جميع الشاشات

**الوقت:** 4-6 ساعات

---

## 💡 التوصية

**أنصح بالبقاء على Riverpod** لأن:
1. ✅ الكود موجود وجاهز
2. ✅ Riverpod قوي وسهل الاستخدام
3. ✅ لا يحتاج إعادة هيكلة
4. ✅ يمكن البدء بالـ APIs فوراً

**لكن إذا كنت مصر على Cubit:**
- يمكنني تحويل المشروع كاملاً إلى Cubit
- سأحتاج وقت أكثر (4-6 ساعات)

---

## ❓ سؤالك

**هل تريد:**
1. **البقاء على Riverpod** ✅ (الأسهل والأسرع)
2. **التحويل إلى Cubit** ⚠️ (يحتاج وقت)

**وكيف تريد التعامل مع الـ APIs:**
- إبقاء Repositories على MockApiService (للتطوير)
- أو تحويلها لاستخدام ApiService الحقيقي (للإنتاج)

