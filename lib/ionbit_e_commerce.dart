import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/app_theme.dart';
import 'core/utils/app_router.dart';
import 'core/managers/language_cubit.dart';
import 'core/managers/theme_cubit.dart';
import 'l10n/app_localizations.dart';

class IonbitECommerce extends StatelessWidget {
  const IonbitECommerce({super.key});

  static final AppRouter _appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    final themeState = context.watch<ThemeCubit>().state;
    final languageState = context.watch<LanguageCubit>().state;

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      themeAnimationDuration: Duration.zero,
      themeMode: themeState.mode,
      theme: AppTheme.light(languageState.locale),
      darkTheme: AppTheme.dark(languageState.locale),
      locale: DevicePreview.locale(context) ?? languageState.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      builder: DevicePreview.appBuilder,
      routerConfig: _appRouter.router,
    );
  }
}
