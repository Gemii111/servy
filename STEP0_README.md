# Step 0: Project Bootstrap

## Overview

This step sets up the complete project structure following Clean Architecture principles with all required dependencies, folder structure, and a mock REST API server.

## What Was Implemented

1. **Updated Dependencies**: Added all required packages including Hive for local storage, Riverpod for state management, Dio for HTTP, go_router for navigation, and testing packages.

2. **Clean Architecture Structure**: Created folder structure:
   - `lib/core/` - Constants, utilities, theme
   - `lib/data/` - Models, repositories, datasources (API, local)
   - `lib/domain/` - Entities and repository interfaces
   - `lib/presentation/` - Pages and widgets
   - `lib/routes/` - Routing configuration

3. **Mock Server**: Created a Dart Shelf-based mock server with all required endpoints:
   - Authentication (login, register)
   - Restaurants (list, details, menu)
   - Addresses (list, create)
   - Orders (create, track)
   - Coupons (validate)

4. **Core Constants**: API endpoints, app constants, and utility classes.

## Files Created/Modified

### New Files:
- `mock_server/pubspec.yaml` - Mock server dependencies
- `mock_server/lib/server.dart` - Mock API server implementation
- `mock_server/README.md` - Mock server documentation
- `lib/core/constants/api_constants.dart` - API endpoint constants
- `lib/core/constants/app_constants.dart` - App-wide constants
- `lib/core/utils/logger.dart` - Logging utility

### Modified Files:
- `pubspec.yaml` - Updated with all required dependencies

## How to Run

### 1. Install Flutter Dependencies

```bash
flutter pub get
```

### 2. Start Mock Server

In a separate terminal:

```bash
cd mock_server
dart pub get
dart run lib/server.dart
```

The server will start on `http://localhost:8080`

### 3. Run the App

```bash
flutter run
```

## Testing Mock Server

Test the mock server endpoints:

```bash
# Test login
curl -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{"phone": "0501234567", "password": "password123"}'

# Test restaurants
curl http://localhost:8080/restaurants?lat=24.7136&lng=46.6753
```

## Firebase Setup (Placeholder)

Firebase setup will be configured in Step 10. For now:

1. Create a Firebase project at https://console.firebase.google.com
2. Add Android app with package name: `com.servy.fooddelivery`
3. Download `google-services.json` to `android/app/`
4. Add iOS app if needed and download `GoogleService-Info.plist` to `ios/Runner/`

## Project Structure

```
lib/
├── core/
│   ├── constants/       # API constants, app constants
│   ├── utils/          # Logger, validators, helpers
│   └── theme/          # App theme, colors, text styles
├── data/
│   ├── models/         # Data models (JSON serializable)
│   ├── repositories/   # Repository implementations
│   └── datasources/    # API client, local storage
├── domain/
│   ├── entities/       # Domain entities
│   └── repositories/   # Repository interfaces
├── presentation/
│   ├── pages/          # Screen widgets
│   └── widgets/        # Reusable widgets
├── routes/             # go_router configuration
└── main.dart           # App entry point
```

## Next Steps

After verifying Step 0 works:
1. Run unit tests for Step 0
2. Verify mock server is running
3. Proceed to Step 1 (Splash + Onboarding)

## Commit Message

```
feat: Step 0 - Project bootstrap with Clean Architecture

- Add all required dependencies (Riverpod, Dio, Hive, go_router, etc.)
- Create Clean Architecture folder structure
- Implement Dart Shelf mock server with all required endpoints
- Add core constants and utilities
- Setup project for incremental feature development
```

