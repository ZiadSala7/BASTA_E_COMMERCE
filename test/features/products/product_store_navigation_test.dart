import 'package:busta/core/utils/app_router.dart';
import 'package:busta/features/products/presentation/models/product_detail_args.dart';
import 'package:busta/features/products/presentation/pages/products_listing_page.dart';
import 'package:busta/features/products/presentation/widgets/product_info_section.dart';
import 'package:busta/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('tapping the store name opens its product listing', (
    tester,
  ) async {
    late final GoRouter router;
    router = GoRouter(
      initialLocation: '/product',
      routes: [
        GoRoute(
          path: '/product',
          builder: (context, state) => const Scaffold(
            body: SingleChildScrollView(
              child: ProductInfoSection(
                product: ProductDetailArgs(
                  id: 'product-1',
                  title: 'Product',
                  price: 'JD 10.00',
                  storeName: 'Barakat Store',
                  storeSlug: 'barakat-store',
                ),
              ),
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.products,
          builder: (context, state) {
            final args = state.extra! as ProductsListingArgs;
            return Scaffold(body: Text('${args.title}:${args.storeSlug}'));
          },
        ),
        GoRoute(
          path: AppRoutes.stores,
          builder: (context, state) => const Scaffold(body: Text('All stores')),
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
    await tester.tap(find.text('Barakat Store'));
    await tester.pumpAndSettle();

    expect(find.text('Barakat Store:barakat-store'), findsOneWidget);

    router.pop();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Stores'));
    await tester.pumpAndSettle();

    expect(find.text('All stores'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    router.dispose();
  });
}
