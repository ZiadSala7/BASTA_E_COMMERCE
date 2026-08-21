import 'package:busta/features/products/presentation/widgets/bottom_action_bar.dart';
import 'package:busta/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('BottomActionBar renders correctly with quantity and prices', (
    WidgetTester tester,
  ) async {
    var quantity = 2;
    var addedToCart = false;

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: BottomActionBar(
            quantity: quantity,
            unitPrice: 24.99,
            stockQuantity: 10,
            isOutOfStock: false,
            onQuantityChanged: (newQ) => quantity = newQ,
            onAddToCart: () => addedToCart = true,
            onBuyNow: () {},
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify quantity and total price are rendered
    expect(find.text('2'), findsOneWidget);
    expect(find.text('JD 49.98'), findsOneWidget);

    // Tap Add to Cart button
    await tester.tap(find.byType(ElevatedButton).first);
    expect(addedToCart, isTrue);
  });
}
