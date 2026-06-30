part of '../enhanced_home_page.dart';

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
