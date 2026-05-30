import '../../domain/entities/order_entity.dart';

class OrderModel extends OrderEntity {
  const OrderModel({
    required super.id,
    required super.status,
    required super.total,
    required super.itemsCount,
    required super.createdAt,
    required super.estimatedDeliveryAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final items = json['items'] ?? json['orderItems'] ?? json['products'];

    return OrderModel(
      id: (json['id'] ?? json['_id'] ?? json['orderId'] ?? json['number'] ?? '')
          .toString(),
      status: (json['status'] ?? json['orderStatus'] ?? json['state'] ?? '')
          .toString(),
      total: _numberFromJson(
        json['total'] ??
            json['totalAmount'] ??
            json['grandTotal'] ??
            json['amount'] ??
            json['subtotal'],
      ),
      itemsCount: _itemsCountFromJson(
        items,
        json['itemsCount'] ?? json['itemCount'] ?? json['quantity'],
      ),
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
    );
  }

  static double _numberFromJson(Object? value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
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
