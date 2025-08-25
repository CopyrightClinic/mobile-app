# GlobalImage Widget Documentation

## Overview

The `GlobalImage` widget is a comprehensive, fully-featured image widget that handles all types of images (network, asset, file, memory) with extensive customization options, error handling, loading states, and responsive design. It follows the project's architecture patterns and integrates seamlessly with the existing theme system.

## Features

### ✅ Image Types Supported
- **Network Images**: HTTP/HTTPS URLs with caching support
- **Asset Images**: Local assets from the assets folder (PNG, JPG, SVG, etc.)
- **File Images**: Local files from device storage (PNG, JPG, SVG, etc.)
- **Memory Images**: Images from byte arrays
- **SVG Support**: Automatic SVG detection and rendering for all sources

### ✅ Advanced Features
- **Caching**: Built-in network image caching with `cached_network_image`
- **Loading States**: Customizable loading indicators with progress tracking
- **Error Handling**: Comprehensive error handling with custom error widgets
- **Shimmer Effects**: Beautiful shimmer loading animations
- **Responsive Design**: Automatic scaling based on screen size
- **Custom Styling**: Borders, shadows, border radius, and more
- **Fade Animations**: Smooth fade-in transitions
- **Retry Mechanism**: Automatic retry on network failures
- **Image Compression**: Memory optimization for large images
- **Custom Headers**: HTTP headers for authenticated requests

## Basic Usage

### Network Images

```dart
// Basic network image (PNG, JPG, etc.)
GlobalImage(
  imageUrl: 'https://example.com/image.jpg',
  width: 200.0.w,
  height: 150.0.h,
)

// Network SVG image (automatically detected)
GlobalImage(
  imageUrl: 'https://example.com/icon.svg',
  width: 100.0.w,
  height: 100.0.h,
  borderRadius: BorderRadius.circular(50.0.r),
)

// With caching enabled
GlobalImage(
  imageUrl: 'https://example.com/image.jpg',
  width: 200.0.w,
  height: 150.0.h,
  enableCaching: true,
  cacheKey: 'unique-cache-key',
)

// With custom headers (for authenticated APIs)
GlobalImage(
  imageUrl: 'https://api.example.com/protected-image.jpg',
  headers: {
    'Authorization': 'Bearer your-token',
    'User-Agent': 'Flutter App',
  },
  width: 200.0.w,
  height: 150.0.h,
)
```

### Asset Images

```dart
// Basic asset image (PNG, JPG, etc.)
GlobalImage(
  assetPath: 'assets/images/logo.png',
  width: 100.0.w,
  height: 100.0.h,
)

// SVG asset image (automatically detected)
GlobalImage(
  assetPath: 'assets/images/icon.svg',
  width: 50.0.w,
  height: 50.0.h,
  borderRadius: BorderRadius.circular(25.0.r),
  border: Border.all(color: AppTheme.primary, width: 2.0),
)

// SVG with custom styling
GlobalImage(
  assetPath: 'assets/images/illustration.svg',
  width: 200.0.w,
  height: 150.0.h,
  fit: BoxFit.contain,
  backgroundColor: AppTheme.greyLight,
)
```

### File Images

```dart
// Local file image (PNG, JPG, etc.)
GlobalImage(
  filePath: '/path/to/local/image.jpg',
  width: 200.0.w,
  height: 150.0.h,
)

// Local SVG file (automatically detected)
GlobalImage(
  filePath: '/path/to/local/icon.svg',
  width: 100.0.w,
  height: 100.0.h,
  borderRadius: BorderRadius.circular(50.0.r),
)
```

### Memory Images

```dart
// Memory image from bytes
GlobalImage(
  memoryBytes: imageBytes, // Uint8List
  width: 200.0.w,
  height: 150.0.h,
)
```

## Styling Options

### Border Radius and Borders

```dart
GlobalImage(
  imageUrl: 'https://example.com/image.jpg',
  width: 200.0.w,
  height: 150.0.h,
  borderRadius: BorderRadius.circular(12.0.r),
  border: Border.all(
    color: AppTheme.primary,
    width: 2.0,
  ),
)
```

### Box Shadows

```dart
GlobalImage(
  imageUrl: 'https://example.com/image.jpg',
  width: 200.0.w,
  height: 150.0.h,
  borderRadius: BorderRadius.circular(12.0.r),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 8.0,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: AppTheme.primary.withOpacity(0.2),
      blurRadius: 16.0,
      offset: const Offset(0, 8),
    ),
  ],
)
```

### Background Colors

```dart
GlobalImage(
  imageUrl: 'https://example.com/image.jpg',
  width: 200.0.w,
  height: 150.0.h,
  backgroundColor: AppTheme.greyLight,
  fit: BoxFit.contain,
)
```

## Loading States

### Default Loading Indicator

```dart
GlobalImage(
  imageUrl: 'https://example.com/image.jpg',
  width: 200.0.w,
  height: 150.0.h,
  showLoading: true, // Default: true
  loadingColor: AppTheme.primary,
  loadingSize: 24.0,
)
```

### Custom Placeholder

```dart
GlobalImage(
  imageUrl: 'https://example.com/image.jpg',
  width: 200.0.w,
  height: 150.0.h,
  placeholder: Container(
    width: 200.0.w,
    height: 150.0.h,
    decoration: BoxDecoration(
      color: AppTheme.primary.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12.0.r),
    ),
    child: Icon(
      Icons.image,
      color: AppTheme.primary,
      size: 32.0.f,
    ),
  ),
)
```

### Shimmer Loading Effect

```dart
GlobalImage(
  imageUrl: 'https://example.com/image.jpg',
  width: 200.0.w,
  height: 150.0.h,
  showShimmer: true,
  shimmerBaseColor: AppTheme.placeholder,
  shimmerHighlightColor: AppTheme.greyLight,
)
```

## Error Handling

### Default Error Widget

```dart
GlobalImage(
  imageUrl: 'https://invalid-url.com/image.jpg',
  width: 200.0.w,
  height: 150.0.h,
  showError: true, // Default: true
)
```

### Custom Error Widget

```dart
GlobalImage(
  imageUrl: 'https://invalid-url.com/image.jpg',
  width: 200.0.w,
  height: 150.0.h,
  errorWidget: Container(
    width: 200.0.w,
    height: 150.0.h,
    decoration: BoxDecoration(
      color: AppTheme.red.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12.0.r),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.error_outline,
          color: AppTheme.red,
          size: 32.0.f,
        ),
        SizedBox(height: 8.0.h),
        Text(
          'Failed to load image',
          style: TextStyle(
            fontSize: 12.0.f,
            color: AppTheme.red,
          ),
        ),
      ],
    ),
  ),
)
```

### Error with Retry

```dart
GlobalImage(
  imageUrl: 'https://invalid-url.com/image.jpg',
  width: 200.0.w,
  height: 150.0.h,
  enableRetry: true,
  maxRetries: 3,
  retryDelay: Duration(seconds: 2),
)
```

### Blur on Error

```dart
GlobalImage(
  imageUrl: 'https://invalid-url.com/image.jpg',
  width: 200.0.w,
  height: 150.0.h,
  blurOnError: true,
  blurRadius: 5.0,
)
```

## Animation and Transitions

### Fade In Animation

```dart
GlobalImage(
  imageUrl: 'https://example.com/image.jpg',
  width: 200.0.w,
  height: 150.0.h,
  fadeIn: true, // Default: true
  fadeInDuration: Duration(milliseconds: 500),
)
```

## Performance Optimization

### Image Compression

```dart
GlobalImage(
  imageUrl: 'https://example.com/large-image.jpg',
  width: 200.0.w,
  height: 150.0.h,
  enableCompression: true,
  maxWidth: 400.0,
  maxHeight: 300.0,
)
```

### Memory Cache Control

```dart
GlobalImage(
  imageUrl: 'https://example.com/image.jpg',
  width: 200.0.w,
  height: 150.0.h,
  enableCaching: true,
  cacheKey: 'unique-key-for-caching',
)
```

## Callbacks

### Loading Callbacks

```dart
GlobalImage(
  imageUrl: 'https://example.com/image.jpg',
  width: 200.0.w,
  height: 150.0.h,
  onImageLoading: () {
    print('Image started loading');
  },
  onImageLoaded: () {
    print('Image loaded successfully');
  },
  onImageError: (error) {
    print('Image failed to load: $error');
  },
)
```

## Responsive Design

The widget automatically uses the project's responsive extensions:

```dart
GlobalImage(
  imageUrl: 'https://example.com/image.jpg',
  width: 200.0.w,  // Responsive width
  height: 150.0.h, // Responsive height
  borderRadius: BorderRadius.circular(12.0.r), // Responsive radius
)
```

## SVG Support

The `GlobalImage` widget automatically detects and handles SVG files for all image sources:

### Automatic SVG Detection
- **File Extension**: Automatically detects `.svg` files by extension
- **All Sources**: Works with network, asset, and file images
- **Seamless Integration**: No additional configuration needed

### SVG Features
- **Scalable**: Perfect for icons, logos, and illustrations
- **Small File Size**: Vector graphics are typically smaller than raster images
- **Crisp at Any Size**: No pixelation when scaled
- **Color Support**: Preserves original SVG colors and styling

### SVG Examples

```dart
// Network SVG
GlobalImage(
  imageUrl: 'https://example.com/logo.svg',
  width: 200.0.w,
  height: 100.0.h,
)

// Asset SVG
GlobalImage(
  assetPath: 'assets/icons/menu.svg',
  width: 24.0.w,
  height: 24.0.h,
)

// File SVG
GlobalImage(
  filePath: '/path/to/downloaded/icon.svg',
  width: 50.0.w,
  height: 50.0.h,
  borderRadius: BorderRadius.circular(25.0.r),
)
```

## BoxFit Options

```dart
// Cover - fills the container, may crop
GlobalImage(
  imageUrl: 'https://example.com/image.jpg',
  width: 200.0.w,
  height: 150.0.h,
  fit: BoxFit.cover,
)

// Contain - fits within container, may have empty space
GlobalImage(
  imageUrl: 'https://example.com/image.jpg',
  width: 200.0.w,
  height: 150.0.h,
  fit: BoxFit.contain,
  backgroundColor: AppTheme.greyLight,
)

// Fill - stretches to fill container
GlobalImage(
  imageUrl: 'https://example.com/image.jpg',
  width: 200.0.w,
  height: 150.0.h,
  fit: BoxFit.fill,
)
```

## Complete Example

Here's a complete example showing various features:

```dart
class ProfileImage extends StatelessWidget {
  final String imageUrl;
  final String? fallbackAsset;
  
  const ProfileImage({
    super.key,
    required this.imageUrl,
    this.fallbackAsset,
  });

  @override
  Widget build(BuildContext context) {
    return GlobalImage(
      imageUrl: imageUrl,
      width: 120.0.w,
      height: 120.0.h,
      borderRadius: BorderRadius.circular(60.0.r),
      border: Border.all(
        color: AppTheme.primary,
        width: 3.0,
      ),
      boxShadow: [
        BoxShadow(
          color: AppTheme.primary.withOpacity(0.3),
          blurRadius: 12.0,
          offset: const Offset(0, 6),
        ),
      ],
      enableCaching: true,
      cacheKey: 'profile-${imageUrl.hashCode}',
      showShimmer: true,
      shimmerBaseColor: AppTheme.placeholder,
      shimmerHighlightColor: AppTheme.greyLight,
      errorWidget: fallbackAsset != null
          ? GlobalImage(
              assetPath: fallbackAsset!,
              width: 120.0.w,
              height: 120.0.h,
              borderRadius: BorderRadius.circular(60.0.r),
            )
          : null,
      onImageLoaded: () {
        print('Profile image loaded successfully');
      },
      onImageError: (error) {
        print('Profile image failed to load: $error');
      },
    );
  }
}
```

## Best Practices

1. **Always provide dimensions**: Set `width` and `height` for better performance
2. **Use caching for network images**: Enable `enableCaching` for frequently accessed images
3. **Provide fallback assets**: Use `errorWidget` with local assets for better UX
4. **Use responsive extensions**: Always use `.w`, `.h`, `.r` for responsive design
5. **Handle errors gracefully**: Implement proper error handling with user-friendly messages
6. **Optimize for performance**: Use `enableCompression` for large images
7. **Use meaningful cache keys**: Provide unique cache keys for better cache management

## Integration with Project Architecture

The `GlobalImage` widget integrates seamlessly with the project's architecture:

- **Theme Integration**: Uses `AppTheme` colors and constants
- **Responsive Design**: Uses the project's responsive extensions
- **Error Handling**: Follows the project's error handling patterns
- **Logging**: Integrates with the project's logging system
- **Dependency Injection**: Can be easily registered in the DI container

## Dependencies

The widget requires the following dependencies (already included in the project):

- `cached_network_image: ^3.4.1` - For network image caching
- `flutter_svg: ^2.1.0` - For SVG image support
- `flutter` - Core Flutter framework

## Performance Considerations

- **Memory Usage**: The widget automatically handles memory optimization
- **Network Efficiency**: Caching reduces network requests
- **Rendering Performance**: Efficient rendering with proper widget lifecycle management
- **Error Recovery**: Automatic retry mechanisms for better user experience

This comprehensive image widget provides everything you need for handling images in your Flutter application with a clean, maintainable, and performant approach.
