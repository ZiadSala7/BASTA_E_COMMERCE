// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_router.dart';
import '../../../../core/widgets/common/custom_app_bar.dart';
import '../../../../core/widgets/common/section_header.dart';
import '../../../../core/widgets/products/product_card.dart';
import '../../../products/presentation/pages/product_detail_page.dart';

class EnhancedHomePage extends StatefulWidget {
  final VoidCallback? onMenuPressed;

  const EnhancedHomePage({super.key, this.onMenuPressed});

  @override
  State<EnhancedHomePage> createState() => _EnhancedHomePageState();
}

class _EnhancedHomePageState extends State<EnhancedHomePage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Demo data
  final List<Map<String, dynamic>> _categories = [
    {
      'icon': Icons.woman,
      'label': 'Women Fashion',
      'color': const Color(0xFFFF6B8B),
    },
    {
      'icon': Icons.man,
      'label': 'Men Fashion',
      'color': const Color(0xFF4ECDC4),
    },
    {
      'icon': Icons.phone_android,
      'label': 'Electronics',
      'color': const Color(0xFF45B7D1),
    },
    {
      'icon': Icons.home,
      'label': 'Home & Garden',
      'color': const Color(0xFF96CEB4),
    },
    {
      'icon': Icons.sports_soccer,
      'label': 'Sports',
      'color': const Color(0xFFFFD93D),
    },
    {
      'icon': Icons.child_care,
      'label': 'Kids',
      'color': const Color(0xFFC7CEEA),
    },
  ];

  final List<Map<String, dynamic>> _flashSaleProducts = [
    {
      'id': '1',
      'title': 'Premium Leather Handbag',
      'price': 'JD 79.99',
      'oldPrice': 'JD 129.99',
      'discount': '-38%',
      'rating': 4.8,
      'reviews': 234,
      'image':
          'https://images.unsplash.com/photo-1584917865442-de89df76afd3?auto=format&fit=crop&w=400&q=85',
      'timeLeft': '2h 34m',
    },
    {
      'id': '2',
      'title': 'Wireless Earbuds Pro',
      'price': 'JD 45.99',
      'oldPrice': 'JD 69.99',
      'discount': '-34%',
      'rating': 4.6,
      'reviews': 189,
      'image':
          'https://images.unsplash.com/photo-1590658268037-6bf12165a8df?auto=format&fit=crop&w=400&q=85',
      'timeLeft': '4h 12m',
    },
    {
      'id': '3',
      'title': 'Smart Watch Series 5',
      'price': 'JD 199.99',
      'oldPrice': 'JD 299.99',
      'discount': '-33%',
      'rating': 4.9,
      'reviews': 567,
      'image':
          'https://images.unsplash.com/photo-1523275335684-37898b6baf30?auto=format&fit=crop&w=400&q=85',
      'timeLeft': '1h 45m',
    },
  ];

  final List<Map<String, dynamic>> _recommendedProducts = [
    {
      'id': '4',
      'title': 'Designer Sunglasses',
      'price': 'JD 59.99',
      'rating': 4.7,
      'reviews': 312,
      'image':
          'https://images.unsplash.com/photo-1572635196237-14b3f281503f?auto=format&fit=crop&w=400&q=85',
    },
    {
      'id': '5',
      'title': 'Luxury Perfume Collection',
      'price': 'JD 89.99',
      'oldPrice': 'JD 120.00',
      'discount': '-25%',
      'rating': 4.8,
      'reviews': 445,
      'image':
          'https://images.unsplash.com/photo-1541643600914-78b084683601?auto=format&fit=crop&w=400&q=85',
    },
    {
      'id': '6',
      'title': 'Fitness Tracker Band',
      'price': 'JD 34.99',
      'rating': 4.5,
      'reviews': 223,
      'image':
          'https://images.unsplash.com/photo-1575311373937-040b8e1fd5b6?auto=format&fit=crop&w=400&q=85',
    },
    {
      'id': '7',
      'title': 'Ceramic Vase Set',
      'price': 'JD 29.99',
      'rating': 4.3,
      'reviews': 89,
      'image':
          'https://images.unsplash.com/photo-1578500494198-246f612d3b3d?auto=format&fit=crop&w=400&q=85',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Enhanced App Bar
          SliverToBoxAdapter(
            child: CustomAppBar(
              title: 'Busta Store',
              showSearch: true,
              searchController: _searchController,
              searchHint: 'Search products...',
            ),
          ),

          // Main Content
          SliverPadding(
            padding: const EdgeInsets.only(top: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Categories Section
                _CategoriesSection(categories: _categories),

                const SizedBox(height: 24),

                // Flash Sale Section
                _FlashSaleSection(
                  products: _flashSaleProducts,
                  onSeeAll: () =>
                      context.push(AppRoutes.products, extra: 'Flash Sale'),
                ),

                const SizedBox(height: 24),

                // Banner Ad
                _PromoBanner(),

                const SizedBox(height: 24),

                // Recommended Products
                _RecommendedSection(
                  products: _recommendedProducts,
                  onSeeAll: () => context.push(AppRoutes.products),
                ),

                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoriesSection extends StatelessWidget {
  final List<Map<String, dynamic>> categories;

  const _CategoriesSection({required this.categories});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Categories',
          actionLabel: 'See All',
          onActionTap: () => context.push(AppRoutes.products),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 90,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final category = categories[index];
              return _CategoryItem(
                icon: category['icon'],
                label: category['label'],
                color: category['color'],
                onTap: () {
                  context.push(AppRoutes.products, extra: category['label']);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _CategoryItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
}

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

class _PromoBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 120,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [AppColors.primary, Color(0xFF7C86FF)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Summer Sale',
                        style: GoogleFonts.cairo(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Up to 50% Off',
                        style: GoogleFonts.cairo(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Shop Now',
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.shopping_bag, size: 60, color: Colors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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
