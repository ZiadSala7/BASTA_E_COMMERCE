import 'dart:developer';

import 'package:dio/dio.dart';

import '../../../../core/api/api_keys.dart';
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

      final rawData = body['data'];
      if (rawData is String && rawData.trim().isNotEmpty) return rawData;
      final data = rawData is Map ? Map<String, dynamic>.from(rawData) : body;

      return (data['invoiceUrl'] ??
              data['invoice_url'] ??
              data['url'] ??
              data['pdfUrl'])
          ?.toString();
    } on DioException catch (error, stackTrace) {
      log(
        'Get order invoice link failed',
        error: error,
        stackTrace: stackTrace,
      );
      throw Exception(ordersDioMessage(error));
    } catch (_) {
      return null;
    }
  }

  Future<List<int>?> downloadOrderInvoice(String orderId) async {
    final invoiceUrl = await getOrderInvoiceUrl(orderId);
    if (invoiceUrl == null || invoiceUrl.trim().isEmpty) return null;

    final parsedUrl = Uri.tryParse(invoiceUrl.trim());
    if (parsedUrl == null) throw const FormatException('Invalid invoice URL.');
    final invoiceUri = parsedUrl.hasScheme
        ? parsedUrl
        : Uri.parse(ApiKeys.baseUrl).resolve(invoiceUrl.trim());
    if (invoiceUri.scheme != 'https' && invoiceUri.scheme != 'http') {
      throw const FormatException('Unsupported invoice URL scheme.');
    }

    final apiUri = Uri.parse(ApiKeys.baseUrl);
    final client = invoiceUri.origin == apiUri.origin ? _dio.dio : Dio();
    final response = await client.get<List<int>>(
      invoiceUri.toString(),
      options: Options(responseType: ResponseType.bytes),
    );
    final bytes = response.data;
    if (bytes == null || bytes.isEmpty) return null;
    if (bytes.length < 5 || String.fromCharCodes(bytes.take(5)) != '%PDF-') {
      throw const FormatException('The invoice response is not a PDF.');
    }
    return bytes;
  }
}
