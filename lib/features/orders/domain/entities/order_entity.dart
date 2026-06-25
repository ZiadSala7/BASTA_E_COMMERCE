class OrderEntity {
  final String id;
  final String status;
  final String paymentStatus;
  final String paymentMethod;
  final double total;
  final int itemsCount;
  final DateTime? createdAt;
  final DateTime? estimatedDeliveryAt;

  const OrderEntity({
    required this.id,
    required this.status,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.total,
    required this.itemsCount,
    required this.createdAt,
    required this.estimatedDeliveryAt,
  });
}
