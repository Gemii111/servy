# Location Picker Setup Guide

## ✅ ما تم إنجازه

تم إضافة Location Picker كامل مع:
- ✅ LocationService - خدمة للحصول على الموقع الحالي
- ✅ LocationPickerScreen - شاشة Google Maps لاختيار الموقع
- ✅ Integration في Add Address Screen
- ✅ Integration في Edit Address Screen
- ✅ Integration في Location Display Widget (Home Screen)

## 📁 الملفات المضافة

1. **`lib/core/services/location_service.dart`**
   - `getCurrentPosition()` - الحصول على الموقع الحالي
   - `getAddressFromCoordinates()` - تحويل الإحداثيات إلى عنوان
   - `getCoordinatesFromAddress()` - تحويل العنوان إلى إحداثيات
   - Permission handling

2. **`lib/presentation/customer/screens/location_picker/location_picker_screen.dart`**
   - شاشة Google Maps كاملة
   - اختيار الموقع من الخريطة
   - سحب Marker لتغيير الموقع
   - عرض العنوان الحالي
   - زر "Use Current Location"

## 🔧 الإعدادات المطلوبة

### 1. Google Maps API Key

1. اذهب إلى [Google Cloud Console](https://console.cloud.google.com/)
2. أنشئ مشروع جديد أو استخدم مشروع موجود
3. فعّل **Maps SDK for Android** و **Maps SDK for iOS**
4. أنشئ API Key
5. افتح `android/app/src/main/AndroidManifest.xml`
6. استبدل `YOUR_GOOGLE_MAPS_API_KEY` بـ API Key الخاص بك:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_ACTUAL_API_KEY_HERE" />
```

### 2. iOS Setup (إذا كنت تستخدم iOS)

افتح `ios/Runner/AppDelegate.swift` وأضف:

```swift
import GoogleMaps

// في application:didFinishLaunchingWithOptions:
GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY")
```

### 3. Permissions

تم إضافة Permissions في `AndroidManifest.xml`:
- `ACCESS_FINE_LOCATION`
- `ACCESS_COARSE_LOCATION`

## 🎯 كيفية الاستخدام

### في Add Address Screen:
1. اضغط "Use Current Location" - يحصل على موقعك الحالي تلقائياً
2. أو اضغط "Select Location" - يفتح Google Maps لاختيار الموقع

### في Edit Address Screen:
1. نفس الخيارات المتاحة
2. يمكن تحديث الموقع

### في Home Screen:
1. اضغط على Location Display Widget
2. يفتح Location Picker
3. اختر موقع جديد
4. يتم حفظه تلقائياً

## 📋 Features

- ✅ الحصول على الموقع الحالي
- ✅ اختيار الموقع من الخريطة
- ✅ سحب Marker لتغيير الموقع
- ✅ عرض العنوان الحالي
- ✅ Geocoding (تحويل الإحداثيات إلى عنوان)
- ✅ Reverse Geocoding (تحويل العنوان إلى إحداثيات)
- ✅ Permission handling
- ✅ Error handling

## ⚠️ ملاحظات

- يجب إضافة Google Maps API Key قبل الاستخدام
- يحتاج إلى اتصال بالإنترنت للعمل
- يحتاج إلى Location Permissions

## 🚀 الخطوات التالية

- [ ] إضافة Google Maps API Key
- [ ] اختبار على Android Device
- [ ] اختبار على iOS Device (إذا لزم الأمر)

---

**Location Picker جاهز للاستخدام!** ✅

