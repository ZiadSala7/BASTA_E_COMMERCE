part of '../product_detail_page.dart';

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _selectedQuantity = 1;
  int _selectedImageIndex = 0;
  late ProductDetailArgs _product;
  ProductVariantEntity? _selectedVariant;
  String? _selectedSize;
  String? _selectedColor;

  late final AddCartItemUseCase _addCartItem;
  late final AddProductReviewUseCase _addProductReview;
  late final GetProductReviewsUseCase _getProductReviews;
  late final GetProductDetailsUseCase _getProductDetails;
  late final FavoritesController _favoritesController;
  final List<ProductReviewEntity> _reviews = <ProductReviewEntity>[];

  bool _isAddingToCart = false;
  bool _isLoadingProduct = false;
  bool _isLoadingReviews = true;
  bool _isSubmittingReview = false;
  String? _productError;
  String? _reviewsError;

  @override
  void initState() {
    super.initState();
    _product = widget.product ?? ProductDetailArgs.fallback(widget.productId);
    _addCartItem = sl<AddCartItemUseCase>();
    _addProductReview = sl<AddProductReviewUseCase>();
    _getProductReviews = sl<GetProductReviewsUseCase>();
    _getProductDetails = sl<GetProductDetailsUseCase>();
    _favoritesController = sl<FavoritesController>();
    _favoritesController.addListener(_onFavoritesChanged);
    _favoritesController.refresh();

    _initVariantSelection(_product);
    _loadProductDetails();
    _loadReviews();
  }

  @override
  void dispose() {
    _favoritesController.removeListener(_onFavoritesChanged);
    super.dispose();
  }

  void _onFavoritesChanged() {
    if (mounted) setState(() {});
  }

  void _initVariantSelection(ProductDetailArgs product) {
    _selectedVariant = product.defaultVariant;
    _selectedSize = _selectedVariant?.size ??
        (product.availableSizes.isNotEmpty ? product.availableSizes.first : null);
    _selectedColor = _selectedVariant?.color ??
        (product.availableColors.isNotEmpty ? product.availableColors.first : null);
  }

  Future<void> _loadProductDetails() async {
    final identifier = _product.slug.isNotEmpty
        ? _product.slug
        : (_product.id.isNotEmpty ? _product.id : widget.productId);

    if (identifier.isEmpty) return;

    if (widget.product == null) {
      setState(() => _isLoadingProduct = true);
    }

    try {
      final fullProduct = await _getProductDetails(identifier);
      if (!mounted) return;

      final updatedArgs = ProductDetailArgs.fromEntity(fullProduct);
      setState(() {
        _product = updatedArgs;
        _initVariantSelection(updatedArgs);
        _isLoadingProduct = false;
        _productError = null;
      });
    } catch (e) {
      if (!mounted) return;
      if (widget.product == null) {
        setState(() {
          _productError = _cleanError(e);
          _isLoadingProduct = false;
        });
      }
    }
  }

  void _onSizeSelected(String size) {
    setState(() {
      _selectedSize = size;
      _selectedVariant = _product.findVariant(
        size: size,
        color: _selectedColor,
      );
      _syncVariantImage(_selectedVariant);
    });
  }

  void _onColorSelected(String color) {
    setState(() {
      _selectedColor = color;
      _selectedVariant = _product.findVariant(
        size: _selectedSize,
        color: color,
      );
      _syncVariantImage(_selectedVariant);
    });
  }

  void _syncVariantImage(ProductVariantEntity? variant) {
    if (variant == null || variant.imageId == null || variant.imageId!.isEmpty) {
      return;
    }

    final images = _product.galleryImages;
    final imagesList = _product.imagesList;

    for (var i = 0; i < imagesList.length; i++) {
      if (imagesList[i].id == variant.imageId) {
        final imgUrl = imagesList[i].imageUrl;
        final index = images.indexOf(imgUrl);
        if (index >= 0) {
          _selectedImageIndex = index;
          return;
        }
      }
    }
  }

  // Resolved dynamic active properties
  double get _currentUnitPrice {
    if (_selectedVariant != null && _selectedVariant!.price > 0) {
      return _selectedVariant!.price;
    }
    return _product.effectiveUnitPrice;
  }

  String get _currentDisplayPrice =>
      _currentUnitPrice > 0
          ? 'JD ${_currentUnitPrice.toStringAsFixed(2)}'
          : _product.price;

  double? get _currentCompareAtPrice {
    if (_selectedVariant?.compareAtPrice != null &&
        _selectedVariant!.compareAtPrice! > _currentUnitPrice) {
      return _selectedVariant!.compareAtPrice;
    }
    return _product.effectiveCompareAtPrice;
  }

  String? get _currentOldPrice =>
      _currentCompareAtPrice != null && _currentCompareAtPrice! > _currentUnitPrice
          ? 'JD ${_currentCompareAtPrice!.toStringAsFixed(2)}'
          : null;

  int? get _currentStockQuantity =>
      _selectedVariant?.stockQuantity ?? _product.stockQuantity;

  bool get _isOutOfStock =>
      _selectedVariant != null
          ? _selectedVariant!.isOutOfStock
          : _product.isOutOfStock;

  ProductDetailArgs get _resolvedProduct => _product.copyWith(
        price: _currentDisplayPrice,
        unitPrice: _currentUnitPrice,
        oldPrice: _currentOldPrice,
        compareAtPrice: _currentCompareAtPrice,
        stockQuantity: _currentStockQuantity,
      );

  @override
  Widget build(BuildContext context) {
    if (widget.error != null || _productError != null) {
      return ProductDetailErrorState(
        error: widget.error ?? _productError!,
        productId: widget.productId,
      );
    }

    if (widget.isLoading || _isLoadingProduct) {
      return const ProductDetailLoadingState();
    }

    final displayedProduct = _resolvedProduct;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: ProductHeader(
                    product: displayedProduct,
                    isFavorite: _favoritesController.isFavorite(displayedProduct.id),
                    isFavoriteUpdating:
                        _favoritesController.isUpdating(displayedProduct.id),
                    onFavoriteTap: () => _toggleFavorite(displayedProduct),
                    selectedImageIndex: _selectedImageIndex,
                    onImageSelected: (index) =>
                        setState(() => _selectedImageIndex = index),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      ProductInfoSection(
                        product: displayedProduct,
                        onReviewTap: () {},
                      ),
                      const SizedBox(height: 16),

                      // Color & Size Variant Selector
                      ProductVariantSelector(
                        product: _product,
                        selectedVariant: _selectedVariant,
                        selectedSize: _selectedSize,
                        selectedColor: _selectedColor,
                        onSizeSelected: _onSizeSelected,
                        onColorSelected: _onColorSelected,
                      ),

                      // Description & Specifications
                      DescriptionSection(product: displayedProduct),
                      const SizedBox(height: 16),

                      // Customer Reviews
                      ReviewsSection(
                        reviews: _reviews,
                        isLoading: _isLoadingReviews,
                        isSubmitting: _isSubmittingReview,
                        error: _reviewsError,
                        onRetry: _loadReviews,
                        onSubmitReview: (rating, comment) =>
                            _submitReview(displayedProduct, rating, comment),
                      ),
                      const SizedBox(height: 16),

                      // Related Products
                      RelatedProductsSection(currentProduct: displayedProduct),
                      const SizedBox(height: 16),
                    ]),
                  ),
                ),
              ],
            ),
          ),
          BottomActionBar(
            quantity: _selectedQuantity,
            unitPrice: _currentUnitPrice,
            stockQuantity: _currentStockQuantity,
            isOutOfStock: _isOutOfStock,
            isAddingToCart: _isAddingToCart,
            onQuantityChanged: (quantity) =>
                setState(() => _selectedQuantity = quantity),
            onAddToCart: () => _addToCart(displayedProduct),
            onBuyNow: () => _buyNow(displayedProduct),
          ),
        ],
      ),
    );
  }

  Future<void> _addToCart(ProductDetailArgs product) async {
    await _submitCartItem(product);
  }

  Future<void> _buyNow(ProductDetailArgs product) async {
    final added = await _submitCartItem(product);
    if (!mounted || !added) return;

    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const CartCheckoutPage()));
  }

  Future<void> _loadReviews() async {
    setState(() {
      _isLoadingReviews = true;
      _reviewsError = null;
    });

    try {
      final productId = _product.id.isNotEmpty ? _product.id : widget.productId;
      final reviews = await _getProductReviews(productId);
      if (!mounted) return;
      setState(() {
        _reviews
          ..clear()
          ..addAll(reviews);
        _isLoadingReviews = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _reviewsError = _cleanError(error);
        _isLoadingReviews = false;
      });
    }
  }

  Future<bool> _submitReview(
    ProductDetailArgs product,
    int rating,
    String comment,
  ) async {
    if (_isSubmittingReview) return false;

    setState(() => _isSubmittingReview = true);
    try {
      await _addProductReview(
        productId: product.id,
        rating: rating,
        comment: comment,
      );
      await _loadReviews();
      if (!mounted) return true;

      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              l10n.pick(
                ar: 'تم إرسال التقييم بنجاح!',
                en: 'Review submitted successfully!',
              ),
            ),
          ),
        );
      return true;
    } catch (error) {
      if (!mounted) return false;

      final errorMsg = _cleanError(error);
      final l10n = AppLocalizations.of(context)!;

      if (errorMsg.contains('Verified Purchase Required') ||
          errorMsg.contains('only review products you have bought')) {
        await _showVerifiedPurchaseDialog(l10n);
      } else {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(errorMsg)));
      }
      return false;
    } finally {
      if (mounted) {
        setState(() => _isSubmittingReview = false);
      }
    }
  }

  Future<void> _showVerifiedPurchaseDialog(AppLocalizations l10n) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(
          Icons.verified_user_outlined,
          color: Color(0xFFF59E0B),
          size: 38,
        ),
        title: Text(
          l10n.pick(
            ar: 'مطلوب عملية شراء مؤكدة',
            en: 'Verified Purchase Required',
          ),
          textAlign: TextAlign.center,
          style: GoogleFonts.cairo(fontWeight: FontWeight.w900),
        ),
        content: Text(
          l10n.pick(
            ar: 'يمكنك تقييم هذا المنتج فقط بعد شرائه واستلامه بنجاح.',
            en: 'You can only leave a review after purchasing and receiving this item.',
          ),
          textAlign: TextAlign.center,
          style: GoogleFonts.cairo(fontWeight: FontWeight.w600),
        ),
        actions: [
          Center(
            child: FilledButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(l10n.pick(ar: 'حسناً', en: 'Got it')),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _submitCartItem(ProductDetailArgs product) async {
    if (_isAddingToCart) return false;

    setState(() => _isAddingToCart = true);
    try {
      final variantId = _selectedVariant?.id;

      await _addCartItem(
        productId: variantId == null || variantId.isEmpty ? product.id : null,
        variantId: variantId != null && variantId.isNotEmpty ? variantId : null,
        quantity: _selectedQuantity,
      );

      if (!mounted) return true;

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
      return true;
    } catch (error) {
      if (!mounted) return false;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(_cleanError(error))));
      return false;
    } finally {
      if (mounted) {
        setState(() => _isAddingToCart = false);
      }
    }
  }

  Future<void> _toggleFavorite(ProductDetailArgs product) async {
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
