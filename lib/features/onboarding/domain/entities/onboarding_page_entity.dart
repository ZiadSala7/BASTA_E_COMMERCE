import 'package:equatable/equatable.dart';

class OnboardingPageEntity extends Equatable {
  final int id;
  final String title;
  final String subtitle;
  final String imagePath;

  const OnboardingPageEntity({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imagePath,
  });

  @override
  List<Object> get props => [id, title, subtitle, imagePath];
}
