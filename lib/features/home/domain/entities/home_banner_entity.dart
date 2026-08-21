class HomeBannerEntity {
  final String id;
  final String title;
  final String imageUrl;
  final String? targetUrl;
  final String buttonText;

  const HomeBannerEntity({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.targetUrl,
    this.buttonText = 'تسوق الآن',
  });
}
