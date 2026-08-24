part of '../cart_checkout_page.dart';

class _CartCheckoutPageState extends State<CartCheckoutPage> {
  static const LatLng _initialDeliveryLocation = LatLng(31.9539, 35.9106);

  late final CartRepository _cartRepository;
  late final OrdersRepository _ordersRepository;
  late final CartBadgeController _cartBadgeController;
  late final CalculateShippingUseCase _calculateShipping;
  final List<CartItemEntity> _items = <CartItemEntity>[];
  final List<SavedAddressModel> _savedAddresses = <SavedAddressModel>[];
  final Set<String> _stockIssueProductIds = <String>{};

  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorMessage;
  int _selectedPaymentMethod = 1;
  LatLng? _selectedDeliveryLocation;
  String? _selectedAddressId;
  double _liveShippingFee = 5.0;

  @override
  void initState() {
    super.initState();
    _cartRepository = sl<CartRepository>();
    _ordersRepository = sl<OrdersRepository>();
    _cartBadgeController = sl<CartBadgeController>();
    _calculateShipping = sl<CalculateShippingUseCase>();
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
            _StoreOrderSection(
              storeName: store.storeName,
              items: store.items,
              stockIssueProductIds: _stockIssueProductIds,
            ),
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
      _updateShippingFee();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = _cleanError(error);
        _isLoading = false;
      });
    }
  }

  Future<void> _updateShippingFee() async {
    final address = _selectedSavedAddress;
    String city = (address != null && address.city.isNotEmpty) ? address.city : '';
    String? street = address?.street;

    if (city.isEmpty && _selectedDeliveryLocation != null) {
      try {
        final placemarks = await placemarkFromCoordinates(
          _selectedDeliveryLocation!.latitude,
          _selectedDeliveryLocation!.longitude,
        );
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          city = p.locality ?? p.subAdministrativeArea ?? p.administrativeArea ?? '';
          street ??= p.street;
        }
      } catch (_) {}
    }

    if (city.isEmpty) city = 'Amman';

    try {
      final rate = await _calculateShipping(city: city, streetAddress: street);
      if (!mounted) return;
      setState(() {
        _liveShippingFee = rate.shippingFee;
      });
    } catch (_) {}
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
        paymentMethod: _selectedPaymentMethod == 1 ? 'CARD' : 'COD',
        couponCode: widget.couponCode,
      );

      if (!mounted) return;

      if (_selectedPaymentMethod == 1) {
        final session = checkout.paymentSession;
        if (session == null ||
            !session.isValid ||
            checkout.order.id.trim().isEmpty ||
            checkout.order.total <= 0) {
          if (checkout.order.id.trim().isNotEmpty) {
            try {
              await _ordersRepository.cancelPayment(checkout.order.id);
            } catch (_) {}
          }
          setState(() => _isSubmitting = false);
          if (!mounted) return;
          _showSnackBar(
            l10n.pick(
              ar: 'حدث خطأ في إنشاء جلسة الدفع، يرجى المحاولة مرة أخرى.',
              en: 'Failed to create payment session, please try again.',
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

        // B. Payment Cancelled (cancelCallback)
        if (result == null ||
            result.outcome == PaymentWebViewOutcome.cancelled) {
          try {
            await _ordersRepository.cancelPayment(checkout.order.id);
          } catch (_) {}
          setState(() => _isSubmitting = false);
          _showSnackBar(
            l10n.pick(
              ar: 'تم إلغاء عملية الدفع.',
              en: 'Payment was cancelled.',
            ),
          );
          return;
        }

        // C. Payment Error (errorCallback)
        if (result.outcome == PaymentWebViewOutcome.failed) {
          try {
            await _ordersRepository.cancelPayment(checkout.order.id);
          } catch (_) {}
          setState(() => _isSubmitting = false);
          _showSnackBar(
            l10n.pick(
              ar: 'حدث خطأ في بوابة الدفع، يرجى المحاولة مرة أخرى.',
              en: 'A payment gateway error occurred, please try again.',
            ),
          );
          return;
        }

        // A. Payment Success (completeCallback)
        if (session.successIndicator.trim().isNotEmpty &&
            result.resultIndicator != null &&
            result.resultIndicator!.trim().isNotEmpty) {
          _verifySuccessIndicator(
            expected: session.successIndicator,
            actual: result.resultIndicator,
          );
        }

        try {
          // Tell the backend to verify the transaction with Mastercard server-to-server
          final verifiedOrder = await _ordersRepository.verifyPayment(
            checkout.order.id,
          );
          final paymentStatus = verifiedOrder.paymentStatus
              .trim()
              .toUpperCase();
          if (paymentStatus.isNotEmpty &&
              paymentStatus != 'PAID' &&
              paymentStatus != 'SUCCESS' &&
              paymentStatus != 'COMPLETED' &&
              paymentStatus != 'PLACED') {
            throw StateError('Payment is not confirmed yet.');
          }
        } catch (_) {
          if (!mounted) return;
          setState(() => _isSubmitting = false);
          await _clearLocalCartState();
          if (!mounted) return;
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
      await _clearLocalCartState();
      if (!mounted) return;
      await _showOrderResultDialog(success: true);
    } catch (error) {
      if (!mounted) return;
      _highlightStockIssue(error);
      setState(() => _isSubmitting = false);
      await _showOrderResultDialog(success: false, message: _cleanError(error));
    }
  }

  void _verifySuccessIndicator({
    required String expected,
    required String? actual,
  }) {
    final normalizedExpected = expected.trim();
    if (normalizedExpected.isEmpty) return;

    if ((actual ?? '').trim() != normalizedExpected) {
      throw Exception(
        'Payment confirmation did not match the gateway session.',
      );
    }
  }

  void _highlightStockIssue(Object error) {
    if (error is! CheckoutException || !error.isInsufficientStock) return;

    final productId = error.productId;
    if (productId == null) return;

    setState(() {
      _stockIssueProductIds.add(productId);
    });
  }

  Future<void> _clearLocalCartState() async {
    try {
      await _cartRepository.clearCart();
    } catch (_) {}
    if (!mounted) return;
    setState(() {
      _isSubmitting = false;
      _items.clear();
      _stockIssueProductIds.clear();
    });
    _cartBadgeController.setItems(const <CartItemEntity>[]);
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
    _updateShippingFee();
  }

  Map<String, dynamic> _addressPayload(LatLng location) {
    final coordinates =
        '${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}';
    final saved = _selectedSavedAddress;
    final street = (saved != null && saved.street.isNotEmpty)
        ? saved.street
        : 'Pinned delivery location: $coordinates';
    final city = (saved != null && saved.city.isNotEmpty) ? saved.city : 'Amman';
    final state = (saved != null && saved.state.isNotEmpty) ? saved.state : 'Amman';
    final postalCode = (saved != null && saved.postalCode.isNotEmpty) ? saved.postalCode : '11183';
    final country = (saved != null && saved.country.isNotEmpty) ? saved.country : 'Jordan';

    return {
      'streetAddress': street,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'country': country,
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

  double get _shipping => _items.isEmpty ? 0 : _liveShippingFee;

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
