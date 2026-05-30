import '../../../../l10n/app_localizations.dart';

class AuthValidators {
  const AuthValidators._();

  static String? name(String? value, AppLocalizations localizations) {
    if (value == null || value.trim().isEmpty) {
      return localizations.nameRequired;
    }
    return null;
  }

  static String? email(String? value, AppLocalizations localizations) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return localizations.emailRequired;
    }

    const pattern = r'^[^@\s]+@[^@\s]+\.[^@\s]+$';
    if (!RegExp(pattern).hasMatch(email)) {
      return localizations.invalidEmail;
    }

    return null;
  }

  static String? phone(String? value, AppLocalizations localizations) {
    final phone = value?.trim() ?? '';
    if (phone.isEmpty) {
      return null;
    }

    const pattern = r'^\+?[0-9]{8,15}$';
    if (!RegExp(pattern).hasMatch(phone)) {
      return localizations.invalidPhone;
    }

    return null;
  }

  static String? password(String? value, AppLocalizations localizations) {
    final password = value ?? '';
    if (password.isEmpty) {
      return localizations.passwordRequired;
    }

    if (password.length < 8) {
      return localizations.passwordTooShort;
    }

    return null;
  }

  static String? confirmPassword(
    String? value,
    String password,
    AppLocalizations localizations,
  ) {
    final confirmation = value ?? '';
    if (confirmation.isEmpty) {
      return localizations.confirmPasswordRequired;
    }

    if (confirmation != password) {
      return localizations.passwordsDoNotMatch;
    }

    return null;
  }

  static String? verificationCode(
    String value,
    AppLocalizations localizations,
  ) {
    if (!RegExp(r'^\d{6}$').hasMatch(value.trim())) {
      return localizations.verificationCodeRequired;
    }

    return null;
  }
}
