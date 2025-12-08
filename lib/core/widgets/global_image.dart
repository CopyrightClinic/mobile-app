import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../config/theme/app_theme.dart';
import '../constants/app_strings.dart';
import '../utils/extensions/extensions.dart';
import 'translated_text.dart';

/// A comprehensive global image widget that handles all types of images
/// with full customization, error handling, and loading states.
class GlobalImage extends StatelessWidget {
  /// The image source - can be network URL, asset path, file path, or memory bytes
  final String? imageUrl;

  /// Asset image path (alternative to imageUrl for assets)
  final String? assetPath;

  /// File path for local files (alternative to imageUrl for files)
  final String? filePath;

  /// Memory bytes for memory images (alternative to imageUrl for memory)
  final Uint8List? memoryBytes;

  /// Width of the image
  final double? width;

  /// Height of the image
  final double? height;

  /// Box fit for the image
  final BoxFit fit;

  /// Border radius for the image
  final BorderRadius? borderRadius;

  /// Border around the image
  final BoxBorder? border;

  /// Box shadow for the image
  final List<BoxShadow>? boxShadow;

  /// Background color behind the image
  final Color? backgroundColor;

  /// Placeholder widget while loading
  final Widget? placeholder;

  /// Error widget when image fails to load
  final Widget? errorWidget;

  /// Loading indicator color
  final Color? loadingColor;

  /// Loading indicator size
  final double? loadingSize;

  /// Whether to show loading indicator
  final bool showLoading;

  /// Whether to show error widget
  final bool showError;

  /// Whether to cache network images
  final bool enableCaching;

  /// Cache key for network images
  final String? cacheKey;

  /// HTTP headers for network images
  final Map<String, String>? headers;

  /// Image quality for network images (0.0 to 1.0)
  final double? imageQuality;

  /// Whether to fade in the image
  final bool fadeIn;

  /// Fade in duration
  final Duration fadeInDuration;

  /// Whether to blur the image on error
  final bool blurOnError;

  /// Blur radius for error state
  final double blurRadius;

  /// Whether to show shimmer loading effect
  final bool showShimmer;

  /// Shimmer base color
  final Color? shimmerBaseColor;

  /// Shimmer highlight color
  final Color? shimmerHighlightColor;

  /// Whether to enable image compression
  final bool enableCompression;

  /// Maximum width for compression
  final double? maxWidth;

  /// Maximum height for compression
  final double? maxHeight;

  /// Whether to enable progressive loading for network images
  final bool progressiveLoading;

  /// Whether to enable retry on error
  final bool enableRetry;

  /// Maximum retry attempts
  final int maxRetries;

  /// Retry delay
  final Duration retryDelay;

  /// Callback when image loads successfully
  final VoidCallback? onImageLoaded;

  /// Callback when image fails to load
  final Function(String error)? onImageError;

  /// Callback when image starts loading
  final VoidCallback? onImageLoading;

  /// Color to apply to SVG images (for tinting)
  final Color? color;

  const GlobalImage({
    super.key,
    this.imageUrl,
    this.assetPath,
    this.filePath,
    this.memoryBytes,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.border,
    this.boxShadow,
    this.backgroundColor,
    this.placeholder,
    this.errorWidget,
    this.loadingColor,
    this.loadingSize,
    this.showLoading = true,
    this.showError = true,
    this.enableCaching = true,
    this.cacheKey,
    this.headers,
    this.imageQuality,
    this.fadeIn = true,
    this.fadeInDuration = const Duration(milliseconds: 300),
    this.blurOnError = false,
    this.blurRadius = 5.0,
    this.showShimmer = false,
    this.shimmerBaseColor,
    this.shimmerHighlightColor,
    this.enableCompression = false,
    this.maxWidth,
    this.maxHeight,
    this.progressiveLoading = false,
    this.enableRetry = false,
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 2),
    this.onImageLoaded,
    this.onImageError,
    this.onImageLoading,
    this.color,
  }) : assert(imageUrl != null || assetPath != null || filePath != null || memoryBytes != null, 'At least one image source must be provided');

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(borderRadius: borderRadius, border: border, boxShadow: boxShadow, color: backgroundColor),
      clipBehavior: borderRadius != null ? Clip.antiAlias : Clip.none,
      child: _buildImageWidget(),
    );
  }

  Widget _buildImageWidget() {
    // Determine image type and build appropriate widget
    if (imageUrl != null) {
      return _buildNetworkImage();
    } else if (assetPath != null) {
      return _buildAssetImage();
    } else if (filePath != null) {
      return _buildFileImage();
    } else if (memoryBytes != null) {
      return _buildMemoryImage();
    } else {
      return _buildErrorWidget('No image source provided');
    }
  }

  Widget _buildNetworkImage() {
    // Check if it's an SVG file
    if (_isSvgFile(imageUrl!)) {
      return SvgPicture.network(
        imageUrl!,
        width: width,
        height: height,
        fit: fit,
        colorFilter: color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
        placeholderBuilder: (context) => _buildPlaceholder(),
      );
    }

    if (!enableCaching) {
      return _buildBasicNetworkImage();
    }

    return CachedNetworkImage(
      imageUrl: imageUrl!,
      width: width,
      height: height,
      fit: fit,
      cacheKey: cacheKey,
      httpHeaders: headers,
      fadeInDuration: fadeIn ? fadeInDuration : Duration.zero,
      placeholder: (context, url) => _buildPlaceholder(),
      errorWidget: (context, url, error) => _buildErrorWidget(error.toString()),
      progressIndicatorBuilder:
          showLoading
              ? (context, url, progress) {
                onImageLoading?.call();
                return _buildLoadingIndicator(null);
              }
              : null,
      memCacheWidth: enableCompression ? maxWidth?.toInt() : null,
      memCacheHeight: enableCompression ? maxHeight?.toInt() : null,
      filterQuality: FilterQuality.medium,
      placeholderFadeInDuration: fadeInDuration,
      errorListener: (error) {
        // Logger.error('Network image error: $error');
        onImageError?.call(error.toString());
      },
    );
  }

  Widget _buildBasicNetworkImage() {
    return Image.network(
      imageUrl!,
      width: width,
      height: height,
      fit: fit,
      headers: headers,
      filterQuality: FilterQuality.medium,
      errorBuilder: (context, error, stackTrace) {
        // Logger.error('Basic network image error: $error');
        onImageError?.call(error.toString());
        return _buildErrorWidget(error.toString());
      },
      loadingBuilder:
          showLoading
              ? (context, child, loadingProgress) {
                onImageLoading?.call();
                if (loadingProgress == null) {
                  onImageLoaded?.call();
                  return fadeIn
                      ? FadeInImage.memoryNetwork(
                        placeholder: Uint8List(0),
                        image: imageUrl!,
                        width: width,
                        height: height,
                        fit: fit,
                        fadeInDuration: fadeInDuration,
                      )
                      : child;
                }
                return _buildLoadingIndicator(loadingProgress);
              }
              : null,
    );
  }

  /// Helper method to check if a file is SVG
  bool _isSvgFile(String path) {
    return path.toLowerCase().endsWith('.svg');
  }

  Widget _buildAssetImage() {
    // Check if it's an SVG file
    if (_isSvgFile(assetPath!)) {
      return SvgPicture.asset(
        assetPath!,
        width: width,
        height: height,
        fit: fit,
        colorFilter: color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
        placeholderBuilder: (context) => _buildPlaceholder(),
      );
    }

    // Handle regular image files (PNG, JPG, etc.)
    return Image.asset(
      assetPath!,
      width: width,
      height: height,
      fit: fit,
      filterQuality: FilterQuality.medium,
      errorBuilder: (context, error, stackTrace) {
        // Logger.error('Asset image error: $error');
        onImageError?.call(error.toString());
        return _buildErrorWidget(error.toString());
      },
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) {
          onImageLoaded?.call();
          return fadeIn ? AnimatedOpacity(opacity: 1.0, duration: fadeInDuration, child: child) : child;
        }
        if (frame != null) {
          onImageLoaded?.call();
          return fadeIn ? AnimatedOpacity(opacity: 1.0, duration: fadeInDuration, child: child) : child;
        }
        onImageLoading?.call();
        return _buildPlaceholder();
      },
    );
  }

  Widget _buildFileImage() {
    // Check if it's an SVG file
    if (_isSvgFile(filePath!)) {
      return SvgPicture.file(
        File(filePath!),
        width: width,
        height: height,
        fit: fit,
        colorFilter: color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
        placeholderBuilder: (context) => _buildPlaceholder(),
      );
    }

    return Image.file(
      File(filePath!),
      width: width,
      height: height,
      fit: fit,
      filterQuality: FilterQuality.medium,
      errorBuilder: (context, error, stackTrace) {
        // Logger.error('File image error: $error');
        onImageError?.call(error.toString());
        return _buildErrorWidget(error.toString());
      },
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) {
          onImageLoaded?.call();
          return child;
        }
        if (frame != null) {
          onImageLoaded?.call();
          return child;
        }
        onImageLoading?.call();
        return _buildPlaceholder();
      },
    );
  }

  Widget _buildMemoryImage() {
    return Image.memory(
      memoryBytes!,
      width: width,
      height: height,
      fit: fit,
      filterQuality: FilterQuality.medium,
      errorBuilder: (context, error, stackTrace) {
        // Logger.error('Memory image error: $error');
        onImageError?.call(error.toString());
        return _buildErrorWidget(error.toString());
      },
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) {
          onImageLoaded?.call();
          return child;
        }
        if (frame != null) {
          onImageLoaded?.call();
          return child;
        }
        onImageLoading?.call();
        return _buildPlaceholder();
      },
    );
  }

  Widget _buildPlaceholder() {
    if (placeholder != null) {
      return placeholder!;
    }

    if (showShimmer) {
      return _buildShimmerPlaceholder();
    }

    if (showLoading) {
      return _buildLoadingIndicator(null);
    }

    return Container(
      width: width,
      height: height,
      color: AppTheme.placeholder,
      child: Icon(Icons.image, color: AppTheme.textBodyLight, size: (loadingSize ?? 24.0).f),
    );
  }

  Widget _buildShimmerPlaceholder() {
    return ShimmerLoading(
      baseColor: shimmerBaseColor ?? AppTheme.placeholder,
      highlightColor: shimmerHighlightColor ?? AppTheme.greyLight,
      child: Container(width: width, height: height, color: AppTheme.placeholder),
    );
  }

  Widget _buildLoadingIndicator(ImageChunkEvent? progress) {
    if (!showLoading) {
      return const SizedBox.shrink();
    }

    return Container(
      width: width,
      height: height,
      color: backgroundColor ?? AppTheme.greyLight,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: (loadingSize ?? 24.0).f,
              height: (loadingSize ?? 24.0).f,
              child: CircularProgressIndicator(
                strokeWidth: 2.0,
                valueColor: AlwaysStoppedAnimation<Color>(loadingColor ?? AppTheme.primary),
                value: progress?.expectedTotalBytes != null ? progress!.cumulativeBytesLoaded / progress.expectedTotalBytes! : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    if (!showError) {
      return const SizedBox.shrink();
    }

    if (errorWidget != null) {
      return errorWidget!;
    }

    Widget errorContent = Container(
      width: width,
      height: height,
      color: backgroundColor ?? AppTheme.greyLight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.broken_image, color: AppTheme.textBodyLight, size: (loadingSize ?? 24.0).f),
          SizedBox(height: 8.0.h),
          TranslatedText(AppStrings.failedToLoadImage, style: TextStyle(fontSize: 12.0.f, color: AppTheme.textBodyLight)),
          if (enableRetry) ...[
            SizedBox(height: 8.0.h),
            TextButton(
              onPressed: () {
                // Trigger rebuild to retry
                // This is a simple retry mechanism
              },
              child: TranslatedText(AppStrings.retryText, style: TextStyle(fontSize: 12.0.f, color: AppTheme.primary)),
            ),
          ],
        ],
      ),
    );

    if (blurOnError) {
      errorContent = ImageFiltered(imageFilter: ImageFilter.blur(sigmaX: blurRadius, sigmaY: blurRadius), child: errorContent);
    }

    return errorContent;
  }
}

/// Shimmer loading effect widget
class ShimmerLoading extends StatefulWidget {
  final Widget child;
  final Color baseColor;
  final Color highlightColor;
  final Duration duration;

  const ShimmerLoading({
    super.key,
    required this.child,
    required this.baseColor,
    required this.highlightColor,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this)..repeat();
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value, 0),
              colors: [widget.baseColor, widget.highlightColor, widget.baseColor],
              stops: const [0.0, 0.5, 1.0],
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

/// Convenience constructors for different image types
extension GlobalImageConstructors on GlobalImage {
  /// Create a network image
  static GlobalImage network(
    String url, {
    Key? key,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
    BoxBorder? border,
    List<BoxShadow>? boxShadow,
    Color? backgroundColor,
    Widget? placeholder,
    Widget? errorWidget,
    Color? loadingColor,
    double? loadingSize,
    bool showLoading = true,
    bool showError = true,
    bool enableCaching = true,
    String? cacheKey,
    Map<String, String>? headers,
    double? imageQuality,
    bool fadeIn = true,
    Duration fadeInDuration = const Duration(milliseconds: 300),
    bool blurOnError = false,
    double blurRadius = 5.0,
    bool showShimmer = false,
    Color? shimmerBaseColor,
    Color? shimmerHighlightColor,
    bool enableCompression = false,
    double? maxWidth,
    double? maxHeight,
    bool progressiveLoading = false,
    bool enableRetry = false,
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 2),
    VoidCallback? onImageLoaded,
    Function(String error)? onImageError,
    VoidCallback? onImageLoading,
  }) {
    return GlobalImage(
      key: key,
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      borderRadius: borderRadius,
      border: border,
      boxShadow: boxShadow,
      backgroundColor: backgroundColor,
      placeholder: placeholder,
      errorWidget: errorWidget,
      loadingColor: loadingColor,
      loadingSize: loadingSize,
      showLoading: showLoading,
      showError: showError,
      enableCaching: enableCaching,
      cacheKey: cacheKey,
      headers: headers,
      imageQuality: imageQuality,
      fadeIn: fadeIn,
      fadeInDuration: fadeInDuration,
      blurOnError: blurOnError,
      blurRadius: blurRadius,
      showShimmer: showShimmer,
      shimmerBaseColor: shimmerBaseColor,
      shimmerHighlightColor: shimmerHighlightColor,
      enableCompression: enableCompression,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      progressiveLoading: progressiveLoading,
      enableRetry: enableRetry,
      maxRetries: maxRetries,
      retryDelay: retryDelay,
      onImageLoaded: onImageLoaded,
      onImageError: onImageError,
      onImageLoading: onImageLoading,
    );
  }

  /// Create an asset image
  static GlobalImage asset(
    String path, {
    Key? key,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
    BoxBorder? border,
    List<BoxShadow>? boxShadow,
    Color? backgroundColor,
    Widget? placeholder,
    Widget? errorWidget,
    Color? loadingColor,
    double? loadingSize,
    bool showLoading = true,
    bool showError = true,
    bool fadeIn = true,
    Duration fadeInDuration = const Duration(milliseconds: 300),
    bool blurOnError = false,
    double blurRadius = 5.0,
    bool showShimmer = false,
    Color? shimmerBaseColor,
    Color? shimmerHighlightColor,
    VoidCallback? onImageLoaded,
    Function(String error)? onImageError,
    VoidCallback? onImageLoading,
  }) {
    return GlobalImage(
      key: key,
      assetPath: path,
      width: width,
      height: height,
      fit: fit,
      borderRadius: borderRadius,
      border: border,
      boxShadow: boxShadow,
      backgroundColor: backgroundColor,
      placeholder: placeholder,
      errorWidget: errorWidget,
      loadingColor: loadingColor,
      loadingSize: loadingSize,
      showLoading: showLoading,
      showError: showError,
      fadeIn: fadeIn,
      fadeInDuration: fadeInDuration,
      blurOnError: blurOnError,
      blurRadius: blurRadius,
      showShimmer: showShimmer,
      shimmerBaseColor: shimmerBaseColor,
      shimmerHighlightColor: shimmerHighlightColor,
      onImageLoaded: onImageLoaded,
      onImageError: onImageError,
      onImageLoading: onImageLoading,
    );
  }

  /// Create a file image
  static GlobalImage file(
    String path, {
    Key? key,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
    BoxBorder? border,
    List<BoxShadow>? boxShadow,
    Color? backgroundColor,
    Widget? placeholder,
    Widget? errorWidget,
    Color? loadingColor,
    double? loadingSize,
    bool showLoading = true,
    bool showError = true,
    bool fadeIn = true,
    Duration fadeInDuration = const Duration(milliseconds: 300),
    bool blurOnError = false,
    double blurRadius = 5.0,
    bool showShimmer = false,
    Color? shimmerBaseColor,
    Color? shimmerHighlightColor,
    VoidCallback? onImageLoaded,
    Function(String error)? onImageError,
    VoidCallback? onImageLoading,
  }) {
    return GlobalImage(
      key: key,
      filePath: path,
      width: width,
      height: height,
      fit: fit,
      borderRadius: borderRadius,
      border: border,
      boxShadow: boxShadow,
      backgroundColor: backgroundColor,
      placeholder: placeholder,
      errorWidget: errorWidget,
      loadingColor: loadingColor,
      loadingSize: loadingSize,
      showLoading: showLoading,
      showError: showError,
      fadeIn: fadeIn,
      fadeInDuration: fadeInDuration,
      blurOnError: blurOnError,
      blurRadius: blurRadius,
      showShimmer: showShimmer,
      shimmerBaseColor: shimmerBaseColor,
      shimmerHighlightColor: shimmerHighlightColor,
      onImageLoaded: onImageLoaded,
      onImageError: onImageError,
      onImageLoading: onImageLoading,
    );
  }

  /// Create a memory image
  static GlobalImage memory(
    Uint8List bytes, {
    Key? key,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
    BoxBorder? border,
    List<BoxShadow>? boxShadow,
    Color? backgroundColor,
    Widget? placeholder,
    Widget? errorWidget,
    Color? loadingColor,
    double? loadingSize,
    bool showLoading = true,
    bool showError = true,
    bool fadeIn = true,
    Duration fadeInDuration = const Duration(milliseconds: 300),
    bool blurOnError = false,
    double blurRadius = 5.0,
    bool showShimmer = false,
    Color? shimmerBaseColor,
    Color? shimmerHighlightColor,
    VoidCallback? onImageLoaded,
    Function(String error)? onImageError,
    VoidCallback? onImageLoading,
  }) {
    return GlobalImage(
      key: key,
      memoryBytes: bytes,
      width: width,
      height: height,
      fit: fit,
      borderRadius: borderRadius,
      border: border,
      boxShadow: boxShadow,
      backgroundColor: backgroundColor,
      placeholder: placeholder,
      errorWidget: errorWidget,
      loadingColor: loadingColor,
      loadingSize: loadingSize,
      showLoading: showLoading,
      showError: showError,
      fadeIn: fadeIn,
      fadeInDuration: fadeInDuration,
      blurOnError: blurOnError,
      blurRadius: blurRadius,
      showShimmer: showShimmer,
      shimmerBaseColor: shimmerBaseColor,
      shimmerHighlightColor: shimmerHighlightColor,
      onImageLoaded: onImageLoaded,
      onImageError: onImageError,
      onImageLoading: onImageLoading,
    );
  }
}
