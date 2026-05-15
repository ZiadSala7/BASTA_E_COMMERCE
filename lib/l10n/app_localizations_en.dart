// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Basta';

  @override
  String get brandName => 'Basta';

  @override
  String get welcome => 'Welcome to';

  @override
  String get searchHint => 'Are you looking for a specific product?';

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

  @override
  String get skip => 'Skip';

  @override
  String get back => 'Back';

  @override
  String get next => 'Next';

  @override
  String get startNow => 'Start now';

  @override
  String get imagePlaceholder => 'Image placeholder';

  @override
  String get replaceImagePathHint =>
      'Replace the imagePath in\nOnboardingLocalDataSource';

  @override
  String get onboardingTitle1 =>
      'Discover the latest offers and products near you';

  @override
  String get onboardingSubtitle1 =>
      'Shop easily and choose from the best products at the best prices. A fast and enjoyable experience is waiting for you.';

  @override
  String get onboardingTitle2 => 'Shop smoothly without any complications';

  @override
  String get onboardingSubtitle2 =>
      'Choose your products and complete your order in simple, quick steps';

  @override
  String get loginTitle => 'Log in';

  @override
  String get loginSubtitle =>
      'Sign in to continue and enjoy an easier shopping experience.';

  @override
  String get registerTitle => 'Create a new account';

  @override
  String get registerSubtitle =>
      'Create your account and start shopping in a few quick steps.';

  @override
  String get forgotPasswordTitle => 'Reset password';

  @override
  String get forgotPasswordSubtitle =>
      'Please enter the email linked to your account so we can send reset instructions.';

  @override
  String get verificationTitle => 'Verification';

  @override
  String verificationSubtitle(Object destination) {
    return 'We sent a verification code to $destination';
  }

  @override
  String get fullNameHint => 'Full name';

  @override
  String get phoneHint => 'Phone number';

  @override
  String get emailHint => 'Email address';

  @override
  String get passwordHint => 'Password';

  @override
  String get confirmPasswordHint => 'Confirm password';

  @override
  String get rememberMe => 'Remember me';

  @override
  String get forgotPasswordQuestion => 'Forgot your password?';

  @override
  String get loginButton => 'Log in';

  @override
  String get createAccountButton => 'Create account';

  @override
  String get sendAction => 'Send';

  @override
  String get continueAction => 'Continue';

  @override
  String get orLabel => 'Or';

  @override
  String get loginWithGoogle => 'Login with Google';

  @override
  String get loginWithFacebook => 'Login with Facebook';

  @override
  String get dontHaveAccountPrompt => 'Don\'t have an account?';

  @override
  String get alreadyHaveAccountPrompt => 'Already have an account?';

  @override
  String get createAccountAction => 'Create new account';

  @override
  String get loginAction => 'Log in';

  @override
  String resendCodeIn(Object time) {
    return 'Resend code in $time';
  }

  @override
  String get nameRequired => 'Please enter your full name';

  @override
  String get phoneRequired => 'Please enter your phone number';

  @override
  String get emailRequired => 'Please enter your email';

  @override
  String get invalidEmail => 'Please enter a valid email address';

  @override
  String get invalidPhone => 'Please enter a valid phone number';

  @override
  String get passwordRequired => 'Please enter your password';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters';

  @override
  String get confirmPasswordRequired => 'Please confirm your password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get verificationCodeRequired => 'Please enter the 4-digit code';

  @override
  String get enterAppButton => 'Enter the app';

  @override
  String get menu => 'Menu';

  @override
  String get notifications => 'Notifications';

  @override
  String get cart => 'Cart';

  @override
  String get coupon => 'Coupon';

  @override
  String get applyCoupon => 'Apply';

  @override
  String get deliveryNote =>
      'Delivery fees and taxes are calculated at checkout.';

  @override
  String get proceedToCheckout => 'Proceed to checkout';

  @override
  String get primeVideo => 'Prime Video';
}
