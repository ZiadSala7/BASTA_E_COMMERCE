class OrderAddressEntity {
  final String? streetAddress;
  final String? city;
  final String? state;
  final String? postalCode;
  final String? country;
  final String? phone;

  const OrderAddressEntity({
    this.streetAddress,
    this.city,
    this.state,
    this.postalCode,
    this.country,
    this.phone,
  });

  String get fullAddress => [
    streetAddress,
    city,
    state,
    country,
  ].where((p) => p != null && p.trim().isNotEmpty).join(', ');
}

class OrderItemEntity {
  final String id;
  final String productId;
  final String productName;
  final String? productSlug;
  final String? storeName;
  final String? storeId;
  final String? sku;
  final String? trackingNumber;
  final int quantity;
  final double priceAtPurchase;
  final String? imageUrl;
  final Map<String, dynamic>? variantSnapshot;

  const OrderItemEntity({
    required this.id,
    required this.productId,
    required this.productName,
    this.productSlug,
    this.storeName,
    this.storeId,
    this.sku,
    this.trackingNumber,
    required this.quantity,
    required this.priceAtPurchase,
    this.imageUrl,
    this.variantSnapshot,
  });

  double get totalPrice => priceAtPurchase * quantity;
}

class OrderEntity {
  final String id;
  final String status;
  final String paymentStatus;
  final String paymentMethod;
  final double total;
  final double shippingCost;
  final double discountAmount;
  final String? appliedCoupon;
  final int itemsCount;
  final DateTime? createdAt;
  final DateTime? estimatedDeliveryAt;
  final OrderAddressEntity? shippingAddress;
  final List<OrderItemEntity> items;

  const OrderEntity({
    required this.id,
    required this.status,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.total,
    this.shippingCost = 0.0,
    this.discountAmount = 0.0,
    this.appliedCoupon,
    required this.itemsCount,
    required this.createdAt,
    required this.estimatedDeliveryAt,
    this.shippingAddress,
    this.items = const [],
  });

  double get subtotal => items.isNotEmpty
      ? items.fold(0.0, (sum, item) => sum + item.totalPrice)
      : (total - shippingCost + discountAmount);
}
