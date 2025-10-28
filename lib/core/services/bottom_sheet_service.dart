import 'package:flutter/material.dart';
import '../../config/routes/app_router.dart';

class BottomSheetService {
  static BuildContext? get _context => AppRouter.rootNavigatorKey.currentContext;

  static Future<T?> show<T>({
    required WidgetBuilder builder,
    Color? backgroundColor,
    bool isScrollControlled = true,
    bool isDismissible = true,
    bool enableDrag = true,
    double? elevation,
    ShapeBorder? shape,
    Clip? clipBehavior,
    BoxConstraints? constraints,
    Color? barrierColor,
    bool? useSafeArea,
  }) {
    final context = _context;
    if (context == null) {
      throw StateError('Root navigator context is not available');
    }

    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: backgroundColor ?? Colors.transparent,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      elevation: elevation,
      shape: shape,
      clipBehavior: clipBehavior,
      constraints: constraints,
      barrierColor: barrierColor,
      useSafeArea: useSafeArea ?? false,
      builder: builder,
    );
  }
}

