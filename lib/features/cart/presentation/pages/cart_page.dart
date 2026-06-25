// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/extensions/app_localizations_x.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/assets.dart';
import '../../../../core/widgets/status/empty_state.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/repositories/cart_repository.dart';
import '../../domain/services/cart_badge_controller.dart';
import '../../../favorites/domain/services/favorites_controller.dart';
import 'cart_checkout_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key, this.onStartShopping, this.onBack});

  final VoidCallback? onStartShopping;
  final VoidCallback? onBack;

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final TextEditingController _couponController = TextEditingController();
  late final CartRepository _cartRepository;
  late final CartBadgeController _cartBadgeController;
  late final FavoritesController _favoritesController;

  final List<_CartProduct> _items = <_CartProduct>[];
  final Set<String> _updatingItemIds = <String>{};
  bool _isLoading = true;
  bool _isApplyingCoupon = false;
  double _couponDiscount = 0;
  String? _appliedCoupon;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _cartRepository = sl<CartRepository>();
    _cartBadgeController = sl<CartBadgeController>();
    _favoritesController = sl<FavoritesController>();
    _favoritesController.addListener(_onFavoritesChanged);
    _favoritesController.refresh();
    _couponController.addListener(_refreshTotals);
    _loadCart();
  }

  @override
  void dispose() {
    _couponController
      ..removeListener(_refreshTotals)
      ..dispose();
    _favoritesController.removeListener(_onFavoritesChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localizedItems = _items
        .map(
          (item) => item.copyWith(
            isFavorite: _favoritesController.isFavorite(item.removeProductId),
          ),
        )
        .toList(growable: false);
    final cartGroups = _cartGroups(localizedItems);
    final itemCount = localizedItems.fold<int>(
      0,
      (total, item) => total + item.quantity,
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          _CartHeader(
            itemCount: itemCount,
            subtotal: _subtotal,
            onBack: _handleBack,
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                ? EmptyState(
                    icon: Icons.error_outline_rounded,
                    title: l10n.pick(
                      ar: 'تعذر تحميل السلة',
                      en: 'Could not load cart',
                    ),
                    message: _errorMessage,
                    actionLabel: l10n.pick(ar: 'إعادة المحاولة', en: 'Retry'),
                    onActionTap: _loadCart,
                  )
                : localizedItems.isEmpty
                ? EmptyState(
                    icon: Icons.shopping_cart_outlined,
                    title: l10n.cart,
                    message: l10n.pick(
                      ar: 'سلة التسوق فارغة الآن. ابدأ بإضافة منتجاتك المفضلة.',
                      en: 'Your cart is empty right now. Start adding products you love.',
                    ),
                    actionLabel: l10n.shopNow,
                    onActionTap: widget.onStartShopping,
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
                    children: [
                      _OrderReadinessPanel(
                        itemCount: itemCount,
                        subtotal: _subtotal,
                      ),
                      const SizedBox(height: 16),
                      _SectionTitle(
                        title: l10n.pick(ar: 'منتجات السلة', en: 'Cart items'),
                        subtitle: l10n.pick(
                          ar: '${localizedItems.length} منتجات جاهزة للطلب',
                          en: '${localizedItems.length} products ready for checkout',
                        ),
                      ),
                      const SizedBox(height: 12),
                      for (
                        var groupIndex = 0;
                        groupIndex < cartGroups.length;
                        groupIndex++
                      ) ...[
                        _VendorCartSection(
                          group: cartGroups[groupIndex],
                          updatingItemIds: _updatingItemIds,
                          onIncrement: (index) => _changeQuantity(index, 1),
                          onDecrement: (index) => _changeQuantity(index, -1),
                          onRemove: _removeItem,
                          onFavoriteTap: _toggleFavorite,
                        ),
                        if (groupIndex != cartGroups.length - 1)
                          const SizedBox(height: 14),
                      ],
                      const SizedBox(height: 18),
                      _BackendCouponCard(
                        controller: _couponController,
                        hasDiscount: _discount > 0,
                        isLoading: _isApplyingCoupon,
                        onApply: _applyCoupon,
                      ),
                      const SizedBox(height: 12),
                      _DeliveryNote(
                        message: l10n.deliveryNote,
                        estimatedDate: l10n.pick(
                          ar: 'التوصيل المتوقع خلال 2-4 أيام',
                          en: 'Estimated delivery in 2-4 days',
                        ),
                      ),
                      const SizedBox(height: 144),
                    ],
                  ),
          ),
        ],
      ),
      bottomNavigationBar:
          _isLoading || _errorMessage != null || localizedItems.isEmpty
          ? null
          : _CartCheckoutSummary(
              subtotal: _subtotal,
              shipping: _shipping,
              discount: _discount,
              onCheckout: _openCheckout,
            ),
    );
  }

  double get _subtotal {
    return _items.fold<double>(
      0,
      (total, item) => total + (item.unitPrice * item.quantity),
    );
  }

  double get _shipping => _items.isEmpty ? 0 : 5;

  double get _discount => _couponDiscount;

  List<_VendorCartGroup> _cartGroups(List<_CartProduct> items) {
    final groupsByKey = <String, _VendorCartGroup>{};

    for (var index = 0; index < items.length; index++) {
      final item = items[index];
      groupsByKey
          .putIfAbsent(
            item.storeGroupKey,
            () => _VendorCartGroup(
              storeId: item.storeId,
              storeName: item.storeName,
              storeSlug: item.storeSlug,
              items: <_IndexedCartProduct>[],
            ),
          )
          .items
          .add(_IndexedCartProduct(index: index, item: item));
    }

    return groupsByKey.values.toList(growable: false);
  }

  void _refreshTotals() {
    final code = _couponController.text.trim();
    if (_appliedCoupon != null && code != _appliedCoupon) {
      _appliedCoupon = null;
      _couponDiscount = 0;
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadCart() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final items = await _cartRepository.getCartItems();
      if (!mounted) return;
      _cartBadgeController.setItems(items);
      setState(() {
        _items
          ..clear()
          ..addAll(items.map(_CartProduct.fromEntity));
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

  Future<void> _handleBack() async {
    final didPop = await Navigator.of(context).maybePop();
    if (!mounted || didPop) return;

    final fallback = widget.onBack ?? widget.onStartShopping;
    fallback?.call();
  }

  Future<void> _changeQuantity(int index, int change) async {
    final item = _items[index];
    if (_updatingItemIds.contains(item.id)) return;

    final previousQuantity = item.quantity;
    final quantity = (previousQuantity + change).clamp(1, 99).toInt();
    if (quantity == previousQuantity) return;

    setState(() {
      _updatingItemIds.add(item.id);
      _items[index] = item.copyWith(quantity: quantity);
    });

    try {
      await _cartRepository.updateQuantity(item.removeProductId, quantity);
      await _refreshCartSnapshot();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _items[index] = item.copyWith(quantity: previousQuantity);
      });
      _showSnackBar(_cleanError(error));
    } finally {
      if (mounted) {
        setState(() => _updatingItemIds.remove(item.id));
      }
    }
  }

  Future<void> _toggleFavorite(int index) async {
    try {
      await _favoritesController.toggle(_items[index].removeProductId);
    } catch (error) {
      if (!mounted) return;
      _showSnackBar(_cleanError(error));
    }
  }

  Future<void> _applyCoupon() async {
    final code = _couponController.text.trim();
    if (code.isEmpty || _isApplyingCoupon) return;

    FocusScope.of(context).unfocus();
    setState(() => _isApplyingCoupon = true);

    try {
      final coupon = await _cartRepository.applyCoupon(code);
      if (!mounted) return;

      setState(() {
        _appliedCoupon = coupon.appliedCoupon.isEmpty
            ? code
            : coupon.appliedCoupon;
        _couponDiscount = coupon.discountAmount;
      });
      _showSnackBar(coupon.message);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _appliedCoupon = null;
        _couponDiscount = 0;
      });
      _showSnackBar(_cleanError(error));
    } finally {
      if (mounted) {
        setState(() => _isApplyingCoupon = false);
      }
    }
  }

  void _onFavoritesChanged() {
    if (mounted) setState(() {});
  }

  Future<bool> _removeItem(int index) async {
    final removedItem = _items[index];
    if (_updatingItemIds.contains(removedItem.id)) return false;

    setState(() {
      _updatingItemIds.add(removedItem.id);
      _items.removeAt(index);
    });

    try {
      await _cartRepository.removeFromCart(removedItem.removeProductId);
      await _refreshCartSnapshot();
      if (!mounted) return true;
      _showSnackBar('${removedItem.title} removed');
      return true;
    } catch (error) {
      if (!mounted) return false;
      setState(() {
        _items.insert(index.clamp(0, _items.length), removedItem);
      });
      _showSnackBar(_cleanError(error));
      return false;
    } finally {
      if (mounted) {
        setState(() => _updatingItemIds.remove(removedItem.id));
      }
    }
  }

  Future<void> _refreshCartSnapshot() async {
    final items = await _cartRepository.getCartItems();
    if (!mounted) return;

    _cartBadgeController.setItems(items);
    setState(() {
      _items
        ..clear()
        ..addAll(items.map(_CartProduct.fromEntity));
    });
  }

  Future<void> _openCheckout() async {
    final completed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(builder: (_) => const CartCheckoutPage()),
    );

    if (!mounted || completed != true) return;

    setState(() {
      _appliedCoupon = null;
      _couponDiscount = 0;
      _couponController.clear();
    });
    await _refreshCartSnapshot();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message, style: GoogleFonts.cairo())),
      );
  }

  String _cleanError(Object error) {
    final message = error.toString();
    return message.startsWith('Exception: ')
        ? message.substring('Exception: '.length)
        : message;
  }
}

class _CartProduct {
  const _CartProduct({
    required this.id,
    required this.productId,
    required this.title,
    required this.storeId,
    required this.storeName,
    required this.storeSlug,
    required this.price,
    required this.unitPrice,
    required this.quantity,
    required this.badge,
    required this.accent,
    required this.imageUrl,
    this.isFavorite = false,
    this.darkImage = false,
  });

  final String id;
  final String productId;
  final String title;
  final String? storeId;
  final String storeName;
  final String? storeSlug;
  final String price;
  final double unitPrice;
  final int quantity;
  final String badge;
  final Color accent;
  final String imageUrl;
  final bool isFavorite;
  final bool darkImage;

  String get removeProductId => productId.isEmpty ? id : productId;

  String get storeGroupKey {
    final slug = storeSlug?.trim();
    if (slug != null && slug.isNotEmpty) return slug;

    final name = storeName.trim();
    if (name.isNotEmpty) return name;

    return 'unknown-store';
  }

  factory _CartProduct.fromEntity(CartItemEntity item) {
    return _CartProduct(
      id: item.id,
      productId: item.productId,
      title: item.name,
      storeId: item.storeId,
      storeName: item.storeName.trim(),
      storeSlug: item.storeSlug,
      price: _money(item.activePrice),
      unitPrice: item.activePrice,
      quantity: item.quantity,
      badge: 'NEW',
      accent: AppColors.primary,
      imageUrl: item.imageUrl,
    );
  }

  _CartProduct copyWith({
    String? title,
    String? price,
    int? quantity,
    bool? isFavorite,
  }) {
    return _CartProduct(
      id: id,
      productId: productId,
      title: title ?? this.title,
      storeId: storeId,
      storeName: storeName,
      storeSlug: storeSlug,
      price: price ?? this.price,
      unitPrice: unitPrice,
      quantity: quantity ?? this.quantity,
      badge: badge,
      accent: accent,
      imageUrl: imageUrl,
      isFavorite: isFavorite ?? this.isFavorite,
      darkImage: darkImage,
    );
  }
}

class _IndexedCartProduct {
  const _IndexedCartProduct({required this.index, required this.item});

  final int index;
  final _CartProduct item;
}

class _VendorCartGroup {
  _VendorCartGroup({
    required this.storeId,
    required this.storeName,
    required this.storeSlug,
    required this.items,
  });

  final String? storeId;
  final String storeName;
  final String? storeSlug;
  final List<_IndexedCartProduct> items;

  bool get hasStoreName => storeName.trim().isNotEmpty;

  double get subtotal => items.fold<double>(
    0,
    (total, entry) => total + (entry.item.unitPrice * entry.item.quantity),
  );
}

class _VendorCartSection extends StatelessWidget {
  const _VendorCartSection({
    required this.group,
    required this.updatingItemIds,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
    required this.onFavoriteTap,
  });

  final _VendorCartGroup group;
  final Set<String> updatingItemIds;
  final ValueChanged<int> onIncrement;
  final ValueChanged<int> onDecrement;
  final Future<bool> Function(int index) onRemove;
  final ValueChanged<int> onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (group.hasStoreName) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.storefront_rounded,
                    color: AppColors.primary,
                    size: 19,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    group.storeName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                      color: colorScheme.onSurface,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  _money(group.subtotal),
                  style: GoogleFonts.cairo(
                    color: AppColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              l10n.pick(
                ar: '${group.items.length} Ù…Ù†ØªØ¬',
                en: '${group.items.length} products',
              ),
              style: GoogleFonts.cairo(
                color: colorScheme.onSurfaceVariant,
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
        for (var index = 0; index < group.items.length; index++) ...[
          _CartItemCard(
            item: group.items[index].item,
            isUpdating: updatingItemIds.contains(group.items[index].item.id),
            onIncrement: () => onIncrement(group.items[index].index),
            onDecrement: () => onDecrement(group.items[index].index),
            onRemove: () => onRemove(group.items[index].index),
            onFavoriteTap: () => onFavoriteTap(group.items[index].index),
          ),
          if (index != group.items.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _CartHeader extends StatelessWidget {
  const _CartHeader({
    required this.itemCount,
    required this.subtotal,
    required this.onBack,
  });

  final int itemCount;
  final double subtotal;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final topPadding = MediaQuery.paddingOf(context).top;

    return Container(
      padding: EdgeInsets.fromLTRB(18, topPadding + 12, 18, 18),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4747C2), Color(0xFF5B5BD6), Color(0xFF20B7A8)],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(26)),
      ),
      child: Column(
        children: [
          Row(
            textDirection: l10n.inverseAppBarDirection,
            children: [
              _HeaderIconButton(icon: Icons.arrow_back_rounded, onTap: onBack),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    l10n.cart,
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.w900,
                      height: 1.05,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    l10n.pick(
                      ar: '$itemCount عناصر في السلة',
                      en: '$itemCount items in your cart',
                    ),
                    style: GoogleFonts.cairo(
                      color: Colors.white.withOpacity(0.78),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.16),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.24)),
                ),
                child: const Icon(
                  Icons.shopping_bag_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _HeaderMetric(
                  label: l10n.pick(ar: 'المجموع الفرعي', en: 'Subtotal'),
                  value: _money(subtotal),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _HeaderMetric(
                  label: l10n.pick(ar: 'حالة الطلب', en: 'Order status'),
                  value: l10n.pick(ar: 'جاهز', en: 'Ready'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.14),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}

class _HeaderMetric extends StatelessWidget {
  const _HeaderMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.cairo(
              color: Colors.white.withOpacity(0.72),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w900,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderReadinessPanel extends StatelessWidget {
  const _OrderReadinessPanel({required this.itemCount, required this.subtotal});

  final int itemCount;
  final double subtotal;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 170,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: colorScheme.outlineVariant.withOpacity(0.7),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF8F5),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.verified_user_outlined,
                    color: Color(0xFF129987),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.pick(
                          ar: 'طلبك جاهز للمراجعة',
                          en: 'Your order is ready',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.cairo(
                          color: colorScheme.onSurface,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        l10n.pick(
                          ar: 'تحقق من المنتجات والكوبون قبل الدفع.',
                          en: 'Review items and coupon before checkout.',
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.cairo(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _ReadinessChip(
                    icon: Icons.inventory_2_outlined,
                    label: l10n.pick(ar: 'العناصر', en: 'Items'),
                    value: '$itemCount',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ReadinessChip(
                    icon: Icons.local_shipping_outlined,
                    label: l10n.pick(ar: 'الشحن', en: 'Shipping'),
                    value: '2-4d',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ReadinessChip(
                    icon: Icons.payments_outlined,
                    label: l10n.pick(ar: 'المجموع', en: 'Subtotal'),
                    value: _money(subtotal),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ReadinessChip extends StatelessWidget {
  const _ReadinessChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 68,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withOpacity(0.42),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 17, color: AppColors.primary),
            const SizedBox(height: 7),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.cairo(
                color: colorScheme.onSurfaceVariant,
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                height: 1.1,
              ),
            ),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.cairo(
                color: colorScheme.onSurface,
                fontSize: 12,
                fontWeight: FontWeight.w900,
                height: 1.15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.cairo(
                  color: colorScheme.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.cairo(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.receipt_long_outlined,
            color: AppColors.primary,
            size: 20,
          ),
        ),
      ],
    );
  }
}

class _CartItemCard extends StatelessWidget {
  const _CartItemCard({
    required this.item,
    required this.isUpdating,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
    required this.onFavoriteTap,
  });

  final _CartProduct item;
  final bool isUpdating;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final Future<bool> Function() onRemove;
  final VoidCallback onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 148,
      child: Dismissible(
        key: ValueKey<String>(item.id),
        direction: DismissDirection.endToStart,
        background: const SizedBox.shrink(),
        secondaryBackground: const _SwipeDeleteBackground(),
        confirmDismiss: (_) async {
          await onRemove();
          return false;
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: colorScheme.outlineVariant.withOpacity(0.7),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.045),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ProductImage(item: item),
              const SizedBox(width: 12),
              Expanded(child: _CartItemDetails(item: item)),
              const SizedBox(width: 8),
              SizedBox(
                width: 94,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _RoundIconButton(
                      icon: item.isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: item.isFavorite
                          ? AppColors.badgeRed
                          : colorScheme.onSurfaceVariant,
                      onTap: onFavoriteTap,
                    ),
                    const SizedBox(height: 8),
                    _RoundIconButton(
                      icon: Icons.delete_outline_rounded,
                      color: colorScheme.onSurfaceVariant,
                      onTap: isUpdating ? null : () async => onRemove(),
                    ),
                    const SizedBox(height: 8),
                    isUpdating
                        ? const SizedBox(
                            width: 34,
                            height: 34,
                            child: Padding(
                              padding: EdgeInsets.all(8),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : _QuantityStepper(
                            quantity: item.quantity,
                            onIncrement: onIncrement,
                            onDecrement: onDecrement,
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SwipeDeleteBackground extends StatelessWidget {
  const _SwipeDeleteBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 22),
      decoration: BoxDecoration(
        color: AppColors.badgeRed,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.item});

  final _CartProduct item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 92,
      height: 124,
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: item.darkImage
            ? const Color(0xFF17171D)
            : item.accent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: item.accent.withOpacity(0.18)),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: item.darkImage
                  ? Image.asset(Assets.imagesCart, fit: BoxFit.contain)
                  : DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [item.accent.withOpacity(0.12), Colors.white],
                        ),
                      ),
                      child: item.imageUrl.isEmpty
                          ? Image.asset(Assets.imagesCart, fit: BoxFit.contain)
                          : Image.network(
                              item.imageUrl,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  Image.asset(
                                    Assets.imagesCart,
                                    fit: BoxFit.contain,
                                  ),
                            ),
                    ),
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
              decoration: BoxDecoration(
                color: item.accent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                item.badge,
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CartItemDetails extends StatelessWidget {
  const _CartItemDetails({required this.item});

  final _CartProduct item;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return SizedBox(
      height: 112,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item.storeName.trim().isNotEmpty) ...[
            Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: item.accent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.storefront_rounded,
                    color: item.accent,
                    size: 13,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    item.storeName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          Text(
            item.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.cairo(
              color: colorScheme.onSurface,
              fontSize: 14.5,
              fontWeight: FontWeight.w900,
              height: 1.22,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.flash_on_rounded, color: item.accent, size: 14),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  l10n.pick(ar: 'تسليم سريع وآمن', en: 'Fast secure delivery'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cairo(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            item.price,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.cairo(
              color: AppColors.primary,
              fontSize: 16,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(
        context,
      ).colorScheme.surfaceContainerHighest.withOpacity(0.55),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 34,
          height: 34,
          child: Icon(icon, color: color, size: 18),
        ),
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.09),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: AppColors.primary.withOpacity(0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepperButton(icon: Icons.remove_rounded, onTap: onDecrement),
          SizedBox(
            width: 30,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                color: AppColors.primaryDark,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          _StepperButton(icon: Icons.add_rounded, onTap: onIncrement),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: 30,
        height: 34,
        child: Icon(icon, color: AppColors.primary, size: 18),
      ),
    );
  }
}

class LegacyCouponCard extends StatelessWidget {
  const LegacyCouponCard({
    super.key,
    required this.controller,
    required this.hasDiscount,
    required this.isLoading,
    required this.onApply,
  });

  final TextEditingController controller;
  final bool hasDiscount;
  final bool isLoading;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: hasDiscount
              ? AppColors.accentGreen.withOpacity(0.35)
              : colorScheme.outlineVariant.withOpacity(0.7),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: hasDiscount
                  ? AppColors.accentGreen.withOpacity(0.12)
                  : AppColors.accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              hasDiscount
                  ? Icons.check_circle_outline_rounded
                  : Icons.local_offer_outlined,
              color: hasDiscount ? AppColors.accentGreen : AppColors.accent,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              style: GoogleFonts.cairo(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
              decoration: InputDecoration(
                hintText: l10n.coupon,
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest.withOpacity(
                  0.35,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            height: 44,
            child: FilledButton(
              onPressed: () {
                FocusScope.of(context).unfocus();
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text(
                        l10n.pick(ar: 'تم تطبيق الكوبون', en: 'Coupon applied'),
                        style: GoogleFonts.cairo(),
                      ),
                    ),
                  );
              },
              child: Text(l10n.applyCoupon),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackendCouponCard extends StatelessWidget {
  const _BackendCouponCard({
    required this.controller,
    required this.hasDiscount,
    required this.isLoading,
    required this.onApply,
  });

  final TextEditingController controller;
  final bool hasDiscount;
  final bool isLoading;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: hasDiscount
              ? AppColors.accentGreen.withOpacity(0.35)
              : colorScheme.outlineVariant.withOpacity(0.7),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: hasDiscount
                  ? AppColors.accentGreen.withOpacity(0.12)
                  : AppColors.accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              hasDiscount
                  ? Icons.check_circle_outline_rounded
                  : Icons.local_offer_outlined,
              color: hasDiscount ? AppColors.accentGreen : AppColors.accent,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              style: GoogleFonts.cairo(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
              decoration: InputDecoration(
                hintText: l10n.coupon,
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest.withOpacity(
                  0.35,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            height: 44,
            child: FilledButton(
              onPressed: isLoading ? null : onApply,
              child: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(l10n.applyCoupon),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeliveryNote extends StatelessWidget {
  const _DeliveryNote({required this.message, required this.estimatedDate});

  final String message;
  final String estimatedDate;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF8F5),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFB7E8DE)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.72),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.local_shipping_outlined,
              color: Color(0xFF0F8D7D),
              size: 21,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  estimatedDate,
                  style: GoogleFonts.cairo(
                    color: const Color(0xFF075E54),
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: GoogleFonts.cairo(
                    color: const Color(0xFF136C61),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CartCheckoutSummary extends StatelessWidget {
  const _CartCheckoutSummary({
    required this.subtotal,
    required this.shipping,
    required this.discount,
    required this.onCheckout,
  });

  final double subtotal;
  final double shipping;
  final double discount;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final total = subtotal + shipping - discount;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 28,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(height: 12),
            _SummaryRow(
              label: l10n.pick(ar: 'المجموع الفرعي', en: 'Subtotal'),
              value: _money(subtotal),
            ),
            const SizedBox(height: 6),
            _SummaryRow(
              label: l10n.pick(ar: 'الشحن', en: 'Shipping'),
              value: _money(shipping),
            ),
            if (discount > 0) ...[
              const SizedBox(height: 6),
              _SummaryRow(
                label: l10n.pick(ar: 'خصم الكوبون', en: 'Coupon discount'),
                value: '-${_money(discount)}',
                valueColor: AppColors.accentGreen,
              ),
            ],
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.pick(ar: 'الإجمالي', en: 'Total'),
                        style: GoogleFonts.cairo(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _money(total),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.cairo(
                          color: AppColors.primary,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: onCheckout,
                    icon: const Icon(Icons.lock_outline_rounded, size: 18),
                    label: Text(
                      l10n.proceedToCheckout,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            color: colorScheme.onSurfaceVariant,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.cairo(
            color: valueColor ?? colorScheme.onSurface,
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

String _money(double value) => 'JD ${value.toStringAsFixed(2)}';
