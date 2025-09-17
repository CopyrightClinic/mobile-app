import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../constants/dimensions.dart';
import '../utils/extensions/responsive_extensions.dart';
import '../utils/extensions/theme_extensions.dart';

class ShimmerWidget extends StatelessWidget {
  final double width;
  final double height;
  final ShapeBorder shapeBorder;

  const ShimmerWidget({super.key, required this.width, required this.height, this.shapeBorder = const RoundedRectangleBorder()});

  const ShimmerWidget.rectangular({super.key, required this.width, required this.height})
    : shapeBorder = const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0)));

  ShimmerWidget.roundedRectangular({super.key, required this.width, required this.height, required double borderRadius})
    : shapeBorder = RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius));

  const ShimmerWidget.circular({super.key, required this.width, required this.height}) : shapeBorder = const CircleBorder();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.filledBgDark,
      highlightColor: context.darkTextSecondary.withOpacity(0.3),
      child: Container(width: width, height: height, decoration: ShapeDecoration(color: context.filledBgDark, shape: shapeBorder)),
    );
  }
}

class DaySelectorShimmer extends StatelessWidget {
  const DaySelectorShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        padding: EdgeInsets.zero,
        itemBuilder: (context, index) {
          return Container(
            width: 45.w,
            margin: EdgeInsets.only(right: index < 6 ? DimensionConstants.gap8Px.w : 0),
            child: ShimmerWidget.roundedRectangular(width: 45.w, height: 70.h, borderRadius: DimensionConstants.radius12Px.r),
          );
        },
      ),
    );
  }
}

class TimeSlotGridShimmer extends StatelessWidget {
  const TimeSlotGridShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3.2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 8, // Show 8 shimmer items
      itemBuilder: (context, index) {
        return ShimmerWidget.roundedRectangular(width: double.infinity, height: double.infinity, borderRadius: DimensionConstants.radius12Px.r);
      },
    );
  }
}
