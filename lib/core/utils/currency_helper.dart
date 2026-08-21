import 'package:flutter/widgets.dart';

import '../../l10n/app_localizations.dart';

class CurrencyHelper {
  /// Format a numeric amount to localized currency string (e.g. `24.99 د.أ` in Arabic, `JD 24.99` in English).
  static String format(
    num? amount, {
    BuildContext? context,
    bool? isArabic,
    int decimalDigits = 2,
    bool showCurrency = true,
  }) {
    if (amount == null) return '';
    final formattedNum = amount.toStringAsFixed(decimalDigits);
    if (!showCurrency) return formattedNum;

    final isAr = isArabic ??
        (context != null
            ? (AppLocalizations.of(context)?.localeName.startsWith('ar') ?? true)
            : true);

    return isAr ? '$formattedNum د.أ' : 'JD $formattedNum';
  }

  /// Robustly extracts a numeric value from a string that may contain Arabic or English currency symbols, commas, or dots in abbreviations
  static double parse(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();

    final text = value.toString().trim();
    if (text.isEmpty) return 0.0;

    // Strip known currency words and symbols
    final stripped = text
        .replaceAll('د.أ', '')
        .replaceAll('د.ا', '')
        .replaceAll('دينار', '')
        .replaceAll(RegExp(r'[a-zA-Z$€£¥]'), '')
        .replaceAll(',', '')
        .trim();

    // Extract the decimal or integer sequence
    final match = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(stripped);
    if (match != null) {
      return double.tryParse(match.group(1)!) ?? 0.0;
    }

    return double.tryParse(stripped) ?? 0.0;
  }
}
