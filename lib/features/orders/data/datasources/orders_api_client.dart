import 'dart:developer';

import 'package:dio/dio.dart';

import '../../../../core/api/dio_consumer.dart';
import '../../../../core/api/endpoints.dart';
import '../models/order_model.dart';
import 'orders_dio_error.dart';
import 'orders_response_parser.dart';

class OrdersApiClient {
  const OrdersApiClient(this._dio);

  final DioConsumer _dio;

  Future<List<OrderModel>> getMyOrders() async {
    try {
      final response = await _dio.get(Endpoints.myOrders);
      return ordersDataList(response.data)
          .whereType<Map>()
          .map((item) => OrderModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } on DioException catch (error, stackTrace) {
      log('Get my orders request failed', error: error, stackTrace: stackTrace);
      throw Exception(ordersDioMessage(error));
    }
  }
}
