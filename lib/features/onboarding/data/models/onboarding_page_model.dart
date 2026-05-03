import '../../domain/entities/onboarding_page_entity.dart';

class OnboardingPageModel extends OnboardingPageEntity {
  const OnboardingPageModel({
    required super.id,
    required super.title,
    required super.subtitle,
    required super.imagePath,
  });

  factory OnboardingPageModel.fromJson(Map<String, dynamic> json) =>
      OnboardingPageModel(
        id:        json['id'] as int,
        title:     json['title'] as String,
        subtitle:  json['subtitle'] as String,
        imagePath: json['imagePath'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id':        id,
        'title':     title,
        'subtitle':  subtitle,
        'imagePath': imagePath,
      };
}
