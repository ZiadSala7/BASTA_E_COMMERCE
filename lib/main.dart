import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'core/api/dio_helper.dart';
import 'core/cache/cache_helper.dart';
import 'core/deeplinks/deep_link_handler.dart';
import 'core/di/service_locator.dart';
import 'core/managers/language_cubit.dart';
import 'core/managers/theme_cubit.dart';
import 'core/notifications/local_notification_service.dart';
import 'features/auth/data/datasources/google_sign_in_diagnostics.dart';
import 'firebase_options.dart';
import 'ionbit_e_commerce.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  DartPluginRegistrant.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (message.notification == null) {
    await LocalNotificationService.showRemoteMessage(message);
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  GoogleSignInDiagnostics.log('Firebase app initialized', {
    'projectId': Firebase.app().options.projectId,
    'appId': Firebase.app().options.appId,
    'platform': defaultTargetPlatform.name,
  });
  if (kDebugMode && defaultTargetPlatform == TargetPlatform.android) {
    await GoogleSignInDiagnostics.logInstalledAndroidSigningInfo();
  }
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await LocalNotificationService.initialize();
  await LocalNotificationService.requestPermissions();
  await LocalNotificationService.configureForegroundPresentation();
  LocalNotificationService.listenForForegroundMessages();

  const serverClientId =
      '263444450427-3h0ge2kq7ncm639nesb3vhd963gipuc4.apps.googleusercontent.com';
  try {
    await GoogleSignIn.instance.initialize(serverClientId: serverClientId);
    GoogleSignInDiagnostics.log('Google Sign-In initialized', {
      'serverClientIdSuffix': serverClientId.substring(
        serverClientId.length - 12,
      ),
    });
  } catch (error, stackTrace) {
    GoogleSignInDiagnostics.log('Google Sign-In initialization failed', {
      'errorType': error.runtimeType.toString(),
      'error': error.toString(),
      'stackTrace': stackTrace.toString(),
    });
    rethrow;
  }

  /// Initialize shared preferences cache
  await CacheHelper.init();

  /// Initialize service locator
  setupServiceLocator();

  /// Initialize Dio
  DioHelper.init();

  /// Listen for referral invite deep links (https://bs6a.com/register?ref=...)
  await DeepLinkHandler.initialize();

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
