// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'بسطة';

  @override
  String get brandName => 'بسطة';

  @override
  String get welcome => 'حياك الله في';

  @override
  String get searchHint => 'هل تبحث عن منتج معين؟';

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

  @override
  String get skip => 'تخطي';

  @override
  String get back => 'الخلف';

  @override
  String get next => 'التالي';

  @override
  String get startNow => 'ابدأ الآن';

  @override
  String get imagePlaceholder => 'عنصر نائب للصورة';

  @override
  String get replaceImagePathHint =>
      'استبدل imagePath داخل\nOnboardingLocalDataSource';

  @override
  String get onboardingTitle1 => 'اكتشف أحدث العروض والمنتجات القريبة منك';

  @override
  String get onboardingSubtitle1 =>
      'تسوّق بسهولة واختر من بين أفضل المنتجات بأفضل الأسعار. تجربة سريعة وممتعة في انتظارك.';

  @override
  String get onboardingTitle2 => 'تسوّق بسهولة وسلاسة من غير أي تعقيد';

  @override
  String get onboardingSubtitle2 =>
      'اختر منتجاتك وأكمل طلبك في خطوات بسيطة وسريعة';

  @override
  String get loginTitle => 'تسجيل الدخول';

  @override
  String get loginSubtitle =>
      'سجّل دخولك للمتابعة والاستمتاع بتجربة تسوق أسهل.';

  @override
  String get registerTitle => 'إنشاء حساب جديد';

  @override
  String get registerSubtitle => 'أنشئ حسابك وابدأ التسوق في خطوات سريعة.';

  @override
  String get forgotPasswordTitle => 'إعادة تعيين كلمة المرور';

  @override
  String get forgotPasswordSubtitle =>
      'يرجى إدخال البريد الإلكتروني المرتبط بحسابك حتى نتمكن من إرسال تعليمات إعادة التعيين.';

  @override
  String get resetPasswordTitle => 'إعادة تعيين كلمة المرور';

  @override
  String get resetPasswordSubtitle =>
      'الصق الرمز المرسل إلى بريدك الإلكتروني واختر كلمة مرور جديدة.';

  @override
  String get resetTokenHint => 'رمز إعادة التعيين';

  @override
  String get resetTokenRequired => 'يرجى إدخال رمز إعادة التعيين';

  @override
  String get resetPasswordButton => 'إعادة تعيين كلمة المرور';

  @override
  String get verificationTitle => 'التحقق';

  @override
  String verificationSubtitle(Object destination) {
    return 'لقد أرسلنا رمز التحقق إلى $destination';
  }

  @override
  String get fullNameHint => 'الاسم بالكامل';

  @override
  String get phoneHint => 'رقم الهاتف';

  @override
  String get emailHint => 'البريد الإلكتروني';

  @override
  String get passwordHint => 'كلمة المرور';

  @override
  String get confirmPasswordHint => 'تأكيد كلمة المرور';

  @override
  String get rememberMe => 'تذكرني';

  @override
  String get forgotPasswordQuestion => 'هل نسيت كلمة المرور؟';

  @override
  String get loginButton => 'تسجيل الدخول';

  @override
  String get createAccountButton => 'إنشاء حساب';

  @override
  String get sendAction => 'إرسال';

  @override
  String get continueAction => 'الاستمرار';

  @override
  String get orLabel => 'أو';

  @override
  String get loginWithGoogle => 'تسجيل الدخول عبر Google';

  @override
  String get loginWithFacebook => 'تسجيل الدخول عبر Facebook';

  @override
  String get dontHaveAccountPrompt => 'ليس لديك حساب؟';

  @override
  String get alreadyHaveAccountPrompt => 'لديك حساب بالفعل؟';

  @override
  String get createAccountAction => 'إنشاء حساب جديد';

  @override
  String get loginAction => 'سجّل الدخول';

  @override
  String resendCodeIn(Object time) {
    return 'إعادة إرسال الرمز خلال $time';
  }

  @override
  String get resendCodeAction => 'إعادة إرسال الرمز';

  @override
  String get nameRequired => 'يرجى إدخال الاسم بالكامل';

  @override
  String get phoneRequired => 'يرجى إدخال رقم الهاتف';

  @override
  String get emailRequired => 'يرجى إدخال البريد الإلكتروني';

  @override
  String get invalidEmail => 'يرجى إدخال بريد إلكتروني صحيح';

  @override
  String get invalidPhone => 'يرجى إدخال رقم هاتف صحيح';

  @override
  String get passwordRequired => 'يرجى إدخال كلمة المرور';

  @override
  String get passwordTooShort => 'يجب أن تكون كلمة المرور 8 أحرف على الأقل';

  @override
  String get passwordComplexityRequired =>
      'يجب أن تحتوي كلمة المرور على حرف كبير وحرف صغير ورقم ورمز خاص.';

  @override
  String get confirmPasswordRequired => 'يرجى تأكيد كلمة المرور';

  @override
  String get passwordsDoNotMatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get verificationCodeRequired =>
      'يرجى إدخال رمز التحقق المكون من 6 أرقام';

  @override
  String get enterAppButton => 'ادخل التطبيق';

  @override
  String get menu => 'القائمة';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get cart => 'السلة';

  @override
  String get coupon => 'قسيمة الخصم';

  @override
  String get applyCoupon => 'تطبيق';

  @override
  String get deliveryNote => 'يتم احتساب رسوم التوصيل والضرائب عند الدفع.';

  @override
  String get proceedToCheckout => 'المتابعة للدفع';

  @override
  String get featuredStoresPageTitle => 'متاجر متميزة';

  @override
  String get couldNotLoadStores => 'تعذر تحميل المتاجر';

  @override
  String get noStoresFound => 'لا توجد متاجر';

  @override
  String get viewProducts => 'عرض المنتجات';

  @override
  String get tryAgain => 'حاول مرة أخرى';

  @override
  String get primeVideo => 'برايم فيديو';
}
