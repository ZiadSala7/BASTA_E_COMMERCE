// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Flutter Demo';

  @override
  String currentLanguage(Object language) {
    return 'Current language: $language';
  }

  @override
  String currentTheme(Object theme) {
    return 'Current theme: $theme';
  }

  @override
  String get toggleLanguage => 'Toggle Language';

  @override
  String get toggleTheme => 'Toggle Theme';

  @override
  String get pushedCounter => 'You have pushed the button this many times:';

  @override
  String get increment => 'Increment';

  @override
  String get english => 'English';

  @override
  String get arabic => 'Arabic';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';
}
