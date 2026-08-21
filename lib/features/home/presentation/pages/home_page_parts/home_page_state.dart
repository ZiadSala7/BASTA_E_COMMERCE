part of '../home_page.dart';

class _HomePageState extends State<HomePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late final GetHomeBannersUseCase _getBanners;
  late final GetHomeCategoriesUseCase _getCategories;
  late final GetHomeProductsUseCase _getProducts;
  late final GetHomeStoresUseCase _getStores;
  late final AddCartItemUseCase _addCartItem;
  late final FavoritesController _favoritesController;
  late Future<List<HomeAdBanner>> _bannersFuture;
  late Future<List<HomeCategoryEntity>> _categoriesFuture;
  late Future<List<HomeFeaturedProduct>> _productsFuture;
  late Future<List<HomeFeaturedStore>> _storesFuture;
  final Set<String> _addingProductIds = <String>{};
  String? _selectedCategorySlug;
  String? _selectedCategoryName;

  @override
  void initState() {
    super.initState();
    _getBanners = sl<GetHomeBannersUseCase>();
    _getCategories = sl<GetHomeCategoriesUseCase>();
    _getProducts = sl<GetHomeProductsUseCase>();
    _getStores = sl<GetHomeStoresUseCase>();
    _addCartItem = sl<AddCartItemUseCase>();
    _favoritesController = sl<FavoritesController>();
    _favoritesController.refresh();
    _bannersFuture = _fetchBanners();
    _categoriesFuture = _getCategories();
    _productsFuture = _fetchProducts();
    _storesFuture = _fetchStores();
  }

  Future<List<HomeAdBanner>> _fetchBanners() async {
    try {
      final banners = await _getBanners();
      if (banners.isNotEmpty) {
        return banners
            .map(
              (b) => HomeAdBanner(
                id: b.id,
                title: b.title,
                buttonText: b.buttonText,
                imageUrl: b.imageUrl,
                targetUrl: b.targetUrl,
              ),
            )
            .toList();
      }
    } catch (_) {}
    return const [];
  }

  Future<List<HomeFeaturedProduct>> _fetchProducts() async {
    final products = await _getProducts(
      categorySlug: _selectedCategorySlug,
      page: 1,
      limit: 10,
    );

    return products.map(_toFeaturedProduct).toList();
  }

  Future<List<HomeFeaturedStore>> _fetchStores() async {
    final storesPage = await _getStores(page: 1, limit: 10);
    return storesPage.stores.map(_toFeaturedStore).toList();
  }

  HomeFeaturedProduct _toFeaturedProduct(HomeProductEntity product) {
    return HomeFeaturedProduct(
      id: product.id,
      slug: product.slug,
      title: product.name,
      price: _formatPrice(product.price),
      unitPrice: product.price,
      oldPrice: product.compareAtPrice == null
          ? null
          : _formatPrice(product.compareAtPrice),
      compareAtPriceNum: product.compareAtPrice,
      imageUrl: product.imageUrl,
      discountLabel: _discountLabel(product),
    );
  }

  HomeFeaturedStore _toFeaturedStore(HomeStoreEntity store) {
    return HomeFeaturedStore(
      id: store.id,
      name: store.name,
      slug: store.slug,
      description: store.description,
    );
  }

  String _formatPrice(double? value) {
    if (value == null) return '';
    final l10n = AppLocalizations.of(context);
    if (l10n != null) return l10n.formatPrice(value);
    return 'JD ${value.toStringAsFixed(2)}';
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

  void _selectCategory(HomeCategoryEntity? category) {
    setState(() {
      _selectedCategorySlug = category?.slug;
      _selectedCategoryName = category?.name;
      _productsFuture = _fetchProducts();
    });
  }

  Future<void> _refreshHome() async {
    setState(() {
      _bannersFuture = _fetchBanners();
      _categoriesFuture = _getCategories();
      _productsFuture = _fetchProducts();
      _storesFuture = _fetchStores();
    });
    await Future.wait([
      _bannersFuture,
      _categoriesFuture,
      _productsFuture,
      _storesFuture,
    ]);
  }

  List<HomeAdBanner> _demoAds(AppLocalizations l10n) => [
    HomeAdBanner(
      id: '1',
      title: l10n.adTitle1,
      buttonText: l10n.shopNow,
      imageUrl:
          'https://images.unsplash.com/photo-1592945403244-b3fbafd7f539?auto=format&fit=crop&w=1100&q=85',
    ),
    HomeAdBanner(
      id: '2',
      title: l10n.adTitle2,
      buttonText: l10n.shopNow,
      imageUrl:
          'https://images.unsplash.com/photo-1523293182086-7651a899d37f?auto=format&fit=crop&w=1100&q=85',
    ),
    HomeAdBanner(
      id: '3',
      title: l10n.adTitle3,
      buttonText: l10n.shopNow,
      imageUrl:
          'https://images.unsplash.com/photo-1608571423902-eed4a5ad8108?auto=format&fit=crop&w=1100&q=85',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      key: _scaffoldKey,
      drawer: widget.onMenuPressed == null ? const AppDrawer() : null,
      appBar: CustomAppBar(
        onMenuPressed:
            widget.onMenuPressed ??
            () => _scaffoldKey.currentState?.openDrawer(),
        onNotificationPressed: () => context.push(AppRoutes.notifications),
        onSearchTap: () => context.push(AppRoutes.products),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshHome,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(top: 12, bottom: 24),
          children: [
            FutureBuilder<List<HomeAdBanner>>(
              future: _bannersFuture,
              builder: (context, snapshot) {
                final banners = (snapshot.hasData && snapshot.data!.isNotEmpty)
                    ? snapshot.data!
                    : _demoAds(l10n);
                return HomeAdCarousel(items: banners);
              },
            ),
          const SizedBox(height: 20),
          FutureBuilder<List<HomeCategoryEntity>>(
            future: _categoriesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const _CategoriesLoadingSection();
              }

              if (snapshot.hasError) {
                return _ProductsErrorSection(
                  message: 'Unable to load categories right now.',
                  onRetry: () {
                    setState(() {
                      _categoriesFuture = _getCategories();
                    });
                  },
                );
              }

              final categories = snapshot.data ?? const <HomeCategoryEntity>[];
              if (categories.isEmpty) return const SizedBox.shrink();

              return HomePageCategoriesStrip(
                categories: categories,
                selectedCategorySlug: _selectedCategorySlug,
                onCategorySelected: _selectCategory,
              );
            },
          ),
          const SizedBox(height: 18),
          FutureBuilder<List<HomeFeaturedProduct>>(
            future: _productsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const _ProductsLoadingSection();
              }

              if (snapshot.hasError) {
                return _ProductsErrorSection(
                  message: 'Unable to load products right now.',
                  onRetry: () {
                    setState(() {
                      _productsFuture = _fetchProducts();
                    });
                  },
                );
              }

              final products = snapshot.data ?? const <HomeFeaturedProduct>[];
              if (products.isEmpty) {
                return _HomeProductsEmptySection(
                  categoryName: _selectedCategoryName,
                  onBrowseAllTap: () => context.push(AppRoutes.products),
                );
              }

              final saleProducts = products
                  .where((product) => product.oldPrice != null)
                  .toList();

              return AnimatedBuilder(
                animation: _favoritesController,
                builder: (context, child) {
                  return Column(
                    children: [
                      HomeFeaturedProductsSection(
                        items: products,
                        addingProductIds: _addingProductIds,
                        favoriteProductIds:
                            _favoritesController.favoriteProductIds,
                        updatingFavoriteProductIds:
                            _favoritesController.updatingProductIds,
                        onFavoriteTap: _toggleFavorite,
                        onShowAllTap: () => context.push(
                          AppRoutes.products,
                          extra: ProductsListingArgs(
                            categorySlug: _selectedCategorySlug,
                            title: _selectedCategoryName,
                          ),
                        ),
                        onProductTap: (product) => context.push(
                          AppRoutes.productDetail,
                          extra: ProductDetailArgs(
                            id: product.id,
                            slug: product.slug,
                            title: product.title,
                            price: product.price,
                            unitPrice: product.unitPrice ??
                                CurrencyHelper.parse(product.price),
                            oldPrice: product.oldPrice,
                            compareAtPrice: product.compareAtPriceNum ??
                                (product.oldPrice != null
                                    ? CurrencyHelper.parse(product.oldPrice)
                                    : null),
                            imageUrl: product.imageUrl,
                            discountBadge: product.discountLabel,
                            reviewCount: product.reviewCount,
                          ),
                        ),
                        onAddToCart: _addProductToCart,
                      ),
                      if (saleProducts.isNotEmpty) ...[
                        const SizedBox(height: 22),
                        HomeFeaturedProductsSection(
                          title: l10n.specialOfferTitle,
                          items: saleProducts,
                          variant: HomeProductsSectionVariant.specialOffer,
                          addingProductIds: _addingProductIds,
                          favoriteProductIds:
                              _favoritesController.favoriteProductIds,
                          updatingFavoriteProductIds:
                              _favoritesController.updatingProductIds,
                          onFavoriteTap: _toggleFavorite,
                          showRisingBadge: false,
                          onShowAllTap: () => context.push(
                            AppRoutes.products,
                            extra: ProductsListingArgs(
                              categorySlug: _selectedCategorySlug,
                              title: _selectedCategoryName,
                            ),
                          ),
                          onProductTap: (product) => context.push(
                            AppRoutes.productDetail,
                            extra: ProductDetailArgs(
                              id: product.id,
                              slug: product.slug,
                              title: product.title,
                              price: product.price,
                              unitPrice: product.unitPrice ??
                                  CurrencyHelper.parse(product.price),
                              oldPrice: product.oldPrice,
                              compareAtPrice: product.compareAtPriceNum ??
                                  (product.oldPrice != null
                                      ? CurrencyHelper.parse(product.oldPrice)
                                      : null),
                              imageUrl: product.imageUrl,
                              discountBadge: product.discountLabel,
                              reviewCount: product.reviewCount,
                            ),
                          ),
                          onAddToCart: _addProductToCart,
                        ),
                      ],
                    ],
                  );
                },
              );
            },
          ),
          const SizedBox(height: 22),
          FutureBuilder<List<HomeFeaturedStore>>(
            future: _storesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const _StoresLoadingSection();
              }

              if (snapshot.hasError) {
                return _ProductsErrorSection(
                  message: 'Unable to load stores right now.',
                  onRetry: () {
                    setState(() {
                      _storesFuture = _fetchStores();
                    });
                  },
                );
              }

              final stores = snapshot.data ?? const <HomeFeaturedStore>[];
              if (stores.isEmpty) return const SizedBox.shrink();

              return HomeFeaturedStoresSection(
                stores: stores,
                onShowAllTap: () => context.push(AppRoutes.stores),
                onStoreTap: (store) => context.push(
                  AppRoutes.products,
                  extra: ProductsListingArgs(
                    storeSlug: store.slug,
                    title: store.name,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    ),
    );
  }

  Future<void> _addProductToCart(HomeFeaturedProduct product) async {
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
                ar: 'تمت إضافة ${product.title} إلى السلة',
                en: '${product.title} added to cart',
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

  Future<void> _toggleFavorite(HomeFeaturedProduct product) async {
    try {
      await _favoritesController.toggle(product.id);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(_cleanError(error))));
    }
  }

  String _cleanError(Object error) {
    return error.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
  }
}
