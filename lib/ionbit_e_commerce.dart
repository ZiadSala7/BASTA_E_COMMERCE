import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'test_page.dart';
import 'core/managers/language_cubit.dart';
import 'core/managers/theme_cubit.dart';
import 'l10n/app_localizations.dart';

class IonbitECommerce extends StatelessWidget {
  const IonbitECommerce({super.key});

  @override
  Widget build(BuildContext context) {
    final themeState = context.watch<ThemeCubit>().state;
    final languageState = context.watch<LanguageCubit>().state;

    return MaterialApp(
      title: 'Flutter Demo',
      themeMode: themeState.mode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark(useMaterial3: true),
      locale: languageState.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: const TestPage(),
    );
  }
}
