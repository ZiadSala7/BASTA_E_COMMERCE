import 'package:dio/dio.dart';

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
