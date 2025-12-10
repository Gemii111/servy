# 🚀 دليل بسيط - ربط Register بالباك اند

## 📝 3 خطوات فقط!

---

## ✅ الخطوة 1: غير Base URL

### افتح:
📁 `lib/core/constants/api_constants.dart`

### غير السطر 11:
```dart
// قبل:
static const String baseUrl = 'https://api.servy.app';

// بعد (ضع Base URL الخاص بك):
static const String baseUrl = 'https://your-backend-url.com';
```

**مثال:**
```dart
static const String baseUrl = 'https://api.servy.com';
// أو
static const String baseUrl = 'http://localhost:8080';
```

---

## ✅ الخطوة 2: تأكد من Endpoint

### في نفس الملف:
تأكد من وجود:
```dart
static const String authRegister = '/auth/register';
```

**إذا كان Endpoint مختلف:**
```dart
// مثال: إذا كان /api/v1/auth/signup
static const String authRegister = '/api/v1/auth/signup';
```

---

## ✅ الخطوة 3: شغّل التطبيق

### شغّل:
```bash
flutter run
```

### جرّب Register:
1. افتح التطبيق
2. اذهب إلى Register
3. املأ البيانات واضغط Register
4. راقب Console Logs

---

## 🎯 النتيجة

**إذا نجح:**
- ✅ Request يُرسل للباك اند
- ✅ Response يتم استقباله
- ✅ Tokens يتم حفظها
- ✅ User يتم تسجيله

**إذا فشل:**
- ❌ شاهد Error في Console
- ❌ تحقق من Base URL
- ❌ تحقق من Endpoint
- ❌ تحقق من Request Format

---

## 📋 Checklist

- [ ] ✅ غير Base URL
- [ ] ✅ تحقق من Endpoint
- [ ] ✅ شغّل التطبيق
- [ ] ✅ جرّب Register
- [ ] ✅ راقب Logs

---

## 🔍 Debugging

### إذا ظهر Error:

**1. Connection Error:**
- تحقق من Base URL
- تحقق من الإنترنت
- تحقق من الباك اند يعمل

**2. 404 Not Found:**
- تحقق من Endpoint path
- جرب الـ URL في المتصفح

**3. 400 Bad Request:**
- تحقق من Request Body
- راجع API Documentation

**4. Response Parsing Error:**
- اطبع Response:
  ```dart
  print('Response: ${response.data}');
  ```
- حدّث Parsing حسب Response الفعلي

---

## 📝 ملاحظات

1. **الكود محدّث بالفعل!** ✅
   - `AuthRepository` يستخدم `ApiService`
   - `main.dart` يحتوي على `TokenService.init()`

2. **فقط غير Base URL** واختبر!

3. **إذا كان Response Format مختلف:**
   - اطبع Response في Console
   - حدّث Parsing في `register()` function

---

**هذا كل شيء! 🎉**

