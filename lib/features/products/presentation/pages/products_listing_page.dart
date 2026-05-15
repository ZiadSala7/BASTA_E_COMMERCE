import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/widgets/common/custom_app_bar.dart';
import '../../../../core/widgets/common/section_header.dart';
import '../../../../core/widgets/common/selectable_tile.dart';
import '../../../../core/widgets/status/empty_state.dart';
import '../../../../core/widgets/products/product_card.dart';
import '../../../../core/utils/app_colors.dart';
import 'product_detail_page.dart';

class ProductsListingPage extends StatefulWidget {
  final String? category;
  final String? storeId;

  const ProductsListingPage({super.key, this.category, this.storeId});

  @override
  State<ProductsListingPage> createState() => _ProductsListingPageState();
}

class _ProductsListingPageState extends State<ProductsListingPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String _searchQuery = '';
  String _sortBy = 'popular';
  double _minPrice = 0;
  double _maxPrice = 1000;
  bool _showOnlySales = false;

  // Demo data
  final List<Map<String, dynamic>> _products = [
    {
      'id': '1',
      'title': 'Elegant Summer Dress with Floral Pattern',
      'price': 'JD 89.99',
      'oldPrice': 'JD 129.99',
      'rating': 4.8,
      'reviews': 234,
      'discount': '-31%',
      'image':
          'https://images.unsplash.com/photo-1523293182086-7651a899d37f?auto=format&fit=crop&w=400&q=85',
    },
    {
      'id': '2',
      'title': 'Premium Cotton Shirt',
      'price': 'JD 45.99',
      'rating': 4.5,
      'reviews': 156,
      'image':
          'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?auto=format&fit=crop&w=400&q=85',
    },
    {
      'id': '3',
      'title': 'Designer Handbag Collection',
      'price': 'JD 159.99',
      'oldPrice': 'JD 199.99',
      'rating': 4.9,
      'reviews': 89,
      'discount': '-20%',
      'image':
          'https://images.unsplash.com/photo-1584917865442-de89df76afd3?auto=format&fit=crop&w=400&q=85',
    },
    {
      'id': '4',
      'title': 'Classic Denim Jeans',
      'price': 'JD 65.99',
      'rating': 4.3,
      'reviews': 312,
      'image':
          'https://images.unsplash.com/photo-1542272604-787c3835535d?auto=format&fit=crop&w=400&q=85',
    },
    {
      'id': '5',
      'title': 'Luxury Watch Collection',
      'price': 'JD 299.99',
      'oldPrice': 'JD 399.99',
      'rating': 4.7,
      'reviews': 67,
      'discount': '-25%',
      'image':
          'https://images.unsplash.com/photo-1524592094714-0f0654e20314?auto=format&fit=crop&w=400&q=85',
    },
    {
      'id': '6',
      'title': 'Comfortable Sneakers',
      'price': 'JD 89.99',
      'rating': 4.6,
      'reviews': 445,
      'image':
          'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=400&q=85',
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
      body: Column(
        children: [
          // Custom App Bar with Search
          CustomAppBar(
            title: widget.category ?? 'All Products',
            showSearch: true,
            searchController: _searchController,
            searchHint: 'Search products...',
            onSearchChanged: (value) => setState(() => _searchQuery = value),
            actions: [
              IconButton(
                onPressed: _showFilterBottomSheet,
                icon: const Icon(Icons.filter_list),
              ),
            ],
          ),
          // Active Filters Bar
          _ActiveFiltersBar(
            sortBy: _sortBy,
            onSortChanged: (value) => setState(() => _sortBy = value),
            onClearFilters: _clearFilters,
          ),
          // Products Grid
          Expanded(child: _buildProductsGrid()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showFilterBottomSheet,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.filter_list),
      ),
    );
  }

  Widget _buildProductsGrid() {
    final filteredProducts = _products.where((product) {
      // Apply search filter
      if (_searchQuery.isNotEmpty) {
        final searchLower = _searchQuery.toLowerCase();
        final title = product['title'].toString().toLowerCase();
        if (!title.contains(searchLower)) return false;
      }

      // Apply sales filter
      if (_showOnlySales && product['oldPrice'] == null) return false;

      final price = _priceValue(product['price'].toString());
      if (price < _minPrice || price > _maxPrice) return false;

      return true;
    }).toList()..sort(_sortProducts);

    if (filteredProducts.isEmpty) {
      return EmptyState(
        icon: Icons.search_off_rounded,
        title: 'No products found',
        message: 'Try a different search, price range, or sale filter.',
        actionLabel: 'Clear Filters',
        onActionTap: _clearFilters,
      );
    }

    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.58,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        final product = filteredProducts[index];
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
            // Navigate to product detail
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductDetailPage(productId: product['id']),
              ),
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
    );
  }

  int _sortProducts(Map<String, dynamic> a, Map<String, dynamic> b) {
    switch (_sortBy) {
      case 'newest':
        return b['id'].toString().compareTo(a['id'].toString());
      case 'price_low':
        return _priceValue(
          a['price'].toString(),
        ).compareTo(_priceValue(b['price'].toString()));
      case 'price_high':
        return _priceValue(
          b['price'].toString(),
        ).compareTo(_priceValue(a['price'].toString()));
      case 'rating':
        return ((b['rating'] as num?) ?? 0).compareTo(
          (a['rating'] as num?) ?? 0,
        );
      case 'popular':
      default:
        return ((b['reviews'] as num?) ?? 0).compareTo(
          (a['reviews'] as num?) ?? 0,
        );
    }
  }

  double _priceValue(String price) {
    return double.tryParse(price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _FilterBottomSheet(
        currentMinPrice: _minPrice,
        currentMaxPrice: _maxPrice,
        currentSortBy: _sortBy,
        showOnlySales: _showOnlySales,
        onApplyFilters: (minPrice, maxPrice, sortBy, showOnlySales) {
          setState(() {
            _minPrice = minPrice;
            _maxPrice = maxPrice;
            _sortBy = sortBy;
            _showOnlySales = showOnlySales;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _searchController.clear();
      _sortBy = 'popular';
      _minPrice = 0;
      _maxPrice = 1000;
      _showOnlySales = false;
    });
  }
}

class _ActiveFiltersBar extends StatelessWidget {
  final String sortBy;
  final ValueChanged<String> onSortChanged;
  final VoidCallback onClearFilters;

  const _ActiveFiltersBar({
    required this.sortBy,
    required this.onSortChanged,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: const Border(
          bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
      ),
      child: Row(
        children: [
          Text(
            'Sort',
            style: GoogleFonts.cairo(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          // Sort Dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: sortBy,
                onChanged: (value) {
                  if (value != null) onSortChanged(value);
                },
                items:
                    [
                      'popular',
                      'newest',
                      'price_low',
                      'price_high',
                      'rating',
                    ].map((value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          _getSortLabel(value),
                          style: GoogleFonts.cairo(fontSize: 13),
                        ),
                      );
                    }).toList(),
              ),
            ),
          ),
          const Spacer(),
          // Clear Filters
          TextButton(
            onPressed: onClearFilters,
            child: Text(
              'Clear Filters',
              style: GoogleFonts.cairo(fontSize: 13, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  String _getSortLabel(String sortValue) {
    switch (sortValue) {
      case 'popular':
        return 'Most Popular';
      case 'newest':
        return 'Newest';
      case 'price_low':
        return 'Price: Low to High';
      case 'price_high':
        return 'Price: High to Low';
      case 'rating':
        return 'Top Rated';
      default:
        return 'Sort By';
    }
  }
}

class _FilterBottomSheet extends StatefulWidget {
  final double currentMinPrice;
  final double currentMaxPrice;
  final String currentSortBy;
  final bool showOnlySales;
  final Function(double, double, String, bool) onApplyFilters;

  const _FilterBottomSheet({
    required this.currentMinPrice,
    required this.currentMaxPrice,
    required this.currentSortBy,
    required this.showOnlySales,
    required this.onApplyFilters,
  });

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  late double _minPrice;
  late double _maxPrice;
  late String _sortBy;
  late bool _showOnlySales;

  @override
  void initState() {
    super.initState();
    _minPrice = widget.currentMinPrice;
    _maxPrice = widget.currentMaxPrice;
    _sortBy = widget.currentSortBy;
    _showOnlySales = widget.showOnlySales;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      height: MediaQuery.of(context).size.height * 0.86,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter Products',
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(
                    title: 'Price Range',
                    subtitle:
                        'Choose the shopping budget that fits this browse.',
                    padding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 12),
                  RangeSlider(
                    values: RangeValues(_minPrice, _maxPrice),
                    min: 0,
                    max: 1000,
                    divisions: 20,
                    labels: RangeLabels(
                      'JD ${_minPrice.toInt()}',
                      'JD ${_maxPrice.toInt()}',
                    ),
                    onChanged: (values) {
                      setState(() {
                        _minPrice = values.start;
                        _maxPrice = values.end;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  const SectionHeader(
                    title: 'Sort By',
                    padding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 12),
                  _buildSortOptions(),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        'Show Sale Items Only',
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Switch(
                        value: _showOnlySales,
                        onChanged: (value) =>
                            setState(() => _showOnlySales = value),
                        activeThumbColor: AppColors.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Apply Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => widget.onApplyFilters(
                _minPrice,
                _maxPrice,
                _sortBy,
                _showOnlySales,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Apply Filters',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortOptions() {
    final options = [
      {'value': 'popular', 'label': 'Most Popular', 'icon': Icons.trending_up},
      {'value': 'newest', 'label': 'Newest First', 'icon': Icons.fiber_new},
      {
        'value': 'price_low',
        'label': 'Price: Low to High',
        'icon': Icons.arrow_upward,
      },
      {
        'value': 'price_high',
        'label': 'Price: High to Low',
        'icon': Icons.arrow_downward,
      },
      {'value': 'rating', 'label': 'Top Rated', 'icon': Icons.star},
    ];

    return Column(
      children: options.map((option) {
        final isSelected = _sortBy == option['value'];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: SelectableTile(
            selected: isSelected,
            onTap: () => setState(() => _sortBy = option['value'] as String),
            leading: Icon(
              option['icon'] as IconData,
              color: isSelected ? AppColors.primary : const Color(0xFF6B7280),
            ),
            title: option['label'] as String,
          ),
        );
      }).toList(),
    );
  }
}
