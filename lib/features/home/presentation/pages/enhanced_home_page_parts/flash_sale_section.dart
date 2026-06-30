part of '../enhanced_home_page.dart';

class _FlashSaleSection extends StatelessWidget {
  final List<Map<String, dynamic>> products;
  final VoidCallback onSeeAll;

  const _FlashSaleSection({required this.products, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'Flash Sale',
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.timer, color: Colors.red, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '02:34:18',
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: onSeeAll,
                child: Text(
                  'See All',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 274,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: products.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final product = products[index];
              return SizedBox(
                width: 160,
                child: ProductCard(
                  id: product['id'],
                  title: product['title'],
                  price: product['price'],
                  oldPrice: product['oldPrice'],
                  imageUrl: product['image'],
                  discountBadge: product['discount'],
                  rating: product['rating']?.toInt(),
                  reviewCount: product['reviews'],
                  onTap: () {
                    context.push(
                      AppRoutes.productDetail,
                      extra: ProductDetailArgs.fromMap(product),
                    );
                  },
                  onFavoriteTap: () {
                    // Toggle favorite
                  },
                  onAddToCart: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${product['title']} added to cart!'),
                      ),
                    );
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
