import 'package:busta/core/theme/app_theme.dart';
import 'package:busta/core/theme/app_text_styles.dart';
import 'package:busta/core/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppTheme.dark', () {
    final theme = AppTheme.dark(const Locale('en'));

    test('sets every text theme style to pure white', () {
      final styles = <TextStyle?>[
        theme.textTheme.displayLarge,
        theme.textTheme.displayMedium,
        theme.textTheme.displaySmall,
        theme.textTheme.headlineLarge,
        theme.textTheme.headlineMedium,
        theme.textTheme.headlineSmall,
        theme.textTheme.titleLarge,
        theme.textTheme.titleMedium,
        theme.textTheme.titleSmall,
        theme.textTheme.bodyLarge,
        theme.textTheme.bodyMedium,
        theme.textTheme.bodySmall,
        theme.textTheme.labelLarge,
        theme.textTheme.labelMedium,
        theme.textTheme.labelSmall,
      ];

      expect(
        styles.where((style) => style != null).map((style) => style!.color),
        everyElement(Colors.white),
      );
    });

    test('uses contrasting surface and accent colors in dark mode', () {
      expect(theme.colorScheme.onSurface, AppColors.darkTextPrimary);
      expect(theme.colorScheme.onSurfaceVariant, AppColors.darkTextSecondary);
      expect(theme.scaffoldBackgroundColor, AppColors.darkBackground);
      expect(theme.colorScheme.surface, AppColors.darkSurface);
      expect(
        theme.colorScheme.surfaceContainerHighest,
        AppColors.darkElevatedSurface,
      );
      expect(theme.cardTheme.color, AppColors.darkCard);
      expect(theme.inputDecorationTheme.fillColor, AppColors.darkCard);
      expect(
        theme.inputDecorationTheme.hintStyle?.color,
        AppColors.darkTextHint,
      );
      expect(
        theme.textButtonTheme.style!.foregroundColor!.resolve({}),
        AppColors.darkPrimary,
      );
    });

    testWidgets('sets shared primary text styles to white in dark mode', (
      tester,
    ) async {
      late TextStyle darkAuthLink;
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          darkTheme: theme,
          themeMode: ThemeMode.dark,
          home: Builder(
            builder: (context) {
              darkAuthLink = AppTextStyles.authLinkText(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(darkAuthLink.color, Colors.white);
    });

    testWidgets('keeps primary color unchanged in light mode', (tester) async {
      late Color primary;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(const Locale('en')),
          home: Builder(
            builder: (context) {
              primary = AppColors.primaryFor(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(primary, AppColors.primary);
    });
  });
}
