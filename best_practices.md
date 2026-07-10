# Flutter Code Standards and Best Practices

All Flutter pull requests must follow these standards to ensure modern, production-safe, crash-free, maintainable, scalable, and reusable Flutter code.

Compliance reviews use `pr_compliance_checklist.yaml` as the primary section structure. Each applicable section is evaluated in **strict compliance mode**: every deviation from these standards must be reported as a violation with actionable fixes.

---

## 1. Proper Title and Description

- Title should be self-explanatory.
- Description must include what changed, why it changed, how it changed, UI evidence if applicable, and testing notes.

---

## 2. Single Responsibility

- One feature, bug fix, or improvement per PR.
- Avoid unrelated file changes.
- Avoid combining formatting-only changes with feature work.
- Avoid changing multiple independent flows in one PR unless clearly justified.

---

## 3. Clean and Scalable Architecture

Analyze the project scope, existing code structure, and architecture before reviewing the PR. The PR should not break or bypass the existing architecture.

### Requirements

- Follow the architecture already used in the project.
- Prefer clean, scalable architecture patterns such as:
  - MVVM
  - Clean Architecture
  - MVC
  - MVP
  - Singleton where appropriate
  - MVI where appropriate
- Keep UI, state management, business logic, data sources, models, repositories, services, and utilities properly separated.
- Do not introduce direct dependencies that make features tightly coupled.
- Do not bypass existing managers, services, repositories, blocs, controllers, notifiers, or view models.
- Keep feature boundaries clear and maintainable.
- Avoid placing business logic directly inside widgets or build methods.
- Avoid adding files to random/common folders when they belong to a feature or layer.
- New code should match the existing project style, folder structure, dependency flow, and naming conventions.

---

## 4. Production-Safe and Crash-Free Code

- Avoid unsafe force unwraps using `!`.
- Avoid unsafe casts using `as` unless fully guaranteed.
- Use null-safe handling.
- Guard against empty lists, missing values, invalid indexes, and invalid states.
- Avoid assumptions about API data, navigation arguments, local storage values, or remote config values.
- Handle lifecycle edge cases safely.
- Use `mounted` checks after async operations before using `context` in StatefulWidget.
- Dispose controllers, focus nodes, streams, listeners, and animation controllers properly.

---

## 5. Managers and Services

Properly use managers and services to manage separate dependent code and reusable application operations.

### Requirements

- Use dedicated manager/service classes for reusable dependencies and system operations, such as:
  - `SharedPrefManager`
  - `ApiManager`
  - `DatabaseManager`
  - `CacheManager`
  - `NotificationManager`
  - `PermissionManager`
  - `LocationManager`
  - `FileManager`
- Do not duplicate API, database, shared preferences, cache, permission, or storage logic inside widgets.
- Do not call low-level platform/storage/network APIs directly from UI if a manager/service already exists.
- Keep managers/services focused and reusable.
- Avoid creating God classes that manage unrelated responsibilities.
- Inject or access managers consistently according to the project architecture.
- Reuse existing managers/services instead of creating duplicate implementations.

---

## 6. Graceful Error Handling

- Use try/catch around risky operations.
- Show user-friendly error messages.
- Log technical details only in safe logging tools.
- Never expose tokens, stack traces, internal errors, or sensitive data in UI.
- Handle network, parsing, permission, platform, database, and storage errors.
- Provide fallback UI for failed states.
- Avoid silent failures.
- Avoid infinite loaders when an operation fails.

---

## 7. Model Mapping with Default Values

- Avoid using raw `Map<String, dynamic>` directly in UI.
- Use strongly typed models.
- Add safe default values during JSON parsing.
- Handle nullable fields carefully.
- Avoid force casts in `fromJson`.
- Keep API mapping logic inside model/data layer.
- UI should consume typed models, not raw API maps.
- Use safe parsing for lists, nested objects, enums, booleans, numbers, and dates.

---

## 8. Const Constructors and Const Widgets

- Add `const` constructors to widgets, models, value objects, and immutable classes where possible.
- Use `const` widgets inside the `build` method where possible.
- Use `const` for static EdgeInsets, SizedBox, Text, Icon, and other compile-time widgets.
- Avoid unnecessary object recreation during rebuilds.
- Prefer immutable widget inputs where possible.

---

## 9. Enums / Sealed Classes

Properly use enums and sealed classes instead of hardcoded conditions.

### Requirements

- Use enums for fixed statuses, roles, filters, tabs, types, actions, and conditions.
- Use sealed classes for complex UI/API/state cases where appropriate.
- Avoid hardcoded string comparisons in UI/business logic.
- Avoid repeated condition strings such as `"active"`, `"pending"`, `"completed"`, `"error"`, etc.
- Map backend values into typed enums safely.
- Handle unknown enum values safely.
- Avoid spreading backend status strings directly across widgets.

---

## 10. Utils and Helper Classes

Avoid hardcoded and duplicated utility logic by creating reusable utility/helper classes with const identifiers.

### Requirements

- Avoid writing hardcoded sizes, paddings, margins, DateTime formatters, UI strings, and color codes directly in widgets.
- Create separate reusable classes for:
  - App sizes
  - App paddings/margins
  - App radius values
  - App durations
  - App strings
  - App colors/theme tokens
  - Date/time parsing and formatting
  - Validators
  - Formatters
  - Extensions
- Use `const` identifiers where possible.
- Avoid duplicated date/time formatting logic.
- Avoid unsafe `DateTime.parse` without fallback handling.
- Keep helper methods reusable, focused, and easy to test.
- Avoid placing business logic inside generic utility classes.

---

## 11. Theme Values and Design System Usage

- Use `Theme.of(context)` for colors and typography.
- Use `colorScheme`, `textTheme`, and existing app design-system tokens.
- Avoid hardcoded colors, font sizes, radius, shadows, and spacing.
- Avoid direct usage of `Colors.black`, `Colors.white`, `Colors.red`, etc. unless justified.
- Support dark mode where applicable.
- Keep UI styling consistent with the app design system.

---

## 12. State Management

- Use the project-approved state management approach.
- Avoid unnecessary `setState`.
- Do not store business logic inside widgets.
- Handle loading, success, empty, and error states.
- Avoid duplicated state flags where one typed state would be better.
- Dispose controllers, streams, focus nodes, and listeners properly.
- Do not mix multiple state management approaches in the same feature unless the project architecture requires it.

---

## 13. Naming Conventions

- Classes, enums, and extensions: `PascalCase`.
- Variables, methods, and parameters: `camelCase`.
- Files and folders: `snake_case`.
- Names should be meaningful and self-explanatory.
- Follow the existing naming style of the project.

---

## 14. Unused Code, Debug Logs, and Imports

- Remove unused imports.
- Remove commented-out code.
- Remove unused variables and methods.
- Remove `print` statements. If logging is necessary, use `debugPrint` instead; otherwise remove the statement.
- `debugPrint` and `log` are allowed and must not be treated as violations.
- Remove test-only code before merging.
- Do not leave TODOs without context or tracking reference.
- Remove duplicated comments that do not add value.

---

## 15. Reusable Code

Components used frequently in the app should be made separately to reduce code duplication and dependency.

### Requirements

- Create reusable components for frequently used UI such as:
  - Buttons
  - Text widgets/styles
  - App bars
  - Text fields
  - Dialogs
  - Bottom sheets
  - Empty/error/loading widgets
  - Cards/list items
- Extract repeated business logic into services, managers, helpers, or extensions.
- Avoid copy-pasted UI blocks.
- Avoid copy-pasted validation, formatting, navigation, and API handling logic.
- Keep reusable components configurable but not over-engineered.
- Prefer composition over large condition-heavy widgets.
- Reuse existing shared components before creating new ones.

---

## 16. Folder Structure

- Follow the existing project folder structure.
- Use feature-based, MVVM, clean architecture, MVC, MVP, singleton, or MVI structure consistently as applicable.
- Avoid placing services, models, managers, utilities, or business logic inside UI folders.
- Avoid dumping unrelated files into common/shared folders.
- Keep file locations predictable and maintainable.

---

## 17. UI Responsiveness and Overflow Safety

- Avoid RenderFlex overflow.
- Test long text, empty values, and small screens.
- Use `Expanded`, `Flexible`, `SingleChildScrollView`, `Wrap`, or responsive layouts where needed.
- Avoid fixed widths/heights unless required.
- Support dynamic content safely.
- Respect safe areas.

---

# General Product Engineering Practices

These practices are important for secure, scalable, high-quality Flutter products. Map violations from these guidelines into the most relevant checklist section when they apply to changed code.

## A. Modern App Architecture

- Prefer feature-first or clean architecture for medium/large apps.
- Keep presentation, domain, and data layers separate.
- Use repositories to abstract API/local data sources.
- Keep API clients isolated from UI and state management.
- Keep business rules in use cases, services, managers, blocs, controllers, or notifiers.
- Avoid direct dependency between unrelated features.
- Use dependency injection for services, repositories, clients, and shared utilities.
- Avoid global mutable state.
- Keep shared modules minimal and intentional.

## B. App Security

- Never hardcode API keys, tokens, credentials, secrets, or private URLs.
- Use secure storage for sensitive tokens.
- Avoid logging tokens, user data, headers, OTPs, passwords, or payment details.
- Do not expose raw backend errors to users.
- Validate and sanitize user input where required.
- Use HTTPS-only API communication.
- Handle authorization failures safely.
- Clear sensitive data on logout.
- Avoid storing sensitive data in plain SharedPreferences.
- Keep environment-specific configuration outside source code.
- Avoid committing `.env`, keystore files, certificates, provisioning profiles, or private configs.
- Review deep links, universal links, and intent filters carefully.

## C. Scalability and Maintainability

- Keep features modular and independently maintainable.
- Avoid large widgets, large controllers, and large service classes.
- Avoid duplicated business logic across features.
- Keep routing centralized and typed where possible.
- Keep error handling centralized.
- Keep manager/service usage centralized and consistent.
- Keep date, currency, number, and string formatting centralized.
- Add documentation for complex flows and architecture decisions.

## D. High-Level Performance Practices

- Avoid expensive work inside `build`.
- Avoid unnecessary rebuilds.
- Use efficient list rendering with `ListView.builder`, `SliverList`, or pagination.
- Avoid loading large data sets at once.
- Dispose controllers, streams, subscriptions, focus nodes, animation controllers, and listeners.
- Avoid memory leaks caused by retained contexts or listeners.
- Optimize images using proper dimensions, caching, placeholders, and compression.
- Avoid blocking the UI thread with heavy parsing or computation.
- Move heavy computation to isolates where needed.
- Use debounce/throttle for search and high-frequency UI events.
- Avoid repeated API calls during rebuilds.

## E. Optimized Code Structure

- Keep widgets small and focused.
- Extract repeated widgets into reusable components.
- Extract repeated logic into utilities, extensions, services, managers, or helpers.
- Prefer composition over inheritance for UI.
- Avoid deeply nested widget trees when readability suffers.
- Avoid complex conditions directly inside widget trees.
- Use private widgets or helper methods carefully; prefer widgets when rebuild boundaries matter.
- Keep files easy to scan and review.
- Avoid mixing UI, API, mapping, state, and business logic in one file.
- Keep imports clean and organized.
