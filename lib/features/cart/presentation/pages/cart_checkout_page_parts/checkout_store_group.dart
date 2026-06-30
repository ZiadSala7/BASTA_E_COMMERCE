part of '../cart_checkout_page.dart';

class _CheckoutStoreGroup {
  _CheckoutStoreGroup({required this.storeName, required this.items});

  final String storeName;
  final List<CartItemEntity> items;

  bool get hasStoreName => storeName.trim().isNotEmpty;
}
