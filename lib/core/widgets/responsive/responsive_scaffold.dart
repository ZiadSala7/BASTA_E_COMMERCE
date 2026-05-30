import 'package:flutter/material.dart';
import '../../responsive/responsive_utils.dart';

/// Responsive scaffold that adjusts padding and layout based on screen size
class ResponsiveScaffold extends StatelessWidget {
  final Widget body;
  final Widget? appBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? bottomNavigationBar;
  final Widget? bottomSheet;
  final Color? backgroundColor;
  final bool resizeToAvoidBottomInset;
  final bool extendBody;
  final bool extendBodyBehindAppBar;
  final EdgeInsetsGeometry? contentPadding;

  const ResponsiveScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.bottomNavigationBar,
    this.bottomSheet,
    this.backgroundColor,
    this.resizeToAvoidBottomInset = true,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = ResponsiveUtils.getScreenWidth(context);
    EdgeInsetsGeometry padding = contentPadding ?? EdgeInsets.zero;

    // Apply responsive padding based on screen width
    if (contentPadding == null) {
      if (screenWidth < 600) {
        // Mobile: smaller padding
        padding = const EdgeInsets.symmetric(horizontal: 16.0);
      } else if (screenWidth < 900) {
        // Tablet: medium padding
        padding = const EdgeInsets.symmetric(horizontal: 24.0);
      } else {
        // Desktop: larger padding with max width
        padding = const EdgeInsets.symmetric(horizontal: 32.0);
      }
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: appBar is PreferredSizeWidget ? appBar as PreferredSizeWidget : null,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomNavigationBar: bottomNavigationBar,
      bottomSheet: bottomSheet,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      extendBody: extendBody,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (screenWidth > 1200) {
            // Desktop: center content with max width
            return Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1200),
                padding: padding,
                child: body,
              ),
            );
          } else {
            // Mobile/Tablet: full width with padding
            return Padding(
              padding: padding,
              child: body,
            );
          }
        },
      ),
    );
  }
}