part of '../related_products_section.dart';

class _RelatedProductsSectionState extends State<RelatedProductsSection> {
  late final FavoritesController _favoritesController;
  late final GetHomeProductsUseCase _getProducts;

  final List<HomeProductEntity> _products = <HomeProductEntity>[];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _favoritesController = sl<FavoritesController>();
    _getProducts = sl<GetHomeProductsUseCase>();
    _favoritesController.refresh();
    _loadRelatedProducts();
  }

  @override
  void didUpdateWidget(covariant RelatedProductsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentProduct.id != widget.currentProduct.id) {
      _loadRelatedProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
        if (_isLoading)
          const SizedBox(
            height: 244,
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_errorMessage != null)
          SizedBox(
            height: 244,
            child: EmptyState(
              icon: Icons.wifi_off_rounded,
              title: 'Could not load related products',
              message: _errorMessage,
              actionLabel: 'Try Again',
              onActionTap: _loadRelatedProducts,
            ),
          )
        else if (_products.isEmpty)
          const SizedBox.shrink()
        else
          AnimatedBuilder(
            animation: _favoritesController,
            builder: (context, child) {
              return SizedBox(
                height: 244,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _products.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final product = _products[index];
                    final detail = _detailArgs(product);

                    return SizedBox(
                      width: 160,
                      child: ProductCard(
                        id: product.id,
                        title: product.name,
                        price: detail.price,
                        oldPrice: detail.oldPrice,
                        discountBadge: detail.discountBadge,
                        imageUrl: product.imageUrl,
                        isFavorite: _favoritesController.isFavorite(product.id),
                        isFavoriteUpdating: _favoritesController.isUpdating(
                          product.id,
                        ),
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProductDetailPage(
                                productId: product.id,
                                product: detail,
                              ),
                            ),
                          );
                        },
                        onFavoriteTap: () => _toggleFavorite(product.id),
                      ),
                    );
                  },
                ),
              );
            },
          ),
      ],
    );
  }

  Future<void> _loadRelatedProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final products = await _getProducts(page: 1, limit: 12);
      if (!mounted) return;

      setState(() {
        _products
          ..clear()
          ..addAll(
            products.where((product) => product.id != widget.currentProduct.id),
          );
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = _cleanError(error);
        _isLoading = false;
      });
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

  Future<void> _toggleFavorite(String productId) async {
    try {
      await _favoritesController.toggle(productId);
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
