import 'package:busta/core/widgets/products/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('product image fits without cropping inside the card', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 160,
              height: 274,
              child: ProductCard(
                id: 'product-1',
                title: 'Product',
                price: '12.00',
                imageUrl: 'https://example.com/product.png',
              ),
            ),
          ),
        ),
      ),
    );

    final image = tester.widget<Image>(find.byType(Image));
    expect(image.fit, BoxFit.contain);
    expect(tester.takeException(), isNull);
  });
}
