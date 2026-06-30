part of '../cart_checkout_page.dart';

class _CartCheckoutPageState extends State<CartCheckoutPage> {
  static const LatLng _initialDeliveryLocation = LatLng(31.9539, 35.9106);

  late final CartRepository _cartRepository;
  late final OrdersRepository _ordersRepository;
  final List<CartItemEntity> _items = <CartItemEntity>[];
  final List<SavedAddressModel> _savedAddresses = <SavedAddressModel>[];

  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorMessage;
  int _selectedPaymentMethod = 1;
  LatLng? _selectedDeliveryLocation;
  String? _selectedAddressId;

  static const double _shippingFee = 5;

  @override
  void initState() {
    super.initState();
    _cartRepository = sl<CartRepository>();
    _ordersRepository = sl<OrdersRepository>();
    _loadCart();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          const _CheckoutHeader(),
          Expanded(child: _buildBody(l10n)),
        ],
      ),
      bottomNavigationBar: _items.isEmpty || _isLoading || _errorMessage != null
          ? null
          : _CheckoutActionBar(
              total: _total,
              isLoading: _isSubmitting,
              onPay: _continuePayment,
            ),
    );
  }

  Widget _buildBody(AppLocalizations l10n) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return EmptyState(
        icon: Icons.error_outline_rounded,
        title: l10n.pick(ar: 'تعذر تحميل الطلب', en: 'Could not load order'),
        message: _errorMessage,
        actionLabel: l10n.tryAgain,
        onActionTap: _loadCart,
      );
    }

    if (_items.isEmpty) {
      return EmptyState(
        icon: Icons.shopping_cart_outlined,
        title: l10n.cart,
        message: l10n.pick(
          ar: 'السلة فارغة. أضف منتجات قبل المتابعة للدفع.',
          en: 'Your cart is empty. Add products before checkout.',
        ),
        actionLabel: l10n.shopNow,
        onActionTap: () => Navigator.of(context).maybePop(),
      );
    }

    final stores = _stores;

    return RefreshIndicator(
      onRefresh: _loadCart,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 140),
        children: [
          _CheckoutStatusCard(
            itemCount: _itemCount,
            storeCount: stores.where((store) => store.hasStoreName).length,
          ),
          const SizedBox(height: 14),
          for (final store in stores) ...[
            _StoreOrderSection(storeName: store.storeName, items: store.items),
            const SizedBox(height: 12),
          ],
          _PaymentMethodsPanel(
            selectedIndex: _selectedPaymentMethod,
            onSelected: (index) =>
                setState(() => _selectedPaymentMethod = index),
          ),
          const SizedBox(height: 12),
          _SavedAddressesPanel(
            addresses: _savedAddresses,
            selectedAddressId: _selectedAddressId,
            onSelected: (address) => setState(() {
              _selectedAddressId = address.id;
              _selectedDeliveryLocation = LatLng(
                address.latitude,
                address.longitude,
              );
            }),
            onManageAddresses: _openAddressesManager,
          ),
          if (_selectedSavedAddress == null) ...[
            const SizedBox(height: 12),
            _DeliveryLocationPanel(
              selectedLocation: _selectedDeliveryLocation,
              initialLocation:
                  _selectedDeliveryLocation ?? _initialDeliveryLocation,
              onLocationSelected: (location) =>
                  setState(() => _selectedDeliveryLocation = location),
            ),
          ],
          const SizedBox(height: 12),
          _TotalsPanel(subtotal: _subtotal, shipping: _shipping, total: _total),
        ],
      ),
    );
  }

  Future<void> _loadCart() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final items = await _cartRepository.getCartItems();
      final addresses = SavedAddressesLocalDataSource.load();
      final selectedAddressId = _resolveSelectedAddressId(addresses);
      if (!mounted) return;
      setState(() {
        _items
          ..clear()
          ..addAll(items);
        _savedAddresses
          ..clear()
          ..addAll(addresses);
        _selectedAddressId = selectedAddressId;
        final selectedAddress = _selectedSavedAddress;
        if (selectedAddress != null) {
          _selectedDeliveryLocation = LatLng(
            selectedAddress.latitude,
            selectedAddress.longitude,
          );
        }
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

  Future<void> _continuePayment() async {
    final l10n = AppLocalizations.of(context)!;
    final deliveryLocation = _selectedDeliveryLocation;
    final selectedAddress = _selectedSavedAddress;

    if (_isSubmitting) return;

    if (selectedAddress == null && deliveryLocation == null) {
      _showSnackBar(
        l10n.pick(
          ar: 'يرجى تحديد موقع التوصيل على الخريطة قبل إتمام الشراء.',
          en: 'Please choose an address or delivery location before checkout.',
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final checkout = await _ordersRepository.checkout(
        address:
            selectedAddress?.toCheckoutPayload() ??
            _addressPayload(deliveryLocation!),
        paymentMethod: _selectedPaymentMethod == 1 ? 'CARD' : 'CASH',
      );

      if (!mounted) return;

      if (_selectedPaymentMethod == 1) {
        final session = checkout.paymentSession;
        if (session == null ||
            !session.isValid ||
            checkout.order.id.trim().isEmpty ||
            checkout.order.total <= 0) {
          setState(() => _isSubmitting = false);
          await _loadCart();
          if (!mounted) return;
          await _showOrderResultDialog(
            success: true,
            message: l10n.pick(
              ar: 'تم إنشاء الطلب بنجاح، لكن لم يتم فتح بوابة الدفع لأن الخادم لم يرسل جلسة دفع. حالة الدفع الآن قيد الانتظار.',
              en: 'Your order was created, but the payment gateway was not opened because the server did not return a payment session. Payment is pending.',
            ),
          );
          return;
        }

        final result = await Navigator.of(context).push<PaymentWebViewResult>(
          MaterialPageRoute(
            builder: (_) => PaymentWebViewPage(
              orderId: checkout.order.id,
              totalAmount: checkout.order.total,
              session: session,
            ),
          ),
        );

        if (!mounted) return;

        if (result == null ||
            result.outcome == PaymentWebViewOutcome.cancelled) {
          setState(() => _isSubmitting = false);
          _showSnackBar(
            l10n.pick(
              ar: 'تم إلغاء عملية الدفع.',
              en: 'Payment was cancelled.',
            ),
          );
          return;
        }

        if (result.outcome == PaymentWebViewOutcome.failed) {
          throw Exception(
            result.message ??
                l10n.pick(
                  ar: 'تعذر إتمام الدفع.',
                  en: 'Payment could not be completed.',
                ),
          );
        }

        try {
          // Verify only the order created by the backend. Never trust an ID
          // that has travelled through the JavaScript bridge.
          final verifiedOrder = await _ordersRepository.verifyPayment(
            checkout.order.id,
          );
          final paymentStatus = verifiedOrder.paymentStatus
              .trim()
              .toUpperCase();
          if (paymentStatus.isNotEmpty &&
              paymentStatus != 'PAID' &&
              paymentStatus != 'SUCCESS' &&
              paymentStatus != 'COMPLETED') {
            throw StateError('Payment is not confirmed yet.');
          }
        } catch (_) {
          if (!mounted) return;
          setState(() => _isSubmitting = false);
          await _showOrderResultDialog(
            success: false,
            verificationPending: true,
            message: l10n.pick(
              ar: 'قد تكون عملية الدفع اكتملت، لكن تعذر تأكيدها مع الخادم الآن. لا تحاول الدفع مرة أخرى. راجع حالة الطلب من صفحة الطلبات.',
              en: 'Your payment may have completed, but the server could not confirm it yet. Do not pay again. Check this order from the orders page.',
            ),
          );
          return;
        }
      }

      if (!mounted) return;
      setState(() => _isSubmitting = false);
      await _loadCart();
      if (!mounted) return;
      await _showOrderResultDialog(success: true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      await _showOrderResultDialog(success: false, message: _cleanError(error));
    }
  }

  Future<void> _openAddressesManager() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const AddressesPage()));
    if (!mounted) return;

    final addresses = SavedAddressesLocalDataSource.load();
    setState(() {
      _savedAddresses
        ..clear()
        ..addAll(addresses);
      _selectedAddressId = _resolveSelectedAddressId(addresses);
      final selectedAddress = _selectedSavedAddress;
      if (selectedAddress != null) {
        _selectedDeliveryLocation = LatLng(
          selectedAddress.latitude,
          selectedAddress.longitude,
        );
      }
    });
  }

  Map<String, dynamic> _addressPayload(LatLng location) {
    final coordinates =
        '${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}';

    return {
      'streetAddress': 'Pinned delivery location: $coordinates',
      'city': 'Cairo',
      'state': 'Cairo Governorate',
      'postalCode': '11511',
      'country': 'Egypt',
      'latitude': location.latitude,
      'longitude': location.longitude,
    };
  }

  Future<void> _showOrderResultDialog({
    required bool success,
    String? message,
    bool verificationPending = false,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final color = success
        ? AppColors.primary
        : verificationPending
        ? const Color(0xFFF59E0B)
        : const Color(0xFFE53935);

    await showDialog<void>(
      context: context,
      barrierDismissible: success || verificationPending,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(
          success
              ? Icons.check_circle_rounded
              : verificationPending
              ? Icons.schedule_rounded
              : Icons.error_outline_rounded,
          color: color,
          size: 42,
        ),
        title: Text(
          success
              ? l10n.pick(ar: 'تم تأكيد الطلب', en: 'Order confirmed')
              : verificationPending
              ? l10n.pick(
                  ar: 'تأكيد الدفع قيد الانتظار',
                  en: 'Payment confirmation pending',
                )
              : l10n.pick(ar: 'فشلت عملية الدفع', en: 'Payment failed'),
          textAlign: TextAlign.center,
          style: GoogleFonts.cairo(fontWeight: FontWeight.w900),
        ),
        content: Text(
          success
              ? (message ??
                    l10n.pick(
                      ar: 'تم إنشاء طلبك بنجاح. يمكنك متابعته من صفحة الطلبات.',
                      en: 'Your order was created successfully. You can follow it from the orders page.',
                    ))
              : (message ??
                    l10n.pick(
                      ar: 'يرجى المحاولة مرة أخرى.',
                      en: 'Please try again.',
                    )),
          textAlign: TextAlign.center,
          style: GoogleFonts.cairo(fontWeight: FontWeight.w600),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          if (!success && !verificationPending)
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.pick(ar: 'إعادة المحاولة', en: 'Try again')),
            ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              if (success || verificationPending) {
                Navigator.of(context).pop(true);
              }
            },
            child: Text(
              success || verificationPending
                  ? l10n.pick(ar: 'تم', en: 'Done')
                  : l10n.pick(ar: 'حسنا', en: 'OK'),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  List<_CheckoutStoreGroup> get _stores {
    final grouped = <String, _CheckoutStoreGroup>{};
    for (final item in _items) {
      final slug = item.storeSlug?.trim();
      final name = item.storeName.trim();
      final key = slug != null && slug.isNotEmpty
          ? slug
          : name.isNotEmpty
          ? name
          : 'unknown-store';
      grouped
          .putIfAbsent(
            key,
            () =>
                _CheckoutStoreGroup(storeName: name, items: <CartItemEntity>[]),
          )
          .items
          .add(item);
    }
    return grouped.values.toList(growable: false);
  }

  int get _itemCount =>
      _items.fold<int>(0, (total, item) => total + item.quantity);

  double get _subtotal => _items.fold<double>(
    0,
    (total, item) => total + (item.activePrice * item.quantity),
  );

  double get _shipping => _items.isEmpty ? 0 : _shippingFee;

  double get _total => _subtotal + _shipping;

  SavedAddressModel? get _selectedSavedAddress {
    final selectedId = _selectedAddressId;
    if (selectedId == null) return null;

    for (final address in _savedAddresses) {
      if (address.id == selectedId) return address;
    }

    return null;
  }

  String? _resolveSelectedAddressId(List<SavedAddressModel> addresses) {
    if (addresses.isEmpty) return null;

    final selectedId = _selectedAddressId;
    if (selectedId != null &&
        addresses.any((address) => address.id == selectedId)) {
      return selectedId;
    }

    for (final address in addresses) {
      if (address.isDefault) return address.id;
    }

    return addresses.first.id;
  }

  String _cleanError(Object error) {
    return error.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
  }
}
