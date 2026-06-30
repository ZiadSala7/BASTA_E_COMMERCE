import 'package:flutter/foundation.dart';

void logPayment(String message, Map<String, Object?> data) {
  if (!kDebugMode) return;
  debugPrint('[Payment] $message');
  debugPrint('[Payment] $data');
}

Object? sanitizePaymentPayload(Object? value) {
  if (value is Map) {
    return value.map((key, item) {
      final safeKey = key.toString();
      return MapEntry(
        safeKey,
        _isSensitive(safeKey)
            ? paymentValuePreview(item?.toString())
            : sanitizePaymentPayload(item),
      );
    });
  }
  if (value is List) {
    return value.map(sanitizePaymentPayload).toList(growable: false);
  }
  return value;
}

String paymentValuePreview(String? value) {
  if (value == null || value.isEmpty) return '<empty>';
  final start = value.length <= 12 ? value : value.substring(0, 12);
  final end = value.length <= 8 ? '' : value.substring(value.length - 8);
  return '$start...$end (${value.length} chars)';
}

bool _isSensitive(String key) {
  final normalized = key.toLowerCase();
  return normalized.contains('token') ||
      normalized.contains('sessionid') ||
      normalized.contains('successindicator') ||
      normalized == 'authorization';
}
