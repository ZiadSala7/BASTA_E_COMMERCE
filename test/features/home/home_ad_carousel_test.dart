import 'package:busta/features/home/presentation/widgets/home_ad_carousel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const banner = HomeAdBanner(
    id: 'banner',
    title: 'Promotion',
    buttonText: 'Shop now',
  );

  testWidgets('banner height keeps a responsive wide aspect ratio', (
    tester,
  ) async {
    for (final width in [284.0, 390.0]) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: width,
                child: const HomeAdCarousel(items: [banner]),
              ),
            ),
          ),
        ),
      );

      final pageViewSize = tester.getSize(find.byType(PageView));
      final expectedHeight = (width * 0.86 / 1.9).clamp(120.0, 236.0);

      expect(pageViewSize.height, closeTo(expectedHeight, 0.1));
      expect(tester.takeException(), isNull);
    }
  });
}
