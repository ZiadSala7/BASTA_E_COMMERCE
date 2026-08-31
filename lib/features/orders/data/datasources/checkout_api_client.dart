import 'dart:developer';

import 'package:dio/dio.dart';

import '../../../../core/api/dio_consumer.dart';
import '../../../../core/api/endpoints.dart';
import '../models/checkout_result_model.dart';
import 'orders_dio_error.dart';
import 'orders_response_parser.dart';
import 'payment_log.dart';

class CheckoutApiClient {
  const CheckoutApiClient(this._dio);

  final DioConsumer _dio;

  Future<CheckoutResultModel> checkout({
    required Map<String, dynamic> address,
    required String paymentMethod,
    String? couponCode,
  }) async {
    final body = _requestBody(address, paymentMethod, couponCode);
    try {
      logPayment('Checkout request', {
        'method': 'POST',
        'endpoint': Endpoints.checkout,
        'body': body,
      });
      final response = await _dio.post(Endpoints.checkout, data: body);
      logPayment('Checkout response', {
        'statusCode': response.statusCode,
        'statusMessage': response.statusMessage,
        'body': sanitizePaymentPayload(response.data),
      });
      return CheckoutResultModel.fromJson(responseMap(response.data));
    } on DioException catch (error, stackTrace) {
      logPayment('Checkout error', {
        'statusCode': error.response?.statusCode,
        'message': error.message,
        'body': sanitizePaymentPayload(error.response?.data),
      });
      log('Checkout request failed', error: error, stackTrace: stackTrace);
      throw checkoutExceptionFromDio(error);
    }
  }

  Map<String, dynamic> _requestBody(
    Map<String, dynamic> address,
    String paymentMethod,
    String? couponCode,
  ) {
    final normalizedCoupon = couponCode?.trim();
    final phone = (address['phone'] ?? address['phoneNumber'] ?? '').toString().trim();
    final addressWithPhone = {
      ...address,
      if (phone.isNotEmpty) 'phone': phone,
    };

    return {
      'addressData': addressWithPhone,
      for (final key in const [
        'streetAddress',
        'city',
        'state',
        'postalCode',
        'country',
      ])
        key: address[key]?.toString() ?? '',
      'paymentMethod': paymentMethod,
      if (phone.isNotEmpty) 'phone': phone,
      if (normalizedCoupon != null && normalizedCoupon.isNotEmpty)
        'couponCode': normalizedCoupon,
    };
  }
}
