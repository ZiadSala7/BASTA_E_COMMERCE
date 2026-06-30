part of '../home_ad_carousel.dart';

class HomeAdBanner {
  final String id;
  final String title;
  final String buttonText;
  final String imageUrl;
  final String? imageAsset;
  final String? targetUrl;

  const HomeAdBanner({
    required this.id,
    required this.title,
    required this.buttonText,
    this.imageUrl = '',
    this.imageAsset,
    this.targetUrl,
  });

  factory HomeAdBanner.fromJson(Map<String, dynamic> json) {
    return HomeAdBanner(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? json['name'] ?? '').toString(),
      buttonText:
          (json['button_text'] ??
                  json['buttonText'] ??
                  '\u062a\u0633\u0648\u0642 \u0627\u0644\u0622\u0646')
              .toString(),
      imageUrl: (json['image_url'] ?? json['imageUrl'] ?? '').toString(),
      targetUrl:
          (json['target_url'] ??
                  json['targetUrl'] ??
                  json['redirect_url'] ??
                  json['redirectUrl'])
              ?.toString(),
    );
  }

  static List<HomeAdBanner> listFromJson(List<dynamic> json) {
    return json
        .whereType<Map>()
        .map((item) => HomeAdBanner.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }
}
