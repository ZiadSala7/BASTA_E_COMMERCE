import 'package:dio/dio.dart';

import '../../domain/exceptions/checkout_exception.dart';
import 'orders_response_parser.dart';

String ordersDioMessage(DioException error) {
  final body = responseMap(error.response?.data);
  final message = body['message']?.toString();
  if (message != null && message.isNotEmpty) return message;
  final apiError = body['error']?.toString();
  if (apiError != null && apiError.isNotEmpty) return apiError;
  if ({
    DioExceptionType.connectionTimeout,
    DioExceptionType.receiveTimeout,
    DioExceptionType.sendTimeout,
  }.contains(error.type)) {
    return 'The server took too long to respond. Please try again.';
  }
  if (error.type == DioExceptionType.connectionError) {
    return 'Unable to reach the server. Check your internet connection.';
  }
  return error.message ?? 'Orders request failed.';
}

CheckoutException checkoutExceptionFromDio(DioException error) {
  final body = responseMap(error.response?.data);
  return CheckoutException(
    message: ordersDioMessage(error),
    errorName: _firstText(body, const ['name', 'errorName', 'error', 'type']),
    productId: _firstText(body, const ['productId', 'product_id']),
    statusCode: error.response?.statusCode,
  );
}

String? _firstText(Map<String, dynamic> body, List<String> keys) {
  final data = responseMap(body['data']);
  final details = responseMap(body['details']);
  for (final source in [body, data, details]) {
    for (final key in keys) {
      final value = source[key];
      if (value == null || value is Map || value is List) continue;
      final text = value.toString().trim();
      if (text.isNotEmpty) return text;
    }
  }
  return null;
}
