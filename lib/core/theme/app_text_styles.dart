// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import 'app_font_families.dart';
import 'app_font_weights.dart';

class AppTextStyles {
  const AppTextStyles._();

  static String fontFamilyFor(Locale locale) {
    return locale.languageCode == 'ar'
        ? AppFontFamilies.notoSansArabic
        : AppFontFamilies.montserrat;
  }

  static TextTheme textTheme(Locale locale) {
    final fontFamily = fontFamilyFor(locale);

    return TextTheme(
      displayLarge: _base(fontFamily, 36, AppFontWeights.bold, 1.2),
      displayMedium: _base(fontFamily, 32, AppFontWeights.bold, 1.2),
      headlineLarge: _base(fontFamily, 30, AppFontWeights.bold, 1.25),
      headlineMedium: _base(fontFamily, 24, AppFontWeights.bold, 1.3),
      headlineSmall: _base(fontFamily, 22, AppFontWeights.bold, 1.35),
      titleLarge: _base(fontFamily, 20, AppFontWeights.semiBold, 1.35),
      titleMedium: _base(fontFamily, 18, AppFontWeights.semiBold, 1.4),
      titleSmall: _base(fontFamily, 16, AppFontWeights.medium, 1.4),
      bodyLarge: _base(fontFamily, 16, AppFontWeights.regular, 1.6),
      bodyMedium: _base(fontFamily, 14, AppFontWeights.regular, 1.6),
      bodySmall: _base(fontFamily, 12, AppFontWeights.regular, 1.5),
      labelLarge: _base(fontFamily, 16, AppFontWeights.semiBold, 1.25),
      labelMedium: _base(fontFamily, 14, AppFontWeights.medium, 1.25),
      labelSmall: _base(fontFamily, 12, AppFontWeights.medium, 1.2),
    );
  }

  static TextStyle authBrand(BuildContext context) {
    return Theme.of(context).textTheme.titleLarge!.copyWith(
      color: AppColors.primary,
      fontSize: 20,
      fontWeight: AppFontWeights.bold,
    );
  }

  static TextStyle authHeadingTitle(BuildContext context) {
    return Theme.of(context).textTheme.headlineLarge!.copyWith(
      color: Theme.of(context).colorScheme.onSurface,
      fontSize: 25,
      fontWeight: AppFontWeights.bold,
    );
  }

  static TextStyle authHeadingSubtitle(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium!.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
      fontSize: 14,
      height: 1.7,
    );
  }

  static TextStyle authPrimaryButton(BuildContext context) {
    return Theme.of(context).textTheme.labelLarge!.copyWith(
      color: Colors.white,
      fontSize: 17,
      fontWeight: AppFontWeights.bold,
    );
  }

  static TextStyle authSocialButton(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium!.copyWith(
      color: Theme.of(context).colorScheme.onSurface,
      fontSize: 14,
      fontWeight: AppFontWeights.medium,
    );
  }

  static TextStyle authHelperText(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium!.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
      fontSize: 14,
    );
  }

  static TextStyle authLinkText(BuildContext context) {
    return Theme.of(context).textTheme.labelMedium!.copyWith(
      color: AppColors.primary,
      fontSize: 14,
      fontWeight: AppFontWeights.semiBold,
    );
  }

  static TextStyle authSecondaryText(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium!.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
      fontSize: 14,
    );
  }

  static TextStyle onboardingSheetTitle(BuildContext context) {
    return Theme.of(context).textTheme.headlineSmall!.copyWith(
      color: Colors.white,
      fontSize: 22,
      fontWeight: AppFontWeights.bold,
      height: 1.45,
    );
  }

  static TextStyle onboardingSheetSubtitle(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium!.copyWith(
      color: Colors.white.withOpacity(0.78),
      fontSize: 13.5,
      height: 1.75,
    );
  }

  static TextStyle onboardingSheetButton(BuildContext context) {
    return Theme.of(context).textTheme.labelLarge!.copyWith(
      color: AppColors.primary,
      fontSize: 15,
      fontWeight: AppFontWeights.bold,
    );
  }

  static TextStyle onboardingSheetTextAction(BuildContext context) {
    return Theme.of(context).textTheme.labelMedium!.copyWith(
      color: Colors.white.withOpacity(0.72),
      fontSize: 15,
      fontWeight: AppFontWeights.semiBold,
    );
  }

  static TextStyle _base(
    String fontFamily,
    double fontSize,
    FontWeight fontWeight,
    double height,
  ) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
    );
  }
}
