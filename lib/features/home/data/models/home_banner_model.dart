import '../../domain/entities/home_banner_entity.dart';

class HomeBannerModel extends HomeBannerEntity {
  const HomeBannerModel({
    required super.id,
    required super.title,
    required super.imageUrl,
    super.targetUrl,
    super.buttonText = 'تسوق الآن',
  });

  factory HomeBannerModel.fromJson(Map<String, dynamic> json) {
    return HomeBannerModel(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? json['name'] ?? '').toString(),
      imageUrl: (json['imageUrl'] ?? json['image_url'] ?? '').toString(),
      targetUrl: (json['targetUrl'] ?? json['target_url'])?.toString(),
      buttonText: (json['buttonText'] ?? json['button_text'] ?? 'تسوق الآن')
          .toString(),
    );
  }
}
