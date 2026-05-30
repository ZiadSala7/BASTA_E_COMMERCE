class HomeProductEntity {
  final String id;
  final String name;
  final double? price;
  final double? compareAtPrice;
  final String imageUrl;

  const HomeProductEntity({
    required this.id,
    required this.name,
    required this.price,
    required this.compareAtPrice,
    required this.imageUrl,
  });

  bool get hasDiscount =>
      price != null && compareAtPrice != null && compareAtPrice! > price!;
}
