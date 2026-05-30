import 'package:flutter/material.dart';
import '../../responsive/responsive_utils.dart';

/// Responsive SizedBox that scales spacing based on screen size
class ResponsiveSizedBox extends StatelessWidget {
  final double width;
  final double height;
  final Widget? child;

  const ResponsiveSizedBox({
    super.key,
    this.width = 0.0,
    this.height = 0.0,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final responsiveWidth =
        width > 0 ? ResponsiveUtils.getResponsiveSize(context, width) : 0.0;
    final responsiveHeight =
        height > 0 ? ResponsiveUtils.getResponsiveSize(context, height) : 0.0;

    return SizedBox(
      width: responsiveWidth,
      height: responsiveHeight,
      child: child,
    );
  }
}