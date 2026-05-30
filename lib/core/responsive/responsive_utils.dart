import 'package:flutter/material.dart';

/// Utility class for responsive design calculations
class ResponsiveUtils {
  /// Get screen width
  static double getScreenWidth(BuildContext context) {
    return MediaQuery.sizeOf(context).width;
  }

  /// Get screen height
  static double getScreenHeight(BuildContext context) {
    return MediaQuery.sizeOf(context).height;
  }

  /// Get screen aspect ratio
  static double getAspectRatio(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return size.width / size.height;
  }

  /// Check if screen is mobile (width < 600)
  static bool isMobile(BuildContext context) {
    return getScreenWidth(context) < 600;
  }

  /// Check if screen is tablet (width >= 600 and < 1200)
  static bool isTablet(BuildContext context) {
    final width = getScreenWidth(context);
    return width >= 600 && width < 1200;
  }

  /// Check if screen is desktop (width >= 1200)
  static bool isDesktop(BuildContext context) {
    return getScreenWidth(context) >= 1200;
  }

  /// Get responsive font size based on screen width
  static double getResponsiveFontSize(BuildContext context, double baseSize) {
    final screenWidth = getScreenWidth(context);
    // Scale font size based on screen width, but keep it within reasonable bounds
    final scaleFactor = screenWidth / 375.0; // Base on iPhone 14 width
    final scaledSize = baseSize * scaleFactor;
    return scaledSize.clamp(baseSize * 0.8, baseSize * 1.4);
  }

  /// Get responsive spacing based on screen width
  static double getResponsiveSpacing(BuildContext context, double baseSpacing) {
    final screenWidth = getScreenWidth(context);
    final scaleFactor = screenWidth / 375.0;
    return baseSpacing * scaleFactor.clamp(0.8, 1.2);
  }

  /// Get responsive widget size based on screen width
  static double getResponsiveSize(BuildContext context, double baseSize) {
    final screenWidth = getScreenWidth(context);
    final scaleFactor = screenWidth / 375.0;
    return baseSize * scaleFactor.clamp(0.7, 1.3);
  }

  /// Calculate optimal grid columns based on screen width
  static int getGridColumns(BuildContext context) {
    final width = getScreenWidth(context);
    if (width < 400) return 1;
    if (width < 600) return 2;
    if (width < 900) return 3;
    if (width < 1200) return 4;
    return 5;
  }

  /// Get safe area padding
  static EdgeInsets getSafeAreaPadding(BuildContext context) {
    return MediaQuery.paddingOf(context);
  }

  /// Get keyboard inset (visible keyboard height)
  static double getKeyboardInset(BuildContext context) {
    return MediaQuery.viewInsetsOf(context).bottom;
  }
}