# Fix: Session Persistence (حفظ حالة تسجيل الدخول)

## المشكلة (Problem)
عند الضغط على زر الرجوع وإغلاق التطبيق، ثم إعادة فتحه، كان يطلب تسجيل الدخول من جديد بدلاً من تذكر حالة المستخدم.

## الحل (Solution)
تم إضافة حفظ حالة تسجيل الدخول باستخدام Hive للتخزين المحلي.

## التغييرات (Changes)

### 1. إضافة خدمة التخزين المحلي
- **File**: `lib/data/datasources/local_storage_service.dart`
- **Purpose**: خدمة لتخزين البيانات محلياً باستخدام Hive

### 2. تحديث AuthNotifier
- **File**: `lib/logic/providers/auth_providers.dart`
- **Changes**:
  - حفظ الـ token والبيانات عند تسجيل الدخول
  - استعادة الـ token والبيانات عند بدء التطبيق
  - مسح البيانات عند تسجيل الخروج

### 3. تحديث SplashScreen
- **File**: `lib/presentation/customer/screens/splash/splash_screen.dart`
- **Changes**:
  - التحقق من حالة تسجيل الدخول عند بدء التطبيق
  - التنقل التلقائي للشاشة المناسبة:
    - إذا مسجل دخول → Home
    - إذا انتهى Onboarding → Login
    - إذا لم ينتهي Onboarding → Onboarding

### 4. تحديث OnboardingScreen
- **File**: `lib/presentation/customer/screens/onboarding/onboarding_screen.dart`
- **Changes**: حفظ حالة إتمام Onboarding

### 5. تحديث main.dart
- **File**: `lib/main.dart`
- **Changes**: تهيئة Hive عند بدء التطبيق

## كيفية العمل (How It Works)

1. **عند تسجيل الدخول**:
   - يتم حفظ Token و Refresh Token
   - يتم حفظ بيانات المستخدم
   - يتم حفظ User ID

2. **عند إعادة فتح التطبيق**:
   - يتم تحميل البيانات المحفوظة
   - يتم استعادة حالة المستخدم
   - يتم التنقل للشاشة المناسبة تلقائياً

3. **عند تسجيل الخروج**:
   - يتم مسح جميع البيانات المحفوظة

## البيانات المحفوظة (Stored Data)

- `auth_token`: Token تسجيل الدخول
- `refresh_token`: Token للتجديد
- `user_id`: معرف المستخدم
- `user_data`: بيانات المستخدم (JSON)
- `onboarding_completed`: حالة إتمام Onboarding

## الاختبار (Testing)

1. سجل دخول في التطبيق
2. اضغط زر الرجوع لإغلاق التطبيق
3. أعد فتح التطبيق
4. يجب أن يتم توجيهك تلقائياً لصفحة Home بدون طلب تسجيل الدخول

## الملفات المعدلة (Modified Files)

1. `lib/data/datasources/local_storage_service.dart` (جديد)
2. `lib/logic/providers/auth_providers.dart` (محدث)
3. `lib/presentation/customer/screens/splash/splash_screen.dart` (محدث)
4. `lib/presentation/customer/screens/onboarding/onboarding_screen.dart` (محدث)
5. `lib/main.dart` (محدث)

## النتيجة (Result)

✅ التطبيق يحفظ حالة تسجيل الدخول  
✅ لا يطلب تسجيل الدخول عند إعادة الفتح  
✅ التنقل التلقائي للشاشات المناسبة  

