import 'package:flutter/material.dart';
import '../constants/dimensions.dart';
import '../utils/extensions/extensions.dart';
import 'custom_back_button.dart';
import 'translated_text.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;

  final String? titleText;

  final TextStyle? titleStyle;

  final bool centerTitle;

  final Widget? leading;

  final bool showBackButton;

  final List<Widget>? actions;

  final Color? backgroundColor;

  final double elevation;

  final double? scrolledUnderElevation;

  final bool automaticallyImplyLeading;

  final double? height;

  final EdgeInsetsGeometry? leadingPadding;

  const CustomAppBar({
    super.key,
    this.title,
    this.titleText,
    this.titleStyle,
    this.centerTitle = false,
    this.leading,
    this.showBackButton = true,
    this.actions,
    this.backgroundColor,
    this.elevation = 0,
    this.scrolledUnderElevation = 0,
    this.automaticallyImplyLeading = false,
    this.height,
    this.leadingPadding,
  });

  @override
  Widget build(BuildContext context) {
    Widget? resolvedLeading;

    if (leading != null) {
      resolvedLeading = leading;
    } else if (showBackButton && automaticallyImplyLeading) {
      resolvedLeading = const CustomBackButton();
    }

    if (resolvedLeading != null && leadingPadding != null) {
      resolvedLeading = Padding(padding: leadingPadding!, child: resolvedLeading);
    } else if (resolvedLeading != null && showBackButton) {
      resolvedLeading = Padding(padding: EdgeInsets.only(left: DimensionConstants.gap8Px.w), child: resolvedLeading);
    }

    Widget? resolvedTitle;
    if (title != null) {
      resolvedTitle = title;
    } else if (titleText != null) {
      resolvedTitle = TranslatedText(
        titleText!,
        style: titleStyle ?? TextStyle(color: context.darkTextPrimary, fontSize: DimensionConstants.font20Px.f, fontWeight: FontWeight.w600),
      );
    }

    AppBar appBar = AppBar(
      title: resolvedTitle,
      centerTitle: centerTitle,
      leading: resolvedLeading,
      actions: actions,
      backgroundColor: backgroundColor ?? Colors.transparent,
      elevation: elevation,
      scrolledUnderElevation: scrolledUnderElevation,
      automaticallyImplyLeading: automaticallyImplyLeading,
      leadingWidth: 60,
    );

    return appBar;
  }

  @override
  Size get preferredSize {
    double appBarHeight = height ?? kToolbarHeight;
    return Size.fromHeight(appBarHeight);
  }
}
