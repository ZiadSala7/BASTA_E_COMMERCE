import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/widgets/products/product_card.dart';
import '../models/product_detail_args.dart';
import '../pages/product_detail_page.dart' show ProductDetailPage;

class RelatedProductsSection extends StatelessWidget {
  const RelatedProductsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Show placeholder related products for demo
    // In production, this would come from API data
    final demoProducts = List.generate(4, (index) {
      return ProductDetailArgs(
        id: 'related_$index',
        title: 'Elegant Summer Dress',
        price: 'JD ${79 + index * 10}',
        oldPrice: index.isEven ? 'JD ${99 + index * 10}' : null,
        discountBadge: index.isEven ? '-20%' : null,
        rating: 4 + (index % 2),
        reviewCount: 120 + index * 20,
      );
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'You May Also Like',
          style: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 244,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: demoProducts.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final product = demoProducts[index];

              return SizedBox(
                width: 160,
                child: ProductCard(
                  id: product.id,
                  title: product.title,
                  price: product.price,
                  oldPrice: product.oldPrice,
                  rating: product.rating?.toInt(),
                  reviewCount: product.reviewCount,
                  discountBadge: product.discountBadge,
                  imageUrl: product.imageUrl,
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailPage(
                          productId: product.id,
                          product: product,
                        ),
                      ),
                    );
                  },
                  onFavoriteTap: () {
                    // Toggle favorite
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
