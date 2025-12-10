# 📱 Splash Screen & Registration Flow

## كيف يعمل Splash Screen؟

### 1. **Splash Screen** (`/splash`)
عند فتح التطبيق لأول مرة، يتم عرض Splash Screen الذي يعرض:
- **Logo/Icon** - أيقونة التطبيق مع Animation
- **App Name** - اسم التطبيق "Servy"
- **Tagline** - "Food Delivery Platform"

#### المنطق (Logic):
```dart
1. انتظر 2 ثانية (splash duration)
2. افحص حالة المستخدم:
   - إذا كان مسجل دخول ✅ → اذهب إلى Home حسب نوعه (Customer/Driver/Restaurant)
   - إذا لم يكن مسجل دخول ولكن Onboarding مكتمل → اذهب إلى User Type Selection
   - إذا لم يكن Onboarding مكتمل → اذهب إلى Onboarding Screen
```

---

## 🎯 Flow كامل للتسجيل

### Scenario 1: أول مرة يفتح التطبيق
```
Splash Screen → Onboarding Screen → User Type Selection → Register Screen → Home
```

### Scenario 2: المستخدم أكمل Onboarding لكن مش مسجل دخول
```
Splash Screen → User Type Selection → Register/Login → Home
```

### Scenario 3: المستخدم مسجل دخول
```
Splash Screen → Home (حسب نوع المستخدم)
```

---

## 📝 شاشات اختيار نوع المستخدم

### 1. **User Type Selection Screen** (`/user-type-selection`)
عند التسجيل، تظهر شاشة اختيار نوع المستخدم:

#### الخيارات المتاحة:
- 🛒 **Customer** - "Order food from restaurants" (اطلب أكلك من المطاعم)
- 🚗 **Driver** - "Deliver orders and earn money" (وصل الطلبات واكسب فلوس)
- 🏪 **Restaurant** - "Manage your restaurant orders" (ادار طلبات مطعمك)

#### عند الضغط على أي خيار:
- يتم الانتقال إلى `/register?type=customer` أو `driver` أو `restaurant`
- يتم تمرير نوع المستخدم في الـ URL parameter

---

### 2. **User Type Login Screen** (`/user-type-login`)
عند تسجيل الدخول، نفس الشاشة لكن للـ Login:

#### الخيارات:
- 🛒 Customer
- 🚗 Driver  
- 🏪 Restaurant

#### عند الضغط:
- يتم الانتقال إلى `/login?type=customer` أو `driver` أو `restaurant`

---

## 🔐 Register Screen

### كيف يحدد نوع المستخدم؟

#### Method 1: من User Type Selection
```dart
// من User Type Selection Screen
context.push('/register?type=customer');
// أو
context.push('/register?type=driver');
// أو
context.push('/register?type=restaurant');
```

#### Method 2: مباشرة من URL
```dart
// يمكن الوصول مباشرة
/register?type=customer
/register?type=driver
/register?type=restaurant
```

### الكود في Register Screen:
```dart
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key, this.userType = 'customer'});
  
  final String userType; // يتم تمريره من URL parameter
  // ...
}
```

### بعد التسجيل الناجح:
```dart
switch (widget.userType) {
  case 'customer':
    context.go('/customer/home');
    break;
  case 'driver':
    context.go('/driver/home');
    break;
  case 'restaurant':
    context.go('/restaurant/home');
    break;
}
```

---

## 🎨 المميزات

### ✨ Animations
- جميع الشاشات تستخدم `flutter_animate`
- Smooth transitions بين العناصر
- Scale & Fade animations

### 🌍 Localization
- جميع النصوص مترجمة (عربي/إنجليزي)
- استخدام `context.l10n` للوصول للنصوص

### 🎨 Dark Theme
- جميع الشاشات تستخدم Dark Theme
- ألوان متناسقة مع `AppColors`

### 📱 Responsive
- يتكيف مع أحجام الشاشات المختلفة

---

## 📋 النصوص المضافة (Localization)

```dart
String get welcomeToApp => 'Welcome to Servy' / 'أهلاً بك في سيرفي';
String get selectUserType => 'Select User Type' / 'اختار نوع المستخدم';
String get customer => 'Customer' / 'عميل';
String get driver => 'Driver' / 'سائق';
String get restaurant => 'Restaurant' / 'مطعم';
String get customerDescription => 'Order food from restaurants' / 'اطلب أكلك من المطاعم';
String get driverDescription => 'Deliver orders and earn money' / 'وصل الطلبات واكسب فلوس';
String get restaurantDescription => 'Manage your restaurant orders' / 'ادار طلبات مطعمك';
```

---

## 🔄 Flow Diagram

```
┌─────────────┐
│   Splash    │
└──────┬──────┘
       │
       ├─ Logged In? ──YES─→ Home (حسب النوع)
       │
       └─ NO
          │
          ├─ Onboarding Done? ──YES─→ User Type Selection
          │
          └─ NO ──→ Onboarding ──→ User Type Selection
                              │
                              ├─ Customer → Register (Customer) → Customer Home
                              ├─ Driver → Register (Driver) → Driver Home
                              └─ Restaurant → Register (Restaurant) → Restaurant Home
```

---

## ✅ الخلاصة

1. **Splash Screen** يفحص حالة المستخدم ويوجهه للشاشة المناسبة
2. **User Type Selection** تظهر بعد Onboarding لتختار نوع المستخدم
3. **Register Screen** يستقبل نوع المستخدم من URL parameter
4. بعد التسجيل، يتم التوجيه للـ Home المناسب حسب نوع المستخدم

---

**تم! الآن المستخدم يمكنه اختيار نوعه بسهولة! 🎉**

