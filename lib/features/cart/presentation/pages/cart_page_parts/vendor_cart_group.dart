part of '../cart_page.dart';

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
