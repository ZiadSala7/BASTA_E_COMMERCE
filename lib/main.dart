import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'core/di/service_locator.dart';
import 'core/api/dio_helper.dart';
import 'core/cache/cache_helper.dart';
import 'core/managers/language_cubit.dart';
import 'core/managers/theme_cubit.dart';
import 'firebase_options.dart';
import 'ionbit_e_commerce.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await GoogleSignIn.instance.initialize(
    serverClientId:
        '263444450427-3h0ge2kq7ncm639nesb3vhd963gipuc4.apps.googleusercontent.com',
  );

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
