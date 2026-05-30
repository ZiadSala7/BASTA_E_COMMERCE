import 'dart:developer';

import 'package:dio/dio.dart';

import '../../../../core/api/dio_consumer.dart';
import '../../../../core/api/endpoints.dart';
import '../models/order_model.dart';

abstract class OrdersRemoteDataSource {
  Future<List<OrderModel>> getMyOrders();
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
