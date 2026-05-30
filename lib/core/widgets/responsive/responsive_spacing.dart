import 'package:flutter/material.dart';
import '../../responsive/responsive_utils.dart';

/// Pre-defined responsive spacing constants for consistent layout
class ResponsiveSpacing {
  /// Small spacing (4pt base)
  static Widget get small => const ResponsiveSpacingWidget(baseSpacing: 4.0);

  /// Medium spacing (8pt base)
  static Widget get medium => const ResponsiveSpacingWidget(baseSpacing: 8.0);

  /// Standard spacing (16pt base)
  static Widget get standard => const ResponsiveSpacingWidget(baseSpacing: 16.0);

  /// Large spacing (24pt base)
  static Widget get large => const ResponsiveSpacingWidget(baseSpacing: 24.0);

  /// Extra large spacing (32pt base)
  static Widget get xLarge => const ResponsiveSpacingWidget(baseSpacing: 32.0);

  /// Double extra large spacing (48pt base)
  static Widget get xxLarge => const ResponsiveSpacingWidget(baseSpacing: 48.0);

  /// Custom spacing with specified base value
  static Widget custom(double baseSpacing) =>
      ResponsiveSpacingWidget(baseSpacing: baseSpacing);
}

/// Widget that provides responsive vertical spacing
class ResponsiveSpacingWidget extends StatelessWidget {
  final double baseSpacing;

  const ResponsiveSpacingWidget({
    super.key,
    required this.baseSpacing,
  });

  @override
  Widget build(BuildContext context) {
    final responsiveSpacing =
        ResponsiveUtils.getResponsiveSpacing(context, baseSpacing);
    return SizedBox(height: responsiveSpacing);
  }
}