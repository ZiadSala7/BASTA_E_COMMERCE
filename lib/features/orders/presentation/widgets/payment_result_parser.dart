import 'dart:convert';

import '../models/payment_webview_result.dart';

PaymentWebViewResult? paymentResultFromUrl(String url, String orderId) {
  final uri = Uri.tryParse(url);
  if (uri == null) return null;

  final isCallbackPath =
      uri.path.contains('callback') ||
      uri.path.contains('checkout') ||
      uri.path.contains('payment');

  if (!isCallbackPath && uri.host != 'bs6a.com') {
    return null;
  }

  if (uri.queryParameters['cancelled'] == 'true' ||
      uri.queryParameters['cancel'] == 'true') {
    return PaymentWebViewResult(
      outcome: PaymentWebViewOutcome.cancelled,
      orderId: orderId,
    );
  }

  final error =
      uri.queryParameters['error'] ?? uri.queryParameters['errorMessage'];
  if (error != null && error.isNotEmpty) {
    return PaymentWebViewResult(
      outcome: PaymentWebViewOutcome.failed,
      orderId: orderId,
      message: error,
    );
  }

  final indicator =
      uri.queryParameters['resultIndicator'] ??
      uri.queryParameters['successIndicator'] ??
      uri.queryParameters['result'];

  if (indicator != null && indicator.isNotEmpty) {
    return PaymentWebViewResult(
      outcome: PaymentWebViewOutcome.completed,
      orderId: orderId,
      resultIndicator: indicator,
    );
  }

  return null;
}

PaymentWebViewResult paymentResultFromMessage(String message, String orderId) {
  final payload = _bridgePayload(message);
  final event = payload.$1.toLowerCase().trim();
  final value = payload.$2;

  return switch (event) {
    'cancelled' || 'cancel' => PaymentWebViewResult(
      outcome: PaymentWebViewOutcome.cancelled,
      orderId: orderId,
    ),
    'completed' || 'complete' || 'success' => PaymentWebViewResult(
      outcome: PaymentWebViewOutcome.completed,
      orderId: orderId,
      resultIndicator: value,
    ),
    'failed' || 'error' || 'timeout' => PaymentWebViewResult(
      outcome: PaymentWebViewOutcome.failed,
      orderId: orderId,
      message: (value != null && value.trim().isNotEmpty)
          ? value.trim()
          : 'A payment gateway error occurred.',
    ),
    _ => PaymentWebViewResult(
      outcome: PaymentWebViewOutcome.failed,
      orderId: orderId,
      message: 'The payment gateway returned an unexpected response.',
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
