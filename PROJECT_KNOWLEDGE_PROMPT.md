# Copyright Clinic Flutter - Project Knowledge Prompt

## Project Overview
This is a Flutter application called "Copyright Clinic Flutter" that follows Clean Architecture principles with a comprehensive setup for modern mobile development. The project is designed as a template/boilerplate with a complete feature structure, state management, networking, localization, and theming capabilities.

## Project Structure & Architecture

### Architecture Pattern
- **Clean Architecture** with clear separation of concerns
- **Feature-based folder structure** following Flutter best practices
- **Domain-Driven Design** with entities, repositories, and use cases
- **BLoC pattern** for state management using flutter_bloc and hydrated_bloc

### Folder Structure
```
lib/
├── config/           # App configuration, routes, and theme
├── core/            # Core utilities, network, storage, widgets
├── features/        # Feature-specific modules
├── shared_features/ # Shared functionality (localization, theme)
├── di.dart         # Dependency injection setup
├── app.dart        # Main app configuration
└── main.dart       # App entry point
```

## Dependencies & Technologies

### Core Dependencies
- **Flutter SDK**: ^3.7.2
- **State Management**: flutter_bloc ^9.1.1, hydrated_bloc ^10.0.0
- **Dependency Injection**: get_it ^7.6.7
- **Networking**: dio ^5.4.0, dio_cache_interceptor ^4.0.3
- **Navigation**: go_router ^13.2.2
- **Localization**: easy_localization ^3.0.7+1
- **Storage**: shared_preferences ^2.5.3, flutter_secure_storage ^9.2.4
- **Utilities**: logger ^2.5.0, equatable ^2.0.5, dartz ^0.10.1

### Development Dependencies
- **Code Generation**: build_runner ^2.4.8, json_serializable ^6.7.1
- **Linting**: flutter_lints ^5.0.0

## Core Architecture Components

### 1. Dependency Injection (di.dart)
- **GetIt** service locator for dependency management
- **Singleton registrations** for core services
- **Lazy initialization** for performance optimization
- **Service registration pattern** for network, storage, and business logic

### 2. Network Layer Architecture
- **ApiService**: High-level API abstraction with generic methods
- **DioService**: HTTP client wrapper with caching support
- **Interceptors**: 
  - ApiInterceptor: Authentication token management
  - RefreshTokenInterceptor: Token refresh handling
  - LoggingInterceptor: Request/response logging
- **Response Model**: Standardized API response structure with headers and body
- **Exception Handling**: Custom exception types with proper error categorization

### 3. Storage Architecture
- **Abstract StorageService**: Generic storage interface
- **SharedPrefService**: Local preferences storage with JSON encoding
- **FlutterSecureStorageService**: Secure storage for sensitive data
- **TokenStorage**: Specialized token management service

### 4. State Management
- **BLoC Pattern**: Event-driven state management
- **Hydrated BLoC**: Persistent state across app restarts
- **Cubit**: Simplified state management for simple features
- **Event/State Pattern**: Clear separation of user actions and UI states

## Feature Architecture Pattern

### Example Feature Structure (example_feature)
```
features/example_feature/
├── data/
│   ├── datasources/     # Data sources (remote, local)
│   ├── models/          # Data models with JSON serialization
│   └── repositories/    # Repository implementations
├── domain/
│   ├── entities/        # Business logic entities
│   ├── repositories/    # Repository interfaces
│   └── usecases/        # Business logic use cases
└── presentation/
    ├── bloc/            # State management
    ├── pages/           # UI screens
    └── widgets/         # Feature-specific widgets
```

### Data Flow
1. **UI Layer** → **BLoC** → **Use Case** → **Repository** → **Data Source**
2. **Repository Pattern**: Abstracts data sources and provides clean API
3. **Use Case Pattern**: Encapsulates business logic
4. **Entity Pattern**: Pure business objects without external dependencies

## Configuration & Theming

### App Configuration (config/app_config/config.dart)
- **Environment-based configuration** using String.fromEnvironment
- **Design system constants** for responsive design
- **Base URL configuration** for API endpoints

### Theme System (config/theme/app_theme.dart)
- **Comprehensive color palette** with light/dark variants
- **Custom gradient backgrounds** with opacity variations
- **Typography system** with consistent font families (Urbanist)
- **Component themes** for buttons, inputs, cards, etc.
- **Responsive design support** with breakpoint considerations

### Color System
- **Primary**: #6882F7 (Blue)
- **Text Colors**: #191919 (Primary), #404145 (Body), #4B5563 (Light)
- **Status Colors**: #32BA78 (Green), #FF9800 (Orange), #EB5756 (Red)
- **Background Colors**: #F4F7F9 (Light), #16181D (Dark)
- **Custom Gradients**: Multiple opacity levels for background effects

## Localization System

### Supported Languages
- **English (en-US)**: Primary language
- **Arabic (ar-SA)**: Secondary language with RTL support

### Localization Structure
- **easy_localization** package for internationalization
- **JSON-based translation files** in assets/translations/
- **Dynamic locale switching** with persistent state
- **TranslatedText widget** for easy text localization

### Translation Keys
- **App strings**: appName, welcomeToX, etc.
- **Form validation**: emailIsRequired, passwordIsRequired, etc.
- **UI elements**: settings, language, theme options

## Routing & Navigation

### Navigation System
- **go_router** for declarative routing
- **Route definitions** in app_routes.dart
- **BLoC integration** with route-level state management
- **Deep linking support** with proper route naming

### Current Routes
- **Root route ('/')**: Main items page with BLoC provider

## Utility Systems

### Responsive Design (core/utils/ui/responsive.dart)
- **Design system scaling** based on screen dimensions
- **Width/Height scaling** with design reference points
- **Font size scaling** with diagonal-based calculations
- **Extension methods** for easy responsive usage

### Validation System (core/utils/mixin/validator.dart)
- **Email validation** with regex patterns
- **Password validation** with length requirements
- **Name validation** with minimum character requirements
- **Phone validation** with format checking

### Logging System (core/utils/logger/logger.dart)
- **Custom logger implementation** with PrettyPrinter
- **Multiple log levels** (info, debug, error, warning, fatal)
- **Class-aware logging** with runtime type information
- **Structured logging** for debugging and monitoring

## Error Handling

### Failure System (core/error/failures.dart)
- **Abstract Failure class** extending Equatable
- **ServerFailure**: Network and API errors
- **CacheFailure**: Local storage errors
- **Stack trace support** for debugging

### Exception Handling
- **CustomException**: Comprehensive error categorization
- **DioException mapping**: HTTP error handling
- **Parsing exception handling**: JSON serialization errors
- **Network connectivity**: Socket exception handling

## Development Patterns

### Code Organization
- **Feature-first architecture** with clear boundaries
- **Separation of concerns** between data, domain, and presentation
- **Interface segregation** with abstract classes
- **Dependency inversion** through dependency injection

### Testing Considerations
- **Testable architecture** with dependency injection
- **Mockable services** through interfaces
- **BLoC testing** support with proper event/state handling
- **Repository testing** with abstract implementations

### Performance Optimizations
- **Lazy loading** of dependencies
- **Caching strategies** with dio_cache_interceptor
- **Efficient state management** with BLoC
- **Memory management** with proper disposal patterns

## Current Implementation Status

### Completed Features
- **Project structure** and architecture setup
- **Core utilities** and helper classes
- **Network layer** with comprehensive error handling
- **Storage systems** for local and secure data
- **Theme system** with light/dark variants
- **Localization system** with English/Arabic support
- **Example feature** demonstrating the architecture
- **Dependency injection** setup
- **Routing system** with go_router

### Example Feature Implementation
- **Item management** with CRUD operations
- **BLoC state management** with loading, success, and error states
- **Repository pattern** with remote data source
- **JSON serialization** with code generation
- **API integration** using the core network layer

## Development Guidelines

### Adding New Features
1. **Follow the feature structure** in features/ directory
2. **Implement domain layer first** (entities, repositories, use cases)
3. **Add data layer** (models, data sources, repository implementations)
4. **Create presentation layer** (BLoC, pages, widgets)
5. **Register dependencies** in di.dart
6. **Add routes** in app_routes.dart and app_router.dart

### State Management
1. **Use BLoC for complex state** with multiple events
2. **Use Cubit for simple state** without events
3. **Implement proper error handling** in BLoC
4. **Use HydratedBloc** for persistent state when needed

### Network Layer Usage
1. **Use ApiService methods** for HTTP operations
2. **Implement proper error handling** with CustomException
3. **Use caching strategies** when appropriate
4. **Handle authentication** through interceptors

### Theming Guidelines
1. **Use AppTheme constants** for colors and spacing
2. **Follow the design system** for consistency
3. **Use theme extensions** for easy access to theme data
4. **Implement responsive design** using responsive extensions

## Configuration & Environment

### Environment Variables
- **BASE_URL**: API base URL (defaults to https://api.example.com)
- **Design dimensions**: 375x812 (iPhone X reference)

### Build Configuration
- **Flutter SDK**: 3.7.2+
- **Platforms**: Android, iOS, Web, macOS, Linux, Windows
- **Fonts**: Urbanist family with all weight variants
- **Assets**: Localization files and font files

## Future Considerations

### Scalability
- **Feature modules** can be easily added following the pattern
- **Shared utilities** are centralized for reuse
- **Dependency injection** supports complex service graphs
- **State management** scales with BLoC pattern

### Maintenance
- **Clear separation of concerns** makes debugging easier
- **Interface-based design** allows for easy mocking in tests
- **Standardized error handling** provides consistent user experience
- **Comprehensive logging** aids in production debugging

### Extensibility
- **New platforms** can be added with minimal changes
- **Additional features** follow the established pattern
- **Third-party integrations** can be added through the service layer
- **Custom widgets** can extend the existing design system

This project serves as a robust foundation for building scalable Flutter applications with modern architecture patterns, comprehensive error handling, and a well-structured codebase that follows Flutter and Dart best practices.
