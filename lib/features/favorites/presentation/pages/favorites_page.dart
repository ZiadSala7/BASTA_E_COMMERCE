import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/extensions/app_localizations_x.dart';
import '../../../../core/utils/app_router.dart';
import '../../../../core/widgets/common/custom_app_bar.dart';
import '../../../../core/widgets/products/product_card.dart';
import '../../../../core/widgets/status/empty_state.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../home/domain/entities/home_product_entity.dart';
import '../../../products/presentation/pages/product_detail_page.dart';
import '../../domain/services/favorites_controller.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  late final FavoritesController _favoritesController;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _favoritesController = sl<FavoritesController>();
    _refreshFavorites();
  }

  Future<void> _refreshFavorites() async {
    setState(() => _errorMessage = null);
    try {
      await _favoritesController.refresh();
    } catch (error) {
      if (!mounted) return;
      setState(() => _errorMessage = _cleanError(error));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Column(
        children: [
          CustomAppBar(
            title: l10n.favorites,
            leading: IconButton(
              onPressed: () => context.canPop()
                  ? context.pop()
                  : context.go(AppRoutes.mainNavigation),
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            ),
          ),
          Expanded(
            child: AnimatedBuilder(
              animation: _favoritesController,
              builder: (context, child) => _buildBody(l10n),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(AppLocalizations l10n) {
    if (_favoritesController.isRefreshing &&
        _favoritesController.favoriteProducts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null &&
        _favoritesController.favoriteProducts.isEmpty) {
      return EmptyState(
        icon: Icons.wifi_off_rounded,
        title: l10n.pick(
          ar: 'تعذر تحميل المفضلة',
          en: 'Could not load favorites',
        ),
        message: _errorMessage,
        actionLabel: l10n.pick(ar: 'حاول مرة أخرى', en: 'Try Again'),
        onActionTap: _refreshFavorites,
      );
    }

    final products = _favoritesController.favoriteProducts;
    if (products.isEmpty) {
      return EmptyState(
        icon: Icons.favorite_border_rounded,
        title: l10n.pick(ar: 'لا توجد مفضلة بعد', en: 'No favorites yet'),
        message: l10n.pick(
          ar: 'اضغط على زر القلب في المنتجات لإضافتها هنا.',
          en: 'Tap the heart on products to save them here.',
        ),
        actionLabel: l10n.pick(ar: 'تصفح المنتجات', en: 'Browse Products'),
        onActionTap: () => context.push(AppRoutes.products),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshFavorites,
      child: GridView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
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
            onTap: () => context.push(
              AppRoutes.productDetail,
              extra: ProductDetailArgs(
                id: product.id,
                title: product.name,
                price: _formatPrice(product.price),
                oldPrice: product.compareAtPrice == null
                    ? null
                    : _formatPrice(product.compareAtPrice),
                imageUrl: product.imageUrl,
                discountBadge: _discountLabel(product),
              ),
            ),
            onFavoriteTap: () => _toggleFavorite(product),
          );
        },
      ),
    );
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
}
