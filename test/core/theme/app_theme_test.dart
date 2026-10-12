import 'package:busta/core/theme/app_theme.dart';
import 'package:busta/core/theme/app_text_styles.dart';
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

    test('uses pure white for inherited secondary and button text', () {
      expect(theme.colorScheme.onSurface, Colors.white);
      expect(theme.colorScheme.onSurfaceVariant, Colors.white);
      expect(
        theme.textButtonTheme.style!.foregroundColor!.resolve({}),
        Colors.white,
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
  });
}
