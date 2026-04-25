import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/managers/language_cubit.dart';
import 'core/managers/language_state.dart';
import 'core/managers/theme_cubit.dart';
import 'l10n/app_localizations.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final languageState = context.watch<LanguageCubit>().state;
    final themeState = context.watch<ThemeCubit>().state;
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(localizations.appTitle),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              localizations.currentLanguage(
                languageState.language == AppLanguage.english
                    ? localizations.english
                    : localizations.arabic,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              localizations.currentTheme(
                themeState.mode == ThemeMode.light
                    ? localizations.light
                    : localizations.dark,
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () =>
                      context.read<LanguageCubit>().toggleLanguage(),
                  child: Text(localizations.toggleLanguage),
                ),
                ElevatedButton(
                  onPressed: () => context.read<ThemeCubit>().toggleTheme(),
                  child: Text(localizations.toggleTheme),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(localizations.pushedCounter),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: localizations.increment,
        child: const Icon(Icons.add),
      ),
    );
  }
}
