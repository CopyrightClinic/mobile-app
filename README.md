# Copyright Clinic

A comprehensive Flutter application connecting creative professionals with expert copyright attorneys for legal consultations and copyright protection services.

## Description

Copyright Clinic is a mobile platform designed for creators, artists, musicians, writers, and other creative professionals who need expert guidance on copyright law. The app features AI-powered initial consultations through "Harold AI," direct video consultations with licensed attorneys via Zoom, session management, payment processing, and professionally reviewed session summaries.

## Features

### Authentication & User Management
- **Email-based Authentication**: Secure signup and login with email verification
- **Password Management**: Reset and change password functionality with OTP verification
- **Profile Management**: Complete user profiles with personal information, contact details, and address
- **Account Management**: Profile editing, password changes, and account deletion

### Harold AI - Initial Consultation
- **AI-Powered Evaluation**: Describe copyright issues and receive instant AI-based assessment
- **Speech-to-Text Input**: Voice input support for describing copyright concerns
- **Qualification Assessment**: Determines if your issue qualifies for attorney consultation
- **Scope Filtering**: Identifies matters within Copyright Clinic's expertise

### Session Management
- **Book Consultations**: Schedule 30-minute sessions with available attorneys
- **Time Slot Selection**: Choose from available time slots across multiple days
- **Session Types**: Support for various copyright areas (Music Licensing, Visual Artists Rights, Video & Media, AI Content, Writing)
- **Session Timeline**: View upcoming and completed sessions
- **Session Extensions**: Extend active sessions by 30 minutes with additional payment
- **Session Cancellation**: Cancel sessions before the cancellation deadline with refund
- **Join Video Calls**: Seamless Zoom integration for video consultations

### Payment Processing
- **Stripe Integration**: Secure payment processing with PCI compliance
- **Payment Methods**: Add, view, and manage multiple payment cards
- **Hold Authorization**: $100 hold during booking, charged after session completion
- **Session Summaries**: Purchase professionally reviewed summaries ($25)
- **Processing Fees**: Transparent non-refundable processing fees ($5)

### Video Consultations
- **Zoom SDK Integration**: Native Zoom support for iOS and Android (see [Zoom SDK Integration Guide](ZOOM_SDK_INTEGRATION.md))
- **Permission Management**: Camera, microphone, and Bluetooth permissions handling
- **Meeting Status**: Real-time connection status and waiting room support
- **In-Meeting Controls**: Join, leave, and manage video call settings

### Session Summaries
- **AI-Generated Summaries**: Professionally reviewed written summaries of consultations
- **PDF Export**: Download summaries as formatted PDF documents
- **Attorney Approval**: All summaries reviewed and approved by consulting attorney
- **Time-Limited Requests**: 15-day window to request session summaries

### Notifications
- **Push Notifications**: Firebase Cloud Messaging for real-time updates
- **Local Notifications**: Scheduled reminders for upcoming sessions
- **Notification History**: View all past notifications with read/unread status
- **Mark as Read**: Individual and bulk mark as read functionality
- **Clear Notifications**: Remove all notifications with confirmation

### User Experience
- **Modern UI**: Clean, intuitive interface with custom Urbanist typography
- **Dark/Light Themes**: Support for both light and dark color schemes
- **Localization**: Multi-language support (English as primary)
- **Responsive Design**: Adaptive layouts for various screen sizes
- **Loading States**: Shimmer effects and skeleton screens
- **Error Handling**: User-friendly error messages with retry options
- **Form Validation**: Real-time input validation with helpful error messages

## Directory Structure

```
lib/
├── app.dart                          # Main app configuration and initialization
├── main.dart                         # App entry point
├── di.dart                          # Dependency injection setup (GetIt)
│
├── config/                          # App-wide configuration
│   ├── app_config/                  # Environment and design system config
│   ├── routes/                      # Route definitions and navigation
│   └── theme/                       # App theme configuration
│
├── core/                            # Core functionality and utilities
│   ├── constants/                   # App constants (API endpoints, strings, etc.)
│   ├── error/                       # Error handling and failure classes
│   ├── network/                     # Network layer (Dio, interceptors, API service)
│   ├── services/                    # Core services (storage, logging, etc.)
│   ├── usecases/                    # Base use case classes
│   ├── utils/                       # Utility functions and helpers
│   └── widgets/                     # Reusable UI components
│
├── features/                        # Feature modules (Clean Architecture)
│   ├── auth/                        # Authentication (login, signup, verification)
│   ├── dashboard/                   # Main dashboard and navigation
│   ├── harold_ai/                   # AI-powered copyright evaluation
│   ├── notifications/               # Push and local notifications
│   ├── onboarding/                  # Welcome and onboarding screens
│   ├── payments/                    # Payment methods and Stripe integration
│   ├── profile/                     # User profile management
│   ├── sessions/                    # Session booking and management
│   ├── speech_to_text/              # Voice input functionality
│   └── zoom/                        # Zoom video call integration
│
└── shared_features/                 # Shared cross-feature functionality
    ├── localization/                # Localization setup and utilities
    └── theme/                       # Theme management and switching

assets/
├── fonts/                           # Urbanist font family (all weights)
├── images/
│   ├── png/                        # Raster images and illustrations
│   └── svg/                        # Vector graphics and icons
└── translations/                    # Localization JSON files (en-US.json)
```

### Feature Module Structure

Each feature follows Clean Architecture with three layers:

```
features/example_feature/
├── data/
│   ├── datasources/                # Remote and local data sources
│   ├── models/                     # Data models with JSON serialization
│   └── repositories/               # Repository implementations
├── domain/
│   ├── entities/                   # Business logic entities
│   ├── repositories/               # Repository interfaces
│   └── usecases/                   # Business logic use cases
└── presentation/
    ├── bloc/                       # State management (BLoC/Cubit)
    ├── pages/                      # UI screens
    └── widgets/                    # Feature-specific widgets
```

## Dependencies

### State Management & Architecture
- **flutter_bloc** (^9.1.1) - BLoC pattern for state management
- **hydrated_bloc** (^10.0.0) - Persistent state across app restarts
- **bloc_concurrency** (^0.3.0) - Concurrent event handling in BLoCs
- **get_it** (^7.6.7) - Dependency injection service locator
- **dartz** (^0.10.1) - Functional programming (Either, Option)
- **equatable** (^2.0.5) - Value equality for entities and states

### Networking & API
- **dio** (^5.4.0) - HTTP client for API requests
- **dio_cache_interceptor** (^4.0.3) - Network response caching

### Local Storage
- **shared_preferences** (^2.5.3) - Key-value storage
- **flutter_secure_storage** (^9.2.4) - Encrypted storage for sensitive data
- **path_provider** (^2.1.5) - Access to common file system locations

### UI & Design
- **flutter_svg** (^2.1.0) - SVG rendering
- **cached_network_image** (^3.4.1) - Network image loading and caching
- **shimmer** (^3.0.0) - Shimmer loading effects
- **pin_code_fields** (^8.0.1) - OTP input fields
- **intl_phone_number_input** (^0.7.4) - International phone number input

### Navigation & Routing
- **go_router** (^13.2.2) - Declarative routing and navigation

### Localization
- **easy_localization** (^3.0.7+1) - Internationalization and localization
- **intl** (^0.20.2) - Internationalization utilities

### Payment Processing
- **flutter_stripe** (^11.5.0) - Stripe payment integration

### Firebase & Notifications
- **firebase_core** (^3.6.0) - Firebase core functionality
- **firebase_messaging** (^15.1.3) - Push notifications
- **flutter_local_notifications** (^18.0.1) - Local notifications

### Speech Recognition
- **manual_speech_to_text** (^1.0.4) - Speech-to-text functionality
- **permission_handler** (^11.3.1) - Runtime permissions management

### PDF Generation
- **pdf** (^3.11.1) - PDF document creation
- **printing** (^5.13.2) - PDF printing and sharing

### Utilities
- **logger** (^2.5.0) - Logging and debugging
- **device_preview** (^1.2.0) - Device preview for testing
- **flutter_dotenv** (^5.2.1) - Environment variable management

### Development Dependencies
- **build_runner** (^2.4.8) - Code generation
- **json_serializable** (^6.7.1) - JSON serialization code generation
- **flutter_lints** (^5.0.0) - Dart linting rules

For a complete list, see `pubspec.yaml`.

## Assets

### Fonts
- **Urbanist**: Complete font family with 9 weights (100-900)
  - Thin (100), ExtraLight (200), Light (300), Regular (400), Medium (500)
  - SemiBold (600), Bold (700), ExtraBold (800), Black (900)
  - Includes italic variants for each weight

### Images
- **SVG Icons**: Located in `assets/images/svg/` (35 vector graphics)
- **PNG Images**: Located in `assets/images/png/` (19 raster images)
- **Client Images**: Located in `assets/images/png/clients/`

### Translations
- **English (en-US)**: Primary language file in `assets/translations/en-US.json`
- Contains 450+ localized strings for all app features

### Environment Variables
- **.env**: Environment configuration file (not committed to version control)

## Getting Started

### Prerequisites

- **Flutter SDK**: 3.7.2 or higher
- **Dart SDK**: Included with Flutter
- **IDE**: Android Studio, VS Code, or IntelliJ IDEA
- **iOS Development** (macOS only):
  - Xcode 14.0 or higher
  - CocoaPods installed
- **Android Development**:
  - Android Studio
  - Android SDK (API level 21 or higher)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd copyright-clinic-flutter
   ```

2. **Install Flutter dependencies**
   ```bash
   flutter pub get
   ```

3. **Install iOS dependencies** (macOS only)
   ```bash
   cd ios
   pod install
   cd ..
   ```

4. **Set up environment variables**
   
   Create a `.env` file in the project root:
   ```env
   BASE_URL=https://api.example.com
   STRIPE_PUBLISHABLE_KEY=your_stripe_publishable_key
   ```

5. **Configure Firebase**
   
   - Place `google-services.json` in `android/app/`
   - Place `GoogleService-Info.plist` in `ios/Runner/`

6. **Set up Zoom SDK (iOS only - REQUIRED)**
   
   The iOS Zoom SDK files are **NOT included in the repository** due to large file sizes.
   
   **You must manually download and install them**:
   
   - Download Zoom iOS SDK v6.6.0 from [Zoom's website](https://developers.zoom.us/docs/meeting-sdk/ios/get-started/install/)
   - Create directory: `mkdir -p ios/ZoomSDK`
   - Copy these frameworks to `ios/ZoomSDK/`:
     - `MobileRTC.xcframework`
     - `MobileRTCResources.bundle`
     - `MobileRTCScreenShare.xcframework`
     - `zoomcml.xcframework`
   - Open `ios/Runner.xcworkspace` in Xcode
   - Link all frameworks with "Embed & Sign" option
   
   **See the [Zoom SDK Integration Guide](ZOOM_SDK_INTEGRATION.md) for complete setup instructions.**

7. **Run code generation** (for JSON serialization)
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

### Running the App

**Run on a connected device or emulator:**
```bash
flutter run
```

**Run in release mode:**
```bash
flutter run --release
```

**Run with a specific flavor/environment:**
```bash
flutter run --dart-define=BASE_URL=https://staging-api.example.com
```

**Run with device preview** (for testing multiple screen sizes):
```bash
flutter run --dart-define=DEVICE_PREVIEW=true
```

### Platform-Specific Notes

#### iOS
- Minimum iOS version: 13.0
- Ensure you have valid provisioning profiles for signing
- Camera and microphone permissions required for Zoom integration
- Speech recognition requires iOS dictation to be enabled

#### Android
- Minimum SDK: 21 (Android 5.0 Lollipop)
- Target SDK: 34 (Android 14)
- Ensure `google-services.json` is properly configured
- Camera and microphone permissions required for video calls

## Building for Release

### Android

1. **Configure signing**
   
   Create `android/key.properties`:
   ```properties
   storePassword=<store-password>
   keyPassword=<key-password>
   keyAlias=<key-alias>
   storeFile=<path-to-keystore>
   ```

2. **Build APK**
   ```bash
   flutter build apk --release
   ```

3. **Build App Bundle** (recommended for Play Store)
   ```bash
   flutter build appbundle --release
   ```

Output: `build/app/outputs/bundle/release/app-release.aab`

### iOS

1. **Configure signing in Xcode**
   - Open `ios/Runner.xcworkspace` in Xcode
   - Select the Runner target
   - Configure signing with your Apple Developer account

2. **Build for release**
   ```bash
   flutter build ipa --release
   ```

3. **Upload to App Store**
   - Use Xcode Organizer or Transporter app
   - Or use `flutter build ipa` and upload via Application Loader

Output: `build/ios/ipa/copyright_clinic_flutter.ipa`

### Build Optimizations

**Reduce app size:**
```bash
flutter build apk --release --split-per-abi
```

**Obfuscate code:**
```bash
flutter build apk --obfuscate --split-debug-info=/<project-name>/<directory>
```

## Contributing

We welcome contributions to Copyright Clinic! Here's how you can help:

### Getting Started
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Code Style Guidelines
- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) style guide
- **No comments in code** - write self-documenting code with clear names
- Use `flutter format` to format code before committing
- Ensure all linter rules pass (`flutter analyze`)

### Localization
- All user-facing strings MUST be localized
- Never hardcode strings in widgets
- Add new strings to `assets/translations/en-US.json`
- Update `AppStrings` constants when adding new content

### Feature Development
1. Follow Clean Architecture pattern
2. Implement domain layer first (entities, repositories, use cases)
3. Add data layer (models, data sources, repository implementations)
4. Create presentation layer (BLoC, pages, widgets)
5. Register dependencies in `di.dart`
6. Add routes in route configuration

### Testing
- Write unit tests for business logic (use cases, repositories)
- Write widget tests for UI components
- Ensure BLoC events and states are properly tested
- Run tests: `flutter test`

### Pull Request Process
1. Ensure your code follows the style guidelines
2. Update documentation if needed
3. Add tests for new features
4. Ensure all tests pass
5. Request review from maintainers

## License

This project is proprietary software. All rights reserved.

For licensing inquiries, please contact [your-email@example.com](mailto:your-email@example.com).

---

## Additional Resources

### Documentation
- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Documentation](https://dart.dev/guides)
- [BLoC Library](https://bloclibrary.dev/)
- [GoRouter Documentation](https://pub.dev/packages/go_router)

### Project-Specific Documentation
- [Zoom SDK Integration Guide](ZOOM_SDK_INTEGRATION.md) - Complete guide for setting up Zoom video calls
- [Project Architecture](PROJECT_KNOWLEDGE_PROMPT.md) - Detailed architecture documentation
- Check `docs/` folder for additional documentation

### Support
For questions or support, please contact:
- Email: support@copyrightclinic.com
- Website: https://copyrightclinic.com

---

**Built with ❤️ using Flutter**
