import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cache/cache_helper.dart';
import 'language_state.dart';

class LanguageCubit extends Cubit<LanguageState> {
  LanguageCubit([AppLanguage initialLanguage = AppLanguage.english])
    : super(
        LanguageState(
          locale: Locale(initialLanguage == AppLanguage.english ? 'en' : 'ar'),
          language: initialLanguage,
        ),
      );

  Future<void> switchToEnglish() async {
    emit(
      const LanguageState(locale: Locale('en'), language: AppLanguage.english),
    );
    await CacheHelper.saveLanguage(AppLanguage.english);
  }

  Future<void> switchToArabic() async {
    emit(
      const LanguageState(locale: Locale('ar'), language: AppLanguage.arabic),
    );
    await CacheHelper.saveLanguage(AppLanguage.arabic);
  }

  Future<void> toggleLanguage() async {
    final nextLanguage = state.language == AppLanguage.english
        ? AppLanguage.arabic
        : AppLanguage.english;
    emit(
      LanguageState(
        locale: Locale(nextLanguage == AppLanguage.english ? 'en' : 'ar'),
        language: nextLanguage,
      ),
    );
    await CacheHelper.saveLanguage(nextLanguage);
  }
}
