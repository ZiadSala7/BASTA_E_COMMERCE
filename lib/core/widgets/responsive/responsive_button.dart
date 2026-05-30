import 'package:flutter/material.dart';
import '../../responsive/responsive_utils.dart';

/// Responsive button that adjusts size and padding based on screen size
class ResponsiveButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final ButtonStyle? style;
  final double? minWidth;
  final double? height;
  final bool expanded;

  const ResponsiveButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.style,
    this.minWidth,
    this.height,
    this.expanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = ResponsiveUtils.getScreenWidth(context);

    // Determine button dimensions based on screen size
    double buttonHeight = height ?? ResponsiveUtils.getResponsiveSize(context, 56);
    double buttonMinWidth = minWidth ?? ResponsiveUtils.getResponsiveSize(context, 120);

    // Adjust for very small screens
    if (screenWidth < 360) {
      buttonHeight = buttonHeight * 0.9;
    }

    final baseStyle = ElevatedButton.styleFrom(
      minimumSize: Size(buttonMinWidth, buttonHeight),
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.getResponsiveSize(context, 24),
        vertical: ResponsiveUtils.getResponsiveSize(context, 12),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getResponsiveSize(context, 16),
        ),
      ),
    );

    return SizedBox(
      width: expanded ? double.infinity : null,
      child: ElevatedButton(
        onPressed: onPressed,
        style: style != null ? baseStyle.merge(style) : baseStyle,
        child: child,
      ),
    );
  }
}

/// Responsive outlined button variant
class ResponsiveOutlinedButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final ButtonStyle? style;
  final double? minWidth;
  final double? height;
  final bool expanded;

  const ResponsiveOutlinedButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.style,
    this.minWidth,
    this.height,
    this.expanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = ResponsiveUtils.getScreenWidth(context);

    double buttonHeight = height ?? ResponsiveUtils.getResponsiveSize(context, 56);
    double buttonMinWidth = minWidth ?? ResponsiveUtils.getResponsiveSize(context, 120);

    if (screenWidth < 360) {
      buttonHeight = buttonHeight * 0.9;
    }

    final baseStyle = OutlinedButton.styleFrom(
      minimumSize: Size(buttonMinWidth, buttonHeight),
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.getResponsiveSize(context, 24),
        vertical: ResponsiveUtils.getResponsiveSize(context, 12),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getResponsiveSize(context, 16),
        ),
      ),
    );

    return SizedBox(
      width: expanded ? double.infinity : null,
      child: OutlinedButton(
        onPressed: onPressed,
        style: style != null ? baseStyle.merge(style) : baseStyle,
        child: child,
      ),
    );
  }
}