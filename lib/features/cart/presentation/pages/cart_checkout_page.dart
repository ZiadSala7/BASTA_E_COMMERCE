// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/extensions/app_localizations_x.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/assets.dart';
import '../../../../core/widgets/location_picker_page.dart';
import '../../../../core/widgets/status/empty_state.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../account/data/datasources/saved_addresses_local_datasource.dart';
import '../../../account/data/models/saved_address_model.dart';
import '../../../account/presentation/pages/addresses_page.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/repositories/cart_repository.dart';
import '../../../orders/domain/repositories/orders_repository.dart';
import '../../../orders/presentation/pages/payment_webview_page.dart';

class CartCheckoutPage extends StatefulWidget {
  const CartCheckoutPage({super.key});

  @override
  State<CartCheckoutPage> createState() => _CartCheckoutPageState();
}

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
        if (session == null || !session.isValid) {
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

        await _ordersRepository.verifyPayment(
          result.orderId.trim().isEmpty ? checkout.order.id : result.orderId,
        );
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
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final color = success ? AppColors.primary : const Color(0xFFE53935);

    await showDialog<void>(
      context: context,
      barrierDismissible: success,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(
          success ? Icons.check_circle_rounded : Icons.error_outline_rounded,
          color: color,
          size: 42,
        ),
        title: Text(
          success
              ? l10n.pick(ar: 'تم تأكيد الطلب', en: 'Order confirmed')
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
          if (!success)
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.pick(ar: 'إعادة المحاولة', en: 'Try again')),
            ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              if (success) Navigator.of(context).pop(true);
            },
            child: Text(
              success
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

class _CheckoutHeader extends StatelessWidget {
  const _CheckoutHeader();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      height: 94 + MediaQuery.paddingOf(context).top,
      padding: EdgeInsets.only(
        top: MediaQuery.paddingOf(context).top,
        left: 16,
        right: 16,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryDark, AppColors.primary, Color(0xFF20B7A8)],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Row(
        children: [
          _HeaderButton(
            icon: Icons.arrow_back_rounded,
            tooltip: l10n.back,
            onTap: () => Navigator.of(context).maybePop(),
          ),
          const Spacer(),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                l10n.proceedToCheckout,
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  height: 1.05,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                l10n.pick(ar: 'مراجعة الطلب والدفع', en: 'Review and payment'),
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
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.16),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.22)),
            ),
            child: const Icon(Icons.lock_outline_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _HeaderButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white.withOpacity(0.14),
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 42,
            height: 42,
            child: Icon(icon, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class _CheckoutStatusCard extends StatelessWidget {
  final int itemCount;
  final int storeCount;

  const _CheckoutStatusCard({
    required this.itemCount,
    required this.storeCount,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final subtitle = storeCount > 0
        ? l10n.pick(
            ar: '$itemCount منتجات من $storeCount متاجر',
            en: '$itemCount products from $storeCount stores',
          )
        : l10n.pick(ar: '$itemCount منتجات', en: '$itemCount products');
    final title = storeCount > 1
        ? l10n.pick(ar: 'طلب متعدد المتاجر', en: 'Multi-vendor order')
        : l10n.pick(ar: 'مراجعة الطلب', en: 'Order review');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.cairo(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
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

class _CheckoutStoreGroup {
  _CheckoutStoreGroup({required this.storeName, required this.items});

  final String storeName;
  final List<CartItemEntity> items;

  bool get hasStoreName => storeName.trim().isNotEmpty;
}

class _StoreOrderSection extends StatelessWidget {
  final String storeName;
  final List<CartItemEntity> items;

  const _StoreOrderSection({required this.storeName, required this.items});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (storeName.trim().isNotEmpty) ...[
            Row(
              children: [
                const Icon(
                  Icons.storefront_rounded,
                  color: AppColors.primary,
                  size: 19,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    storeName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                      color: colorScheme.onSurface,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Text(
                  _money(_storeTotal),
                  style: GoogleFonts.cairo(
                    color: AppColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
          for (var index = 0; index < items.length; index++) ...[
            _CheckoutItemTile(item: items[index]),
            if (index != items.length - 1) const Divider(height: 18),
          ],
        ],
      ),
    );
  }

  double get _storeTotal => items.fold<double>(
    0,
    (total, item) => total + (item.activePrice * item.quantity),
  );
}

class _CheckoutItemTile extends StatelessWidget {
  final CartItemEntity item;

  const _CheckoutItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        _ProductThumb(imageUrl: item.imageUrl),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.cairo(
                  color: colorScheme.onSurface,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Qty ${item.quantity}',
                style: GoogleFonts.cairo(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Text(
          _money(item.activePrice * item.quantity),
          style: GoogleFonts.cairo(
            color: AppColors.primary,
            fontSize: 13.5,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _ProductThumb extends StatelessWidget {
  final String imageUrl;

  const _ProductThumb({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl.trim().isEmpty
          ? Image.asset(Assets.imagesCart, fit: BoxFit.contain)
          : Image.network(
              imageUrl,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  Image.asset(Assets.imagesCart, fit: BoxFit.contain),
            ),
    );
  }
}

class _PaymentMethodsPanel extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _PaymentMethodsPanel({
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final methods = [
      _PaymentMethod(
        icon: Icons.payments_outlined,
        title: l10n.pick(ar: 'الدفع عند الاستلام', en: 'Cash on delivery'),
        subtitle: l10n.pick(
          ar: 'ادفع عند استلام الطلب',
          en: 'Pay when the order arrives',
        ),
      ),
      _PaymentMethod(
        icon: Icons.credit_card_rounded,
        title: l10n.pick(ar: 'بطاقة بنكية', en: 'Card payment'),
        subtitle: l10n.pick(
          ar: 'ادفع بأمان عبر Mastercard',
          en: 'Pay securely with Mastercard',
        ),
      ),
    ];

    return _Panel(
      title: l10n.pick(ar: 'طريقة الدفع', en: 'Payment method'),
      child: Column(
        children: [
          for (var index = 0; index < methods.length; index++) ...[
            _PaymentTile(
              method: methods[index],
              selected: selectedIndex == index,
              onTap: () => onSelected(index),
            ),
            if (index != methods.length - 1) const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _PaymentMethod {
  final IconData icon;
  final String title;
  final String subtitle;

  const _PaymentMethod({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}

class _PaymentTile extends StatelessWidget {
  final _PaymentMethod method;
  final bool selected;
  final VoidCallback onTap;

  const _PaymentTile({
    required this.method,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withOpacity(0.08)
              : colorScheme.surfaceContainerHighest.withOpacity(0.38),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppColors.primary : colorScheme.outlineVariant,
          ),
        ),
        child: Row(
          children: [
            Icon(
              method.icon,
              color: selected
                  ? AppColors.primary
                  : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method.title,
                    style: GoogleFonts.cairo(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    method.subtitle,
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? AppColors.primary : colorScheme.outline,
            ),
          ],
        ),
      ),
    );
  }
}

class _SavedAddressesPanel extends StatelessWidget {
  const _SavedAddressesPanel({
    required this.addresses,
    required this.selectedAddressId,
    required this.onSelected,
    required this.onManageAddresses,
  });

  final List<SavedAddressModel> addresses;
  final String? selectedAddressId;
  final ValueChanged<SavedAddressModel> onSelected;
  final VoidCallback onManageAddresses;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return _Panel(
      title: l10n.pick(ar: 'عنوان التوصيل', en: 'Delivery address'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (addresses.isEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withOpacity(0.38),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.add_location_alt_outlined,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.pick(
                        ar: 'أضف عنوان توصيل لاستخدامه عند تأكيد الطلب.',
                        en: 'Add a delivery address to use at checkout.',
                      ),
                      style: GoogleFonts.cairo(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            for (var index = 0; index < addresses.length; index++) ...[
              _SavedAddressTile(
                address: addresses[index],
                selected: addresses[index].id == selectedAddressId,
                onTap: () => onSelected(addresses[index]),
              ),
              if (index != addresses.length - 1) const SizedBox(height: 8),
            ],
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: onManageAddresses,
            icon: const Icon(Icons.edit_location_alt_outlined, size: 18),
            label: Text(
              addresses.isEmpty
                  ? l10n.pick(ar: 'إضافة عنوان', en: 'Add address')
                  : l10n.pick(ar: 'إدارة العناوين', en: 'Manage addresses'),
              style: GoogleFonts.cairo(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _SavedAddressTile extends StatelessWidget {
  const _SavedAddressTile({
    required this.address,
    required this.selected,
    required this.onTap,
  });

  final SavedAddressModel address;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withOpacity(0.08)
              : colorScheme.surfaceContainerHighest.withOpacity(0.38),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppColors.primary : colorScheme.outlineVariant,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? AppColors.primary : colorScheme.outline,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          address.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.cairo(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      if (address.isDefault)
                        Text(
                          l10n.pick(ar: 'افتراضي', en: 'Default'),
                          style: GoogleFonts.cairo(
                            color: AppColors.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    address.summary,
                    maxLines: 2,
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
          ],
        ),
      ),
    );
  }
}

class _DeliveryLocationPanel extends StatefulWidget {
  final LatLng initialLocation;
  final LatLng? selectedLocation;
  final ValueChanged<LatLng> onLocationSelected;

  const _DeliveryLocationPanel({
    required this.initialLocation,
    required this.selectedLocation,
    required this.onLocationSelected,
  });

  @override
  State<_DeliveryLocationPanel> createState() => _DeliveryLocationPanelState();
}

class _DeliveryLocationPanelState extends State<_DeliveryLocationPanel> {
  final MapController _mapController = MapController();
  late LatLng _currentMapCenter;

  @override
  void initState() {
    super.initState();
    _currentMapCenter = widget.selectedLocation ?? widget.initialLocation;
  }

  @override
  void didUpdateWidget(covariant _DeliveryLocationPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedLocation != oldWidget.selectedLocation) {
      _currentMapCenter = widget.selectedLocation ?? widget.initialLocation;
      if (widget.selectedLocation != null) {
        _mapController.move(widget.selectedLocation!, 15);
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _selectLocation(LatLng location) async {
    widget.onLocationSelected(location);
    setState(() {
      _currentMapCenter = location;
    });
    _mapController.move(location, 15);
  }

  Future<void> _openLargeMap() async {
    final result = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        builder: (_) => LocationPickerPage(
          initialCenter: _currentMapCenter,
          selectedLocation: widget.selectedLocation,
        ),
      ),
    );

    if (result != null) {
      await _selectLocation(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final selectedLocation = widget.selectedLocation;

    return _Panel(
      title: l10n.pick(ar: 'موقع التوصيل', en: 'Delivery location'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.pick(
              ar: 'اسحب الخريطة أو اضغط على الموقع لتحديد مكان التوصيل.',
              en: 'Drag the map or tap a point to choose your delivery location.',
            ),
            style: GoogleFonts.cairo(
              color: colorScheme.onSurfaceVariant,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 210,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: widget.initialLocation,
                      initialZoom: 13,
                      onTap: (_, point) => _selectLocation(point),
                      onPositionChanged: (camera, _) {
                        _currentMapCenter = camera.center;
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.ionbit.bsTa',
                      ),
                      if (selectedLocation != null)
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: selectedLocation,
                              width: 42,
                              height: 42,
                              child: const Icon(
                                Icons.location_on_rounded,
                                color: Color(0xFFE53935),
                                size: 42,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const Icon(
                    Icons.location_pin,
                    size: 42,
                    color: Color(0xFFE53935),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: () => _selectLocation(_currentMapCenter),
            icon: const Icon(Icons.check_rounded, size: 16),
            label: Text(
              l10n.pick(ar: 'تأكيد الموقع', en: 'Confirm location'),
              style: GoogleFonts.cairo(fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _openLargeMap,
            icon: const Icon(Icons.open_in_full_rounded, size: 16),
            label: Text(
              l10n.pick(ar: 'فتح الخريطة', en: 'Open map'),
              style: GoogleFonts.cairo(fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: selectedLocation == null
                  ? colorScheme.surfaceContainerHighest.withOpacity(0.38)
                  : AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: selectedLocation == null
                    ? colorScheme.outlineVariant
                    : AppColors.primary.withOpacity(0.35),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  selectedLocation == null
                      ? Icons.add_location_alt_outlined
                      : Icons.location_on_rounded,
                  color: selectedLocation == null
                      ? colorScheme.onSurfaceVariant
                      : AppColors.primary,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    selectedLocation == null
                        ? l10n.pick(
                            ar: 'لم يتم تحديد موقع بعد',
                            en: 'No location selected yet',
                          )
                        : '${selectedLocation.latitude.toStringAsFixed(5)}, ${selectedLocation.longitude.toStringAsFixed(5)}',
                    style: GoogleFonts.cairo(
                      color: selectedLocation == null
                          ? colorScheme.onSurfaceVariant
                          : colorScheme.onSurface,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _selectLocation(_currentMapCenter),
                  icon: const Icon(Icons.my_location_rounded, size: 16),
                  label: Text(
                    l10n.pick(ar: 'استخدام مركز الخريطة', en: 'Use map center'),
                    style: GoogleFonts.cairo(fontWeight: FontWeight.w800),
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

class _FullScreenMapPage extends StatefulWidget {
  final LatLng initialCenter;
  final LatLng? selectedLocation;

  const _FullScreenMapPage({
    required this.initialCenter,
    required this.selectedLocation,
  });

  @override
  State<_FullScreenMapPage> createState() => _FullScreenMapPageState();
}

class _FullScreenMapPageState extends State<_FullScreenMapPage> {
  final MapController _controller = MapController();
  late LatLng _currentCenter;
  LatLng? _selected;

  @override
  void initState() {
    super.initState();
    _currentCenter = widget.initialCenter;
    _selected = widget.selectedLocation ?? widget.initialCenter;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.pick(ar: 'حدد الموقع', en: 'Choose location')),
        actions: [
          TextButton.icon(
            onPressed: _selected == null
                ? null
                : () => Navigator.of(context).pop<LatLng>(_selected!),
            icon: const Icon(Icons.check, color: Colors.white),
            label: Text(
              l10n.pick(ar: 'تأكيد', en: 'Confirm'),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: FlutterMap(
        mapController: _controller,
        options: MapOptions(
          initialCenter: _currentCenter,
          initialZoom: 15,
          onTap: (tapPos, point) => setState(() => _selected = point),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.ionbit.bsTa',
          ),
          if (_selected != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: _selected!,
                  width: 48,
                  height: 48,
                  child: const Icon(
                    Icons.location_on_rounded,
                    color: Color(0xFFE53935),
                    size: 48,
                  ),
                ),
              ],
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // move to selected or center
          if (_selected != null) {
            _controller.move(_selected!, 15);
          } else {
            _controller.move(_currentCenter, 15);
          }
        },
        child: const Icon(Icons.my_location_rounded),
      ),
    );
  }
}

class _TotalsPanel extends StatelessWidget {
  final double subtotal;
  final double shipping;
  final double total;

  const _TotalsPanel({
    required this.subtotal,
    required this.shipping,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return _Panel(
      title: l10n.pick(ar: 'ملخص الدفع', en: 'Payment summary'),
      child: Column(
        children: [
          _TotalLine(label: l10n.subtotal, value: _money(subtotal)),
          const SizedBox(height: 8),
          _TotalLine(
            label: l10n.pick(ar: 'الشحن', en: 'Shipping'),
            value: _money(shipping),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1),
          ),
          _TotalLine(
            label: l10n.grandTotal,
            value: _money(total),
            isBold: true,
          ),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  final String title;
  final Widget child;

  const _Panel({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.cairo(
              color: colorScheme.onSurface,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _TotalLine extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _TotalLine({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            color: isBold
                ? colorScheme.onSurface
                : colorScheme.onSurfaceVariant,
            fontSize: isBold ? 14.5 : 13,
            fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.cairo(
            color: isBold ? AppColors.primary : colorScheme.onSurface,
            fontSize: isBold ? 16 : 13,
            fontWeight: isBold ? FontWeight.w900 : FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _CheckoutActionBar extends StatelessWidget {
  final double total;
  final bool isLoading;
  final VoidCallback onPay;

  const _CheckoutActionBar({
    required this.total,
    required this.isLoading,
    required this.onPay,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 22,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.grandTotal,
                    style: GoogleFonts.cairo(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    _money(total),
                    style: GoogleFonts.cairo(
                      color: AppColors.primary,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              height: 50,
              child: FilledButton.icon(
                onPressed: isLoading ? null : onPay,
                icon: isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.lock_outline_rounded, size: 18),
                label: Text(
                  isLoading
                      ? l10n.pick(ar: 'جاري المعالجة...', en: 'Processing...')
                      : l10n.proceedToCheckout,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _money(double value) => 'JD ${value.toStringAsFixed(2)}';
