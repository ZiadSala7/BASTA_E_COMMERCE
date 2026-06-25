import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/api/dio_consumer.dart';
import '../../../../core/api/endpoints.dart';
import '../models/checkout_result_model.dart';
import '../models/order_model.dart';

abstract class OrdersRemoteDataSource {
  Future<List<OrderModel>> getMyOrders();

  Future<CheckoutResultModel> checkout({
    required Map<String, dynamic> address,
    required String paymentMethod,
  });

  Future<OrderModel> verifyPayment(String orderId);
}

class OrdersRemoteDataSourceImpl implements OrdersRemoteDataSource {
  final DioConsumer _dioConsumer;

  const OrdersRemoteDataSourceImpl({required DioConsumer dioConsumer})
    : _dioConsumer = dioConsumer;

  @override
  Future<List<OrderModel>> getMyOrders() async {
    try {
      final response = await _dioConsumer.get(Endpoints.myOrders);
      final items = _dataList(response.data);

      return items
          .whereType<Map>()
          .map((item) => OrderModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } on DioException catch (error, stackTrace) {
      log('Get my orders request failed', error: error, stackTrace: stackTrace);
      throw Exception(_messageFromDio(error));
    }
  }

  @override
  Future<CheckoutResultModel> checkout({
    required Map<String, dynamic> address,
    required String paymentMethod,
  }) async {
    try {
      final streetAddress = address['streetAddress']?.toString() ?? '';
      final city = address['city']?.toString() ?? '';
      final state = address['state']?.toString() ?? '';
      final postalCode = address['postalCode']?.toString() ?? '';
      final country = address['country']?.toString() ?? '';
      final requestBody = {
        'address': address,
        'streetAddress': streetAddress,
        'city': city,
        'state': state,
        'postalCode': postalCode,
        'country': country,
        'paymentMethod': paymentMethod,
      };
      _debugLogPayment('Checkout request', {
        'method': 'POST',
        'endpoint': Endpoints.checkout,
        'body': requestBody,
      });
      final response = await _dioConsumer.post(
        Endpoints.checkout,
        data: requestBody,
      );

      _debugLogPayment('Checkout response', {
        'statusCode': response.statusCode,
        'statusMessage': response.statusMessage,
        'body': _sanitizePaymentPayload(response.data),
      });
      return CheckoutResultModel.fromJson(_asMap(response.data));
    } on DioException catch (error, stackTrace) {
      _debugLogPayment('Checkout error', {
        'statusCode': error.response?.statusCode,
        'message': error.message,
        'body': _sanitizePaymentPayload(error.response?.data),
      });
      log('Checkout request failed', error: error, stackTrace: stackTrace);
      throw Exception(_messageFromDio(error));
    }
  }

  @override
  Future<OrderModel> verifyPayment(String orderId) async {
    try {
      _debugLogPayment('Verify request', {
        'method': 'GET',
        'endpoint': Endpoints.verifyPayment(orderId),
        'orderId': orderId,
      });
      final response = await _dioConsumer.get(Endpoints.verifyPayment(orderId));
      _debugLogPayment('Verify response', {
        'statusCode': response.statusCode,
        'statusMessage': response.statusMessage,
        'body': _sanitizePaymentPayload(response.data),
      });
      final body = _asMap(response.data);
      final data = _asMap(body['data']);
      final orderJson = _asMap(body['order']).isNotEmpty
          ? _asMap(body['order'])
          : _asMap(data['order']).isNotEmpty
          ? _asMap(data['order'])
          : data.isNotEmpty
          ? data
          : body;

      return OrderModel.fromJson(orderJson);
    } on DioException catch (error, stackTrace) {
      _debugLogPayment('Verify error', {
        'statusCode': error.response?.statusCode,
        'message': error.message,
        'body': _sanitizePaymentPayload(error.response?.data),
      });
      log('Payment verification failed', error: error, stackTrace: stackTrace);
      throw Exception(_messageFromDio(error));
    }
  }

  List<dynamic> _dataList(dynamic data) {
    if (data is List) return data;

    if (data is Map<String, dynamic>) {
      final directData = data['data'];
      if (directData is List) return directData;

      if (directData is Map<String, dynamic>) {
        final nestedOrders = directData['orders'];
        if (nestedOrders is List) return nestedOrders;
      }

      final orders = data['orders'];
      if (orders is List) return orders;
    }

    if (data is Map) {
      final directData = data['data'];
      if (directData is List) return directData;

      if (directData is Map) {
        final nestedOrders = directData['orders'];
        if (nestedOrders is List) return nestedOrders;
      }

      final orders = data['orders'];
      if (orders is List) return orders;
    }

    return const [];
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, item) => MapEntry(key.toString(), item));
    }

    return <String, dynamic>{};
  }

  void _debugLogPayment(String message, Map<String, Object?> data) {
    if (!kDebugMode) return;
    debugPrint('[Payment] $message');
    debugPrint('[Payment] $data');
  }

  Object? _sanitizePaymentPayload(Object? value) {
    if (value is Map<String, dynamic>) {
      return value.map((key, item) {
        if (_isSensitivePaymentKey(key)) {
          return MapEntry(key, _valuePreview(item?.toString()));
        }
        return MapEntry(key, _sanitizePaymentPayload(item));
      });
    }

    if (value is Map) {
      return value.map((key, item) {
        final safeKey = key.toString();
        if (_isSensitivePaymentKey(safeKey)) {
          return MapEntry(safeKey, _valuePreview(item?.toString()));
        }
        return MapEntry(safeKey, _sanitizePaymentPayload(item));
      });
    }

    if (value is List) {
      return value.map(_sanitizePaymentPayload).toList(growable: false);
    }

    return value;
  }

  bool _isSensitivePaymentKey(String key) {
    final normalized = key.toLowerCase();
    return normalized.contains('token') ||
        normalized.contains('sessionid') ||
        normalized.contains('successindicator') ||
        normalized == 'authorization';
  }

  String _valuePreview(String? value) {
    if (value == null || value.isEmpty) return '<empty>';
    final start = value.length <= 12 ? value : value.substring(0, 12);
    final end = value.length <= 8 ? '' : value.substring(value.length - 8);
    return '$start...$end (${value.length} chars)';
  }

  String _messageFromDio(DioException error) {
    final map = _asMap(error.response?.data);
    final message = map['message']?.toString();
    if (message != null && message.isNotEmpty) return message;

    final apiError = map['error']?.toString();
    if (apiError != null && apiError.isNotEmpty) return apiError;

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return 'The server took too long to respond. Please try again.';
    }

    if (error.type == DioExceptionType.connectionError) {
      return 'Unable to reach the server. Check your internet connection.';
    }

    return error.message ?? 'Orders request failed.';
  }
}
