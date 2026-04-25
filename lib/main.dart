import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/service_locator.dart';
import 'core/api/dio_helper.dart';
import 'core/cache/cache_helper.dart';
import 'core/managers/language_cubit.dart';
import 'core/managers/theme_cubit.dart';
import 'ionbit_e_commerce.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// Initialize shared preferences cache
  await CacheHelper.init();

  /// Initialize service locator
  setupServiceLocator();

  /// Initialize Dio
  DioHelper.init();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit(CacheHelper.getThemeMode())),
        BlocProvider(create: (_) => LanguageCubit(CacheHelper.getLanguage())),
      ],
      child: const IonbitECommerce(),
    ),
  );
}
