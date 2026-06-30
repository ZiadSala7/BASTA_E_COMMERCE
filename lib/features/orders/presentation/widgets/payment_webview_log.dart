import 'package:flutter/foundation.dart';

void logPaymentWebView(String message, [Map<String, Object?>? data]) {
  if (!kDebugMode) return;
  debugPrint('[PaymentWebView] $message');
  if (data != null) debugPrint('[PaymentWebView] $data');
}
