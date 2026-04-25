import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cache/cache_helper.dart';
import 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit([ThemeMode initialMode = ThemeMode.light])
    : super(ThemeState(mode: initialMode));

  Future<void> switchToLight() async {
    emit(const ThemeState(mode: ThemeMode.light));
    await CacheHelper.saveThemeMode(ThemeMode.light);
  }

  Future<void> switchToDark() async {
    emit(const ThemeState(mode: ThemeMode.dark));
    await CacheHelper.saveThemeMode(ThemeMode.dark);
  }

  Future<void> toggleTheme() async {
    final nextMode = state.mode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    emit(ThemeState(mode: nextMode));
    await CacheHelper.saveThemeMode(nextMode);
  }
}
