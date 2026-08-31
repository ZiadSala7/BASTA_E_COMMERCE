import '../../domain/entities/order_entity.dart';

class OrderModel extends OrderEntity {
  const OrderModel({
    required super.id,
    required super.status,
    required super.paymentStatus,
    required super.paymentMethod,
    required super.total,
    super.shippingCost,
    super.discountAmount,
    super.appliedCoupon,
    required super.itemsCount,
    required super.createdAt,
    required super.estimatedDeliveryAt,
    super.shippingAddress,
    super.items,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] ?? json['orderItems'] ?? json['products'];
    final parsedItems = <OrderItemEntity>[];
    if (rawItems is List) {
      for (final item in rawItems) {
        if (item is Map) {
          final m = Map<String, dynamic>.from(item);
          final product = m['product'] is Map ? Map<String, dynamic>.from(m['product']) : null;
          final images = product?['images'] ?? m['images'];
          String? imageUrl;
          if (images is List && images.isNotEmpty) {
            final first = images.first;
            imageUrl = first is Map ? (first['imageUrl'] ?? first['url'] ?? first['image'])?.toString() : first?.toString();
          } else if (m['imageUrl'] != null || product?['imageUrl'] != null) {
            imageUrl = (m['imageUrl'] ?? product?['imageUrl'])?.toString();
          }

          parsedItems.add(
            OrderItemEntity(
              id: (m['id'] ?? m['_id'] ?? '').toString(),
              productId: (m['productId'] ?? m['product_id'] ?? product?['id'] ?? '').toString(),
              productName: (m['productName'] ?? m['product_name'] ?? m['title'] ?? product?['name'] ?? product?['title'] ?? 'منتج').toString(),
              productSlug: (m['productSlug'] ?? m['product_slug'] ?? product?['slug'])?.toString(),
              storeName: (m['storeName'] ?? m['store_name'] ?? m['vendorName'] ?? product?['storeName'])?.toString(),
              storeId: (m['storeId'] ?? m['store_id'] ?? m['vendorId'] ?? product?['storeId'])?.toString(),
              sku: (m['sku'] ?? product?['sku'])?.toString(),
              trackingNumber: (m['trackingNumber'] ?? m['tracking_number'])?.toString(),
              quantity: _intFromJson(m['quantity'] ?? m['qty'] ?? 1),
              priceAtPurchase: _numberFromJson(m['priceAtPurchase'] ?? m['price'] ?? m['unitPrice'] ?? product?['price']),
              imageUrl: imageUrl,
              variantSnapshot: m['variantSnapshot'] is Map ? Map<String, dynamic>.from(m['variantSnapshot']) : null,
            ),
          );
        }
      }
    }

    OrderAddressEntity? parsedAddress;
    final rawAddress = json['shippingAddress'] ?? json['address'] ?? json['shipping_address'] ?? json['addressData'];
    if (rawAddress is Map) {
      final a = Map<String, dynamic>.from(rawAddress);
      parsedAddress = OrderAddressEntity(
        streetAddress: (a['streetAddress'] ?? a['street_address'] ?? a['street'] ?? a['address'])?.toString(),
        city: (a['city'])?.toString(),
        state: (a['state'] ?? a['region'])?.toString(),
        postalCode: (a['postalCode'] ?? a['postal_code'] ?? a['zip'])?.toString(),
        country: (a['country'])?.toString(),
        phone: (a['phone'] ?? a['phoneNumber'] ?? a['mobile'])?.toString(),
      );
    }

    final total = _numberFromJson(
      json['total'] ??
          json['totalAmount'] ??
          json['grandTotal'] ??
          json['amount'] ??
          json['subtotal'],
    );
    final shippingCost = _numberFromJson(json['shippingCost'] ?? json['shipping_cost'] ?? json['shippingFee']);
    final discountAmount = _numberFromJson(json['discountAmount'] ?? json['discount_amount'] ?? json['discount']);
    final appliedCoupon = json['appliedCoupon']?.toString();

    return OrderModel(
      id: (json['id'] ?? json['_id'] ?? json['orderId'] ?? json['number'] ?? '')
          .toString(),
      status: (json['status'] ??
              json['orderStatus'] ??
              json['currentStatus'] ??
              json['current_status'] ??
              json['state'] ??
              'PLACED')
          .toString(),
      paymentStatus: (json['paymentStatus'] ??
              json['payment_status'] ??
              json['payment']?['status'] ??
              'PENDING')
          .toString(),
      paymentMethod: (json['paymentMethod'] ??
              json['payment_method'] ??
              json['payment']?['method'] ??
              'CARD')
          .toString(),
      total: total,
      shippingCost: shippingCost,
      discountAmount: discountAmount,
      appliedCoupon: appliedCoupon,
      itemsCount: parsedItems.isNotEmpty
          ? parsedItems.fold(0, (sum, i) => sum + i.quantity)
          : _itemsCountFromJson(rawItems, json['itemsCount'] ?? json['itemCount'] ?? json['quantity']),
      createdAt: _dateFromJson(
        json['createdAt'] ??
            json['created_at'] ??
            json['date'] ??
            json['orderDate'],
      ),
      estimatedDeliveryAt: _dateFromJson(
        json['estimatedDeliveryAt'] ??
            json['estimated_delivery_at'] ??
            json['estimatedDelivery'] ??
            json['deliveryDate'],
      ),
      shippingAddress: parsedAddress,
      items: parsedItems,
    );
  }

  static double _numberFromJson(Object? value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  static int _intFromJson(Object? value) {
    if (value == null) return 1;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 1;
  }

  static int _itemsCountFromJson(Object? items, Object? fallback) {
    if (items is List) return items.length;
    if (fallback is num) return fallback.toInt();
    return int.tryParse(fallback?.toString() ?? '') ?? 0;
  }

  static DateTime? _dateFromJson(Object? value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }
}
