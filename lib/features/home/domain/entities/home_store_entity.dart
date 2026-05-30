class HomeStoreEntity {
  final String id;
  final String vendorId;
  final String name;
  final String slug;
  final String description;
  final String status;
  final DateTime? createdAt;

  const HomeStoreEntity({
    required this.id,
    required this.vendorId,
    required this.name,
    required this.slug,
    required this.description,
    required this.status,
    required this.createdAt,
  });
}
