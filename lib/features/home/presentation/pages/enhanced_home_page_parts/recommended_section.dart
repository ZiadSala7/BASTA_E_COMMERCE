part of '../enhanced_home_page.dart';

class _RecommendedSection extends StatelessWidget {
  final List<Map<String, dynamic>> products;
  final VoidCallback onSeeAll;

  const _RecommendedSection({required this.products, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Recommended For You',
          actionLabel: 'See All',
          onActionTap: onSeeAll,
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.58,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return ProductCard(
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
                  SnackBar(content: Text('${product['title']} added to cart!')),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
