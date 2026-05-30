// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../responsive/responsive_utils.dart';

/// Responsive logo widget that adjusts size based on screen dimensions
class ResponsiveLogo extends StatelessWidget {
  final IconData icon;
  final double baseSize;
  final Color? color;
  final Color? backgroundColor;
  final double? maxWidth;
  final double? minWidth;

  const ResponsiveLogo({
    super.key,
    required this.icon,
    this.baseSize = 120.0,
    this.color,
    this.backgroundColor,
    this.maxWidth,
    this.minWidth,
  });

  @override
  Widget build(BuildContext context) {
    final responsiveSize =
        ResponsiveUtils.getResponsiveSize(context, baseSize);

    double finalSize = responsiveSize;

    // Apply min/max constraints
    if (maxWidth != null && finalSize > maxWidth!) {
      finalSize = maxWidth!;
    }
    if (minWidth != null && finalSize < minWidth!) {
      finalSize = minWidth!;
    }

    return Container(
      width: finalSize,
      height: finalSize,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: ResponsiveUtils.getResponsiveSize(context, 30),
            offset: Offset(
              0,
              ResponsiveUtils.getResponsiveSize(context, 10),
            ),
          ),
        ],
      ),
      child: Icon(
        icon,
        size: finalSize * 0.417, // Maintain same比例 as original (50/120)
        color: color,
      ),
    );
  }
}