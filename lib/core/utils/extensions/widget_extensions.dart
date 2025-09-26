import 'package:flutter/material.dart';

/// Basic widget extensions for padding and margin
extension WidgetPadding on Widget {
  /// Add padding to all sides
  Widget paddingAll(double padding) => Padding(padding: EdgeInsets.all(padding), child: this);

  /// Add horizontal padding
  Widget paddingHorizontal(double padding) => Padding(padding: EdgeInsets.symmetric(horizontal: padding), child: this);

  /// Add vertical padding
  Widget paddingVertical(double padding) => Padding(padding: EdgeInsets.symmetric(vertical: padding), child: this);

  /// Add padding with specific sides
  Widget paddingOnly({double left = 0.0, double top = 0.0, double right = 0.0, double bottom = 0.0}) =>
      Padding(padding: EdgeInsets.only(left: left, top: top, right: right, bottom: bottom), child: this);

  /// Add symmetric padding
  Widget paddingSymmetric({double horizontal = 0.0, double vertical = 0.0}) =>
      Padding(padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical), child: this);
}

extension WidgetMargin on Widget {
  /// Add margin to all sides
  Widget marginAll(double margin) => Container(margin: EdgeInsets.all(margin), child: this);

  /// Add horizontal margin
  Widget marginHorizontal(double margin) => Container(margin: EdgeInsets.symmetric(horizontal: margin), child: this);

  /// Add vertical margin
  Widget marginVertical(double margin) => Container(margin: EdgeInsets.symmetric(vertical: margin), child: this);

  /// Add margin with specific sides
  Widget marginOnly({double left = 0.0, double top = 0.0, double right = 0.0, double bottom = 0.0}) =>
      Container(margin: EdgeInsets.only(left: left, top: top, right: right, bottom: bottom), child: this);

  /// Add symmetric margin
  Widget marginSymmetric({double horizontal = 0.0, double vertical = 0.0}) =>
      Container(margin: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical), child: this);
}
