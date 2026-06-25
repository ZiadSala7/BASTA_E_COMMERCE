class CartItemEntity {
  final String id;
  final String productId;
  final String name;
  final double price;
  final double activePrice;
  final int quantity;
  final String? storeId;
  final String storeName;
  final String? storeSlug;
  final String? color;
  final String? size;
  final String imageUrl;

  const CartItemEntity({
    required this.id,
    this.productId = '',
    required this.name,
    required this.price,
    double? activePrice,
    required this.quantity,
    this.storeId,
    this.storeName = '',
    this.storeSlug,
    this.color,
    this.size,
    required this.imageUrl,
  }) : activePrice = activePrice ?? price;

  CartItemEntity copyWith({
    String? id,
    String? productId,
    String? name,
    double? price,
    double? activePrice,
    int? quantity,
    String? storeId,
    String? storeName,
    String? storeSlug,
    String? color,
    String? size,
    String? imageUrl,
  }) {
    return CartItemEntity(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      price: price ?? this.price,
      activePrice: activePrice ?? this.activePrice,
      quantity: quantity ?? this.quantity,
      storeId: storeId ?? this.storeId,
      storeName: storeName ?? this.storeName,
      storeSlug: storeSlug ?? this.storeSlug,
      color: color ?? this.color,
      size: size ?? this.size,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
