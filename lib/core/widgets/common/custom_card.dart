import 'package:flutter/material.dart';
import '../../responsive/responsive_utils.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final double? borderRadius;
  final List<BoxShadow>? shadows;
  final Border? border;

  const CustomCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.backgroundColor,
    this.borderRadius,
    this.shadows,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final responsiveBorderRadius = borderRadius != null
        ? ResponsiveUtils.getResponsiveSize(context, borderRadius!)
        : ResponsiveUtils.getResponsiveSize(context, 16);
    final responsivePadding = padding ??
        EdgeInsets.all(ResponsiveUtils.getResponsiveSize(context, 16));
    final responsiveBlurRadius = ResponsiveUtils.getResponsiveSize(context, 12);
    final responsiveOffset = Offset(
      0,
      ResponsiveUtils.getResponsiveSize(context, 2),
    );

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.cardColor,
        borderRadius: BorderRadius.circular(responsiveBorderRadius),
        boxShadow:
            shadows ??
            [
              BoxShadow(
                color: theme.shadowColor.withValues(alpha: 0.08),
                blurRadius: responsiveBlurRadius,
                offset: responsiveOffset,
              ),
            ],
        border: border,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(responsiveBorderRadius),
          child: Padding(
            padding: responsivePadding,
            child: child,
          ),
        ),
      ),
    );
  }
}
