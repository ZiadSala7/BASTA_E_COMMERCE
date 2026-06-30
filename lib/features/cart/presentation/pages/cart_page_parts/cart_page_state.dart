part of '../cart_page.dart';

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
