import 'dart:convert';

import '../models/payment_webview_result.dart';

PaymentWebViewResult? paymentResultFromUrl(String url, String orderId) {
  final uri = Uri.tryParse(url);
  if (uri == null ||
      uri.scheme != 'https' ||
      uri.host != 'bs6a.com' ||
      uri.path != '/checkout/callback') {
    return null;
  }
  if (uri.queryParameters['cancelled'] == 'true') {
    return PaymentWebViewResult(
      outcome: PaymentWebViewOutcome.cancelled,
      orderId: orderId,
    );
  }
  final error = uri.queryParameters['error'];
  if (error != null && error.isNotEmpty) {
    return PaymentWebViewResult(
      outcome: PaymentWebViewOutcome.failed,
      orderId: orderId,
      message: error,
    );
  }
  return PaymentWebViewResult(
    outcome: PaymentWebViewOutcome.completed,
    orderId: orderId,
    resultIndicator:
        uri.queryParameters['resultIndicator'] ??
        uri.queryParameters['successIndicator'],
  );
}

PaymentWebViewResult paymentResultFromMessage(String message, String orderId) {
  final payload = _bridgePayload(message);
  final event = payload.$1;
  final value = payload.$2;
  return switch (event) {
    'cancelled' => PaymentWebViewResult(
      outcome: PaymentWebViewOutcome.cancelled,
      orderId: orderId,
    ),
    'completed' => PaymentWebViewResult(
      outcome: PaymentWebViewOutcome.completed,
      orderId: orderId,
      resultIndicator: value,
    ),
    'failed' => PaymentWebViewResult(
      outcome: PaymentWebViewOutcome.failed,
      orderId: orderId,
      message: value ?? 'The payment gateway reported an error.',
    ),
    _ => PaymentWebViewResult(
      outcome: PaymentWebViewOutcome.failed,
      orderId: orderId,
      message: 'The payment gateway returned an unknown response.',
    ),
  };
}

(String, String?) _bridgePayload(String message) {
  try {
    final payload = jsonDecode(message);
    if (payload is Map) {
      return (
        payload['event']?.toString() ?? '',
        payload['message']?.toString(),
      );
    }
  } on FormatException {
    final separator = message.indexOf(':');
    return (
      separator < 0 ? message : message.substring(0, separator),
      separator < 0 ? null : message.substring(separator + 1),
    );
  }
  return ('', null);
}
