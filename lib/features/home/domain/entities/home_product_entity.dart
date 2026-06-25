class HomeProductEntity {
  final String id;
  final String name;
  final double? price;
  final double? compareAtPrice;
  final String imageUrl;
  final String? storeName;
  final String? storeSlug;

  const HomeProductEntity({
    required this.id,
    required this.name,
    required this.price,
    required this.compareAtPrice,
    required this.imageUrl,
    this.storeName,
    this.storeSlug,
  });

  bool get hasDiscount =>
      price != null && compareAtPrice != null && compareAtPrice! > price!;
}
