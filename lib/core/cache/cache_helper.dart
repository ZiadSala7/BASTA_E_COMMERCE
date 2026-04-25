import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../managers/language_state.dart';
import 'cache_keys.dart';

class CacheHelper {
  static SharedPreferences? _preferences;

  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  static Future<bool> setString(String key, String value) {
    return _preferences!.setString(key, value);
  }

  static String? getString(String key) {
    return _preferences?.getString(key);
  }

  static Future<bool> setBool(String key, bool value) {
    return _preferences!.setBool(key, value);
  }

  static bool? getBool(String key) {
    return _preferences?.getBool(key);
  }

  static Future<bool> setInt(String key, int value) {
    return _preferences!.setInt(key, value);
  }

  static int? getInt(String key) {
    return _preferences?.getInt(key);
  }

  static Future<bool> setDouble(String key, double value) {
    return _preferences!.setDouble(key, value);
  }

  static double? getDouble(String key) {
    return _preferences?.getDouble(key);
  }

  static Future<bool> remove(String key) {
    return _preferences!.remove(key);
  }

  static Future<bool> clear() {
    return _preferences!.clear();
  }

  static Future<bool> saveThemeMode(ThemeMode mode) {
    return setString(CacheKeys.themeMode, mode.name);
  }

  static ThemeMode getThemeMode() {
    final stored = getString(CacheKeys.themeMode);
    if (stored == ThemeMode.dark.name) {
      return ThemeMode.dark;
    }
    return ThemeMode.light;
  }

  static Future<bool> saveLanguage(AppLanguage language) {
    return setString(CacheKeys.appLanguage, language.name);
  }

  static AppLanguage getLanguage() {
    final stored = getString(CacheKeys.appLanguage);
    if (stored == AppLanguage.arabic.name) {
      return AppLanguage.arabic;
    }
    return AppLanguage.english;
  }
}
