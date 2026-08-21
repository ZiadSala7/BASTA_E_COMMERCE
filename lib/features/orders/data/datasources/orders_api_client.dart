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

  Future<OrderModel?> getOrderById(String orderId) async {
    try {
      final response = await _dio.get(Endpoints.orderDetails(orderId));
      final Map<String, dynamic> body = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : (response.data is Map
              ? Map<String, dynamic>.from(response.data as Map)
              : <String, dynamic>{});

      final orderData = body['data'] is Map<String, dynamic>
          ? body['data'] as Map<String, dynamic>
          : body;

      return OrderModel.fromJson(orderData);
    } on DioException catch (error, stackTrace) {
      log('Get order by id failed', error: error, stackTrace: stackTrace);
      throw Exception(ordersDioMessage(error));
    }
  }

  Future<String?> getOrderInvoiceUrl(String orderId) async {
    try {
      final response = await _dio.get(Endpoints.orderInvoice(orderId));
      final Map<String, dynamic> body = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : (response.data is Map
              ? Map<String, dynamic>.from(response.data as Map)
              : <String, dynamic>{});

      final data = body['data'] is Map<String, dynamic>
          ? body['data'] as Map<String, dynamic>
          : body;

      return (data['invoiceUrl'] ??
              data['invoice_url'] ??
              data['url'] ??
              data['pdfUrl'])
          ?.toString();
    } catch (_) {
      return null;
    }
  }
}
