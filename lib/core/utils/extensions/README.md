# Widget Extensions

This directory contains basic Flutter widget extensions for common styling operations.

## Available Extensions

### 1. Widget Extensions (`widget_extensions.dart`)
Basic widget padding and margin extensions:

```dart
// Padding
widget.paddingAll(16)
widget.paddingHorizontal(16)
widget.paddingVertical(16)
widget.paddingOnly(left: 8, top: 4, right: 8, bottom: 4)
widget.paddingSymmetric(horizontal: 16, vertical: 8)

// Margin
widget.marginAll(16)
widget.marginHorizontal(16)
widget.marginVertical(16)
widget.marginOnly(left: 8, top: 4, right: 8, bottom: 4)
widget.marginSymmetric(horizontal: 16, vertical: 8)
```

### 2. Responsive Extensions (`responsive_extensions.dart`)
Responsive design extensions:

```dart
// Responsive sizing
16.w  // responsive width
16.h  // responsive height
16.f  // responsive font size
16.d  // responsive diameter
16.r  // responsive radius
```

### 3. Theme Extensions (`theme_extensions.dart`)
Theme-based styling extensions:

```dart
// Colors
context.primaryColor
context.backgroundColor
context.surfaceColor
context.textColor
context.successColor
context.errorColor
context.warningColor

// Spacing
context.spacingSmall
context.spacingMedium
context.spacingLarge
context.radiusSmall
context.radiusMedium
context.radiusLarge

// Text styles
context.headlineStyle
context.titleStyle
context.bodyStyle
context.captionStyle
```

## Usage Examples

### Basic Usage
```dart
import 'package:your_app/core/utils/extensions/extensions.dart';

// Simple widget with padding and margin
Text('Hello World')
    .paddingAll(16)
    .marginVertical(8)
```

### Responsive Design
```dart
Text('Responsive Text')
    .paddingAll(16.w)
    .marginVertical(8.h)
```

### Theme Integration
```dart
Text('Theme Text')
    .paddingAll(context.spacingMedium)
    .marginVertical(context.spacingSmall)
```

## Importing

To use all extensions, import the main extensions file:

```dart
import 'package:your_app/core/utils/extensions/extensions.dart';
```

Or import specific extension files:

```dart
import 'package:your_app/core/utils/extensions/widget_extensions.dart';
import 'package:your_app/core/utils/extensions/responsive_extensions.dart';
import 'package:your_app/core/utils/extensions/theme_extensions.dart';
```

## Benefits

1. **Cleaner Code**: Reduces boilerplate for common padding and margin operations
2. **Consistent Spacing**: Ensures consistent spacing across the app
3. **Faster Development**: Quick access to common widget modifications
4. **Type Safety**: All extensions are type-safe and provide IDE autocomplete
5. **Responsive**: Built-in responsive design support
6. **Theme Integration**: Seamless integration with app themes

## Best Practices

1. **Chain Extensions**: Use method chaining for cleaner code
2. **Theme Usage**: Use theme extensions for consistent spacing
3. **Responsive Design**: Use responsive extensions for adaptive layouts
