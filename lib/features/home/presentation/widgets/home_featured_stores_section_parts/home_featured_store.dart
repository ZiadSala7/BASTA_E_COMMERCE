part of '../home_featured_stores_section.dart';

class HomeFeaturedStore {
  final String id;
  final String name;
  final String slug;
  final String description;
  final String imageUrl;
  final String? imageAsset;
  final String? targetUrl;

  const HomeFeaturedStore({
    required this.id,
    required this.name,
    this.slug = '',
    this.description = '',
    this.imageUrl = '',
    this.imageAsset,
    this.targetUrl,
  });

  factory HomeFeaturedStore.fromJson(Map<String, dynamic> json) {
    return HomeFeaturedStore(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? json['title'] ?? '').toString(),
      slug: (json['slug'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      imageUrl: (json['image_url'] ?? json['imageUrl'] ?? json['logo'] ?? '')
          .toString(),
      targetUrl: (json['target_url'] ?? json['targetUrl'] ?? json['url'])
          ?.toString(),
    );
  }

  static List<HomeFeaturedStore> listFromJson(List<dynamic> json) {
    return json
        .whereType<Map>()
        .map(
          (item) => HomeFeaturedStore.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }
}
