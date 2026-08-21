part of '../products_listing_page.dart';

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
  String _screenTitle(AppLocalizations l10n) =>
      widget.args?.title ??
      widget.category ??
      l10n.pick(ar: 'كل المنتجات', en: 'All Products');

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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Column(
        children: [
          CustomAppBar(
            title: _screenTitle(l10n),
            showSearch: true,
            searchController: _searchController,
            searchHint: l10n.pick(
              ar: 'ابحث عن المنتجات...',
              en: 'Search products...',
            ),
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
    final l10n = AppLocalizations.of(context)!;

    if (_isLoadingInitial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_products.isEmpty && _errorMessage != null) {
      return EmptyState(
        icon: Icons.wifi_off_rounded,
        title: l10n.pick(
          ar: 'تعذر تحميل المنتجات',
          en: 'Could not load products',
        ),
        message: _errorMessage,
        actionLabel: l10n.pick(ar: 'حاول مرة أخرى', en: 'Try Again'),
        onActionTap: _loadFirstPage,
      );
    }

    final filteredProducts = _filteredProducts();

    if (filteredProducts.isEmpty) {
      return EmptyState(
        icon: Icons.search_off_rounded,
        title: l10n.pick(ar: 'لا توجد منتجات', en: 'No products found'),
        message: l10n.pick(
          ar: 'جرّب بحثًا مختلفًا أو نطاق سعر أو فلتر عروض آخر.',
          en: 'Try a different search, price range, or sale filter.',
        ),
        actionLabel: l10n.pick(ar: 'مسح الفلاتر', en: 'Clear Filters'),
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
                price: _formatPrice(product.price, l10n),
                oldPrice: product.compareAtPrice == null
                    ? null
                    : _formatPrice(product.compareAtPrice, l10n),
                storeName: product.storeName,
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
    final l10n = AppLocalizations.of(context)!;

    return ProductDetailArgs(
      id: product.id,
      slug: product.slug,
      title: product.name,
      price: _formatPrice(product.price, l10n),
      unitPrice: product.price ?? 0.0,
      oldPrice: product.compareAtPrice == null
          ? null
          : _formatPrice(product.compareAtPrice, l10n),
      compareAtPrice: product.compareAtPrice,
      imageUrl: product.imageUrl,
      discountBadge: _discountLabel(product),
    );
  }

  String _formatPrice(double? value, AppLocalizations l10n) {
    if (value == null) return '';
    return l10n.formatPrice(value);
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
