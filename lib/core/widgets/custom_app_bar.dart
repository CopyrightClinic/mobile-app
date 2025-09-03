import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  final SystemUiOverlayStyle? systemOverlayStyle;

  final double? height;

  final bool showBottomBorder;

  final Color? bottomBorderColor;

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
    this.systemOverlayStyle,
    this.height,
    this.showBottomBorder = false,
    this.bottomBorderColor,
    this.leadingPadding,
  });

  factory CustomAppBar.basic({
    Key? key,
    String? titleText,
    TextStyle? titleStyle,
    bool centerTitle = false,
    List<Widget>? actions,
    bool showBackButton = true,
    Widget? customLeading,
    EdgeInsetsGeometry? leadingPadding,
  }) {
    return CustomAppBar(
      key: key,
      titleText: titleText,
      titleStyle: titleStyle,
      centerTitle: centerTitle,
      actions: actions,
      showBackButton: showBackButton,
      leading: customLeading,
      leadingPadding: leadingPadding,
    );
  }

  factory CustomAppBar.transparent({
    Key? key,
    String? titleText,
    Widget? title,
    TextStyle? titleStyle,
    bool centerTitle = false,
    List<Widget>? actions,
    bool showBackButton = true,
    Widget? customLeading,
    EdgeInsetsGeometry? leadingPadding,
  }) {
    return CustomAppBar(
      key: key,
      title: title,
      titleText: titleText,
      titleStyle: titleStyle,
      centerTitle: centerTitle,
      actions: actions,
      showBackButton: showBackButton,
      leading: customLeading,
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      leadingPadding: leadingPadding,
    );
  }

  factory CustomAppBar.withTitle({
    Key? key,
    required String titleText,
    TextStyle? titleStyle,
    bool centerTitle = true,
    List<Widget>? actions,
    bool showBackButton = true,
    Widget? customLeading,
    Color? backgroundColor,
    EdgeInsetsGeometry? leadingPadding,
  }) {
    return CustomAppBar(
      key: key,
      titleText: titleText,
      titleStyle: titleStyle,
      centerTitle: centerTitle,
      actions: actions,
      showBackButton: showBackButton,
      leading: customLeading,
      backgroundColor: backgroundColor ?? Colors.transparent,
      leadingPadding: leadingPadding,
    );
  }

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
      systemOverlayStyle: systemOverlayStyle,
    );

    if (showBottomBorder) {
      return Column(mainAxisSize: MainAxisSize.min, children: [appBar, Container(height: 1, color: bottomBorderColor ?? context.greyLight)]);
    }

    return appBar;
  }

  @override
  Size get preferredSize {
    double appBarHeight = height ?? kToolbarHeight;
    if (showBottomBorder) {
      appBarHeight += 1;
    }
    return Size.fromHeight(appBarHeight);
  }
}

extension CustomAppBarExtensions on CustomAppBar {
  static CustomAppBar get simple => CustomAppBar.transparent();

  static CustomAppBar withCustomBackButton({String? titleText, List<Widget>? actions, EdgeInsetsGeometry? backButtonPadding}) {
    return CustomAppBar.transparent(
      titleText: titleText,
      actions: actions,
      leadingPadding: backButtonPadding ?? EdgeInsets.only(left: DimensionConstants.gap8Px.w),
    );
  }
}
