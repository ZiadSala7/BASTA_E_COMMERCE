import 'package:busta/core/widgets/custom_app_bar.dart';
import 'package:busta/core/widgets/common/custom_app_bar.dart' as common;
import 'package:busta/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('shows a functional back button on pushed routes', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/home',
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => context.push('/detail'),
                child: const Text('Open detail'),
              ),
            ),
          ),
        ),
        GoRoute(
          path: '/detail',
          builder: (context, state) => const Scaffold(
            appBar: CustomAppBar(
              showSearch: false,
              showLogo: false,
              showMenuButton: false,
              showNotificationButton: false,
            ),
            body: Text('Detail page'),
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
      ),
    );
    await tester.tap(find.text('Open detail'));
    await tester.pumpAndSettle();

    expect(find.text('Detail page'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Open detail'), findsOneWidget);
  });

  testWidgets('back button opens the main page for a standalone route', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/detail',
      routes: [
        GoRoute(
          path: '/detail',
          builder: (context, state) => const Scaffold(
            appBar: CustomAppBar(
              showSearch: false,
              showLogo: false,
              showMenuButton: false,
              showNotificationButton: false,
              showBackButton: true,
            ),
            body: Text('Detail page'),
          ),
        ),
        GoRoute(
          path: '/mainNavigation',
          builder: (context, state) => const Scaffold(body: Text('Main page')),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('ar'),
      ),
    );

    expect(find.byTooltip('رجوع'), findsOneWidget);
    expect(Icons.arrow_back_rounded.matchTextDirection, isTrue);
    await tester.tap(find.byTooltip('رجوع'));
    await tester.pumpAndSettle();

    expect(find.text('Main page'), findsOneWidget);
  });

  testWidgets('search input follows the active locale direction', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/search',
      routes: [
        GoRoute(
          path: '/search',
          builder: (context, state) => const Scaffold(
            appBar: CustomAppBar(
              showSearch: true,
              showLogo: false,
              showMenuButton: false,
              showNotificationButton: false,
            ),
          ),
        ),
      ],
    );

    for (final locale in const [Locale('en'), Locale('ar')]) {
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      );

      final field = tester.widget<TextField>(find.byType(TextField));
      expect(
        field.textDirection,
        locale.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      );
      expect(tester.takeException(), isNull);
    }

    await tester.pumpWidget(const SizedBox.shrink());
    router.dispose();
  });

  testWidgets('shared page app bar uses localized search copy', (tester) async {
    for (final locale in const [Locale('en'), Locale('ar')]) {
      await tester.pumpWidget(
        MaterialApp(
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(
            appBar: common.CustomAppBar(showSearch: true),
          ),
        ),
      );

      final field = tester.widget<TextField>(find.byType(TextField));
      expect(
        field.decoration?.hintText,
        locale.languageCode == 'ar'
            ? 'هل تبحث عن منتج معين؟'
            : 'Are you looking for a specific product?',
      );
      expect(
        tester.widget<EditableText>(find.byType(EditableText)).textDirection,
        locale.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      );
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('brand header places actions at the directional end', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/header',
      routes: [
        GoRoute(
          path: '/header',
          builder: (context, state) => const Scaffold(
            appBar: CustomAppBar(
              showSearch: false,
              showLogo: false,
            ),
          ),
        ),
      ],
    );

    for (final locale in const [Locale('en'), Locale('ar')]) {
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      );

      final menuX = tester.getCenter(find.byIcon(Icons.menu_rounded)).dx;
      final name = locale.languageCode == 'ar' ? 'بسطة الثقافي' : 'Basta Cultural';
      final nameX = tester.getCenter(find.text(name)).dx;
      expect(
        locale.languageCode == 'ar' ? menuX < nameX : menuX > nameX,
        isTrue,
      );
      expect(tester.takeException(), isNull);
    }

    await tester.pumpWidget(const SizedBox.shrink());
    router.dispose();
  });

  testWidgets('hidden back button stays hidden on a tab route', (tester) async {
    final router = GoRouter(
      initialLocation: '/home',
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => context.push('/coupons'),
                child: const Text('Open coupons'),
              ),
            ),
          ),
        ),
        GoRoute(
          path: '/coupons',
          builder: (context, state) => const Scaffold(
            appBar: CustomAppBar(
              title: 'My Rewards & Coupons',
              showSearch: false,
              showMenuButton: false,
              showNotificationButton: false,
              hideBackButton: true,
            ),
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
    await tester.tap(find.text('Open coupons'));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.arrow_back_rounded), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    router.dispose();
  });
}
