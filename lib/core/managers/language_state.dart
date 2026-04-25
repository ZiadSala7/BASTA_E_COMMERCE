import 'package:flutter/material.dart';

enum AppLanguage { english, arabic }

class LanguageState {
  final Locale locale;
  final AppLanguage language;

  const LanguageState({required this.locale, required this.language});
}
