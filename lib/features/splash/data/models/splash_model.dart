import '../../domain/entities/splash_entity.dart';

class SplashModel extends SplashEntity {
  const SplashModel({
    required super.initialRoute,
    required super.isFirstLaunch,
  });

  factory SplashModel.fromJson(Map<String, dynamic> json) => SplashModel(
    initialRoute: json['initialRoute'] as String,
    isFirstLaunch: json['isFirstLaunch'] as bool,
  );

  Map<String, dynamic> toJson() => {
    'initialRoute': initialRoute,
    'isFirstLaunch': isFirstLaunch,
  };
}
