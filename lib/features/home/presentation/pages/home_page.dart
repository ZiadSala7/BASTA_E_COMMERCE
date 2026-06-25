import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/utils/app_router.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../../../core/extensions/app_localizations_x.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../cart/domain/usecases/add_cart_item_usecase.dart';
import '../../../favorites/domain/services/favorites_controller.dart';
import '../../domain/entities/home_category_entity.dart';
import '../../domain/entities/home_product_entity.dart';
import '../../domain/entities/home_store_entity.dart';
import '../../domain/usecases/get_home_categories_usecase.dart';
import '../../domain/usecases/get_home_products_usecase.dart';
import '../../domain/usecases/get_home_stores_usecase.dart';
import '../widgets/home_ad_carousel.dart';
import '../widgets/home_featured_products_section.dart';
import '../widgets/home_featured_stores_section.dart';
import '../widgets/home_page_categories_strip.dart';
import '../../../products/presentation/pages/product_detail_page.dart';
import '../../../products/presentation/pages/products_listing_page.dart';

class HomePage extends StatefulWidget {
  final VoidCallback? onMenuPressed;

  const HomePage({super.key, this.onMenuPressed});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late final GetHomeCategoriesUseCase _getCategories;
  late final GetHomeProductsUseCase _getProducts;
  late final GetHomeStoresUseCase _getStores;
  late final AddCartItemUseCase _addCartItem;
  late final FavoritesController _favoritesController;
  late Future<List<HomeCategoryEntity>> _categoriesFuture;
  late Future<List<HomeFeaturedProduct>> _productsFuture;
  late Future<List<HomeFeaturedStore>> _storesFuture;
  final Set<String> _addingProductIds = <String>{};
  String? _selectedCategorySlug;
  String? _selectedCategoryName;

  @override
  void initState() {
    super.initState();
    _getCategories = sl<GetHomeCategoriesUseCase>();
    _getProducts = sl<GetHomeProductsUseCase>();
    _getStores = sl<GetHomeStoresUseCase>();
    _addCartItem = sl<AddCartItemUseCase>();
    _favoritesController = sl<FavoritesController>();
    _favoritesController.refresh();
    _categoriesFuture = _getCategories();
    _productsFuture = _fetchProducts();
    _storesFuture = _fetchStores();
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
      title: product.name,
      price: _formatPrice(product.price),
      oldPrice: product.compareAtPrice == null
          ? null
          : _formatPrice(product.compareAtPrice),
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

  void _selectCategory(HomeCategoryEntity? category) {
    setState(() {
      _selectedCategorySlug = category?.slug;
      _selectedCategoryName = category?.name;
      _productsFuture = _fetchProducts();
    });
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
      body: ListView(
        padding: const EdgeInsets.only(top: 12, bottom: 24),
        children: [
          HomeAdCarousel(items: _demoAds(l10n)),
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
                            title: product.title,
                            price: product.price,
                            oldPrice: product.oldPrice,
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
                              title: product.title,
                              price: product.price,
                              oldPrice: product.oldPrice,
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

class _CategoriesLoadingSection extends StatelessWidget {
  const _CategoriesLoadingSection();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 132,
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _ProductsLoadingSection extends StatelessWidget {
  const _ProductsLoadingSection();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 274,
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _StoresLoadingSection extends StatelessWidget {
  const _StoresLoadingSection();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 164,
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _HomeProductsEmptySection extends StatelessWidget {
  final String? categoryName;
  final VoidCallback onBrowseAllTap;

  const _HomeProductsEmptySection({
    required this.categoryName,
    required this.onBrowseAllTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasCategory = categoryName != null && categoryName!.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: colorScheme.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
          child: Column(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.inventory_2_outlined,
                  color: colorScheme.primary,
                  size: 34,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                hasCategory
                    ? l10n.pick(
                        ar: 'لا توجد منتجات في هذا القسم',
                        en: 'No products in this category',
                      )
                    : l10n.pick(
                        ar: 'لا توجد منتجات حالياً',
                        en: 'No products found',
                      ),
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                hasCategory
                    ? l10n.pick(
                        ar: 'لم نجد منتجات في $categoryName الآن. يمكنك تصفح كل المنتجات أو تجربة قسم آخر.',
                        en: 'We could not find products in $categoryName right now. Browse all products or try another category.',
                      )
                    : l10n.pick(
                        ar: 'سنضيف منتجات جديدة قريباً. يمكنك تصفح كل المنتجات أو العودة لاحقاً.',
                        en: 'New products will appear here soon. You can browse all products or check back later.',
                      ),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: onBrowseAllTap,
                icon: const Icon(Icons.shopping_bag_outlined, size: 18),
                label: Text(
                  l10n.pick(ar: 'تصفح كل المنتجات', en: 'Browse all products'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductsErrorSection extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ProductsErrorSection({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.wifi_off_rounded, color: colorScheme.onErrorContainer),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(color: colorScheme.onErrorContainer),
                ),
              ),
              TextButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ),
        ),
      ),
    );
  }
}
