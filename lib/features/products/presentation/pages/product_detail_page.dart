import 'package:flutter/material.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/extensions/app_localizations_x.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../cart/domain/usecases/add_cart_item_usecase.dart';
import '../../../cart/presentation/pages/cart_checkout_page.dart';
import '../../../favorites/domain/services/favorites_controller.dart';
import '../../domain/entities/product_review_entity.dart';
import '../../domain/usecases/add_product_review_usecase.dart';
import '../../domain/usecases/get_product_reviews_usecase.dart';
export '../models/product_detail_args.dart';

import '../models/product_detail_args.dart';
import '../widgets/bottom_action_bar.dart';
import '../widgets/description_section.dart';
import '../widgets/product_detail_states.dart';
import '../widgets/product_header.dart';
import '../widgets/product_info_section.dart';
import '../widgets/related_products_section.dart';
import '../widgets/reviews_section.dart';

class ProductDetailPage extends StatefulWidget {
  final String productId;
  final ProductDetailArgs? product;
  final bool isLoading;
  final String? error;

  const ProductDetailPage({
    super.key,
    required this.productId,
    this.product,
    this.isLoading = false,
    this.error,
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _selectedQuantity = 1;
  late final AddCartItemUseCase _addCartItem;
  late final AddProductReviewUseCase _addProductReview;
  late final GetProductReviewsUseCase _getProductReviews;
  late final FavoritesController _favoritesController;
  final List<ProductReviewEntity> _reviews = <ProductReviewEntity>[];
  bool _isAddingToCart = false;
  bool _isLoadingReviews = true;
  bool _isSubmittingReview = false;
  String? _reviewsError;

  @override
  void initState() {
    super.initState();
    _addCartItem = sl<AddCartItemUseCase>();
    _addProductReview = sl<AddProductReviewUseCase>();
    _getProductReviews = sl<GetProductReviewsUseCase>();
    _favoritesController = sl<FavoritesController>();
    _favoritesController.refresh();
    _loadReviews();
  }

  @override
  Widget build(BuildContext context) {
    final product =
        widget.product ?? ProductDetailArgs.fallback(widget.productId);

    if (widget.error != null) {
      return ProductDetailErrorState(
        error: widget.error!,
        productId: widget.productId,
      );
    }

    if (widget.isLoading) {
      return const ProductDetailLoadingState();
    }

    return Scaffold(
      body: Column(
        children: [
          AnimatedBuilder(
            animation: _favoritesController,
            builder: (context, child) {
              return ProductHeader(
                product: product,
                isFavorite: _favoritesController.isFavorite(product.id),
                isFavoriteUpdating: _favoritesController.isUpdating(product.id),
                onFavoriteTap: () => _toggleFavorite(product),
              );
            },
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProductInfoSection(product: product),
                  const SizedBox(height: 20),
                  DescriptionSection(product: product),
                  const SizedBox(height: 20),
                  ReviewsSection(
                    reviews: _reviews,
                    isLoading: _isLoadingReviews,
                    isSubmitting: _isSubmittingReview,
                    error: _reviewsError,
                    onRetry: _loadReviews,
                    onSubmitReview: (rating, comment) =>
                        _submitReview(product, rating, comment),
                  ),
                  const SizedBox(height: 20),
                  RelatedProductsSection(currentProduct: product),
                ],
              ),
            ),
          ),
          BottomActionBar(
            quantity: _selectedQuantity,
            isAddingToCart: _isAddingToCart,
            onQuantityChanged: (quantity) =>
                setState(() => _selectedQuantity = quantity),
            onAddToCart: () => _addToCart(product),
            onBuyNow: () => _buyNow(product),
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
      final productId = widget.product?.id.isNotEmpty == true
          ? widget.product!.id
          : widget.productId;
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

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Review submitted successfully')),
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
        setState(() => _isSubmittingReview = false);
      }
    }
  }

  Future<bool> _submitCartItem(ProductDetailArgs product) async {
    if (_isAddingToCart) return false;

    setState(() => _isAddingToCart = true);
    try {
      await _addCartItem(productId: product.id, quantity: _selectedQuantity);
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
