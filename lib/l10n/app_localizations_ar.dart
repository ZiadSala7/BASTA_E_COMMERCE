// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'مثال فلاتر';

  @override
  String currentLanguage(Object language) {
    return 'اللغة الحالية: $language';
  }

  @override
  String currentTheme(Object theme) {
    return 'الوضع الحالي: $theme';
  }

  @override
  String get toggleLanguage => 'تبديل اللغة';

  @override
  String get toggleTheme => 'تبديل النسق';

  @override
  String get pushedCounter => 'لقد ضغطت الزر هذا العدد من المرات:';

  @override
  String get increment => 'زيادة';

  @override
  String get english => 'الإنجليزية';

  @override
  String get arabic => 'العربية';

  @override
  String get light => 'فاتح';

  @override
  String get dark => 'داكن';
}
