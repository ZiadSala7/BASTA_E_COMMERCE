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

class CartCheckoutPage extends StatefulWidget {
  const CartCheckoutPage({super.key});

  @override
  State<CartCheckoutPage> createState() => _CartCheckoutPageState();
}

class _CartCheckoutPageState extends State<CartCheckoutPage> {
  late final CartRepository _cartRepository;
  final List<CartItemEntity> _items = <CartItemEntity>[];

  bool _isLoading = true;
  String? _errorMessage;
  int _selectedPaymentMethod = 0;

  static const double _shippingFee = 5;

  @override
  void initState() {
    super.initState();
    _cartRepository = sl<CartRepository>();
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
          : _CheckoutActionBar(total: _total, onPay: _continuePayment),
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

    return RefreshIndicator(
      onRefresh: _loadCart,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 140),
        children: [
          _CheckoutStatusCard(
            itemCount: _itemCount,
            storeCount: _stores.length,
          ),
          const SizedBox(height: 14),
          for (final store in _stores.entries) ...[
            _StoreOrderSection(storeName: store.key, items: store.value),
            const SizedBox(height: 12),
          ],
          _PaymentMethodsPanel(
            selectedIndex: _selectedPaymentMethod,
            onSelected: (index) =>
                setState(() => _selectedPaymentMethod = index),
          ),
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
      if (!mounted) return;
      setState(() {
        _items
          ..clear()
          ..addAll(items);
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

  void _continuePayment() {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            l10n.pick(
              ar: 'سيتم ربط بوابة الدفع في الخطوة التالية.',
              en: 'Payment gateway will be connected in the next step.',
            ),
          ),
        ),
      );
  }

  Map<String, List<CartItemEntity>> get _stores {
    final grouped = <String, List<CartItemEntity>>{};
    for (final item in _items) {
      final storeName = item.storeName.trim().isEmpty
          ? 'IonBit'
          : item.storeName;
      grouped.putIfAbsent(storeName, () => <CartItemEntity>[]).add(item);
    }
    return grouped;
  }

  int get _itemCount =>
      _items.fold<int>(0, (total, item) => total + item.quantity);

  double get _subtotal => _items.fold<double>(
    0,
    (total, item) => total + (item.price * item.quantity),
  );

  double get _shipping => _items.isEmpty ? 0 : _shippingFee;

  double get _total => _subtotal + _shipping;

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
                  l10n.pick(ar: 'طلب متعدد المتاجر', en: 'Multi-vendor order'),
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.pick(
                    ar: '$itemCount منتجات من $storeCount متاجر',
                    en: '$itemCount products from $storeCount stores',
                  ),
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
    (total, item) => total + (item.price * item.quantity),
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
          _money(item.price * item.quantity),
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
          ar: 'جاهز للربط مع بوابة الدفع',
          en: 'Ready for payment gateway',
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
              : const Color(0xFFF9FAFB),
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
  final VoidCallback onPay;

  const _CheckoutActionBar({required this.total, required this.onPay});

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
                onPressed: onPay,
                icon: const Icon(Icons.lock_outline_rounded, size: 18),
                label: Text(l10n.proceedToCheckout),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _money(double value) => 'JD ${value.toStringAsFixed(2)}';
