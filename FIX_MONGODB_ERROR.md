# Fix MongoDB Connection Error

## Problem
The app is showing MongoDB connection errors when running on the tablet. This is because there's an old version of the app installed that has MongoDB code.

## Solution

### Step 1: Uninstall the Old App
On your tablet, uninstall the old app:
1. Go to Settings > Apps
2. Find the app (it might be named "servy" or have a different name)
3. Tap on it and select "Uninstall"

### Step 2: Clean Build
Run these commands in your terminal:

```bash
# Clean the Flutter build
flutter clean

# Remove old build artifacts
flutter pub get

# Uninstall from connected device (if device is connected)
flutter uninstall
```

### Step 3: Reinstall Fresh App
```bash
# Install the fresh app
flutter run --debug
```

## Alternative: Change Package Name
If you can't uninstall the old app, you can change the package name to avoid conflicts:

1. Edit `android/app/build.gradle.kts`:
   - Change `applicationId = "com.example.servy"` to `applicationId = "com.example.servy_food"`

2. Edit `android/app/src/main/AndroidManifest.xml` if needed

3. Clean and rebuild:
```bash
flutter clean
flutter pub get
flutter run --debug
```

## Why This Happened
The error occurs because:
- An old version of the app is still installed on your tablet
- That old app has MongoDB connection code that tries to connect to `192.168.1.90:27017`
- Our new food delivery app doesn't have any MongoDB code
- Flutter might be running the old app instead of the new one

## Verification
After reinstalling, you should see:
- ✅ The splash screen appears
- ✅ No MongoDB connection errors
- ✅ The app navigates to onboarding/login
- ✅ Only errors you might see are network-related (which is normal since we're using mock APIs)


