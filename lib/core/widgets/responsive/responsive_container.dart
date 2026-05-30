import 'package:flutter/material.dart';
import '../../responsive/responsive_utils.dart';

/// Responsive Container that adjusts size based on screen dimensions
class ResponsiveContainer extends StatelessWidget {
  final double? width;
  final double? height;
  final Widget? child;
  final Color? color;
  final Decoration? decoration;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final AlignmentGeometry? alignment;
  final double? maxWidth;
  final double? minWidth;

  const ResponsiveContainer({
    super.key,
    this.width,
    this.height,
    this.child,
    this.color,
    this.decoration,
    this.padding,
    this.margin,
    this.alignment,
    this.maxWidth,
    this.minWidth,
  });

  @override
  Widget build(BuildContext context) {
    double? finalWidth = width;
    double? finalHeight = height;

    // Apply responsive scaling if dimensions are provided
    if (width != null) {
      finalWidth = ResponsiveUtils.getResponsiveSize(context, width!);
      if (maxWidth != null && finalWidth > maxWidth!) {
        finalWidth = maxWidth;
      }
      if (minWidth != null && finalWidth! < minWidth!) {
        finalWidth = minWidth;
      }
    }

    if (height != null) {
      finalHeight = ResponsiveUtils.getResponsiveSize(context, height!);
    }

    return Container(
      width: finalWidth,
      height: finalHeight,
      padding: padding,
      margin: margin,
      alignment: alignment,
      decoration: decoration ??
          (color != null
              ? BoxDecoration(color: color)
              : null),
      child: child,
    );
  }
}