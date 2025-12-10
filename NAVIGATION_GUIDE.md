# دليل التنقل في التطبيق (Navigation Guide)

## كيفية التنقل بين الصفحات

### 1. من Home Screen
- **للذهاب لـ Orders**: اضغط على أيقونة Orders في Bottom Navigation
- **للذهاب لـ Profile**: اضغط على أيقونة Profile في Bottom Navigation
- **للرجوع**: اضغط زر الرجوع → سيظهر dialog تأكيد → اختر "Exit" للإغلاق أو "Cancel" للبقاء

### 2. من Orders/Profile Screen
- **للرجوع**: اضغط زر الرجوع في AppBar → سيعود لـ Home تلقائياً
- **أو**: استخدم Bottom Navigation للعودة لـ Home

### 3. التنقل البرمجي (Programmatic Navigation)

#### استخدام go_router:
```dart
// للذهاب لصفحة جديدة (استبدال الصفحة الحالية)
context.go('/customer/home');

// للذهاب لصفحة جديدة (إضافة للستاك)
context.push('/customer/orders');

// للرجوع
context.pop();
```

## سلوك زر الرجوع

### في Home Screen:
- يظهر dialog تأكيد قبل الإغلاق
- يمكنك اختيار "Cancel" للبقاء في التطبيق
- أو "Exit" لإغلاق التطبيق

### في الصفحات الأخرى:
- يعود للصفحة السابقة مباشرة
- لا يغلق التطبيق

## حفظ حالة تسجيل الدخول

### عند تسجيل الدخول:
- يتم حفظ Token وبيانات المستخدم تلقائياً
- لا حاجة لعمل أي شيء إضافي

### عند إعادة فتح التطبيق:
- يتم استعادة حالة تسجيل الدخول تلقائياً
- يتم التنقل للصفحة المناسبة:
  - مسجل دخول → Home
  - غير مسجل → Login أو Onboarding

## نصائح (Tips)

1. **استخدم Bottom Navigation** للتنقل السريع بين الصفحات الرئيسية
2. **استخدم AppBar Back Button** للرجوع من الصفحات الفرعية
3. **زر الرجوع في Home** يطلب تأكيد قبل الإغلاق (لحماية من الإغلاق بالخطأ)

## الملفات المهمة

- `lib/core/routing/app_router.dart` - تعريف جميع المسارات
- `lib/core/widgets/back_button_handler.dart` - معالجة زر الرجوع
- `lib/presentation/customer/screens/splash/splash_screen.dart` - التحقق من حالة تسجيل الدخول

