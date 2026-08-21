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

      dynamic responseData;
      try {
        final response = await _dio.get(endpoint);
        responseData = response.data;
      } on DioException catch (dioErr) {
        if (dioErr.response?.statusCode == 404 ||
            dioErr.response?.statusCode == 405) {
          // Fallback to POST /api/payments/verify if legacy route is used
          final postResponse = await _dio.post(
            'api/payments/verify',
            data: {'orderId': orderId},
          );
          responseData = postResponse.data;
        } else {
          rethrow;
        }
      }

      final body = responseMap(responseData);
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

  Future<void> cancel(String orderId) async {
    final endpoint = Endpoints.cancelPayment(orderId);
    try {
      logPayment('Cancel payment request', {
        'method': 'POST',
        'endpoint': endpoint,
        'orderId': orderId,
      });
      await _dio.post(endpoint, data: {'orderId': orderId});
    } on DioException catch (error, stackTrace) {
      logPayment('Cancel payment error', {
        'statusCode': error.response?.statusCode,
        'message': error.message,
      });
      log('Cancel payment failed', error: error, stackTrace: stackTrace);
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
