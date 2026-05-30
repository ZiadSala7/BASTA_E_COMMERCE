import 'package:flutter/material.dart';
import '../../responsive/responsive_utils.dart';
import 'responsive_text.dart';

/// Responsive app bar that adjusts height and content based on screen size
class ResponsiveAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final String? titleText;
  final List<Widget>? actions;
  final Widget? leading;
  final PreferredSizeWidget? bottom;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final bool? centerTitle;
  final double? titleSpacing;

  const ResponsiveAppBar({
    super.key,
    this.title,
    this.titleText,
    this.actions,
    this.leading,
    this.bottom,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.centerTitle,
    this.titleSpacing,
  });

  @override
  Widget build(BuildContext context) {
    final _ = ResponsiveUtils.getScreenWidth(context);

    // Adjust app bar height based on screen size
    double _ = ResponsiveUtils.isMobile(context) ? 56 : 64;

    // Adjust title font size based on screen size
    double titleFontSize = ResponsiveUtils.isMobile(context) ? 18 : 20;

    Widget actualTitle =
        title ??
        (titleText != null
            ? ResponsiveText(
                titleText!,
                fontSize: titleFontSize,
                fontWeight: FontWeight.w600,
                color:
                    foregroundColor ??
                    Theme.of(context).appBarTheme.foregroundColor,
              )
            : const SizedBox.shrink());

    return AppBar(
      title: actualTitle,
      actions: actions,
      leading: leading,
      bottom: bottom,
      backgroundColor:
          backgroundColor ?? Theme.of(context).appBarTheme.backgroundColor,
      foregroundColor:
          foregroundColor ?? Theme.of(context).appBarTheme.foregroundColor,
      elevation: elevation ?? Theme.of(context).appBarTheme.elevation,
      centerTitle: centerTitle ?? true,
      titleSpacing: titleSpacing,
    );
  }

  @override
  Size get preferredSize {
    double height = 56;
    if (bottom != null) {
      height += bottom!.preferredSize.height;
    }
    return Size.fromHeight(height);
  }
}

/// Responsive SliverAppBar for use in CustomScrollView
class ResponsiveSliverAppBar extends StatelessWidget {
  final Widget? title;
  final String? titleText;
  final List<Widget>? actions;
  final Widget? leading;
  final Widget? flexibleSpace;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final bool? centerTitle;
  final bool pinned;
  final bool floating;
  final bool expanded;
  final double? collapsedHeight;
  final double? expandedHeight;
  final PreferredSizeWidget? bottom;

  const ResponsiveSliverAppBar({
    super.key,
    this.title,
    this.titleText,
    this.actions,
    this.leading,
    this.flexibleSpace,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.centerTitle,
    this.pinned = true,
    this.floating = false,
    this.expanded = false,
    this.collapsedHeight,
    this.expandedHeight,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    double finalExpandedHeight =
        expandedHeight ?? (ResponsiveUtils.isMobile(context) ? 200 : 250);
    double finalCollapsedHeight =
        collapsedHeight ?? (ResponsiveUtils.isMobile(context) ? 56 : 64);

    Widget actualTitle =
        title ??
        (titleText != null
            ? ResponsiveText(
                titleText!,
                fontSize: ResponsiveUtils.isMobile(context) ? 18 : 20,
                fontWeight: FontWeight.w600,
                color: foregroundColor,
              )
            : const SizedBox.shrink());

    return SliverAppBar(
      title: actualTitle,
      actions: actions,
      leading: leading,
      flexibleSpace: flexibleSpace,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: elevation,
      centerTitle: centerTitle ?? true,
      pinned: pinned,
      floating: floating,
      collapsedHeight: finalCollapsedHeight,
      expandedHeight: finalExpandedHeight,
      bottom: bottom,
    );
  }
}
