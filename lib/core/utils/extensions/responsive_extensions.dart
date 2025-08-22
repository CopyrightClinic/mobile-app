import '../ui/responsive.dart';

extension ResponsiveDoubleExtension on double {
  double get w => Responsive.w(this); // width
  double get h => Responsive.h(this); // height
  double get f => Responsive.f(this); // font size
  double get d => Responsive.d(this); // diameter
  double get r => Responsive.r(this); // radius
}

extension ResponsiveIntExtension on int {
  double get w => Responsive.w(toDouble()); // width
  double get h => Responsive.h(toDouble()); // height
  double get f => Responsive.f(toDouble()); // font size
  double get d => Responsive.d(toDouble()); // diameter
  double get r => Responsive.r(toDouble()); // radius
}
