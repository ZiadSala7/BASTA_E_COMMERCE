class OrderEntity {
  final String id;
  final String status;
  final double total;
  final int itemsCount;
  final DateTime? createdAt;
  final DateTime? estimatedDeliveryAt;

  const OrderEntity({
    required this.id,
    required this.status,
    required this.total,
    required this.itemsCount,
    required this.createdAt,
    required this.estimatedDeliveryAt,
  });
}
