# Servy - Project Structure Documentation

## 📁 Folder Structure

```
servy/
├── lib/
│   ├── core/                           # Core infrastructure
│   │   ├── constants/
│   │   │   ├── app_constants.dart     # App-wide constants (API URLs, keys, etc.)
│   │   │   └── app_strings.dart       # Application strings
│   │   ├── theme/
│   │   │   └── app_theme.dart         # Theme configurations for all 3 apps
│   │   ├── utils/
│   │   │   ├── validators.dart        # Form validation utilities
│   │   │   └── logger.dart            # Logging utility
│   │   ├── localization/
│   │   │   ├── app_localization.dart  # Localization constants
│   │   │   └── l10n/
│   │   │       └── app_localizations.dart  # Localization implementation
│   │   └── routing/
│   │       └── app_router.dart        # go_router configuration
│   │
│   ├── data/                           # Data layer
│   │   ├── models/                     # Data models
│   │   │   ├── user_model.dart
│   │   │   ├── auth_response_model.dart
│   │   │   ├── restaurant_model.dart
│   │   │   └── category_model.dart
│   │   ├── repositories/               # Data repositories
│   │   │   ├── auth_repository.dart
│   │   │   ├── restaurant_repository.dart
│   │   │   └── category_repository.dart
│   │   └── services/                   # API services
│   │       ├── api_service.dart        # Real API service (Dio)
│   │       └── mock_api_service.dart   # Mock API for development
│   │
│   ├── logic/                          # Business logic layer
│   │   └── providers/                  # Riverpod providers
│   │       ├── auth_providers.dart
│   │       ├── restaurant_providers.dart
│   │       └── category_providers.dart
│   │
│   ├── presentation/                   # UI layer
│   │   ├── customer/                   # Customer app
│   │   │   ├── screens/
│   │   │   │   ├── splash/
│   │   │   │   │   └── splash_screen.dart
│   │   │   │   ├── onboarding/
│   │   │   │   │   └── onboarding_screen.dart
│   │   │   │   ├── auth/
│   │   │   │   │   ├── login_screen.dart
│   │   │   │   │   └── register_screen.dart
│   │   │   │   ├── home/
│   │   │   │   │   └── home_screen.dart
│   │   │   │   ├── orders/
│   │   │   │   │   └── orders_screen.dart
│   │   │   │   └── profile/
│   │   │   │       └── profile_screen.dart
│   │   │   └── widgets/
│   │   │       ├── common/
│   │   │       │   ├── custom_button.dart
│   │   │       │   └── custom_text_field.dart
│   │   │       └── home/
│   │   │           ├── category_item.dart
│   │   │           ├── restaurant_card.dart
│   │   │           └── search_bar_widget.dart
│   │   │
│   │   ├── driver/                     # Driver app
│   │   │   └── screens/
│   │   │       ├── splash/
│   │   │       │   └── driver_splash_screen.dart
│   │   │       ├── onboarding/
│   │   │       │   └── driver_onboarding_screen.dart
│   │   │       └── home/
│   │   │           └── driver_home_screen.dart
│   │   │
│   │   └── restaurant/                 # Restaurant app
│   │       └── screens/
│   │           ├── splash/
│   │           │   └── restaurant_splash_screen.dart
│   │           └── home/
│   │               └── restaurant_home_screen.dart
│   │
│   └── main.dart                       # App entry point
│
├── assets/
│   ├── images/                         # Image assets
│   ├── icons/                          # Icon assets
│   ├── animations/                     # Lottie animations
│   └── translations/                   # Localization files
│       ├── en.json
│       └── ar.json
│
├── pubspec.yaml                        # Dependencies configuration
├── README.md                           # Project documentation
└── PROJECT_STRUCTURE.md               # This file
```

## 🏗️ Architecture Explanation

### 1. Core Layer (`lib/core/`)
Contains shared infrastructure that all apps use:
- **Constants**: App-wide constants like API URLs, keys, durations
- **Theme**: Material 3 themes for each app (Customer, Driver, Restaurant)
- **Utils**: Reusable utilities like validators and logger
- **Localization**: Setup for Arabic and English
- **Routing**: Centralized routing configuration using go_router

### 2. Data Layer (`lib/data/`)
Handles all data operations:
- **Models**: Data models representing entities (User, Restaurant, Category, etc.)
- **Repositories**: Abstract data access layer that can switch between mock and real APIs
- **Services**: 
  - `ApiService`: Real API implementation using Dio
  - `MockApiService`: Mock API for development with dummy data

### 3. Logic Layer (`lib/logic/`)
Contains business logic and state management:
- **Providers**: Riverpod providers for state management
  - `auth_providers.dart`: Authentication state
  - `restaurant_providers.dart`: Restaurant data state
  - `category_providers.dart`: Category data state

### 4. Presentation Layer (`lib/presentation/`)
Contains all UI components organized by app:
- **Customer App**: Full-featured customer-facing app
- **Driver App**: Driver delivery app with drawer navigation
- **Restaurant App**: Restaurant management app with drawer navigation

Each app has:
- **Screens**: Full page widgets
- **Widgets**: Reusable UI components

## 🔄 Data Flow

1. **UI Layer** (Screens/Widgets) 
   ↓ calls
2. **Logic Layer** (Riverpod Providers)
   ↓ calls
3. **Data Layer** (Repositories)
   ↓ calls
4. **Services** (API Service or Mock Service)
   ↓ returns data
5. Back to UI through Riverpod state

## 🎨 Theme System

Each app has its own distinct theme defined in `app_theme.dart`:
- **Customer Theme**: Green (#00D9A5) - Modern, vibrant
- **Driver Theme**: Blue (#3B82F6) - Professional, reliable
- **Restaurant Theme**: Purple (#8B5CF6) - Business-oriented

## 🛣️ Routing

All routes are centralized in `app_router.dart`:
- Customer routes: `/onboarding`, `/login`, `/customer/home`, etc.
- Driver routes: `/driver/splash`, `/driver/login`, `/driver/home`, etc.
- Restaurant routes: `/restaurant/splash`, `/restaurant/login`, `/restaurant/home`, etc.

## 🔐 Mock Authentication

For development, use these credentials:
- **Customer**: customer@servy.com / 123456
- **Driver**: driver@servy.com / 123456
- **Restaurant**: restaurant@servy.com / 123456

## 📝 Next Steps

1. Replace `MockApiService` with real API calls in repositories
2. Uncomment token storage in `AuthNotifier`
3. Configure Firebase for notifications
4. Add Google Maps API key
5. Complete order management flows
6. Add payment integration
7. Implement real-time updates
8. Add more screens and features

## 🚀 Running the App

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run

# Run with specific flavor (when configured)
flutter run --flavor customer
flutter run --flavor driver
flutter run --flavor restaurant
```

---

**Note**: This structure allows easy separation of concerns and makes it simple to maintain and scale the application.



