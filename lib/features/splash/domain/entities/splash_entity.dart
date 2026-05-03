import 'package:equatable/equatable.dart';

class SplashEntity extends Equatable {
  final String initialRoute;
  final bool isFirstLaunch;

  const SplashEntity({
    required this.initialRoute,
    required this.isFirstLaunch,
  });

  @override
  List<Object> get props => [initialRoute, isFirstLaunch];
}
