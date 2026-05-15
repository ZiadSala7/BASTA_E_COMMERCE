class CartItemEntity {
  final String id;
  final String name;
  final double price;
  final int quantity;
  final String? color;
  final String? size;
  final String imageUrl;

  const CartItemEntity({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    this.color,
    this.size,
    required this.imageUrl,
  });

  CartItemEntity copyWith({
    String? id,
    String? name,
    double? price,
    int? quantity,
    String? color,
    String? size,
    String? imageUrl,
  }) {
    return CartItemEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      color: color ?? this.color,
      size: size ?? this.size,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}