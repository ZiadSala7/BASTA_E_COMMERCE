import '../../../../core/api/api_keys.dart';
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
      imageUrl: _absoluteUrl(
        (json['imageUrl'] ?? json['image_url'] ?? '').toString(),
      ),
      targetUrl: (json['targetUrl'] ?? json['target_url'])?.toString(),
      buttonText: (json['buttonText'] ?? json['button_text'] ?? 'تسوق الآن')
          .toString(),
    );
  }

  static String _absoluteUrl(String url) {
    if (url.isEmpty ||
        url.startsWith('http://') ||
        url.startsWith('https://')) {
      return url;
    }

    final baseUrl = ApiKeys.baseUrl.endsWith('/')
        ? ApiKeys.baseUrl.substring(0, ApiKeys.baseUrl.length - 1)
        : ApiKeys.baseUrl;
    final path = url.startsWith('/') ? url : '/$url';
    return '$baseUrl$path';
  }
}
