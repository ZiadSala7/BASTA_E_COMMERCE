class CartItemEntity {
  final String id;
  final String productId;
  final String name;
  final double price;
  final int quantity;
  final String storeName;
  final String? color;
  final String? size;
  final String imageUrl;

  const CartItemEntity({
    required this.id,
    this.productId = '',
    required this.name,
    required this.price,
    required this.quantity,
    this.storeName = '',
    this.color,
    this.size,
    required this.imageUrl,
  });

  CartItemEntity copyWith({
    String? id,
    String? productId,
    String? name,
    double? price,
    int? quantity,
    String? storeName,
    String? color,
    String? size,
    String? imageUrl,
  }) {
    return CartItemEntity(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      storeName: storeName ?? this.storeName,
      color: color ?? this.color,
      size: size ?? this.size,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
