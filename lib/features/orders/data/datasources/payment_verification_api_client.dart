import 'dart:developer';

import 'package:dio/dio.dart';

import '../../../../core/api/dio_consumer.dart';
import '../../../../core/api/endpoints.dart';
import '../models/order_model.dart';
import 'orders_dio_error.dart';
import 'orders_response_parser.dart';
import 'payment_log.dart';

class PaymentVerificationApiClient {
  const PaymentVerificationApiClient(this._dio);

  final DioConsumer _dio;

  Future<OrderModel> verify(String orderId) async {
    final endpoint = Endpoints.verifyPayment(orderId);
    try {
      logPayment('Verify request', {
        'method': 'GET',
        'endpoint': endpoint,
        'orderId': orderId,
      });
      final response = await _dio.get(endpoint);
      logPayment('Verify response', {
        'statusCode': response.statusCode,
        'statusMessage': response.statusMessage,
        'body': sanitizePaymentPayload(response.data),
      });
      final body = responseMap(response.data);
      _throwForFailure(body);
      return OrderModel.fromJson(orderFromVerification(body));
    } on DioException catch (error, stackTrace) {
      logPayment('Verify error', {
        'statusCode': error.response?.statusCode,
        'message': error.message,
        'body': sanitizePaymentPayload(error.response?.data),
      });
      log('Payment verification failed', error: error, stackTrace: stackTrace);
      throw Exception(ordersDioMessage(error));
    }
  }

  void _throwForFailure(Map<String, dynamic> body) {
    final status = body['status']?.toString().toLowerCase().trim();
    if (const {'error', 'failed', 'failure'}.contains(status)) {
      throw Exception(
        body['message']?.toString() ?? 'Payment verification failed.',
      );
    }
  }
}
