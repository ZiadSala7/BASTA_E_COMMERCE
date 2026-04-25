import 'package:get_it/get_it.dart';
import '../api/dio_consumer.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  // Register DioConsumer as singleton
  getIt.registerSingleton<DioConsumer>(DioConsumer());

  // Register repositories
  getIt.registerSingleton<AuthRepository>(AuthRepositoryImpl());
}
