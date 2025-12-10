# Localization Guide - دليل الترجمة

## ✅ ما تم إنجازه

تم إنشاء نظام Localization كامل يدعم:
- ✅ اللغة العربية (RTL)
- ✅ اللغة الإنجليزية (LTR)
- ✅ جميع النصوص الأساسية مترجمة

## 📁 الملفات المضافة

1. **`lib/core/localization/app_localizations.dart`**
   - يحتوي على جميع النصوص مترجمة
   - يدعم العربية والإنجليزية
   - يحتوي على أكثر من 100+ نص مترجم

2. **`lib/core/localization/app_localizations_delegate.dart`**
   - Delegate للـ Localization
   - يدعم Arabic و English

## 🔧 كيفية الاستخدام

### في أي Widget:

```dart
import 'package:servy/core/localization/app_localizations.dart';

// استخدام مباشر
Text(context.l10n.home)

// أو
final l10n = AppLocalizations.of(context)!;
Text(l10n.home)
```

### مثال:

```dart
// قبل:
Text('Home')

// بعد:
Text(context.l10n.home)
```

## 📋 النصوص المتاحة

### Common:
- `appName`, `loading`, `cancel`, `save`, `delete`, `edit`, `done`, `retry`, `ok`

### Auth:
- `login`, `register`, `logout`, `email`, `password`, `welcomeBack`, `signInToContinue`

### Navigation:
- `home`, `orders`, `profile`, `cart`, `menu`, `settings`

### Home:
- `helloGuest`, `helloUser(name)`, `whatWouldYouLikeToOrder`, `categories`, `featuredRestaurants`

### Cart & Checkout:
- `yourCart`, `cartIsEmpty`, `checkout`, `deliveryAddress`, `paymentMethod`, `orderSummary`, `placeOrder`

### Orders:
- `myOrders`, `orderConfirmed`, `trackOrder`, `orderDetails`

### Profile & Settings:
- `editProfile`, `addresses`, `paymentMethods`, `language`, `settings`

## 🔄 تغيير اللغة

اللغة تتغير تلقائياً من Settings → Language → Select Language

## 📝 ملاحظات

- جميع النصوص في `app_localizations.dart` قابلة للتوسع
- يمكن إضافة المزيد من النصوص بسهولة
- RTL يدعم تلقائياً عند اختيار العربية

## ⚠️ TODO

- تحديث جميع الشاشات لاستخدام localization (حالياً فقط Home Screen محدث)
- يمكن تحديث الشاشات الأخرى بنفس الطريقة

