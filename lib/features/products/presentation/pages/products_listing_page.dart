import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/extensions/app_localizations_x.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/widgets/common/custom_app_bar.dart';
import '../../../../core/widgets/common/section_header.dart';
import '../../../../core/widgets/common/selectable_tile.dart';
import '../../../../core/widgets/products/product_card.dart';
import '../../../../core/widgets/status/empty_state.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../cart/domain/usecases/add_cart_item_usecase.dart';
import '../../../favorites/domain/services/favorites_controller.dart';
import '../../../home/domain/entities/home_product_entity.dart';
import '../../../home/domain/usecases/get_home_products_usecase.dart';
import 'product_detail_page.dart';

class ProductsListingArgs {
  final String? categorySlug;
  final String? storeSlug;
  final String? title;

  const ProductsListingArgs({this.categorySlug, this.storeSlug, this.title});
}

class ProductsListingPage extends StatefulWidget {
  final ProductsListingArgs? args;
  final String? category;
  final String? storeId;

  const ProductsListingPage({
    super.key,
    this.args,
    this.category,
    this.storeId,
  });

  @override
  State<ProductsListingPage> createState() => _ProductsListingPageState();
}

class _ProductsListingPageState extends State<ProductsListingPage> {
  static const int _pageLimit = 10;

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late final GetHomeProductsUseCase _getProducts;
  late final AddCartItemUseCase _addCartItem;
  late final FavoritesController _favoritesController;

  final List<HomeProductEntity> _products = [];
  final Set<String> _addingProductIds = <String>{};
  String _searchQuery = '';
  String _sortBy = 'newest';
  double _minPrice = 0;
  double _maxPrice = 10000;
  bool _showOnlySales = false;
  bool _isLoadingInitial = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _errorMessage;
  int _page = 1;

  String? get _categorySlug => widget.args?.categorySlug;
  String? get _storeSlug => widget.args?.storeSlug ?? widget.storeId;
  String get _screenTitle =>
      widget.args?.title ?? widget.category ?? 'All Products';

  @override
  void initState() {
    super.initState();
    _getProducts = sl<GetHomeProductsUseCase>();
    _addCartItem = sl<AddCartItemUseCase>();
    _favoritesController = sl<FavoritesController>();
    _favoritesController.refresh();
    _scrollController.addListener(_onScroll);
    _loadFirstPage();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  Future<void> _loadFirstPage() async {
    setState(() {
      _page = 1;
      _products.clear();
      _hasMore = true;
      _errorMessage = null;
      _isLoadingInitial = true;
    });

    try {
      final products = await _fetchPage(_page);
      if (!mounted) return;

      setState(() {
        _products.addAll(products);
        _hasMore = products.length == _pageLimit;
        _isLoadingInitial = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = _cleanError(error);
        _isLoadingInitial = false;
      });
    }
  }

  Future<void> _loadNextPage() async {
    if (_isLoadingInitial || _isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
      _errorMessage = null;
    });

    try {
      final nextPage = _page + 1;
      final products = await _fetchPage(nextPage);
      if (!mounted) return;

      setState(() {
        _page = nextPage;
        _products.addAll(products);
        _hasMore = products.length == _pageLimit;
        _isLoadingMore = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = _cleanError(error);
        _isLoadingMore = false;
      });
    }
  }

  Future<List<HomeProductEntity>> _fetchPage(int page) {
    return _getProducts(
      categorySlug: _categorySlug,
      storeSlug: _storeSlug,
      page: page,
      limit: _pageLimit,
    );
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    if (position.extentAfter < 320) {
      _loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          CustomAppBar(
            title: _screenTitle,
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
          _ActiveFiltersBar(
            sortBy: _sortBy,
            onSortChanged: (value) => setState(() => _sortBy = value),
            onClearFilters: _clearFilters,
          ),
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
    if (_isLoadingInitial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_products.isEmpty && _errorMessage != null) {
      return EmptyState(
        icon: Icons.wifi_off_rounded,
        title: 'Could not load products',
        message: _errorMessage,
        actionLabel: 'Try Again',
        onActionTap: _loadFirstPage,
      );
    }

    final filteredProducts = _filteredProducts();

    if (filteredProducts.isEmpty) {
      return EmptyState(
        icon: Icons.search_off_rounded,
        title: 'No products found',
        message: 'Try a different search, price range, or sale filter.',
        actionLabel: 'Clear Filters',
        onActionTap: _clearFilters,
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await Future.wait([_loadFirstPage(), _favoritesController.refresh()]);
      },
      child: AnimatedBuilder(
        animation: _favoritesController,
        builder: (context, child) {
          return GridView.builder(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.58,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: filteredProducts.length + (_isLoadingMore ? 2 : 0),
            itemBuilder: (context, index) {
              if (index >= filteredProducts.length) {
                return const Center(child: CircularProgressIndicator());
              }

              final product = filteredProducts[index];
              return ProductCard(
                id: product.id,
                title: product.name,
                price: _formatPrice(product.price),
                oldPrice: product.compareAtPrice == null
                    ? null
                    : _formatPrice(product.compareAtPrice),
                imageUrl: product.imageUrl,
                discountBadge: _discountLabel(product),
                isFavorite: _favoritesController.isFavorite(product.id),
                isFavoriteUpdating: _favoritesController.isUpdating(product.id),
                isAddingToCart: _addingProductIds.contains(product.id),
                onTap: () {
                  final detail = _detailArgs(product);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetailPage(
                        productId: detail.id,
                        product: detail,
                      ),
                    ),
                  );
                },
                onFavoriteTap: () => _toggleFavorite(product),
                onAddToCart: () => _addProductToCart(product),
              );
            },
          );
        },
      ),
    );
  }

  List<HomeProductEntity> _filteredProducts() {
    final products = _products.where((product) {
      if (_searchQuery.isNotEmpty) {
        final searchLower = _searchQuery.toLowerCase();
        if (!product.name.toLowerCase().contains(searchLower)) return false;
      }

      if (_showOnlySales && !product.hasDiscount) return false;

      final price = product.price ?? 0;
      if (price < _minPrice || price > _maxPrice) return false;

      return true;
    }).toList();

    products.sort(_sortProducts);
    return products;
  }

  int _sortProducts(HomeProductEntity a, HomeProductEntity b) {
    switch (_sortBy) {
      case 'price_low':
        return (a.price ?? 0).compareTo(b.price ?? 0);
      case 'price_high':
        return (b.price ?? 0).compareTo(a.price ?? 0);
      case 'sale':
        final aDiscount = (a.compareAtPrice ?? a.price ?? 0) - (a.price ?? 0);
        final bDiscount = (b.compareAtPrice ?? b.price ?? 0) - (b.price ?? 0);
        return bDiscount.compareTo(aDiscount);
      case 'newest':
      default:
        return b.id.compareTo(a.id);
    }
  }

  ProductDetailArgs _detailArgs(HomeProductEntity product) {
    return ProductDetailArgs(
      id: product.id,
      title: product.name,
      price: _formatPrice(product.price),
      oldPrice: product.compareAtPrice == null
          ? null
          : _formatPrice(product.compareAtPrice),
      imageUrl: product.imageUrl,
      discountBadge: _discountLabel(product),
    );
  }

  String _formatPrice(double? value) {
    if (value == null) return '';
    final formatted = value % 1 == 0
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(2);
    return 'JOD $formatted';
  }

  String? _discountLabel(HomeProductEntity product) {
    if (!product.hasDiscount) return null;

    final discount =
        ((product.compareAtPrice! - product.price!) /
                product.compareAtPrice! *
                100)
            .round();
    return '$discount%';
  }

  String _cleanError(Object error) {
    return error.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
  }

  Future<void> _addProductToCart(HomeProductEntity product) async {
    if (_addingProductIds.contains(product.id)) return;

    setState(() => _addingProductIds.add(product.id));
    try {
      await _addCartItem(productId: product.id, quantity: 1);
      if (!mounted) return;

      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              l10n.pick(
                ar: 'تمت إضافة ${product.name} إلى السلة',
                en: '${product.name} added to cart',
              ),
            ),
          ),
        );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(_cleanError(error))));
    } finally {
      if (mounted) {
        setState(() => _addingProductIds.remove(product.id));
      }
    }
  }

  Future<void> _toggleFavorite(HomeProductEntity product) async {
    try {
      await _favoritesController.toggle(product.id);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(_cleanError(error))));
    }
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
      _sortBy = 'newest';
      _minPrice = 0;
      _maxPrice = 10000;
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
                items: ['newest', 'price_low', 'price_high', 'sale'].map((
                  value,
                ) {
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
      case 'newest':
        return 'Newest';
      case 'price_low':
        return 'Price: Low to High';
      case 'price_high':
        return 'Price: High to Low';
      case 'sale':
        return 'Best Sale';
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
                    max: 10000,
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
      {'value': 'sale', 'label': 'Best Sale', 'icon': Icons.local_offer},
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
